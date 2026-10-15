// SPDX-License-Identifier: GPL-3.0-only
#include "msxgl.h"
#include "dos.h"
#include "dos_mapper.h"
#include "compress/zx0.h"
#include "ui/title.h"
#include "version.h"
#include "font/font_mgl_sample6.h"
#include "audio/intro_music.h"

typedef struct
{
	const c8* file;
	const c8* heading;
	const c8* line1;
	const c8* line2;
} IntroScene;

#include "intro_data.h"

#define ART_BYTES 20480
#define ACTION_NEXT 0
#define ACTION_SKIP 1
#define ACTION_EXIT 2

static u8 g_ImageBuffer[INTRO_BUFFER_BYTES];
static u8 g_Segments[14];
static u8 g_SegmentCount;
static u8 g_OriginalPage2;
static u8 g_MapperSlot;
static u8 g_Audio;

// ALL_SEG without stack arguments: allocation failure must unwind cleanly.
static u8 AllocateSegment(void) __NAKED
{
	__asm
		push ix
		xor a
		ld b, a
		ld hl, (_g_DOS_JumpTable)
		call ___sdcc_call_hl
		pop ix
		ret nc
		ld a, #0xFF
		ret
	__endasm;
}

static void Text(u8 x, u8 y, u8 color, const c8* message)
{
	Print_SetColor(color, 0);
	Print_SetPosition(x, y);
	Print_DrawText(message);
}

static bool ActionPressed(void)
{
	return Keyboard_IsKeyPressed(KEY_SPACE) ||
		Keyboard_IsKeyPressed(KEY_ENTER) ||
		Keyboard_IsKeyPressed(KEY_S) ||
		Keyboard_IsKeyPressed(KEY_ESC);
}

static u8 WaitAction(void)
{
	VDP_CommandWait();
	while (ActionPressed())
		Halt();
	while (TRUE)
	{
		Halt();
		if (Keyboard_IsKeyPressed(KEY_ESC))
			return ACTION_EXIT;
		if (Keyboard_IsKeyPressed(KEY_S))
			return ACTION_SKIP;
		if (Keyboard_IsKeyPressed(KEY_SPACE) || Keyboard_IsKeyPressed(KEY_ENTER))
			return ACTION_NEXT;
	}
}

static u8 Finish(u8 status)
{
	IntroMusic_Stop();
	while (g_SegmentCount)
	{
		--g_SegmentCount;
		if (!DOSMapper_Free(g_Segments[g_SegmentCount], g_MapperSlot))
		{
			Text(6, 188, 10, "ERRO AO LIBERAR RAM MAPPER");
			VDP_CommandWait();
			VDP_EnableDisplay(TRUE);
			WaitAction();
			status = 1;
		}
	}
	while (ActionPressed())
		Halt();
	// Raw-key controls also enter the BIOS buffer; do not leak them to DOS.
	DisableInterrupt();
	g_GETPNT = g_PUTPNT;
	EnableInterrupt();
	return status;
}

static bool ImageError(const c8* file, const c8* reason, u8 error)
{
	VDP_CommandWait();
	Draw_FillBox(0, 160, 255, 211, 0, VDP_OP_IMP);
	Text(6, 164, 10, "ERRO AO CARREGAR IMAGEM");
	Text(6, 175, 7, file);
	Text(6, 186, 7, reason);
	Print_DrawHex8(error);
	Text(6, 201, 14, "SPACE/ENTER OU ESC: VOLTAR AO DOS");
	VDP_CommandWait();
	VDP_EnableDisplay(TRUE);
	WaitAction();
	return FALSE;
}

static u16 Checksum(u16 size)
{
	u16 crc = 0xFFFF;
	u16 offset;
	u8 bit;
	for (offset = 0; offset < size; ++offset)
	{
		crc ^= g_ImageBuffer[offset];
		for (bit = 0; bit < 8; ++bit)
			crc = (crc >> 1) ^ ((crc & 1) ? 0xA001 : 0);
	}
	return crc;
}

