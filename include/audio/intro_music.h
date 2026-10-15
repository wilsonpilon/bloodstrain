// SPDX-License-Identifier: GPL-3.0-only
#pragma once
#include "msxgl.h"

#define INTRO_AUDIO_PSG 1
#define INTRO_AUDIO_FM 2
#define INTRO_AUDIO_SCC 4

u8 IntroMusic_Initialize(void);
void IntroMusic_Start(void);
void IntroMusic_Stop(void);
