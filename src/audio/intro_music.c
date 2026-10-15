// SPDX-License-Identifier: GPL-3.0-only
#include "audio/intro_music.h"
#include "bios_hook.h"
#include "psg.h"
#include "msx-music.h"
#include "scc.h"

// "Madrugada de Ferrugem": 32 bars, E phrygian/minor, 136 BPM, eighth notes.
static const u16 g_Periods[12] = {
	1710, 1614, 1524, 1438, 1357, 1281, 1209, 1141, 1077, 1017, 960, 906
};
static const u16 g_FNumbers[12] = {
	172, 182, 193, 205, 217, 230, 244, 258, 274, 290, 307, 325
};
static const u8 g_Roots[32] = {
	4,4,5,4, 4,4,2,5, 4,0,2,5, 4,0,7,5,
	4,4,10,5, 4,2,0,5, 4,0,2,5, 7,5,2,4
};
static const u8 g_Riff[4][8] = {
	{0,0,12,0,7,0,12,1},
	{0,12,0,0,7,6,3,1},
	{0,0,7,12,0,0,6,7},
	{0,7,12,7,3,1,0,0}
};
static const u8 g_Lead[4][16] = {
	{28,28,35,35,29,29,28,26, 28,28,31,35,34,31,29,26},
	{28,35,40,38,35,34,31,29, 28,31,35,38,41,40,35,29},
	{40,40,41,38,35,35,34,31, 40,38,35,34,31,29,28,26},
	{35,38,40,43,41,38,35,34, 31,29,28,26,29,26,28,28}
};
static const u8 g_Grit[32] = {
	112,112,112,112,112,112,96,72, 48,24,12,8,4,4,4,4,
	144,144,144,144,144,144,160,184, 208,232,244,248,252,252,252,252
};
// High feedback and rectified operators give the YM2413 a biting guitar tone.
static const u8 g_Distortion[8] = {
	0x21, 0x21, 0x18, 0x1F, 0xF3, 0xF2, 0x45, 0x17
};
static const u8 g_Shadow[32] = {
	0,24,48,70,90,106,118,125,127,125,118,106,90,70,48,24,
	0,232,208,186,166,150,138,131,129,131,138,150,166,186,208,232
};

static u8 g_Audio;
static u8 g_Hook[5];
static bool g_Playing;
static u16 g_Phase;
static u16 g_Threshold;
static u8 g_Step;
static u8 g_Age;
static u8 g_Bass;
static u8 g_Melody;
static u8 g_Fill;

// Unlike BIOS_InterSlotWrite, this ISR-only wrapper must not execute EI.
static void SCCWrite(u8 reg, u8 value) __NAKED
{
	reg; value;
	__asm
		ld e, l
		ld l, a
		ld h, #0x98
		ld a, (_g_SCC_SlotId)
		call #0x0014
		ret
	__endasm;
}

static u16 Period(u8 note)
{
	return g_Periods[note % 12] >> (note / 12);
}

static void FMNote(u8 channel, u8 note, u8 instrument, u8 volume)
{
	u16 frequency = g_FNumbers[note % 12];
	u8 control = ((note / 12 + 2) << 1) | (frequency >> 8);
	MSXMusic_SetRegister(0x20 + channel, control);
	MSXMusic_SetRegister(0x30 + channel, (instrument << 4) | volume);
	MSXMusic_SetRegister(0x10 + channel, (u8)frequency);
	MSXMusic_SetRegister(0x20 + channel, control | 0x10);
}

static void SCCNote(u8 channel, u8 note, u8 volume)
{
	u16 frequency = (Period(note) >> 1) - 1;
	SCCWrite(0x80 + channel * 2, (u8)frequency);
	SCCWrite(0x81 + channel * 2, frequency >> 8);
	SCCWrite(0x8A + channel, volume);
}

static void NextStep(void)
{
	u8 bar = g_Step >> 3;
	u8 beat = g_Step & 7;
	u8 root = g_Roots[bar];
	g_Age = 0;
	g_Bass = root + g_Riff[(bar >> 1) & 3][beat];
	g_Melody = g_Lead[bar >> 3][g_Step & 15];
	g_Fill = (bar & 3) == 3 && beat >= 6;
	PSG_SetTone(0, Period(g_Bass));
	PSG_SetTone(1, Period(g_Melody));
	if (g_Audio & INTRO_AUDIO_FM)
	{
		FMNote(0, g_Bass, 0, 2);
		FMNote(1, g_Bass + 7, 0, 5);
		FMNote(2, root + 12, 3, 9);
		FMNote(3, root + 19, 3, 10);
		FMNote(4, g_Melody, 1, 6);
	}
	if (g_Audio & INTRO_AUDIO_SCC)
	{
		SCCNote(0, g_Bass, 7);
		SCCNote(1, g_Bass + 7, 5);
		SCCNote(2, g_Melody + 12, 3);
		SCCWrite(SCC_REG_MIXER, 7);
	}
	++g_Step;
}