static bool PreloadImages(void)
{
	u8 handle;
	u8 error;
	u8 index;
	u16 count;
	if (!DOSMapper_Init())
		return ImageError("RAM MAPPER", "DOS2 MAPPER INDISPONIVEL: ", 0);
	Text(6, 12, 10, "BLOODSTRAIN " BLOODSTRAIN_VERSION);
	Text(6, 32, 7, "SISTEMA: ");
	switch (Sys_GetMSXVersion())
	{
	case 0: Print_DrawText("MSX"); break;
	case 1: Print_DrawText("MSX2"); break;
	case 2: Print_DrawText("MSX2+"); break;
	case 3: Print_DrawText("MSX turbo R"); break;
	default: Print_DrawText("MSX (VERSAO DESCONHECIDA)"); break;
	}
	Text(6, 49, 7, "MAPPER PRIMARIO: ");
	Print_DrawInt((DOSMapper_GetVarTable()->NumSeg ?
		(u16)DOSMapper_GetVarTable()->NumSeg : 256) * 16);
	Print_DrawText(" KiB");
	Text(6, 66, 7, "RAM LIVRE NO DOS: ");
	Print_DrawInt((u16)DOSMapper_GetVarTable()->FreeSeg * 16);
	Print_DrawText(" KiB");
	Text(6, 83, 14, "CACHE DA INTRO: 224 KiB");
	for (index = 0; index < 3; ++index)
	{
		u8 x = 6 + index * 80;
		Draw_Box(x, 104, x + 9, 113, 14, VDP_OP_IMP);
		if (g_Audio & (1 << index))
		{
			Draw_Line(x + 2, 108, x + 4, 111, 9, VDP_OP_IMP);
			Draw_Line(x + 4, 111, x + 8, 105, 9, VDP_OP_IMP);
		}
		Text(x + 14, 105, 7, index == 0 ? "PSG" : (index == 1 ? "FM" : "SCC"));
	}
	Text(6, 132, 7, "CARREGANDO IMAGENS E TRILHA...");
	Text(6, 169, 14, "MADRUGADA DE FERRUGEM");
	Text(6, 185, 7, "TRILHA ORIGINAL - 136 BPM");
	VDP_CommandWait();
	VDP_EnableDisplay(TRUE);
	g_MapperSlot = DOSMapper_GetVarTable()->Slot;
	if (DOSMapper_GetVarTable()->FreeSeg < 14)
		return ImageError("RAM MAPPER", "PRECISA DE 224 KiB LIVRES: ", 0);
	g_OriginalPage2 = DOSMapper_GetPage2();
	for (index = 0; index < 14; ++index)
	{
		u8 segment = AllocateSegment();
		if (segment == 0xFF)
			return ImageError("RAM MAPPER", "FALHA AO RESERVAR RAM: ", index);
		g_Segments[g_SegmentCount++] = segment;
	}
	handle = DOS_OpenHandle("INTRO.PAK", O_RDONLY);
	error = DOS_GetLastError();
	if (error)
		return ImageError("INTRO.PAK", "ERRO DOS: ", error);
	for (index = 0; index < 14; ++index)
	{
		count = DOS_ReadHandle(handle, g_ImageBuffer, g_IntroSizes[index]);
		error = DOS_GetLastError();
		if (error || count != g_IntroSizes[index])
		{
			DOS_CloseHandle(handle);
			return ImageError("INTRO.PAK", "LEITURA INCOMPLETA / DOS: ", error);
		}
		if (Checksum(count) != g_IntroChecksums[index])
		{
			DOS_CloseHandle(handle);
			return ImageError("INTRO.PAK", "BLOCO CORROMPIDO: ", index);
		}
		// Page 2 is a temporary window; restore it before every DOS call.
		DOSMapper_SetPage2(g_Segments[index]);
		ZX0_UnpackToRAM(g_ImageBuffer, (void*)0x8000);
		DOSMapper_SetPage2(g_OriginalPage2);
		Draw_FillBox(6, 145, 6 + (index + 1) * 17, 149, 9, VDP_OP_IMP);
		VDP_CommandWait();
	}
	count = DOS_ReadHandle(handle, g_ImageBuffer, 1);
	error = DOS_GetLastError();
	// DOS2 reports EOF on this final probe; any data or other error is invalid.
	if ((!error && count) || (error && error != DOS_ERR_EOF))
	{
		DOS_CloseHandle(handle);
		return ImageError("INTRO.PAK", "TAMANHO INVALIDO / DOS: ", error);
	}
	error = DOS_CloseHandle(handle);
	if (error)
		return ImageError("INTRO.PAK", "ERRO AO FECHAR / DOS: ", error);
	return TRUE;
}

