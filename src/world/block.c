// SPDX-License-Identifier: GPL-3.0-only
#include "msxgl.h"
#include "dos.h"
#include "compress/zx0.h"
#include "audio/intro_music.h"
#include "world/block.h"

typedef struct { u8 x, y, w, h, target, spawnX, spawnY; } Portal;
typedef struct { u8 x, y, color; const c8* text; } Label;
typedef struct
{
	const c8* name;
	u16 offset;
	u16 size[2], crc[2];
	const u8* walk;
	const Portal* portals;
	u8 portalCount;
	const Label* labels;
	u8 labelCount;
} Room;

#include "block_data.h"

u8 g_BlockRoom, g_BlockX, g_BlockY;
static u8 g_Direction, g_Animation;
static bool g_Continuation;

static void Text(u8 x, u8 y, u8 color, const c8* text)
{
	Print_SetColor(color, 0);
	Print_SetPosition(x, y);
	Print_DrawText(text);
}

static u16 Checksum(u16 size)
{
	const u8* data = (const u8*)0x8000;
	u16 crc = 0xFFFF;
	u8 bit;
	while (size--)
	{
		crc ^= *data++;
		for (bit = 0; bit < 8; ++bit)
			crc = (crc >> 1) ^ ((crc & 1) ? 0xA001 : 0);
	}
	return crc;
}

static bool LoadRoom(void)
{
	const Room* room = &g_Rooms[g_BlockRoom];
	u8 handle, error, part;
	VDP_CommandWait();
	VDP_EnableDisplay(FALSE);
	VDP_HideAllSprites();
	handle = DOS_OpenHandle("WORLD.PAK", O_RDONLY);
	error = DOS_GetLastError();
	if (!error)
	{
		DOS_SeekHandle(handle, room->offset, SEEK_SET);
		error = DOS_GetLastError();
		for (part = 0; part < 2 && !error; ++part)
		{
			u16 count = DOS_ReadHandle(handle, (void*)0x8000, room->size[part]);
			error = DOS_GetLastError();
			if (!error && (count != room->size[part] || Checksum(count) != room->crc[part]))
				error = 1;
			if (!error)
			{
				// Intro cache is released. Page 2 now holds only bounded scratch data.
				ZX0_UnpackToRAM((const void*)0x8000, (void*)0x9000);
				VDP_WriteVRAM((const u8*)0x9000, part * 12288, 0, 12288);
			}
		}
		{
			u8 closeError = DOS_CloseHandle(handle);
			if (!error)
				error = closeError;
		}
	}
	if (error)
	{
		Draw_FillBox(0, 0, 255, 211, 0, VDP_OP_IMP);
		Text(6, 80, 10, "ERRO WORLD.PAK / DOS OU CRC: ");
		Print_DrawHex8(error);
		Text(6, 100, 7, "CONFIRA OS ARQUIVOS DA MESMA VERSAO");
		Text(6, 120, 14, "ESC: VOLTAR AO DOS");
		VDP_CommandWait();
		VDP_EnableDisplay(TRUE);
		while (!Keyboard_IsKeyPressed(KEY_ESC)) Halt();
		return FALSE;
	}
	for (part = 0; part < room->labelCount; ++part)
	{
		const Label* label = &room->labels[part];
		Text(label->x, label->y, label->color, label->text);
	}
	Draw_FillBox(0, 192, 255, 211, 0, VDP_OP_IMP);
	Text(3, 193, 11, room->name);
	Text(3, 203, 13, "SETAS: ANDAR  ESC: TITULO");
	g_Continuation = FALSE;
	VDP_CommandWait();
	VDP_EnableDisplay(TRUE);
	return TRUE;
}

static bool Walkable(u8 x, u8 y)
{
	u16 cell = (u16)(y >> 3) * 32 + (x >> 3);
	return (g_Rooms[g_BlockRoom].walk[cell >> 3] & (1 << (cell & 7))) != 0;
}