static void MusicTick(void)
{
	if (g_Playing)
	{
		u8 beat = (g_Step - 1) & 7;
		u8 drumAge;
		bool kick;
		g_Phase += 272;
		if (g_Phase >= g_Threshold)
		{
			g_Phase -= g_Threshold;
			NextStep();
			beat = (g_Step - 1) & 7;
		}
		PSG_SetVolume(0, g_Age < 3 ? 15 : (g_Age < 6 ? 11 : 5));
		PSG_SetVolume(1, g_Age < 7 ? 9 : 6);
		kick = (beat & 3) == 0;
		drumAge = g_Age;
		// A second short kick creates a double-bass gallop under the riff.
		if (kick && g_Age >= 5)
			drumAge -= 5;
		PSG_SetMixer(PSG_TONE_A_ON | PSG_TONE_B_ON |
			(kick && !g_Fill ? PSG_TONE_C_ON : PSG_NOISE_C_ON));
		PSG_SetTone(2, 700 + drumAge * 240);
		PSG_SetNoise((beat & 3) == 2 || g_Fill ? 16 : 2);
		PSG_SetVolume(2, drumAge < 2 ? 15 : (drumAge < 5 ? 10 : 0));
		if (g_Audio & INTRO_AUDIO_FM)
		{
			MSXMusic_SetRegister(0x30, g_Age < 3 ? 2 : (g_Age < 6 ? 5 : 12));
			MSXMusic_SetRegister(0x31, g_Age < 3 ? 5 : (g_Age < 6 ? 8 : 14));
		}
		if (g_Audio & INTRO_AUDIO_SCC)
		{
			SCCWrite(SCC_REG_VOL_1, g_Age < 3 ? 7 : (g_Age < 6 ? 4 : 1));
			SCCWrite(SCC_REG_VOL_2, g_Age < 3 ? 5 : (g_Age < 6 ? 3 : 1));
		}
		PSG_Apply();
		++g_Age;
	}
	Call((u16)g_Hook);
}

u8 IntroMusic_Initialize(void)
{
	u8 channel;
	g_Audio = INTRO_AUDIO_PSG; // Every conforming MSX has an internal PSG.
	g_Playing = FALSE;
	if (MSXMusic_Initialize() != MSXMUSIC_NOTFOUND)
	{
		g_Audio |= INTRO_AUDIO_FM;
		MSXMusic_SetRegister(0x0E, 0);
		MSXMusic_Mute();
		for (channel = 0; channel < 8; ++channel)
			MSXMusic_SetRegister(channel, g_Distortion[channel]);
	}
	if (SCC_Initialize())
	{
		g_Audio |= INTRO_AUDIO_SCC;
		SCC_Mute();
		for (channel = 0; channel < 4; ++channel)
			SCC_LoadWaveform(channel, channel < 2 ? g_Grit : g_Shadow);
	}
	PSG_Mute();
	PSG_Apply();
	g_Threshold = VDP_GetFrequency() == VDP_FREQ_50HZ ? 3000 : 3600;
	return g_Audio;
}

void IntroMusic_Start(void)
{
	g_Phase = 0;
	g_Step = 0;
	DisableInterrupt();
	NextStep();
	BIOS_BackupHook(H_TIMI, g_Hook);
	BIOS_SetHookCallback(H_TIMI, MusicTick);
	g_Playing = TRUE;
	EnableInterrupt();
}

void IntroMusic_Stop(void)
{
	if (!g_Playing)
		return;
	DisableInterrupt();
	g_Playing = FALSE;
	Mem_Copy(g_Hook, (void*)H_TIMI, 5);
	PSG_Mute();
	PSG_Apply();
	if (g_Audio & INTRO_AUDIO_FM)
		MSXMusic_Mute();
	if (g_Audio & INTRO_AUDIO_SCC)
		SCCWrite(SCC_REG_MIXER, 0);
	EnableInterrupt();
}
