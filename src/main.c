// SPDX-License-Identifier: GPL-3.0-only
#include "msxgl.h"
#include "ui/title.h"

void main(void)
{
	u8 status = Title_Show();

	VDP_SetDefaultPalette();
	VDP_SetLineCount(VDP_LINE_192);
	BIOS_Exit(status);
}
