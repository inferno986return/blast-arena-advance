// =====================================================================
//	  Look-Up Tables
//		RECIPSTARSCALE: Better LUT for the star scale reciprtocal.
//
//	Exported by Cearn's excellut v1.0
//	(comments, kudos, flames to daytshen@hotmail.com)
//
// =====================================================================

#include "starscale1.h"
// -----------------------------------------------------------------------
// RECIPSTARSCALE: a 175 long LUT of 16bit values in 8.8 format
// Better LUT for the star scale reciprtocal.
const signed short RECIPSTARSCALE[175]=
{
	0x03EF,0x03DE,0x03CE,0x03BE,0x03AF,0x03A0,0x0392,0x0385,
	0x0377,0x036A,0x035E,0x0351,0x0345,0x033A,0x032F,0x0324,
	0x0319,0x030F,0x0304,0x02FB,0x02F1,0x02E8,0x02DE,0x02D6,
	0x02CD,0x02C4,0x02BC,0x02B4,0x02AC,0x02A4,0x029D,0x0295,
	0x028E,0x0287,0x0280,0x0279,0x0273,0x026C,0x0266,0x025F,
	0x0259,0x0253,0x024D,0x0248,0x0242,0x023D,0x0237,0x0232,
	0x022D,0x0227,0x0222,0x021D,0x0219,0x0214,0x020F,0x020A,
	0x0206,0x0201,0x01FD,0x01F9,0x01F5,0x01F0,0x01EC,0x01E8,

	0x01E4,0x01E0,0x01DD,0x01D9,0x01D5,0x01D1,0x01CE,0x01CA,
	0x01C7,0x01C3,0x01C0,0x01BD,0x01B9,0x01B6,0x01B3,0x01B0,
	0x01AD,0x01AA,0x01A7,0x01A4,0x01A1,0x019E,0x019B,0x0198,
	0x0195,0x0193,0x0190,0x018D,0x018B,0x0188,0x0186,0x0183,
	0x0181,0x017E,0x017C,0x0179,0x0177,0x0175,0x0172,0x0170,
	0x016E,0x016B,0x0169,0x0167,0x0165,0x0163,0x0161,0x015F,
	0x015D,0x015B,0x0159,0x0157,0x0155,0x0153,0x0151,0x014F,
	0x014D,0x014B,0x0149,0x0148,0x0146,0x0144,0x0142,0x0141,

	0x013F,0x013D,0x013B,0x013A,0x0138,0x0137,0x0135,0x0133,
	0x0132,0x0130,0x012F,0x012D,0x012C,0x012A,0x0129,0x0127,
	0x0126,0x0124,0x0123,0x0121,0x0120,0x011F,0x011D,0x011C,
	0x011B,0x0119,0x0118,0x0117,0x0115,0x0114,0x0113,0x0112,
	0x0110,0x010F,0x010E,0x010D,0x010B,0x010A,0x0109,0x0108,
	0x0107,0x0106,0x0104,0x0103,0x0102,0x0101,0x0100,
};
