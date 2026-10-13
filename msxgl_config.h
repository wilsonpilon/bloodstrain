// Reuse the MSX2 template configuration without changing the dependency.
#pragma once
#include "MSXgl/projects/template_msx2/msxgl_config.h"

#undef VDP_USE_DEFAULT_PALETTE
#define VDP_USE_DEFAULT_PALETTE TRUE

#undef INPUT_USE_MOUSE
#define INPUT_USE_MOUSE FALSE
#undef INPUT_USE_DETECT
#define INPUT_USE_DETECT FALSE
