// SPDX-License-Identifier: GPL-3.0-only
#include "msxgl.h"
#include "ui/title.h"

void main(void)
{
	Title_Show();

	while (!Keyboard_IsKeyPressed(KEY_ESC))
		Halt();

	VDP_SetDefaultPalette();
	BIOS_Exit(0);
}
