#ifndef __AAS_DATA__
#define __AAS_DATA__

#include "AAS.h"

#if AAS_VERSION != 0x111
#error AAS version does not match Conv2AAS version
#endif

AAS_BEGIN_DECLS

extern const AAS_u8 AAS_DATA_MOD_baPinball;

extern const AAS_u8 AAS_DATA_MOD_batitle;

extern const AAS_u8 AAS_DATA_MOD_baTunnelEnd2;

extern const AAS_s8* const AAS_DATA_SFX_START_beepcoll;

extern const AAS_s8* const AAS_DATA_SFX_END_beepcoll;

extern const AAS_s8* const AAS_DATA_SFX_START_blastarenagbaintro;

extern const AAS_s8* const AAS_DATA_SFX_END_blastarenagbaintro;

extern const AAS_s8* const AAS_DATA_SFX_START_bouncer;

extern const AAS_s8* const AAS_DATA_SFX_END_bouncer;

extern const AAS_u8 AAS_DATA_MOD_btlemend;

extern const AAS_s8* const AAS_DATA_SFX_START_explos;

extern const AAS_s8* const AAS_DATA_SFX_END_explos;

extern const AAS_s8* const AAS_DATA_SFX_START_movesel;

extern const AAS_s8* const AAS_DATA_SFX_END_movesel;

extern const AAS_s8* const AAS_DATA_SFX_START_selecrtan;

extern const AAS_s8* const AAS_DATA_SFX_END_selecrtan;

extern const AAS_s8* const AAS_DATA_SFX_START_selection;

extern const AAS_s8* const AAS_DATA_SFX_END_selection;

extern const AAS_s8* const AAS_DATA_SFX_START_snakeclix;

extern const AAS_s8* const AAS_DATA_SFX_END_snakeclix;

AAS_END_DECLS

#endif
