// SPDX-License-Identifier: GPL-3.0-only
#include "msxgl.h"
#include "ui/title.h"
#include "version.h"
#include "font/font_mgl_sample6.h"

void Title_Show(void)
{
	VDP_SetMode(VDP_MODE_SCREEN5);
	VDP_EnableDisplay(FALSE);
	VDP_SetColor(COLOR_BLACK);
	VDP_SetDefaultPalette();
	VDP_EnableVBlank(TRUE);
	VDP_ClearVRAM();

	Draw_FillBox(0, 0, 255, 39, COLOR_DARK_RED, VDP_OP_IMP);
	Draw_FillBox(0, 152, 255, 191, COLOR_DARK_BLUE, VDP_OP_IMP);
	Draw_Box(12, 48, 243, 143, COLOR_GRAY, VDP_OP_IMP);
	VDP_CommandWait();

	Print_SetBitmapFont(g_Font_MGL_Sample6);
	Print_SetColor(COLOR_WHITE, COLOR_BLACK);
	Print_SetPosition(95, 72);
	Print_DrawText("BLOODSTRAIN");
	Print_SetPosition(86, 94);
	Print_DrawText("Versao " BLOODSTRAIN_VERSION);
	Print_SetPosition(59, 118);
	Print_DrawText("Um bairro. Muitos caminhos.");
	Print_SetColor(COLOR_WHITE, COLOR_DARK_BLUE);
	Print_SetPosition(41, 167);
	Print_DrawText("ESC: voltar ao MSX-DOS");

	VDP_CommandWait();
	VDP_EnableDisplay(TRUE);
}