static void Move(i8 dx, i8 dy)
{
	i16 x = (i16)g_BlockX + dx, y = (i16)g_BlockY + dy;
	if (x < 4 || x > 251 || y < 4 || y > 191)
		return;
	if (Walkable(x - 3, y) && Walkable(x + 3, y) &&
		Walkable(x - 3, y - 3) && Walkable(x + 3, y - 3))
	{
		g_BlockX = x;
		g_BlockY = y;
		g_Animation = (g_Animation + (dx ? (dx < 0 ? -dx : dx) : (dy < 0 ? -dy : dy))) % 24;
	}
}

static void Player(void)
{
	u8 phase = g_Animation / 6;
	u8 frame = g_Direction * 3 + (phase == 1 ? 1 : (phase == 3 ? 2 : 0));
	u8 index;
	for (index = 0; index < 8; ++index)
	{
		VDP_SetSpritePattern(index, g_PlayerFrames[frame * 8 + index]);
		VDP_SetSpritePosition(index, g_BlockX - 8, g_BlockY - 32 + (index / 4) * 16);
	}
}

u8 Block_Run(void)
{
	u8 status = 0;
	u16 pace = 0;
	g_BlockRoom = 1;
	g_BlockX = 128;
	g_BlockY = 88;
	g_Direction = 0;
	g_Animation = 0;
	VDP_SetPalette((const u8*)g_WorldPalette + 2);
	VDP_SetSpriteTables(0x7800, 0x7600);
	VDP_SetSpriteFlag(VDP_SPRITE_SIZE_16);
	ZX0_UnpackToRAM(g_PlayerPatterns, (void*)0x9000);
	VDP_WriteVRAM((const u8*)0x9000, 0x7800, 0, PLAYER_PATTERN_BYTES);
	{
		u8 index;
		for (index = 0; index < 8; ++index)
			VDP_SetSpriteMultiColor(index, g_PlayerColors + index * 16);
	}
	VDP_EnableSprite(TRUE);
	// Music remains exclusive to the narrative intro during this map prototype.
	if (!LoadRoom()) status = 1;
	while (!status && !Keyboard_IsKeyPressed(KEY_ESC))
	{
		const Room* room = &g_Rooms[g_BlockRoom];
		u8 index;
		u8 distance;
		u8 oldX = g_BlockX, oldY = g_BlockY;
		bool continuation = FALSE;
		u8 hz = VDP_GetFrequency() == VDP_FREQ_50HZ ? 50 : 60;
		Halt();
		// 100 pixels/second at either video rate, no faster diagonal movement.
		pace += 100;
		distance = pace / hz;
		pace %= hz;
		if (Keyboard_IsKeyPressed(KEY_LEFT)) { g_Direction = 2; Move(-distance, 0); }
		else if (Keyboard_IsKeyPressed(KEY_RIGHT)) { g_Direction = 3; Move(distance, 0); }
		else if (Keyboard_IsKeyPressed(KEY_UP)) { g_Direction = 1; Move(0, -distance); }
		else if (Keyboard_IsKeyPressed(KEY_DOWN)) { g_Direction = 0; Move(0, distance); }
		if (oldX == g_BlockX && oldY == g_BlockY) g_Animation = 0;
		for (index = 0; index < room->portalCount; ++index)
		{
			const Portal* p = &room->portals[index];
			if (g_BlockX >= p->x && (u16)g_BlockX < (u16)p->x + p->w &&
				g_BlockY >= p->y && (u16)g_BlockY < (u16)p->y + p->h)
			{
				if (p->target == 255)
					continuation = TRUE;
				else
				{
					g_BlockRoom = p->target;
					g_BlockX = p->spawnX;
					g_BlockY = p->spawnY;
					if (!LoadRoom()) status = 1;
				}
				break;
			}
		}
		if (continuation != g_Continuation)
		{
			Draw_FillBox(0, 202, 255, 211, 0, VDP_OP_IMP);
			Text(3, 203, continuation ? 10 : 13, continuation ?
				"CONTINUACAO FORA DESTA DEMO" : "SETAS: ANDAR  ESC: TITULO");
			g_Continuation = continuation;
		}
		Player();
	}
	VDP_DisableSprite();
	VDP_HideAllSprites();
	while (Keyboard_IsKeyPressed(KEY_ESC)) Halt();
	DisableInterrupt();
	g_GETPNT = g_PUTPNT;
	EnableInterrupt();
	return status;
}
