// Reuse the MSX2 template configuration without changing the dependency.
#pragma once
#include "MSXgl/projects/template_msx2/msxgl_config.h"

#undef VDP_USE_DEFAULT_PALETTE
#define VDP_USE_DEFAULT_PALETTE TRUE

#undef INPUT_USE_MOUSE
#define INPUT_USE_MOUSE FALSE
#undef INPUT_USE_DETECT
#define INPUT_USE_DETECT FALSE

#undef DOS_USE_HANDLE
#define DOS_USE_HANDLE TRUE
#undef DOS_USE_VALIDATOR
#define DOS_USE_VALIDATOR TRUE
