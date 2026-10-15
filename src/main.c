// SPDX-License-Identifier: GPL-3.0-only
#include "msxgl.h"
#include "ui/title.h"
#include "world/block.h"

void main(void)
{
	u8 status = Title_Show();
	while (status == TITLE_MAP)
	{
		status = Block_Run();
		if (!status)
			status = Title_Show();
	}

	VDP_SetDefaultPalette();
	VDP_SetLineCount(VDP_LINE_192);
	BIOS_Exit(status);
}