static void ShowImage(u8 index)
{
	VDP_CommandWait();
	VDP_EnableDisplay(FALSE);
	DOSMapper_SetPage2(g_Segments[index * 2]);
	VDP_WriteVRAM((const u8*)0x8000, 0, 0, 16384);
	DOSMapper_SetPage2(g_Segments[index * 2 + 1]);
	VDP_WriteVRAM((const u8*)0x8000, 16384, 0, ART_BYTES - 16384);
	DOSMapper_SetPage2(g_OriginalPage2);
	Draw_FillBox(0, 160, 255, 211, 0, VDP_OP_IMP);
	VDP_CommandWait();
}

static void ShowCard(u8 index)
{
	u8 line;
	VDP_CommandWait();
	VDP_EnableDisplay(FALSE);
	Draw_FillBox(0, 0, 255, 211, 0, VDP_OP_IMP);
	Draw_FillBox(0, 0, 1, 0, index + 8, VDP_OP_IMP);
	Draw_Box(4, 35, 251, 177, 3, VDP_OP_IMP);
	Text(8, 45, 10, g_IntroScenes[index].heading);
	for (line = 0; line < 4; ++line)
		Text(8, 78 + line * 20, 7, g_IntroCards[index][line]);
	Text(6, 201, 14, "SPACE/ENTER: SEGUE  S: PULA  ESC: DOS");
	VDP_CommandWait();
	VDP_EnableDisplay(TRUE);
}

static void TitleCaption(const c8* prompt)
{
	Text(6, 164, 10, "BLOODSTRAIN " BLOODSTRAIN_VERSION);
	Text(6, 176, 7, "Um bairro. Muitos caminhos.");
	Text(6, 188, 14, prompt);
	Text(6, 201, 14, "ESC: DOS  -  CAMPANHA EM CONSTRUCAO");
	VDP_CommandWait();
	VDP_EnableDisplay(TRUE);
}

u8 Title_Show(void)
{
	u8 index;
	u8 action;
	g_SegmentCount = 0;
	VDP_SetMode(VDP_MODE_SCREEN5);
	VDP_EnableDisplay(FALSE);
	VDP_SetLineCount(VDP_LINE_212);
	VDP_SetColor(0);
	VDP_SetPalette(g_IntroPalette + 2);
	VDP_EnableVBlank(TRUE);
	VDP_ClearVRAM();
	Print_SetBitmapFont(g_Font_MGL_Sample6);
	g_Audio = IntroMusic_Initialize();

	if (!PreloadImages())
		return Finish(1);
	IntroMusic_Start();
	ShowImage(6);
	TitleCaption("SPACE/ENTER: INTRO  S: TITULO");
	action = WaitAction();
	while (action != ACTION_EXIT)
	{
		if (action == ACTION_NEXT)
		{
			for (index = 0; index < INTRO_SCENE_COUNT; ++index)
			{
				const IntroScene* scene = &g_IntroScenes[index];
				ShowImage(index);
				Text(6, 164, 10, scene->heading);
				Text(6, 176, 7, scene->line1);
				Text(6, 186, 7, scene->line2);
				Text(6, 201, 14, "SPACE/ENTER: SEGUE  S: PULA  ESC: DOS");
				VDP_CommandWait();
				VDP_EnableDisplay(TRUE);
				action = WaitAction();
				if (action != ACTION_NEXT)
					break;
				ShowCard(index);
				action = WaitAction();
				if (action != ACTION_NEXT)
					break;
			}
			if (action == ACTION_EXIT)
				break;
		}
		ShowImage(6);
		TitleCaption("SPACE/ENTER: REVER INTRO");
		action = WaitAction();
	}
	return Finish(0);
}
