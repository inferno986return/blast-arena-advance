// Based on the TONC, and AAS C++ Example for projects with no other CPU intensive interrupts
// Notes:
//  + crt0.s file included with the example should be set to use __FastInterrupts.
//  + Can also be made to work with __SingleInterrupts and __MultipleInterrupts.
//  + Use __AAS_MultipleInterrupts when there are other CPU intensive interrupts - see AASExample2.

#include <tonc_gba.h>
#include <stdlib.h>
#include "AAS.h"
#include "AAS_Data.h"
#include "bitwise.h"
#include "palls.h"
#include "affine.h"
#include "luts.h"
#include "holdforasec.h"
#include "starbig.h"
#include "numbers.h"
#include "grey.h"
#include "fragment.h"
#include "bullets.h"
#include "starscale1.h"
#include "starrot1.h"
#include "cursorp.h"
#include "collect.h"
#include "sparkle.h"
#include "sparkle2.h"
#include "gameovertiles.h"
#include "largenum.h"
#include "bigtarg.h"
#include "swooshd.h"
#include "bigtime.h"
#include "retrytext.h"
#include "mattpresents.h"
#include "blastarenaletters.h"
#include "blastarenatitlescreen.h"
#include "advancehalves.h"
#include "presstaletters.h"
#include "finalbars.h"
#include "menuletters.h"
#include "whiteline.h"
#include "blankline.h"
#include "BGbackg.h"
#include "BGsprites.h"
#include "texttiles.h"
#include "texttiles2.h"
#include "hislide.h"
#include "hiarrow.h"
#include "hiscoretexts.h"
#include "speedyglowbox.h"
#include "appearbox.h"
#include "messages.h"

#define dont_optimize key_poll

#define REG_COLEY (*(vu16*)(0x04000054))
#define REG_COLEV (*(vu16*)(0x04000052))

#define VSync() asm volatile("swi 0x05")

//void VSync() {
//   asm volatile("swi 0x05");
//}

//#define VSync() vid_vsync();
//#define VSync() ;

#define Bail() asm volatile("swi 0xa5")

#define AAS_DMC32(s, d, f) AAS_DoDMA3(s, d, f | 0x84000000)
#define cpy(s, d, f) AAS_DMC32(s, d, f)
// It's a new generation of dma_memcpy.
// This one is Source, Dest, 32 Bit Chunx.

#define teppcpy(i, o, l) tepplescpy((void *)i, (void *)o, l)

void tepplescpy(void *in, void *out, u32 length) {
   u8 *source = (u8 *)in;
   u8 *dest   = (u8 *)out;
   for (; length > 0; length--) {
      *dest++ = *source++;
   }
}

#define _xRGB15(r,g,b) (((b)<<10) | ((g)<<5) | ((r)))

// ------------------------------------------------------------------------------------------------

typedef struct tagHiscore {
   u8  character[8];
   u16 flanges;
   u16 timeins;
} HISCORE;       // this is 12 bytes big, yeah!

u8   playername[8]  = {0, 0, 0, 0, 0, 0, 0, 0};
u32* playernamehash = (u32 *)playername;

HISCORE besttimestable[10];
HISCORE bestscoretable[10];

// ------------------------------------------------------------------------------------------------

typedef struct tagSavegame {
   u8      signaturehash[36];       //                    36 bytes
   u32     scoretotal;              //  36 +         4 =  40 bytes
   u8      savedname[8];            //  40 +         8 =  48 bytes
   HISCORE savedtimestable[10];     //  48 + (10 * 12) = 168 bytes
   HISCORE savedscoretable[10];     // 168 + (10 * 12) = 288 bytes
   u32     timestotal;              // 288 +         4 = 292 bytes
} BLAST_ARENA_SRAM_PACKAGE;    //

// ------------------------------------------------------------------------------------------------

#define BLAST_ARENA_SRAM_START 0x0E000010
                       //123456789012345678901234567890123456
u8 validationstring[] = "BLASTARENAmathewcarrMrDictionary.net";

bool isSaveGameValid(void) {
   BLAST_ARENA_SRAM_PACKAGE localcopy;

   teppcpy(BLAST_ARENA_SRAM_START, &localcopy, 292);

   for (u8 vc = 0; vc < 36; vc++) {
      if (localcopy.signaturehash[vc] != validationstring[vc]) {
         return false;
      }
   }
   u32 actualscoretotal = 0;
   u32 actualtimetotal  = 0;
   for (u8 ch = 0; ch < 10; ch++) {
      actualscoretotal  += localcopy.savedscoretable[ch].flanges;
      actualscoretotal  += localcopy.savedtimestable[ch].flanges;
      
      actualtimetotal   += localcopy.savedscoretable[ch].timeins;
      actualtimetotal   += localcopy.savedtimestable[ch].timeins;
   }
   if (actualscoretotal != localcopy.scoretotal) return false;
   if (actualtimetotal  != localcopy.timestotal) return false;
   
   return true;
}

void writeCurrentStateToCart() {
   BLAST_ARENA_SRAM_PACKAGE prepared;
   for (u8 vc = 0; vc < 36; vc++) {
      prepared.signaturehash[vc] = validationstring[vc];
   }
   u32 actualscoretotal = 0;
   u32 actualtimetotal  = 0;
   for (u8 ch = 0; ch < 10; ch++) {
      actualscoretotal  += besttimestable[ch].flanges;
      actualscoretotal  += bestscoretable[ch].flanges;
      
      actualtimetotal   += besttimestable[ch].timeins;
      actualtimetotal   += bestscoretable[ch].timeins;
   }
   for (u8 vc = 0; vc < 8; vc++) {
      prepared.savedname[vc] = playername[vc];
   }
   prepared.scoretotal = actualscoretotal;
   prepared.timestotal = actualtimetotal;
              
   for (u8 ch = 0; ch < 10; ch++) {
      prepared.savedtimestable[ch] = besttimestable[ch];
      prepared.savedscoretable[ch] = bestscoretable[ch];
   }
   
   teppcpy(&prepared, BLAST_ARENA_SRAM_START, 292);

   //*((BLAST_ARENA_SRAM_PACKAGE *)(BLAST_ARENA_SRAM_START)) = prepared;
}

void retrieveStateFromCart() {
   BLAST_ARENA_SRAM_PACKAGE localcopy;

   teppcpy(BLAST_ARENA_SRAM_START, &localcopy, 292);
   for (u8 vc = 0; vc < 8; vc++) {
      playername[vc] = localcopy.savedname[vc];
   }
   for (u8 ch = 0; ch < 10; ch++) {
      besttimestable[ch] = localcopy.savedtimestable[ch];
      bestscoretable[ch] = localcopy.savedscoretable[ch];
   }
}



#define M_H_E(tbl, no, score, time, a, b, c, d, e, f, g, h) tbl[no].character[0] = _HX_(a);              \
                                                            tbl[no].character[1] = _HX_(b);              \
                                                            tbl[no].character[2] = _HX_(c);              \
                                                            tbl[no].character[3] = _HX_(d);              \
                                                            tbl[no].character[4] = _HX_(e);              \
                                                            tbl[no].character[5] = _HX_(f);              \
                                                            tbl[no].character[6] = _HX_(g);              \
                                                            tbl[no].character[7] = _HX_(h);              \
                                                                                                         \
                                                            tbl[no].flanges = score; tbl[no].timeins = time;

#define replayername(a,b,c,d,e,f,g,h) playername[0] = _HX_(a); \
                                      playername[1] = _HX_(b); \
                                      playername[2] = _HX_(c); \
                                      playername[3] = _HX_(d); \
                                      playername[4] = _HX_(e); \
                                      playername[5] = _HX_(f); \
                                      playername[6] = _HX_(g); \
                                      playername[7] = _HX_(h);

void makeDefaultState(void) {

   replayername(P,l,a,y,e,r,sp,sp);

   M_H_E(bestscoretable, 0,  10,  20,  K,  a,  m,  i,  n,  e,  k,  o);
   M_H_E(bestscoretable, 1,   9,  18,  C,  h,  e,  s,  s,  e,  c, sp);
   M_H_E(bestscoretable, 2,   8,  16,  T,  o,  m,  o,  C,  h,  a,  n);
   M_H_E(bestscoretable, 3,   7,  14,  U,  r,  i,  k,  o, sp, sp, sp);
   M_H_E(bestscoretable, 4,   6,  12,  N,  a,  g,  i, sp, sp, sp, sp);
   M_H_E(bestscoretable, 5,   5,  10,  V,  a,  s,  h, pe,  T, pe,  S);
   M_H_E(bestscoretable, 6,   4,   8,  J, pe,  F, pe, sp,  M,  a,  n);
   M_H_E(bestscoretable, 7,   3,   6,  L,  i,  s,  t,  e,  r, sp, sp);
   M_H_E(bestscoretable, 8,   2,   4,  L,  a,  r,  r,  y, pe, sp,  I);
   M_H_E(bestscoretable, 9,   1,   2,  M,  a,  r,  i,  o, sp, sp, sp);

   M_H_E(besttimestable, 0,  10,  20,  S,  a,  k,  a,  k,  i, sp, sp);
   M_H_E(besttimestable, 1,   9,  18,  W,  o,  l,  f, sp, sp, sp, sp);
   M_H_E(besttimestable, 2,   8,  16,  C,  h,  i,  y,  o, sp, sp, sp);
   M_H_E(besttimestable, 3,   7,  14,  Y,  o,  s,  h,  i, sp, sp, sp);
   M_H_E(besttimestable, 4,   6,  12,  B,  l,  i,  n,  x, sp, sp, sp);
   M_H_E(besttimestable, 5,   5,  10,  C,  o,  l,  i,  n, pe, sp,  T);
   M_H_E(besttimestable, 6,   4,   8,  J,  a,  m,  e,  s, sp, sp, sp);
   M_H_E(besttimestable, 7,   3,   6,  M,  u,  l,  d,  e,  r, sp, sp);
   M_H_E(besttimestable, 8,   2,   4,  R,  a,  i,  d,  e,  n, sp, sp);
   M_H_E(besttimestable, 9,   1,   2,  A,  s,  h,  l,  e,  y, pe,  K);
}


void makeEliteState(void) {

   //replayername(P,l,a,y,e,r,sp,sp);

   M_H_E(bestscoretable, 0, 150, 200,  K,  a,  m,  i,  n,  e,  k,  o);
   M_H_E(bestscoretable, 1, 125, 150,  C,  h,  e,  s,  s,  e,  c, sp);
   M_H_E(bestscoretable, 2, 100, 120,  T,  o,  m,  o,  C,  h,  a,  n);
   M_H_E(bestscoretable, 3,  80, 100,  U,  r,  i,  k,  o, sp, sp, sp);
   M_H_E(bestscoretable, 4,  60,  90,  N,  a,  g,  i, sp, sp, sp, sp);
   M_H_E(bestscoretable, 5,  50,  75,  V,  a,  s,  h, pe,  T, pe,  S);
   M_H_E(bestscoretable, 6,  40,  70,  J, pe,  F, pe, sp,  M,  a,  n);
   M_H_E(bestscoretable, 7,  30,  50,  L,  i,  s,  t,  e,  r, sp, sp);
   M_H_E(bestscoretable, 8,  20,  30,  L,  a,  r,  r,  y, pe, sp,  I);
   M_H_E(bestscoretable, 9,  10,  15,  M,  a,  r,  i,  o, sp, sp, sp);

   M_H_E(besttimestable, 0, 100, 300,  S,  a,  k,  a,  k,  i, sp, sp);
   M_H_E(besttimestable, 1,  90, 250,  W,  o,  l,  f, sp, sp, sp, sp);
   M_H_E(besttimestable, 2,  80, 225,  C,  h,  i,  y,  o, sp, sp, sp);
   M_H_E(besttimestable, 3,  70, 200,  Y,  o,  s,  h,  i, sp, sp, sp);
   M_H_E(besttimestable, 4,  60, 150,  B,  l,  i,  n,  x, sp, sp, sp);
   M_H_E(besttimestable, 5,  50, 120,  C,  o,  l,  i,  n, pe, sp,  T);
   M_H_E(besttimestable, 6,  40,  90,  J,  a,  m,  e,  s, sp, sp, sp);
   M_H_E(besttimestable, 7,  30,  60,  M,  u,  l,  d,  e,  r, sp, sp);
   M_H_E(besttimestable, 8,  20,  40,  R,  a,  i,  d,  e,  n, sp, sp);
   M_H_E(besttimestable, 9,  10,  20,  A,  s,  h,  l,  e,  y, pe,  K);
}

// ------------------------------------------------------------------------------------------------


#define ranged_rand(rng) ((((((u16)rand())&0x7fff)*rng)>>15))

inline vu16 rng_rand(vu16 rng)
{    return (rand()&0x7fff)*rng>>15;  }


#define bitmappos(x, y) (((u16*)(0x06000000))[(x)+240*(y)])

#define CHEAT_GRAVITY_ON      bit0
#define CHEAT_FRICTIONLESS_ON bit1
#define CHEAT_REVERSE_ON      bit2
#define CHEAT_SUPERSLOW_ON    bit3
#define CHEAT_CANT_SAVE       bit7

vu8 cheatmodes = 0;//CHEAT_SUPERSLOW_ON;// CHEAT_GRAVITY_ON | CHEAT_FRICTIONLESS_ON;

#define SOUND_ON bit0
#define MUSIC_ON bit1
#define MENU_ON  bit6
#define SCOPE_ON bit7

//u8 curpal = 0;

//#define ALREADY_DEAD
#define MUSICSTARTSON

#ifdef MUSICSTARTSON
vu8 sfxflags = SOUND_ON | MUSIC_ON | SCOPE_ON;
#else
vu8 sfxflags = SOUND_ON | SCOPE_ON;// | MUSIC_ON;
#endif

#define AAS_SFX_Enhanced_Play(channel, sample_volume, sample_frequency, sample_start, sample_end, sample_restart) if (bitset(sfxflags, SOUND_ON)) {AAS_SFX_Play(channel, sample_volume, sample_frequency, sample_start, sample_end, sample_restart);}
#define AAS_MOD_Enhanced_Play(stuff) if (bitset(sfxflags, MUSIC_ON)) {AAS_MOD_Play(stuff);}

void VBlankInterruptHandler() {
   REG_IME = 0;
   AAS_DoWork();
   REG_IFBIOS = INT_VBLANK;      // Tell the bios we've recieved the VBlank interrupt.
   //curpal = 0;
   REG_IF = bit0;
   // Insert your own VBlank code here
   REG_IME = 1;
}

#define HBLANK_NONE            0
#define HBLANK_HISCORE1        1
#define HBLANK_HISCORESTEADY   2
#define HBLANK_HISCOREDYING    3
#define HBLANK_BLASTARENATITLE 4

s16 hfadeline       = 0;
u8  hcinemabars     = 0;
u8  hcinemabars2    = 0;
u8  HBlanksituation = HBLANK_NONE;
u8  VCOUNTER;

void HBlankInterruptHandler() {
   REG_IME = 0;
   VCOUNTER = (REG_VCOUNT == 227) ? 0 : (REG_VCOUNT+1);
   //VCOUNTER = (REG_VCOUNT);
   if (HBlanksituation == HBLANK_NONE) {
   } else if (HBlanksituation == HBLANK_HISCORE1) {
#define HBLANK_HISCORE1_HFWIDTH 12
#define HBLANK_HISCORE1_FADEFORMULA1 ((VCOUNTER - (hfadeline-HBLANK_HISCORE1_CORONA-HBLANK_HISCORE1_HFWIDTH))>>1)
#define HBLANK_HISCORE1_CORONA 32
      hcinemabars2 = 160 - hcinemabars;
      if ((VCOUNTER > hcinemabars) && (VCOUNTER < hcinemabars2)) {
         if (VCOUNTER > (hfadeline)) {
            REG_BLDMOD = bit2 | bit1 | bit6 | bit8 | bitC;  // TOTAL TRANSPARENCY FROM b1 TO B0
            REG_COLEV  = 16 << 8;
         } else if (VCOUNTER > (hfadeline-HBLANK_HISCORE1_HFWIDTH)) {
            REG_BLDMOD = bit2 | bit1 | bit7;
            REG_COLEY  = 16;
         } else if (VCOUNTER > (hfadeline - HBLANK_HISCORE1_CORONA-HBLANK_HISCORE1_HFWIDTH)) {
            REG_BLDMOD = bit2 | bit1 | bit7;
            REG_COLEY  = HBLANK_HISCORE1_FADEFORMULA1;
         } else  {
            REG_BLDMOD = 0;
         }
      } else {
         REG_BLDMOD = bit7 | bit6 | bit5 | bit4 | bit0;
         REG_COLEY  = 16;
      }
   } else if (HBlanksituation == HBLANK_HISCORESTEADY) {
      hcinemabars2 = 160 - hcinemabars;
      if ((VCOUNTER > hcinemabars) && (VCOUNTER < hcinemabars2)) {
         REG_BLDMOD = REG_COLEY = 0;
      } else {
         REG_BLDMOD = bit7 | bit6 | bit5 | bit4 | bit0;
         REG_COLEY  = 16;
      }
   } else if (HBlanksituation == HBLANK_HISCOREDYING) {
      if ((VCOUNTER > 18) && (VCOUNTER < 142)) {    
         REG_BLDMOD = bit7 | bit6 | bit5 | bit4 | bit3 | bit2 | bit1 | bit0;
         REG_COLEY = hcinemabars;
      } else {
         REG_BLDMOD = bit7 | bit6 | bit5 | bit4 | bit3 | bit2 | bit1 | bit0;
         REG_COLEY  = 16;
      }
   } else if (HBlanksituation == HBLANK_BLASTARENATITLE) {
#define HBLANK_BAT_FADEHEIGHT 32
#define HBLANK_BAT_TOPFORMULA (((VCOUNTER - (79-hfadeline-HBLANK_BAT_FADEHEIGHT))>>1))
#define HBLANK_BAT_BOTFORMULA ((((80+hfadeline+HBLANK_BAT_FADEHEIGHT)-VCOUNTER)>>1))
      if (VCOUNTER < 79) {
         if (VCOUNTER < (79-hfadeline-HBLANK_BAT_FADEHEIGHT)) {
            REG_BLDMOD = 0;
         } else {
            if (VCOUNTER < (79-hfadeline)) {
               REG_BLDMOD = bit2 | bit4 | bit7 | bit6;
               REG_COLEY  = HBLANK_BAT_TOPFORMULA;
            } else {
               REG_BLDMOD = bit2 | bit4 | bit7 | bit6;
               REG_COLEY  = 16;
            }
         }
      } else {
         if (VCOUNTER < (80+hfadeline)) {
            REG_BLDMOD = bit2 | bit4 | bit7 | bit6;
            REG_COLEY  = 16;
         } else {
            if (VCOUNTER < (80+hfadeline+HBLANK_BAT_FADEHEIGHT)) {
               REG_BLDMOD = bit2 | bit4 | bit7 | bit6;
               REG_COLEY  = HBLANK_BAT_BOTFORMULA;
            } else {
               REG_BLDMOD = 0;
            }
         }
      }
   }
   REG_IME = 1;
};

void UnusedInterruptHandler() {
};

void (*AAS_IntrTable[13])(void) = {
   VBlankInterruptHandler,      // VBlank Interrupt
   HBlankInterruptHandler,      // HBlank Interrupt
   UnusedInterruptHandler,      // V Counter Interrupt
   UnusedInterruptHandler,      // Timer 0 Interrupt
   UnusedInterruptHandler,      // Timer 2 Interrupt
   UnusedInterruptHandler,      // Timer 3 Interrupt
   UnusedInterruptHandler,      // Serial Communication Interrupt
   UnusedInterruptHandler,      // DMA0 Interrupt
   UnusedInterruptHandler,      // DMA1 Interrupt
   UnusedInterruptHandler,      // DMA2 Interrupt
   UnusedInterruptHandler,      // DMA3 Interrupt
   UnusedInterruptHandler,      // Key Interrupt
   UnusedInterruptHandler       // Cart Interrupt
};

// Affinity information
OBJINFO oi_buffer[OI_COUNT];
OBJAFF *const oa_buffer= (OBJAFF*)oi_buffer;
// copy oi_buffer to oam_mem
void oam_update(int start, int num)
{
   // num<<1 ?!? Remember, one OBJINFO struct is 4 u16 = 2 u32 long
   cpy(&oi_buffer[start], &oam_mem[start], num<<1);
}

// update only the OBJINFO part
void oi_update(int start, int num)
{
   int ii;
   OBJINFO *oi= (OBJINFO*)oam_mem;
   for(ii=start; ii<start+num; ii++)
   {
      oi[ii].attr0= oi_buffer[ii].attr0;
      oi[ii].attr1= oi_buffer[ii].attr1;
      oi[ii].attr2= oi_buffer[ii].attr2;
   }
}

// update only the OBJAFF part
void oa_update(int start, int num)
{
   int ii;
   OBJAFF *oa= (OBJAFF*)oam_mem;
   for(ii=start; ii<start+num; ii++)
   {
      oa[ii].pa= oa_buffer[ii].pa;
      oa[ii].pb= oa_buffer[ii].pb;
      oa[ii].pc= oa_buffer[ii].pc;
      oa[ii].pd= oa_buffer[ii].pd;
   }
}

// ------------

void RegisterHiscores(u16 FLANGES, u16 TIME) {
   u8 hiscoreyoubeat = 10;
   for (u8 h = 0; h < 10; h++) {
      if (!(FLANGES < bestscoretable[h].flanges)) {
         hiscoreyoubeat = h;
         while ((hiscoreyoubeat != 10) && ((TIME >= bestscoretable[hiscoreyoubeat].timeins) && (FLANGES == bestscoretable[hiscoreyoubeat].flanges))) {
            hiscoreyoubeat++;
         }
         break;
      }
   }
   if (hiscoreyoubeat != 10) {
      HISCORE temp;   
      temp.character[0] = playername[0];
      temp.character[1] = playername[1];
      temp.character[2] = playername[2];
      temp.character[3] = playername[3];
      temp.character[4] = playername[4];
      temp.character[5] = playername[5];
      temp.character[6] = playername[6];
      temp.character[7] = playername[7];
      temp.flanges = FLANGES;
      temp.timeins = TIME;
      for (u8 h = 9; h > hiscoreyoubeat; h--) {
         bestscoretable[h] = bestscoretable[h-1];
      }
      bestscoretable[hiscoreyoubeat] = temp;
   }

   hiscoreyoubeat = 10;
   for (u8 h = 0; h < 10; h++) {
      if (!(TIME < besttimestable[h].timeins)) {
         hiscoreyoubeat = h;
         while ((hiscoreyoubeat != 10) && ((TIME == besttimestable[hiscoreyoubeat].timeins) && (FLANGES <= besttimestable[hiscoreyoubeat].flanges))) {
            hiscoreyoubeat++;
         }
         break;
      }
   }
   if (hiscoreyoubeat != 10) {
      HISCORE temp;   
      temp.character[0] = playername[0];
      temp.character[1] = playername[1];
      temp.character[2] = playername[2];
      temp.character[3] = playername[3];
      temp.character[4] = playername[4];
      temp.character[5] = playername[5];
      temp.character[6] = playername[6];
      temp.character[7] = playername[7];
      temp.flanges = FLANGES;
      temp.timeins = TIME;
      for (u8 h = 9; h > hiscoreyoubeat; h--) {
         besttimestable[h] = besttimestable[h-1];
      }
      besttimestable[hiscoreyoubeat] = temp;
   }

   if (!bitset(cheatmodes, CHEAT_CANT_SAVE)) {
      writeCurrentStateToCart();
   }

}

// ------------

typedef struct tagExplo {
   u8   y;
   u16  x;
   u16 frameal;
   u8  offset;

   u8 palette;
} FRAG;

typedef struct tagBul {
   FIXED yF;
   FIXED xF;
   u8  flaction;

   u8 palette;
} BULL;

typedef struct wasFlange {
   u8   x;
   u8   y;
   u8   frameal;
} DUST;

void SetUpGame() {
   REG_DISPCNT = 3 | VID_BG2 | VID_OBJ | VID_LINEAR;
   REG_BLDMOD = 0;
   REG_COLEY = 0;

   bitmappos(0,0) = 0;
   bitmappos(0,1) = 0;

   *(u32 *)MEM_VRAM = 0;
   cpy((void *)MEM_VRAM,(void *)0x06000004,19199);

//   for (u8 i=0; i<12; i++) {
//      cpy((void *)((u16 *)pallsPal + 16*i)                , (void *)(pal_obj_mem+16*i)  , 4);
//      cpy((void *)((u16 *)pallsPal + 16*(i<6?i+6:i-6) + 8), (void *)(pal_obj_mem+16*i+8), 4);
//   }

   for (u8 i=0; i<12; i++) {
      cpy((void *)((u16 *)pallsPal + 16*i)                , (void *)(pal_obj_mem+16*i)  , 4);
      cpy((void *)((u16 *)pallsPal + 16*(i<6?i+6:i-6) + 8), (void *)(pal_obj_mem+16*i+8), 4);
   }

   cpy((void *)((u16 *)greyPal), (void *)(pal_obj_mem+192)  , 4);
   cpy((void *)((u16 *)greyPal), (void *)(pal_obj_mem+192+8), 4);

   cpy((void *)starbigData, (void *)&tl_mem[TB_OBJ][0+512], 512);
   cpy((void *)bulletsData, (void *)&tl_mem[TB_OBJ][16+512+48], 24);

   cpy((void *)cursorpData, (void *)&tl_mem[TB_OBJ][19+512+48], 8);
   cpy((void *)cursorpPal, (void *)(pal_obj_mem+208), 2);

   //Lighten bullets.

#define RED_COMP(a)    ((a & (    31)))
#define GREEN_COMP(a)  ((a & ( 31<<5))>>5)
#define BLUE_COMP(a)   ((a & (31<<10))>>10)

#define LIBI 3

   for (u8 pall = 0; pall<12; pall++) {
      for (u8 col = 0; col<7; col++) {
         pal_obj_mem[pall*16+8+col] = (  RED_COMP(pal_obj_mem[pall*16+8+col])+LIBI > 31 ? 31 :   RED_COMP(pal_obj_mem[pall*16+8+col])+LIBI)     |
                                      (GREEN_COMP(pal_obj_mem[pall*16+8+col])+LIBI > 31 ? 31 : GREEN_COMP(pal_obj_mem[pall*16+8+col])+LIBI)<< 5 |
                                      ( BLUE_COMP(pal_obj_mem[pall*16+8+col])+LIBI > 31 ? 31 :  BLUE_COMP(pal_obj_mem[pall*16+8+col])+LIBI)<<10;
      }
      pal_obj_mem[pall*16+15] = 0x7ffff;
   }

#define DABI 6

   for (u8 pall = 0; pall<12; pall++) {
      for (u8 col = 0; col<8; col++) {
           pal_obj_mem[pall*16+col] = (  RED_COMP(pal_obj_mem[pall*16+col])-DABI < 0 ? 0 :   RED_COMP(pal_obj_mem[pall*16+col])-DABI)     |
                                      (GREEN_COMP(pal_obj_mem[pall*16+col])-DABI < 0 ? 0 : GREEN_COMP(pal_obj_mem[pall*16+col])-DABI)<< 5 |
                                      ( BLUE_COMP(pal_obj_mem[pall*16+col])-DABI < 0 ? 0 :  BLUE_COMP(pal_obj_mem[pall*16+col])-DABI)<<10;
      }
   }

   cpy((void *)fragmentData, (void *)&tl_mem[TB_OBJ][20+512+48], 8);

   cpy((void *)collectData, (void *)&tl_mem[TB_OBJ][21+512+48], 8);
   (*((u16*)(0x050003A6))) = _xRGB15(26,26,0);
   (*((u16*)(0x050003A8))) = _xRGB15(31,31,0);  // Sick of the god damn dma screwing up. These are the shades of yellow.
   (*((u16*)(0x050003AA))) = _xRGB15(12,12,0);  // Sick of the god damn dma screwing up. These are the shades of yellow.

   (*((u16*)(0x050003AC))) = _xRGB15(15,15,15);
   (*((u16*)(0x050003AE))) = _xRGB15( 8, 8, 8);  // Sick of the god damn dma screwing up. These are the shades of grey.

   (*((u16*)(0x050003B0))) = _xRGB15(21,21,0);
   (*((u16*)(0x050003B2))) = _xRGB15(29,29,0);  // Sick of the god damn dma screwing up. These are the shades of yellow.
   (*((u16*)(0x050003B4))) = _xRGB15(17,17,0);  // Sick of the god damn dma screwing up. These are the shades of yellow.
   (*((u16*)(0x050003B6))) = _xRGB15( 8, 8,0);  // Sick of the god damn dma screwing up. These are the shades of yellow.

   cpy((void *)sparkleData, (void *)&tl_mem[TB_OBJ][22+512+48], 8);
   cpy((void *)sparkle2Data, (void *)&tl_mem[TB_OBJ][23+512+48], 8);

   cpy((void *)largenumData, (void *)&tl_mem[TB_OBJ][24+512+48], 640);

   cpy((void *)gameovertilesPal, (void *)&pal_bg_mem[0], 20);

   cpy((void *)bigtargData, (void *)&tl_mem[TB_OBJ][664], 32);
   cpy((void *)bigtimeData, (void *)&tl_mem[TB_OBJ][700], 32);

   cpy((void *)swooshdData, (void *)&tl_mem[TB_OBJ][668], 256);
   cpy((void *)swooshdPal, (void *)&pal_obj_mem[224], 8);
                                                     
   pal_bg_mem[39] = _xRGB15(3, 3, 3);
   cpy((void *)retrytextPal, (void *)&pal_bg_mem[40], 4);

   srand(REG_TM0D);


   /*                          // NEGATIVE COLOURS.
   for (u8 i=0; i<255; i++) {
      pal_obj_mem[i] ^= 0x7fff;
      pal_bg_mem[i] ^= 0x7fff;
   }

   for (u8 x = 0; x<240; x++) {
      for (u8 y = 0; y<160; y++) {
         bitmappos(x, y) = 0x7fff;
      }
   } */        // NEGATIVE COLOURS.
}

#define GAME_PLAY     0     // playing
#define GAME_PLAYH    1     // playing, pause doesn't respond until start is released.
#define GAME_LOST     2     // RESULT: The game has been lost, go to menu.
#define GAME_QUIT     3     // RESULT: The game has been quit, go to menu.
#define GAME_REST     4     // RESULT: The game has been restarted from GOS, go to game.
#define GAME_DYING    5     // Going to the white screen of between.
#define GAME_WHITE    6     //          the white screen of between.
#define GAME_GOS      7     // GAME OVER SCREEN
#define GAME_PAUSE    8     // PauseD.
#define GAME_PAUSEH   9     // PauseHOLD.
#define GAME_TOREST  10     // Fading out to a new Game().
#define GAME_TOMENU  11     // Fading out to menu.
#define GAME_UNGOS   12     // Fading out to Blinx.
#define GAME_BLINX   13     // Bink bink bink lets cheat!

 char Game() {
                    
   AAS_MOD_Stop();

   u8 GameStatus = GAME_PLAYH;
#ifdef ALREADY_DEAD
   GameStatus = GAME_WHITE;
#endif
   s16 a;
   u8 obj_counter = 127, aff_counter = 0;

   FRAG explosions[30];
   //FRAG *explosions = (FRAG *)malloc(180);
   for (u8 currex = 0; currex<30; currex++) {
      explosions[currex].frameal = 0;
   }

   BULL bullets[100];
   //BULL *bullets = (BULL *)malloc(500);
   for (u8 currbull = 0; currbull<100; currbull++) {
      bullets[currbull].flaction = 0;
   }

   DUST flangedust[3];
   ////BULL *bullets = (BULL *)malloc(500);
   for (u8 currdust = 0; currdust<3; currdust++) {
      flangedust[currdust].frameal = 0;
   }

   FIXED playerx  = (120<<8);
   FIXED playery  = (80<<8);
   FIXED playerxs = 0;
   FIXED playerys = 0;

//#define BSS (1<<8)
//#define BDS (bit7|bit6|bit4)

#define BSS (bit8|bit7)
#define BDS (bit8|bit4|bit3)

//speeds of the bullets per frame in fixed point 8.8

   u32 gametimeinVblanks = 0;
   u32 gameoverinVblanks = 0;
   
   u16 s; //need this for hiscore keepage.

   u8  firsttimer = 400;

   u8  nextpopVb  = 3;
   u8  NEXTnextpopVb = 200;
   u8  decrement  = nextpopVb;
   u8  decrement2 = 90;

   u8  pallam2    = 0;

   u8  fadeframe  = 0;

   u8  gameflags  = 0;
   u16 flangecoll = 0;
   u16 flangerescount = 0;

   u8  flangex    = 0;
   u8  flangey    = 0;

   s16 previouswave[240];

   // Game over statics.

   BGINFO back0;
   bg_init(&back0, 0, 0, 30, BG_REG_1X1 | BG_PAL256 | 3);
   TEGEL *tegelset0 = back0.map;

   BGINFO back1;
   bg_init(&back1, 1, 2, 31, BG_REG_1X1 | BG_PAL256 | 3);
   TEGEL *tegelset1 = back1.map;

   BGINFO back2;
   bg_init(&back2, 2, 0, 29, BG_REG_1X1 | BG_PAL256 | 0);
   TEGEL *tegelset2 = back2.map;

   BGINFO back3;
   bg_init(&back3, 3, 0, 29, BG_REG_1X1 | BG_PAL256 | 0);

   u16 keydowngos = 0;

   u8 hundredscollected = 0;
   u8 tenscollected = 0;
   u8 unitscollected = 0;
   
   u8 tensminspass = 0;
   u8 unitsminspass = 0;
   u8 tenssecspass = 0;
   u8 unitssecspass = 0;

   // tegelset ==> tegelset (taglemap, xtile, ytile, tileid)
#define settegel(t, x, y, i)    t[((x) + ((y)<<5))] = (i)

#define settegelrun(tegellingset, xpos, ypos, index, runcount)   \
   for (vu8 tegelrun = 0; tegelrun < runcount; tegelrun++) {      \
      settegel(tegellingset, ((xpos) + tegelrun), (ypos), ((index) + (tegelrun)));      \
   }

#define settegelrun256(tegellingset, xpos, ypos, index, runcount)   \
   for (vu8 tegelrun = 0; tegelrun < runcount; tegelrun++) {      \
      settegel(tegellingset, ((xpos) + tegelrun), (ypos), ((index) + (tegelrun)));      \
   }

   //

   while ((GameStatus != GAME_LOST) && (GameStatus != GAME_QUIT) && (GameStatus != GAME_REST)) {
    if ((GameStatus == GAME_PLAY) || (GameStatus == GAME_PLAYH) || (GameStatus == GAME_DYING)) {
      VSync();
      key_poll();

      //pallam2++;

#define PALLUPD  if (pallam2++ == 2*11) pallam2=0;
#define PALLCURR (pallam2>>1)

      if (firsttimer>0) {
         firsttimer--;
         if (firsttimer==70) {
            AAS_MOD_Enhanced_Play(AAS_DATA_MOD_baPinball);
         } else if (firsttimer==1) {
            firsttimer = 0;
         }
      } else {
         decrement--;   //Creation of explosions.
         if (GameStatus == GAME_DYING) {
            fadeframe += 2;
            REG_BLDMOD = bit7 | bit5 | bit4 | bit3 | bit2 | bit1 | bit0;
            //REG_COLEY  = fadeframe;
            REG_COLEY = fadeframe;
            if (fadeframe >= 16) {
               GameStatus = GAME_WHITE;
            }
         }
      }

      if (decrement == 0) {
         if (gametimeinVblanks > (60*60*4)) {
            nextpopVb = 40;
         } else {
         // nextpopVb == !?!?!?   Some relationship with gametimeinVblanks.
            nextpopVb = NEXTnextpopVb;  //Starts at 200 and goes down to 40 over      4 minutes      16777216/280896 = 59.7375 fps
                              //                                      =   240 seconds
                              //                                      = 14335 blanx
                              
                              // As in, it loses 160 in 14335 blanx.
                              // As in, it loses   1 in 90 blanx!
         }
         //AAS_SFX_Enhanced_Play(2, 32, 16000, AAS_DATA_SFX_START_appear, AAS_DATA_SFX_END_appear, AAS_NULL);//AAS_DATA_SFX_START_explos);

         u8 currex = 0;
         while (currex<30) {
            if (explosions[currex].frameal == 0) {
               explosions[currex].frameal = 360;
               explosions[currex].x = rng_rand(240);
               explosions[currex].y = rng_rand(160);
               explosions[currex].offset = gametimeinVblanks;
               explosions[currex].palette = PALLCURR;
               PALLUPD;
               break;
            }
            currex++;
         }
         decrement = nextpopVb;
      }

      decrement2--;
      if (decrement2 == 0 && (gametimeinVblanks < (60*60*4))) {
          NEXTnextpopVb--;
          decrement2 = 90;
      }

      //Game Logic and Control.
      for (u8 currex = 0; currex<30; currex++) {
         if (explosions[currex].frameal > 0) {
            explosions[currex].frameal--;                        // Decay the explosions.
            if ((explosions[currex].frameal > 176) && (explosions[currex].frameal < 196)) {
               if (gameflags < 2) {
                  gameflags++;
                  if (gameflags == 2) {     
                     flangex = rng_rand(230)+5;
                     flangey = rng_rand(150)+5;
                  }
               }
               AAS_SFX_Enhanced_Play(1, 52, 16000, AAS_DATA_SFX_START_explos, AAS_DATA_SFX_END_explos, AAS_NULL);//AAS_DATA_SFX_START_explos);
               explosions[currex].frameal = 174;
               u8 currbull = 0;
               while (currbull < 100) {
                  if (bullets[currbull].flaction == 0) {
                     bullets[currbull].flaction = B_ALIVE;
                     bullets[currbull].xF = ((explosions[currex].x))<<8;
                     bullets[currbull].yF = ((explosions[currex].y))<<8;
                     bullets[currbull].palette = PALLCURR;
                     break;
                  }
                  currbull++;
               }
               currbull = 0;
               while (currbull < 100) {
                  if (bullets[currbull].flaction == 0) {
                     bullets[currbull].flaction = B_ALIVE | B_LEFT;
                     bullets[currbull].xF = ((explosions[currex].x))<<8;
                     bullets[currbull].yF = ((explosions[currex].y))<<8;
                     bullets[currbull].palette = PALLCURR;
                     break;
                  }
                  currbull++;
               }
               currbull = 0;
               while (currbull < 100) {
                  if (bullets[currbull].flaction == 0) {
                     bullets[currbull].flaction = B_ALIVE | B_DOWN | B_VERT;
                     bullets[currbull].xF = ((explosions[currex].x))<<8;
                     bullets[currbull].yF = ((explosions[currex].y))<<8;     
                     bullets[currbull].palette = PALLCURR;
                     break;
                  }
                  currbull++;
               }
               currbull = 0;
               while (currbull < 100) {
                  if (bullets[currbull].flaction == 0) {
                     bullets[currbull].flaction = B_ALIVE | B_VERT;
                     bullets[currbull].xF = ((explosions[currex].x))<<8;
                     bullets[currbull].yF = ((explosions[currex].y))<<8;
                     bullets[currbull].palette = PALLCURR;
                     break;
                  }
                  currbull++;
               }
               currbull = 0;
               while (currbull < 100) {
                  if (bullets[currbull].flaction == 0) {
                     bullets[currbull].flaction = B_ALIVE | B_DIAG;
                     bullets[currbull].xF = ((explosions[currex].x))<<8;
                     bullets[currbull].yF = ((explosions[currex].y))<<8;
                     bullets[currbull].palette = PALLCURR;
                     break;
                  }
                  currbull++;
               }
               currbull = 0;
               while (currbull < 100) {
                  if (bullets[currbull].flaction == 0) {
                     bullets[currbull].flaction = B_ALIVE | B_DIAG | B_LEFT;
                     bullets[currbull].xF = ((explosions[currex].x))<<8;
                     bullets[currbull].yF = ((explosions[currex].y))<<8;     
                     bullets[currbull].palette = PALLCURR;
                     break;
                  }
                  currbull++;
               }
               currbull = 0;
               while (currbull < 100) {
                  if (bullets[currbull].flaction == 0) {
                     bullets[currbull].flaction = B_ALIVE | B_DIAG | B_LEFT | B_DOWN;
                     bullets[currbull].xF = ((explosions[currex].x))<<8;
                     bullets[currbull].yF = ((explosions[currex].y))<<8;     
                     bullets[currbull].palette = PALLCURR;
                     break;
                  }
                  currbull++;
               }
               currbull = 0;
               while (currbull < 100) {
                  if (bullets[currbull].flaction == 0) {
                     bullets[currbull].flaction = B_ALIVE | B_DIAG | B_DOWN;
                     bullets[currbull].xF = ((explosions[currex].x))<<8;
                     bullets[currbull].yF = ((explosions[currex].y))<<8;      
                     bullets[currbull].palette = PALLCURR;
                     break;
                  }
                  currbull++;
               }
            }
         }
      }

      for (u8 currbull = 0; currbull<100; currbull++) {
         u8 f = bullets[currbull].flaction;
         if (bitset(f, B_ALIVE)) {
            if (bitset(f, B_DIAG)) {
               if (bitset(f, B_LEFT)) {
                  if (bitset(f, B_DOWN)) {
                     bullets[currbull].xF += BDS;
                     bullets[currbull].yF += BDS;
                  } else {
                     bullets[currbull].xF += BDS;
                     bullets[currbull].yF -= BDS;
                  }
               } else {
                  if (bitset(f, B_DOWN)) {
                     bullets[currbull].xF -= BDS;
                     bullets[currbull].yF += BDS;
                  } else {
                     bullets[currbull].xF -= BDS;
                     bullets[currbull].yF -= BDS;
                  }
               }
            } else {
               if (bitset(f, B_VERT)) {
                  if (bitset(f, B_DOWN)) {
                     bullets[currbull].yF += BSS;
                  } else {
                     bullets[currbull].yF -= BSS;
                  }
               } else {
                  if (bitset(f, B_LEFT)) {
                     bullets[currbull].xF += BSS;
                  } else {
                     bullets[currbull].xF -= BSS;
                  }
               }
            }
            if (bullets[currbull].xF < (-5<<8)) bullets[currbull].flaction = 0;
            if (bullets[currbull].yF < (-5<<8)) bullets[currbull].flaction = 0;
            if (bullets[currbull].xF > (245<<8)) bullets[currbull].flaction = 0;
            if (bullets[currbull].yF > (165<<8)) bullets[currbull].flaction = 0;
         }
      }
      
      //Decay the flangedust collaborations. *.*
      for (u8 currdust = 0; currdust < 3; currdust++) {
         if (flangedust[currdust].frameal != 0) {
            flangedust[currdust].frameal--;
         }
      }

      // Player collision with sides of the gameboy.
      if (playerx < (3<<8)) {
         playerx = (3<<8);
         playerxs = ABS(playerxs);
         AAS_SFX_Enhanced_Play(0, 40, 19000, AAS_DATA_SFX_START_bouncer, AAS_DATA_SFX_END_bouncer, AAS_NULL);//AAS_DATA_SFX_START_explos);
      } else if (playerx > (236<<8)) {
         playerx = (236<<8);
         playerxs = 0-ABS(playerxs);
         AAS_SFX_Enhanced_Play(0, 40, 18000, AAS_DATA_SFX_START_bouncer, AAS_DATA_SFX_END_bouncer, AAS_NULL);//AAS_DATA_SFX_START_explos);
      }
      if (playery < (3<<8)) {
         playery = (3<<8);
         playerys = ABS(playerys);
         AAS_SFX_Enhanced_Play(0, 40, 17000, AAS_DATA_SFX_START_bouncer, AAS_DATA_SFX_END_bouncer, AAS_NULL);//AAS_DATA_SFX_START_explos);
      } else if (playery > (157<<8)) {
         playery = (157<<8);
         playerys = 0-ABS(playerys);
         AAS_SFX_Enhanced_Play(0, 40, 16000, AAS_DATA_SFX_START_bouncer, AAS_DATA_SFX_END_bouncer, AAS_NULL);//AAS_DATA_SFX_START_explos);
      }

      playerx += playerxs;
      playery += playerys;

//#define PLAYER_FASTACC ((1<<8) + (1<<7))
//#define PLAYER_ACC (1<<8)
//#define PLAYER_SLOWACC (1<<7)

#define PLAYER_FASTACC (256)
#define PLAYER_ACC     (192)
#define PLAYER_SLOWACC (64)

#define PLAYER_FASTTV (1280)
#define PLAYER_TV     (768)
#define PLAYER_SLOWTV (512)

      bool adown = _key_down(KEY_A)!=0;
      bool bdown = _key_down(KEY_B)!=0;

#define PLAYER_BASESUPER_TV (adown?(bdown?PLAYER_TV:PLAYER_FASTTV):(bdown?PLAYER_SLOWTV:PLAYER_TV))
#define PLAYER_BASESUPER_ACC (adown?(bdown?PLAYER_ACC:PLAYER_FASTACC):(bdown?PLAYER_SLOWACC:PLAYER_ACC))

#define PLAYER_SUPER_TV (bitset(cheatmodes, CHEAT_SUPERSLOW_ON) ? (PLAYER_BASESUPER_TV >> 2) : (PLAYER_BASESUPER_TV))
#define PLAYER_SUPER_ACC (bitset(cheatmodes, CHEAT_SUPERSLOW_ON) ? (PLAYER_BASESUPER_ACC >> 2) : (PLAYER_BASESUPER_ACC))

//#define ALT_CONTROL_METHOD

      if (GameStatus != GAME_DYING) {
         if (!bitset(cheatmodes, CHEAT_REVERSE_ON)) {
            #ifdef ALT_CONTROL_METHOD
               if (_key_down(KEY_DOWN)) {
                  playerys = PLAYER_SUPER_TV;
               }
               if (_key_down(KEY_UP)) {
                  playerys = 0-PLAYER_SUPER_TV;
               }
               if (_key_down(KEY_RIGHT)) {
                  playerxs = PLAYER_SUPER_TV;
               }
               if (_key_down(KEY_LEFT)) {
                  playerxs = 0-PLAYER_SUPER_TV;
               }
            #else
               if (_key_down(KEY_DOWN)) {
                  playerys += PLAYER_SUPER_ACC;
               }
               if (_key_down(KEY_UP)) {
                  playerys -= PLAYER_SUPER_ACC;
               }
               if (_key_down(KEY_RIGHT)) {
                  playerxs += PLAYER_SUPER_ACC;
               }
               if (_key_down(KEY_LEFT)) {
                  playerxs -= PLAYER_SUPER_ACC;
               }
            #endif
         } else {  
            #ifdef ALT_CONTROL_METHOD
               if (_key_down(KEY_DOWN)) {
                  playerys = 0-PLAYER_SUPER_TV;
               }
               if (_key_down(KEY_UP)) {
                  playerys = PLAYER_SUPER_TV;
               }
               if (_key_down(KEY_RIGHT)) {
                  playerxs = 0-PLAYER_SUPER_TV;
               }
               if (_key_down(KEY_LEFT)) {
                  playerxs = PLAYER_SUPER_TV;
               }
            #else
               if (_key_down(KEY_DOWN)) {
                  playerys -= PLAYER_SUPER_ACC;
               }
               if (_key_down(KEY_UP)) {
                  playerys += PLAYER_SUPER_ACC;
               }
               if (_key_down(KEY_RIGHT)) {
                  playerxs -= PLAYER_SUPER_ACC;
               }
               if (_key_down(KEY_LEFT)) {
                  playerxs += PLAYER_SUPER_ACC;
               }
            #endif
         }
      }

      // FRICTION. Cheats can disable.
      
      if (!bitset(cheatmodes, CHEAT_FRICTIONLESS_ON)) {
         playerxs = (playerxs * 15) >> 4;
         playerys = (playerys * 15) >> 4;
      }

      if ((playerxs < 17) && (playerxs > -17)) playerxs = 0;
      if ((playerys < 17) && (playerys > -17)) playerys = 0;

      // Collide the player with all those bullets resulting in the gameover

#define BX (bullets[currbull].xF>>8)
#define BY (bullets[currbull].yF>>8)
#define PX (playerx             >>8)
#define PY (playery             >>8)
      if (GameStatus != GAME_DYING) {
         for (u8 currbull = 0; currbull<100; currbull++) {
            if (bullets[currbull].flaction != 0) {
               if (((BY  )<=(PY+2)) &&
                   ((BY+1)>=(PY-2)) &&
                   ((BX  )<=(PX+3)) &&
                   ((BX+1)>=(PX-2))) {
                   GameStatus = GAME_DYING; 
                   AAS_MOD_Enhanced_Play(AAS_DATA_MOD_baTunnelEnd2);
               }
            }
         }
      }

#define STARTFRAMEDUST 110
#define FADEFRAMEDUST 30

//#define STARTFRAMEDUST 30
//#define FADEFRAMEDUST 10

#define FX (flangex)
#define FY (flangey)
      // Collide the player with the flange
      if (GameStatus != GAME_DYING) {
         if (gameflags == 2) {
            if (((FY-4)<=(PY+2)) &&
                ((FY+4)>=(PY-2)) &&
                ((FX-4)<=(PX+3)) &&
                ((FX+4)>=(PX-2))) {
               flangecoll++;
               AAS_SFX_Enhanced_Play(2, 40, 22000, AAS_DATA_SFX_START_beepcoll, AAS_DATA_SFX_END_beepcoll, AAS_NULL);//AAS_DATA_SFX_START_explos);
               u8 currdust = 0;
               for (u8 finddust = 1; finddust < 3; finddust++) {
                  if (flangedust[finddust].frameal < flangedust[currdust].frameal) {
                     currdust = finddust;
                  }
               }
               //while (currdust<3) {
                  //if (flangedust[currdust].frameal == 0) {
                     flangedust[currdust].frameal = STARTFRAMEDUST;//110;
                     flangedust[currdust].x = flangex;
                     flangedust[currdust].y = flangey;
                     //break;
                  //}
               //   currdust++;
               //}

#define GENEROSITY 10  //This number defines how far the flanges HAVE to be from the player.

               while ((((FY-9-GENEROSITY)<=(PY+2)) &&
                      ((FY+9+GENEROSITY)>=(PY-2)) &&
                      ((FX-9-GENEROSITY)<=(PX+3)) &&
                      ((FX+9+GENEROSITY)>=(PX-2)))) {
                  flangex = rng_rand(230)+5;
                  flangey = rng_rand(150)+5;
                  //flangex = flangecoll*10+10;
                  //flangey = 60;
               }
            }
         }
      }


      obj_counter = 0;
      aff_counter = 0;

   // PutPlayerInOAM
      oi_buffer[obj_counter].attr0 = (((playery-(2<<8)) >> 8) & 255);
      oi_buffer[obj_counter].attr1 = (((playerx-(2<<8)) >> 8) & 511);
      oi_buffer[obj_counter].attr2 = 579 | 13 << 12;
      obj_counter++;

   // PutTargetInOAM
   if (gameflags == 2) {
      u8 randjig = rng_rand(5);
      switch (randjig) {
         case 0:
            oi_buffer[obj_counter].attr0 = ((flangey-4) & 255);
            oi_buffer[obj_counter].attr1 = ((flangex-4) & 511);
         break;
         case 1:
            oi_buffer[obj_counter].attr0 = ((flangey-4-1) & 255);
            oi_buffer[obj_counter].attr1 = ((flangex-4) & 511);
         break;
         case 2:
            oi_buffer[obj_counter].attr0 = ((flangey-4) & 255);
            oi_buffer[obj_counter].attr1 = ((flangex-4-1) & 511);
         break;
         case 3:
            oi_buffer[obj_counter].attr0 = ((flangey-4+1) & 255);
            oi_buffer[obj_counter].attr1 = ((flangex-4) & 511);
         break;
         case 4:
            oi_buffer[obj_counter].attr0 = ((flangey-4) & 255);
            oi_buffer[obj_counter].attr1 = ((flangex-4+1) & 511);
         break;
      }
      oi_buffer[obj_counter].attr2 = 581 | 13 << 12;
      obj_counter++;
   }

   // PutScoreInfoInOAM?

   // PutBullsInOAM
      for (u8 currbull = 0; currbull<100; currbull++) {
         u16 f = bullets[currbull].flaction;
         if (bitset(f, B_ALIVE)) {
            if (obj_counter < 128) {
               if (bitset(f, B_DIAG)) {
                  if (bitset(f, B_DOWN)) {
                     if (bitset(f, B_LEFT)) {
                        oi_buffer[obj_counter].attr0 = (((bullets[currbull].yF-(5<<8)) >> 8) & 255);
                        oi_buffer[obj_counter].attr1 = (((bullets[currbull].xF-(5<<8)) >> 8) & 511) | bitC | bitD;
                        oi_buffer[obj_counter].attr2 = 576 | 0 << 10 | (bullets[currbull].palette) << 12;
                     } else {
                        oi_buffer[obj_counter].attr0 = (((bullets[currbull].yF-(5<<8)) >> 8) & 255);
                        oi_buffer[obj_counter].attr1 = (((bullets[currbull].xF-(3<<8)) >> 8) & 511) | bitD;
                        oi_buffer[obj_counter].attr2 = 576 | 0 << 10 | (bullets[currbull].palette) << 12;
                     }
                  } else {
                     if (bitset(f, B_LEFT)) {
                        oi_buffer[obj_counter].attr0 = (((bullets[currbull].yF-(3<<8)) >> 8) & 255);
                        oi_buffer[obj_counter].attr1 = (((bullets[currbull].xF-(5<<8)) >> 8) & 511) | bitC;
                        oi_buffer[obj_counter].attr2 = 576 | 0 << 10 | (bullets[currbull].palette) << 12;
                     } else {
                        oi_buffer[obj_counter].attr0 = (((bullets[currbull].yF-(3<<8)) >> 8) & 255);
                        oi_buffer[obj_counter].attr1 = (((bullets[currbull].xF-(3<<8)) >> 8) & 511);
                        oi_buffer[obj_counter].attr2 = 576 | 0 << 10 | (bullets[currbull].palette) << 12;
                     }
                  }
               } else {
                  if (bitset(f, B_VERT)) {
                     if (bitset(f, B_DOWN)) {
                        oi_buffer[obj_counter].attr0 = (((bullets[currbull].yF-(2<<8)) >> 8) & 255);
                        oi_buffer[obj_counter].attr1 = (((bullets[currbull].xF-(4<<8)) >> 8) & 511) | bitD;
                        oi_buffer[obj_counter].attr2 = 577 | 0 << 10 | (bullets[currbull].palette) << 12;
                     } else {
                        oi_buffer[obj_counter].attr0 = (((bullets[currbull].yF-(6<<8)) >> 8) & 255);
                        oi_buffer[obj_counter].attr1 = (((bullets[currbull].xF-(4<<8)) >> 8) & 511);
                        oi_buffer[obj_counter].attr2 = 577 | 0 << 10 | (bullets[currbull].palette) << 12;
                     }
                  } else {
                     if (bitset(f, B_LEFT)) {
                        oi_buffer[obj_counter].attr0 = (((bullets[currbull].yF-(4<<8)) >> 8) & 255);
                        oi_buffer[obj_counter].attr1 = (((bullets[currbull].xF-(2<<8)) >> 8) & 511) | bitC;
                        oi_buffer[obj_counter].attr2 = 578 | 0 << 10 | (bullets[currbull].palette) << 12;
                     } else {
                        oi_buffer[obj_counter].attr0 = (((bullets[currbull].yF-(4<<8)) >> 8) & 255);
                        oi_buffer[obj_counter].attr1 = (((bullets[currbull].xF-(6<<8)) >> 8) & 511);
                        oi_buffer[obj_counter].attr2 = 578 | 0 << 10 | (bullets[currbull].palette) << 12;
                     }
                  }
               }
            }
            obj_counter++;
         }
      }



//#define FIXPDIST 170
//#define FIXS2     0
//#define SPINSPDD 20

#define FIXPDIST 100
#define FIXS2     0
#define SPINSPDD 10

      for (u8 currdust = 0; currdust < 3; currdust++) {
         u8 e = flangedust[currdust].frameal;
         if (e != 0) {
            if (e>FADEFRAMEDUST) {
               if (obj_counter < 128) {
                  oi_buffer[obj_counter].attr0 = ((((((s32)slut_sin(e*SPINSPDD+000))*(FIXPDIST*(STARTFRAMEDUST-e)-FIXS2))>>16)        +(flangedust[currdust].y)-3) & 255);
                  oi_buffer[obj_counter].attr1 = ((((((s32)slut_cos(e*SPINSPDD+000))*(FIXPDIST*(STARTFRAMEDUST-e)-FIXS2))>>16)        +(flangedust[currdust].x)-3) & 511);
                  oi_buffer[obj_counter].attr2 = 582 | 0 << 10 | 13 << 12;
                  obj_counter++;
               }
              if (obj_counter < 128) {
                  oi_buffer[obj_counter].attr0 = ((((((s32)slut_sin(e*SPINSPDD+170))*(FIXPDIST*(STARTFRAMEDUST-e)-FIXS2))>>16)        +(flangedust[currdust].y)-3) & 255);
                  oi_buffer[obj_counter].attr1 = ((((((s32)slut_cos(e*SPINSPDD+170))*(FIXPDIST*(STARTFRAMEDUST-e)-FIXS2))>>16)        +(flangedust[currdust].x)-3) & 511);
                  oi_buffer[obj_counter].attr2 = 582 | 0 << 10 | 13 << 12;
                  obj_counter++;
               }
               if (obj_counter < 128) {
                  oi_buffer[obj_counter].attr0 = ((((((s32)slut_sin(e*SPINSPDD+341))*(FIXPDIST*(STARTFRAMEDUST-e)-FIXS2))>>16)        +(flangedust[currdust].y)-3) & 255);
                  oi_buffer[obj_counter].attr1 = ((((((s32)slut_cos(e*SPINSPDD+341))*(FIXPDIST*(STARTFRAMEDUST-e)-FIXS2))>>16)        +(flangedust[currdust].x)-3) & 511);
                  oi_buffer[obj_counter].attr2 = 582 | 0 << 10 | 13 << 12;
                  obj_counter++;
               }
            } else {
               if (obj_counter < 128) {
                  oi_buffer[obj_counter].attr0 = ((((((s32)slut_sin(e*SPINSPDD+000))*(FIXPDIST*(STARTFRAMEDUST-e)-FIXS2))>>16)        +(flangedust[currdust].y)-3) & 255);
                  oi_buffer[obj_counter].attr1 = ((((((s32)slut_cos(e*SPINSPDD+000))*(FIXPDIST*(STARTFRAMEDUST-e)-FIXS2))>>16)        +(flangedust[currdust].x)-3) & 511);
                  oi_buffer[obj_counter].attr2 = 583 | 0 << 10 | 13 << 12;
                  obj_counter++;
               }
              if (obj_counter < 128) {
                  oi_buffer[obj_counter].attr0 = ((((((s32)slut_sin(e*SPINSPDD+170))*(FIXPDIST*(STARTFRAMEDUST-e)-FIXS2))>>16)        +(flangedust[currdust].y)-3) & 255);
                  oi_buffer[obj_counter].attr1 = ((((((s32)slut_cos(e*SPINSPDD+170))*(FIXPDIST*(STARTFRAMEDUST-e)-FIXS2))>>16)        +(flangedust[currdust].x)-3) & 511);
                  oi_buffer[obj_counter].attr2 = 583 | 0 << 10 | 13 << 12;
                  obj_counter++;
               }
               if (obj_counter < 128) {
                  oi_buffer[obj_counter].attr0 = ((((((s32)slut_sin(e*SPINSPDD+341))*(FIXPDIST*(STARTFRAMEDUST-e)-FIXS2))>>16)        +(flangedust[currdust].y)-3) & 255);
                  oi_buffer[obj_counter].attr1 = ((((((s32)slut_cos(e*SPINSPDD+341))*(FIXPDIST*(STARTFRAMEDUST-e)-FIXS2))>>16)        +(flangedust[currdust].x)-3) & 511);
                  oi_buffer[obj_counter].attr2 = 583 | 0 << 10 | 13 << 12;
                  obj_counter++;
               }
            }
         }
      }

      #define FIXS 2421
      #define SCO 17
      #define SPINSPD 15

   // PutFragsInOAM
      for (u8 currex = 0; currex<30; currex++) {
         u16 e = explosions[currex].frameal;
         if (e > 0) {
            if (e > 345) {
               if (obj_counter < 128) {
                  oi_buffer[obj_counter].attr0 = ((((((s32)slut_sin(0-e*SPINSPD+000))*(SCO*e-FIXS))>>16)        +(explosions[currex].y)-4) & 255);
                  oi_buffer[obj_counter].attr1 = ((((((s32)slut_cos(0-e*SPINSPD+000))*(SCO*e-FIXS))>>16)        +(explosions[currex].x)-4) & 511);
                  oi_buffer[obj_counter].attr2 = 580 | 0 << 10 | 12 << 12;
                  obj_counter++;
               }
               if (obj_counter < 128) {
                  oi_buffer[obj_counter].attr0 = ((((((s32)slut_sin(0-e*SPINSPD+170))*(SCO*e-FIXS))>>16)        +(explosions[currex].y)-4) & 255);
                  oi_buffer[obj_counter].attr1 = ((((((s32)slut_cos(0-e*SPINSPD+170))*(SCO*e-FIXS))>>16)        +(explosions[currex].x)-4) & 511);
                  oi_buffer[obj_counter].attr2 = 580 | 0 << 10 | 12 << 12;
                  obj_counter++;
               }
               if (obj_counter < 128) {
                  oi_buffer[obj_counter].attr0 = ((((((s32)slut_sin(0-e*SPINSPD+341))*(SCO*e-FIXS))>>16)        +(explosions[currex].y)-4) & 255);
                  oi_buffer[obj_counter].attr1 = ((((((s32)slut_cos(0-e*SPINSPD+341))*(SCO*e-FIXS))>>16)        +(explosions[currex].x)-4) & 511);
                  oi_buffer[obj_counter].attr2 = 580 | 0 << 10 | 12 << 12;
                  obj_counter++;
               }
            } else if (e > 175) {
               if (obj_counter < 128) {
                  oi_buffer[obj_counter].attr0 = ((((((s32)slut_sin(0-e*SPINSPD+000))*(SCO*e-FIXS))>>16)        +(explosions[currex].y)-4) & 255);
                  oi_buffer[obj_counter].attr1 = ((((((s32)slut_cos(0-e*SPINSPD+000))*(SCO*e-FIXS))>>16)        +(explosions[currex].x)-4) & 511);
                  oi_buffer[obj_counter].attr2 = 580 | 0 << 10 | (explosions[currex].palette) << 12;
                  obj_counter++;
               }
               if (obj_counter < 128) {
                  oi_buffer[obj_counter].attr0 = ((((((s32)slut_sin(0-e*SPINSPD+170))*(SCO*e-FIXS))>>16)        +(explosions[currex].y)-4) & 255);
                  oi_buffer[obj_counter].attr1 = ((((((s32)slut_cos(0-e*SPINSPD+170))*(SCO*e-FIXS))>>16)        +(explosions[currex].x)-4) & 511);
                  oi_buffer[obj_counter].attr2 = 580 | 0 << 10 | (explosions[currex].palette) << 12;
                  obj_counter++;
               }
               if (obj_counter < 128) {
                  oi_buffer[obj_counter].attr0 = ((((((s32)slut_sin(0-e*SPINSPD+341))*(SCO*e-FIXS))>>16)        +(explosions[currex].y)-4) & 255);
                  oi_buffer[obj_counter].attr1 = ((((((s32)slut_cos(0-e*SPINSPD+341))*(SCO*e-FIXS))>>16)        +(explosions[currex].x)-4) & 511);
                  oi_buffer[obj_counter].attr2 = 580 | 0 << 10 | (explosions[currex].palette) << 12;
                  obj_counter++;
               }
            }
         }
      }

      for (u8 currex = 0; currex<30; currex++) {
         u16 e = explosions[currex].frameal;
         if (e > 0 && e < 176) {
            if (e > 10) {
               if (obj_counter < 128 && aff_counter < 32) {
                  oi_buffer[obj_counter].attr0 = ((explosions[currex].y-33) & 255) | bit8;
                  oi_buffer[obj_counter].attr1 = ((explosions[currex].x-33) & 511) | (aff_counter << 9) | bitE | bitF;
                  oi_buffer[obj_counter].attr2 = 512 | 0 << 10 | (explosions[currex].palette) << 12;
                  oa_rotscale(&oa_buffer[aff_counter], (explosions[currex].offset+STARROT[175-e])&511, RECIPSTARSCALE[175-e], RECIPSTARSCALE[175-e]);
                  obj_counter++;
                  aff_counter++;
               }
            } else {
               if (obj_counter < 128 && aff_counter < 32) {
                  oi_buffer[obj_counter].attr0 = ((explosions[currex].y-33) & 255) | bit8;
                  oi_buffer[obj_counter].attr1 = ((explosions[currex].x-33) & 511) | (aff_counter << 9) | bitE | bitF;
                  oi_buffer[obj_counter].attr2 = 512 | 0 << 10 | (12 << 12);
                  oa_rotscale(&oa_buffer[aff_counter], (explosions[currex].offset+STARROT[175-e])&511, RECIPSTARSCALE[175-e], RECIPSTARSCALE[175-e]);
                  obj_counter++;
                  aff_counter++;
               }
            }
         }
      }       


      //Clean up the rest of the OAM, if there's any of it left!
      for (u8 obj_emptier = obj_counter; obj_emptier < 128; obj_emptier++) {
         oi_buffer[obj_emptier].attr0 = 0;
         oi_buffer[obj_emptier].attr1 = 0;
         oi_buffer[obj_emptier].attr2 = 0;
      }

      // Copy our buffer to the real mem using AAS DoDMA3.
      cpy(&oi_buffer[0], (void *)MEM_OAM, 256);
      gametimeinVblanks++;

      /*
      Time for me to try and be a total smartass with the wavebuffer.
      */
      if (bitset(sfxflags, SCOPE_ON)) {
         const AAS_s8* soundbuffer1    = AAS_GetOutputBufferAddress(0);
         const AAS_s8* soundbuffer2    = AAS_GetOutputBufferAddress(1);

         for (u8 soundposition = 0; soundposition < 240; soundposition++) {
            bitmappos(soundposition, previouswave[soundposition]) = pal_bg_mem[0];
            s16 ploty = 80;
            if (&(soundbuffer1[0]) != AAS_NULL) ploty += soundbuffer1[soundposition+120]>>1;
            if (&(soundbuffer2[0]) != AAS_NULL) ploty += soundbuffer2[soundposition+120]>>1;
            ploty = ploty<1?1:(ploty>239?239:ploty);
            bitmappos(soundposition, ploty) = pal_bg_mem[1];
            previouswave[soundposition] = ploty;
         }
      }

      /* -
      End smartass.
      - */

      // Gravity is crap.
      if (bitset(cheatmodes, CHEAT_GRAVITY_ON)) {
         playerys += 75;
      }

      if (GameStatus == GAME_PLAY) {
         if (_key_down(KEY_START)) {
            GameStatus = GAME_PAUSEH;
            VSync();
            REG_BLDMOD = bit7 | bit6 | bit5 | bit4 | bit3 | bit2 | bit1 | bit0;
            REG_COLEY  = 11;
            AAS_MOD_Pause();
         }
      }
      if (GameStatus == GAME_PLAYH) {
         if (!_key_down(KEY_START)) {
            GameStatus = GAME_PLAY;
         }
      }

      } else if ((GameStatus == GAME_PAUSEH) || (GameStatus == GAME_PAUSE)) {
         VSync();
         if (GameStatus == GAME_PAUSEH) {
            if (!_key_down(KEY_START)) {
               GameStatus = GAME_PAUSE;
            }
         } else if (GameStatus == GAME_PAUSE) {
            if (_key_down(KEY_START)) {
               GameStatus = GAME_PLAYH;
               AAS_MOD_Resume();
               REG_BLDMOD = 0;
               REG_COLEY = 0;
            }
         }
      } else if (GameStatus == GAME_WHITE) {
      // SETUP THE GAME OVER. // SETUP THE GAME OVER. // SETUP THE GAME OVER. // SETUP THE GAME OVER.
         VSync();
         REG_DISPCNT = VID_BLANK;

         // You've got white, and you've got the whole OAM. Set up the game over screen.

         fadeframe = 16<<2;
         for (u8 obj_emptier = 0; obj_emptier < 128; obj_emptier++) {
            oi_buffer[obj_emptier].attr0 = 0;
            oi_buffer[obj_emptier].attr1 = 0;
            oi_buffer[obj_emptier].attr2 = 0;
         }
         cpy(&oi_buffer[0], (void *)MEM_OAM, 256);

         cpy((void *)gameovertilesData, (void *)&tl_mem[0][2], 6240);
         cpy((void *)retrytextData, (void *)&tl_mem[2][2], 896);

//#define settegel(t, x, y, i)    t[((x) + ((y)<<5))] = i

         //settegel(tegelset0,   0, 0, 780);
         //settegel(tegelset0, 1+0, 0, 780);
         //cpy((void *)&(tegelset0[0]),(void *)&(tegelset0[2]),511);
         for (u8 ytile = 4; ytile<4+13; ytile++) {
            for (u8 xtile = 0; xtile<30; xtile++) {
               settegel(tegelset0, xtile, ytile, xtile+(ytile-4)*30 + 1);
            }
         }
         bg_set_pos(&back0, 0, 4);
         bg_update(&back0);

         //settegel(tegelset1,   0, 0, 56);
         //settegel(tegelset1, 1+0, 0, 56);
         //cpy((void *)&(tegelset1[0]),(void *)&(tegelset1[2]),511);
         for (u8 ytile = 0; ytile<2; ytile++) {
            for (u8 xtile = 0; xtile<28; xtile++) {
               settegel(tegelset1, xtile, ytile, xtile+ytile*28 + 1);
            }
         }
         bg_set_pos(&back1, 0-9, 0-138);
         bg_update(&back1);

         bg_set_pos(&back2, 0, 80);
         bg_update(&back2);

         bg_set_pos(&back3, 0, 0-160);
         bg_update(&back3);

         gameoverinVblanks = 0;

         //gametimeinVblanks = 3600 * 10;

         //flangecoll=99;


         hundredscollected = (flangecoll-(flangecoll % 100)) / 100;
         if (hundredscollected == 0) {
            hundredscollected = 11;
            tenscollected = (flangecoll-(flangecoll % 10)) / 10;
            if (tenscollected == 0) tenscollected = 11;
         } else {
            tenscollected = ((flangecoll % 100)-(flangecoll%10)) / 10;
         }
         unitscollected = flangecoll % 10;

         //u16 s = gametimeinVblanks / 57;
         //u16 s = (gametimeinVblanks*2) / 115;//(2*57.5);
         s = (gametimeinVblanks*2) / 119;//(2*57.5);

         tensminspass = s / 600;
         if (tensminspass == 0) tensminspass = 11;
         unitsminspass = ((s/60) % 10);

         tenssecspass = ((s%60) - (s%10))/10;
         unitssecspass = s % 10;

         keydowngos = 0;

         GameStatus = GAME_GOS;
      } else if ((GameStatus == GAME_GOS)||(GameStatus == GAME_TOREST)||(GameStatus == GAME_TOMENU)) {

         VSync();
         if ((fadeframe == 16<<2) && (GameStatus == GAME_GOS)) {
            REG_DISPCNT = 0 | VID_BG0 | VID_OBJ | VID_LINEAR;
         }
         if ((fadeframe > 0) && (GameStatus == GAME_GOS)) {
            fadeframe -= 1;
            if (fadeframe == 0) {
               REG_BLDMOD = 0;
            } else {
               REG_BLDMOD = bit7 | bit5 | bit4 | bit3 | bit2 | bit1 | bit0;
               //REG_COLEY  = fadeframe;
               REG_COLEY = fadeframe>>2;
            }
         }

#define WIPESWOOSH 46

#define XWIPEFORMULA ((((s16)gameoverinVblanks*6) - 58) & 511)
#define YWIPE 80
         if (gameoverinVblanks < WIPESWOOSH) {
            oi_buffer[127].attr0 = YWIPE | bitE;
            oi_buffer[127].attr1 = XWIPEFORMULA | bitE | bitF;
            oi_buffer[127].attr2 = 668 | (14 << 12);
         } else {
            oi_buffer[127].attr1 = oi_buffer[127].attr1 = oi_buffer[127].attr2 = 0;
         }

//Times in Vblanks for the various elements to appear, if they appear at all.
#define WIPETARGET (6 +1)
#define WIPESCOREH (12+1)
#define WIPESCORET (14+1)
#define WIPESCOREU (16+1)

#define WIPETIME   (22+1)
#define WIPETIMETM (26+1)
#define WIPETIMEUM (29+1)
#define WIPETIMETS (33+1)
#define WIPETIMEUS (36+1)

         if (gameoverinVblanks >= WIPETARGET) {
            u8 randjig = rng_rand(5);

            oi_buffer[0].attr0 = 88;
            oi_buffer[0].attr1 = 20 | bitE;
            switch (randjig) {
               case 0:
               break;
               case 1:
                  oi_buffer[0].attr0--;
               break;
               case 2:
                  oi_buffer[0].attr1--;
               break;
               case 3:
                  oi_buffer[0].attr0++;
               break;
               case 4:
                  oi_buffer[0].attr1++;
               break;
            }

            oi_buffer[0].attr2 = 664 | (1 << 10) | (13 << 12);
         }// else {
         //   oi_buffer[0].attr0 = oi_buffer[0].attr1 = oi_buffer[0].attr2 = 0;
         //}

//#define XPOSSCORERES 60
#define XPOSSCORERES 55

         if (gameoverinVblanks == WIPESCOREH) {
            oi_buffer[1].attr0 = 80 | bitF;
            oi_buffer[1].attr1 = XPOSSCORERES | bitF;
            if (hundredscollected != 11) {
               oi_buffer[1].attr2 = 584 + (8*hundredscollected) | (1 << 10) | (13 << 12);
            } else {
               oi_buffer[1].attr2 = 1016 | (1 << 10) | (13 << 12);
            }
         }// else {
         //   oi_buffer[1].attr0 = oi_buffer[1].attr1 = oi_buffer[1].attr2 = 0;
         //}
         if (gameoverinVblanks == WIPESCORET) {
            oi_buffer[2].attr0 = 80 | bitF;
            oi_buffer[2].attr1 = XPOSSCORERES + 16 | bitF;
            if (tenscollected != 11) {
               oi_buffer[2].attr2 = 584 + (8*tenscollected) | (1 << 10) | (13 << 12);
            } else {
               oi_buffer[2].attr2 = 1016 | (1 << 10) | (13 << 12);
            }
         }// else {
         //   oi_buffer[2].attr0 = oi_buffer[2].attr1 = oi_buffer[2].attr2 = 0;
         //}
         if (gameoverinVblanks == WIPESCOREU) {
            oi_buffer[3].attr0 = 80 | bitF;
            oi_buffer[3].attr1 = XPOSSCORERES + 32 | bitF;
            oi_buffer[3].attr2 = 584 + (8*unitscollected) | (1 << 10) | (13 << 12);
         }// else {
         //   oi_buffer[3].attr0 = oi_buffer[3].attr1 = oi_buffer[3].attr2 = 0;
         //}

#define XPOSTIMERES 152

         if (gameoverinVblanks == WIPETIME) {
            oi_buffer[4].attr0 = 88;
            oi_buffer[4].attr1 = 126 | bitE;
            oi_buffer[4].attr2 = 700 | (1 << 10) | (13 << 12);
         }// else {
         //   oi_buffer[4].attr0 = oi_buffer[4].attr1 = oi_buffer[4].attr2 = 0;
         //}
         if (gameoverinVblanks == WIPETIMETM) {
            oi_buffer[5].attr0 = 80 | bitF;
            oi_buffer[5].attr1 = XPOSTIMERES | bitF;
            if (tensminspass != 11) {
               oi_buffer[5].attr2 = 584 + (8*tensminspass) | (1 << 10) | (13 << 12);
            } else {
               oi_buffer[5].attr2 = 1016 | (1 << 10) | (13 << 12);
            }
         }// else {
         //   oi_buffer[5].attr0 = oi_buffer[5].attr1 = oi_buffer[5].attr2 = 0;
         //}
         if (gameoverinVblanks == WIPETIMEUM) {
            oi_buffer[6].attr0 = 80 | bitF;
            oi_buffer[6].attr1 = XPOSTIMERES + 16 | bitF;
            if (unitsminspass != 11) {
               oi_buffer[6].attr2 = 584 + (8*unitsminspass) | (1 << 10) | (13 << 12);
            } else {
               oi_buffer[6].attr2 = 1016 | (1 << 10) | (13 << 12);
            }
         }// else {
         //   oi_buffer[6].attr0 = oi_buffer[6].attr1 = oi_buffer[6].attr2 = 0;
         //}
         if (gameoverinVblanks == WIPETIMETS) {
            oi_buffer[7].attr0 = 80 | bitF;
            oi_buffer[7].attr1 = XPOSTIMERES + 40 | bitF;
            if (tenssecspass != 11) {
               oi_buffer[7].attr2 = 584 + (8*tenssecspass) | (1 << 10) | (13 << 12);
            } else {
               oi_buffer[7].attr2 = 1016 | (1 << 10) | (13 << 12);
            }
         }// else {
         //   oi_buffer[7].attr0 = oi_buffer[7].attr1 = oi_buffer[7].attr2 = 0;
         //}
         if (gameoverinVblanks == WIPETIMEUS) {
            oi_buffer[8].attr0 = 80 | bitF;
            oi_buffer[8].attr1 = XPOSTIMERES + 56 | bitF;
            if (unitssecspass != 11) {
               oi_buffer[8].attr2 = 584 + (8*unitssecspass) | (1 << 10) | (13 << 12);
            } else {
               oi_buffer[8].attr2 = 1016 | (1 << 10) | (13 << 12);
            }
         }// else {
         //   oi_buffer[8].attr0 = oi_buffer[8].attr1 = oi_buffer[8].attr2 = 0;
         //}


         cpy(&oi_buffer[0], (void *)MEM_OAM, 256);

#define FADEBEGIN (160)
#define FADEEND   (FADEBEGIN+128)

         if (GameStatus == GAME_GOS) {
            if (gameoverinVblanks < FADEEND) {
               if (gameoverinVblanks == FADEBEGIN) {
                  REG_DISPCNT = 0 | VID_BG0 | VID_BG1 | VID_OBJ | VID_LINEAR;
               }
               if (gameoverinVblanks >= FADEBEGIN) {
                  REG_BLDMOD = bit7 | bit6 | bit1;
                  //REG_COLEY  = fadeframe;
                  REG_COLEY = 16-((gameoverinVblanks - FADEBEGIN)>>3);
               }
               gameoverinVblanks++;
               if (16-((gameoverinVblanks - FADEBEGIN)>>3) == 0) {
                  REG_BLDMOD = 0;
                  REG_COLEY = 0;
               }
            }
            //if (_key_down(KEY_SELECT)) GameStatus = GAME_LOST;

#define VBLANKSGOSWAIT 100
            // Game over screen controls. Such as the restart and things.
            if (gameoverinVblanks == VBLANKSGOSWAIT) {
               if (_key_down(KEY_B)) {
                  keydowngos |= KEY_B;
               }
               if (_key_down(KEY_START)) {
                  keydowngos |= KEY_START;
               }
            }
            if (gameoverinVblanks > VBLANKSGOSWAIT) {
               if (bitset(keydowngos, KEY_B)) {
                  if (_key_down(KEY_B)) {
                  } else {
                     keydowngos ^= KEY_B;
                  }
               } else {
                  if (_key_down(KEY_B)) {
                     // Key B can now be used.                     ----------------------------------------
                     //asm volatile ("swi 0x26");
                     GameStatus = GAME_TOREST;
                     fadeframe = 64;
                     REG_BLDMOD = bit7 | bit5 | bit4 | bit3 | bit2 | bit1 | bit0;
                  }
               }
               if (bitset(keydowngos, KEY_START)) {
                  if (_key_down(KEY_START)) {
                  } else {
                     keydowngos ^= KEY_START;
                  }
               } else {
                  if (_key_down(KEY_START)) {
                     // Key Start can now be used.                 ----------------------------------------
                     // asm volatile ("swi 0x26");
                     GameStatus = GAME_TOMENU;
                     fadeframe = 80;
                     REG_DISPCNT = 0 | VID_BG0 | VID_BG1 | VID_BG2 | VID_BG3 | VID_OBJ | VID_LINEAR;
                     //REG_BLDMOD = bit7 | bit6 | bit5 | bit4 | bit3 | bit2 | bit1 | bit0;
                     for (u8 curpix = 0; curpix < 32; curpix++) {
                        (*(u16 *)(0x060061c0 + curpix*2)) = (u16)((48<<8) + 48);    // Can only write to VRAM in 16 bit chunx.
                     }
                     pal_bg_mem[48] = 0;//0x7fff; //This is going to be the black for the cinema bars closing wipe. Okay? Good.
                     for (u8 curtegelx = 0; curtegelx < 30; curtegelx++) {
                        for (u8 curtegely = 0; curtegely < 10; curtegely++) {
                           settegel(tegelset2, curtegelx, curtegely, 391);
                        }
                     }
                  }
               }
            }
         }
         if ((fadeframe > 0) && (GameStatus == GAME_TOREST)) {
            fadeframe--;
            if (bitset(sfxflags, MUSIC_ON)) {
               AAS_MOD_SetVolume(fadeframe<<2);
            }
            if (fadeframe > 32) {
               REG_COLEY = 16-((fadeframe-32)>>1);
            }
            if (fadeframe == 32) {
               REG_DISPCNT = 0 | VID_BLANK | VID_BG0 | VID_BG1 | VID_LINEAR;
               GameStatus = GAME_REST;
               cpy((void *)&pal_bg_mem[127], (void *)&pal_bg_mem[0], 64);
               VSync();
               dont_optimize();
               VSync();
               RegisterHiscores(flangecoll, s);
            }
            if (fadeframe == 31) {
               REG_DISPCNT = 0 | VID_BG0 | VID_BG1 | VID_LINEAR;
            }
            if (fadeframe < 32) {
               REG_COLEY = (fadeframe>>1);
            }
            if (fadeframe == 0) {
               AAS_MOD_Stop();
               AAS_MOD_SetVolume(255);  //Thats the maximum!
               GameStatus = GAME_REST;
            }
         }
         if ((fadeframe > 0) && (GameStatus == GAME_TOMENU)) {
            fadeframe--;
            if (bitset(sfxflags, MUSIC_ON)) {
               AAS_MOD_SetVolume(fadeframe*3);
            }
            bg_set_pos(&back2, 0, fadeframe);
            bg_update(&back2);
            bg_set_pos(&back3, 0, (0-80)-fadeframe);
            bg_update(&back3);
            if (fadeframe == 0) {
               AAS_MOD_Stop();
               AAS_MOD_SetVolume(255);  //Thats the maximum!
               GameStatus = GAME_LOST;
               RegisterHiscores(flangecoll, s);
            }
         }

      }
   }
   return GameStatus;
}

void SetUpMathewCarr() {
   cpy ((void *)&mattpresentsPal[0], (void *)&pal_bg_mem[0], 128);
   cpy ((void *)&mattpresentsData[0], (void *)&tl_mem[0][0], 3840);  
}

void DoMathewCarr() {
   BGINFO back0;
   bg_init(&back0, 0, 0, 31, BG_REG_1X1 | BG_PAL256 | 3);
   TEGEL *tegelset0 = back0.map;
   bg_set_pos(&back0, 0, 0);
   bg_update(&back0);

   for (u16 curtile = 0; curtile < 1024; curtile++) {
      settegel(tegelset0, curtile, 0, 60);
   }

   settegelrun256(tegelset0, 14, 5, 0, 2);
   settegelrun256(tegelset0, 8, 6, 2, 22);
   settegelrun256(tegelset0, 8, 7, 24, 22);
   settegelrun256(tegelset0, 8, 8, 46, 22);
   settegelrun256(tegelset0, 0, 9, 68, 2);
   settegelrun256(tegelset0, 9, 9, 70, 6);
   settegelrun256(tegelset0, 0, 10, 76, 3);
   settegelrun256(tegelset0, 7, 10, 79, 7);
   settegelrun256(tegelset0, 0, 11, 86, 14);
   settegelrun256(tegelset0, 0, 12, 100, 13);
   settegelrun256(tegelset0, 0, 13, 113, 13);
   settegelrun256(tegelset0, 0, 14, 126, 13);
   settegelrun256(tegelset0, 0, 15, 139, 12);
   settegelrun256(tegelset0, 0, 16, 151, 12);
   settegelrun256(tegelset0, 0, 17, 163, 13);
   settegelrun256(tegelset0, 0, 18, 176, 14);
   settegelrun256(tegelset0, 0, 19, 190, 14);
   settegelrun256(tegelset0, 16, 18, 204, 14);
   settegelrun256(tegelset0, 16, 19, 218, 14);

   REG_COLEY   = 16;
   REG_BLDMOD  = bit7 | bit5 | bit4 | bit3 | bit2 | bit1 | bit0;
   REG_DISPCNT = 0 | VID_BG0;


   vu16 matttimeinVblanks = 0;

   //(*(u32 *)(0x03000200)) = (u32)&matttimeinVblanks;

#define MATTFADEINENDS 32
#define MATTSTAYLENGTH 128
#define MATTFADEOUTBEGINS (MATTFADEINENDS+MATTSTAYLENGTH)
#define MATTFADEOUTENDS (MATTFADEOUTBEGINS+32)

   while (matttimeinVblanks < MATTFADEOUTENDS) {
      VSync();             
      dont_optimize();
      if (matttimeinVblanks < MATTFADEINENDS) {
         REG_COLEY  = 17 - (matttimeinVblanks >> 1);
      } else if (matttimeinVblanks == MATTFADEINENDS) {
         REG_COLEY  = 0;
         REG_BLDMOD = 0;
      } else if (matttimeinVblanks >= MATTFADEOUTBEGINS) {
         REG_COLEY = ((matttimeinVblanks-MATTFADEOUTBEGINS) >> 1);
      }
      if (matttimeinVblanks == MATTFADEOUTBEGINS) {
         REG_BLDMOD  = bit7 | bit5 | bit4 | bit3 | bit2 | bit1 | bit0;
      }
      matttimeinVblanks += 1;
      //matttimeinVblanks += 2;
      //matttimeinVblanks -= 1;
      //matttimeinVblanks -= 1;
      //matttimeinVblanks += 10;
      //matttimeinVblanks += 12;
      //matttimeinVblanks -= 10;
      //matttimeinVblanks -= 12;
   }
   REG_DISPCNT = VID_BLANK;
   REG_BLDMOD = 0;
   REG_COLEY = 0;
}

void SetUpBlastArenaLetterSlamTitle() {
   cpy ((void *)&blastarenalettersPal[0], (void *)&pal_obj_mem[0], 8);
   cpy ((void *)&blastarenalettersData[0], (void *)&tl_mem[4][512], 2048);
   cpy ((void *)&advancehalvesPal[0], (void *)&pal_bg_mem[0], 8);
   cpy ((void *)&advancehalvesData[0], (void *)&tl_mem[0][1], 608);
}

void DoBlastArenaLetterSlamTitle() {

   vu16 titletimeinVblanks = 0;

   #define BAT_YPOS  ((18-32) & 255)
   #define BAT_XBASE ((26-16) & 511)

   #define BAT_XB1_POS   (BAT_XBASE+10)
   #define BAT_XL2_POS   (BAT_XBASE+22)
   #define BAT_XA3_POS   (BAT_XBASE+35)
   #define BAT_XS4_POS   (BAT_XBASE+51)
   #define BAT_XT5_POS   (BAT_XBASE+63)

   #define BAT_XA6_POS   (BAT_XBASE+84)
   #define BAT_XR7_POS   (BAT_XBASE+99)
   #define BAT_XE8_POS   (BAT_XBASE+113)
   #define BAT_XN9_POS   (BAT_XBASE+129)
   #define BAT_XA0_POS   (BAT_XBASE+146)

   #define BAT_L_TILENUM    (512+0*32)
   #define BAT_B_TILENUM    (512+1*32)
   #define BAT_A_TILENUM    (512+2*32)
   #define BAT_S_TILENUM    (512+3*32)
   #define BAT_T_TILENUM    (512+4*32)
   #define BAT_R_TILENUM    (512+5*32)
   #define BAT_E_TILENUM    (512+6*32)
   #define BAT_N_TILENUM    (512+7*32)

   #define BAT_DELAY 10
   #define BAT_LENGTH (82 + BAT_DELAY - 12)
   #define BAT_FADEBEGIN (BAT_LENGTH-16)
   
   #define BAT_ADVANCESPEED (6)
   #define BAT_YOFFSETOFFSET 2

   #define BAT_STARTTOAPPEAR 10

   #define BAT_B1_APPEAR (BAT_STARTTOAPPEAR+0*6)
   #define BAT_L2_APPEAR (BAT_STARTTOAPPEAR+1*6)
   #define BAT_A3_APPEAR (BAT_STARTTOAPPEAR+2*6)
   #define BAT_S4_APPEAR (BAT_STARTTOAPPEAR+3*6)
   #define BAT_T5_APPEAR (BAT_STARTTOAPPEAR+4*6)
   #define BAT_A6_APPEAR (BAT_STARTTOAPPEAR+5*6)
   #define BAT_R7_APPEAR (BAT_STARTTOAPPEAR+6*6)
   #define BAT_E8_APPEAR (BAT_STARTTOAPPEAR+7*6)
   #define BAT_N9_APPEAR (BAT_STARTTOAPPEAR+8*6)
   #define BAT_A0_APPEAR (BAT_STARTTOAPPEAR+9*6)

   #define BAT_B1_SETTLE (BAT_B1_APPEAR+16)
   #define BAT_L2_SETTLE (BAT_L2_APPEAR+16)
   #define BAT_A3_SETTLE (BAT_A3_APPEAR+16)
   #define BAT_S4_SETTLE (BAT_S4_APPEAR+16)
   #define BAT_T5_SETTLE (BAT_T5_APPEAR+16)
   #define BAT_A6_SETTLE (BAT_A6_APPEAR+16)
   #define BAT_R7_SETTLE (BAT_R7_APPEAR+16)
   #define BAT_E8_SETTLE (BAT_E8_APPEAR+16)
   #define BAT_N9_SETTLE (BAT_N9_APPEAR+16)
   #define BAT_A0_SETTLE (BAT_A0_APPEAR+16)

   #define BAT_ADVANCE_APPEAR (58 + BAT_DELAY)

   REG_DISPCNT = 0 | VID_LINEAR | VID_OBJ;

   BGINFO back0;
   bg_init(&back0, 0, 0, 30, BG_REG_1X1 | 0);
   TEGEL *tegelset0 = back0.map;
   bg_set_pos(&back0, 0, 0);
   bg_update(&back0);
   BGINFO back1;
   bg_init(&back1, 1, 0, 31, BG_REG_1X1 | 0);
   TEGEL *tegelset1 = back1.map;
   bg_set_pos(&back1, 0, 0);
   bg_update(&back1);
   
   REG_BG0HOFS = -46;
   REG_BG1HOFS = -46;

   for (u16 curtile = 0; curtile < 1024; curtile++) {
      settegel(tegelset0, curtile, 0, 0);
      settegel(tegelset1, curtile, 0, 0);
   }

   settegelrun(tegelset0, 0, 0,  1, 19);
   settegelrun(tegelset0, 0, 1, 20, 19);

   settegelrun(tegelset1, 0, 0, 39, 19);
   settegelrun(tegelset1, 0, 1, 58, 19);

   //#define BAT_SCALEFORMULA(ROG) (256+((titletimeinVblanks-(ROG))<<4))
   #define BAT_SCALEFORMULA(ROG) (128+3*((titletimeinVblanks-(ROG))<<3))

   #define BAT_LETTER(OBJNUM, GLYPH, CODE)  if (titletimeinVblanks == (BAT_##CODE##_APPEAR)) {                                                                     \
                                               oi_buffer[OBJNUM].attr0 = BAT_YPOS | bit9 | bit8 | bitF;                                                            \
                                               oi_buffer[OBJNUM].attr1 = (BAT_X##CODE##_POS) | (OBJNUM << 9) | bitE | bitF;                                        \
                                               oi_buffer[OBJNUM].attr2 = (BAT_##GLYPH##_TILENUM) | (1 << 10);                                                      \
                                            }                                                                                                                      \
                                            if (titletimeinVblanks == (BAT_##CODE##_SETTLE)) {                                                                     \
                                               oi_buffer[OBJNUM].attr0 = (BAT_YPOS + 32) | bit8 | bitF;                                                                   \
                                               oi_buffer[OBJNUM].attr1 = (BAT_X##CODE##_POS + 16) | (OBJNUM << 9) | bitE | bitF;                                        \
                                               oi_buffer[OBJNUM].attr2 = (BAT_##GLYPH##_TILENUM) | (1 << 10);                                                      \
                                            }                                                                                                                      \
                                            if (titletimeinVblanks <= (BAT_##CODE##_SETTLE)) {                                                                     \
                                               if (titletimeinVblanks >= (BAT_##CODE##_APPEAR)) {                                                                  \
                                                  oa_scale(&oa_buffer[OBJNUM], BAT_SCALEFORMULA(BAT_##CODE##_APPEAR), BAT_SCALEFORMULA(BAT_##CODE##_APPEAR));      \
                                               }                                                                                                                   \
                                            }                                                                                                                      \
                                            

      //(*(u32 *)(0x03000200)) = (u32)&titleinVblanks;
   while (titletimeinVblanks < BAT_LENGTH) {
      VSync();
      key_poll();
      BAT_LETTER(10, B, B1);
      BAT_LETTER( 9, L, L2);
      BAT_LETTER( 8, A, A3);
      BAT_LETTER( 7, S, S4);
      BAT_LETTER( 6, T, T5);
      BAT_LETTER( 5, A, A6);
      BAT_LETTER( 4, R, R7);
      BAT_LETTER( 3, E, E8);
      BAT_LETTER( 2, N, N9);
      BAT_LETTER( 1, A, A0);

      if (titletimeinVblanks == BAT_ADVANCE_APPEAR) {
         REG_DISPCNT |= VID_BG0 | VID_BG1;
      }
      if (titletimeinVblanks >= BAT_ADVANCE_APPEAR) {
         s16 yoffsetbg = BAT_YOFFSETOFFSET+BAT_ADVANCESPEED*(titletimeinVblanks - BAT_ADVANCE_APPEAR);
         REG_BG0VOFS = 0-(yoffsetbg);
         REG_BG1VOFS = 0-(147-yoffsetbg);
      }
      if (titletimeinVblanks == BAT_FADEBEGIN) {
         REG_BLDMOD  = bit7 | bit5 | bit4 | bit1 | bit0;
         REG_COLEY   = 0;
      }
      if (titletimeinVblanks > BAT_FADEBEGIN) {
         REG_COLEY   = (titletimeinVblanks - BAT_FADEBEGIN);
      }

      cpy(&oi_buffer[0], (void *)MEM_OAM, 256);
      titletimeinVblanks += 1;
   }

   REG_DISPCNT = VID_BLANK;
   REG_BLDMOD  = 0;
   REG_COLEY   = 0;
   for (u8 obj_emptier = 0; obj_emptier < 12; obj_emptier++) {
      oi_buffer[obj_emptier].attr0 = 0;
      oi_buffer[obj_emptier].attr1 = 0;
      oi_buffer[obj_emptier].attr2 = 0;
   }
   cpy(&oi_buffer[0], (void *)MEM_OAM, 256);
}

void BlastArenaTitleFadeAndManagePressStart() {
   cpy((void *)&blastarenatitlescreenPal[0], (void *)&pal_bg_mem[0], 128);
   cpy((void *)&blastarenatitlescreenData[0], (void *)MEM_VRAM, 9600);
   cpy((void *)&presstalettersPal[0], (void *)&pal_obj_mem[0], 8);
   cpy((void *)&presstalettersData[0], (void *)&tl_mem[5][0], 224);
   REG_DISPCNT = 4 | VID_LINEAR | VID_BG2 | VID_OBJ;
   REG_BLDMOD  = bit7 | bit5 | bit2;
   REG_COLEY   = 16;
   
   #define BAT_NOTHING 0     
   #define BAT_COLOUREDLEAVING 1
   #define BAT_LEAVING 2

   vu16 titlescreentimeinVblanks = 0;
   vu8  tscreenstat              = BAT_NOTHING;
   vu16 frameofleaving           = 0;

   #define BAPS_YPOS  ((117) & 255)
   #define BAPS_XBASE ((37) & 511)

   #define BAPS_XP1_POS   (BAPS_XBASE)
   #define BAPS_XR2_POS   (BAPS_XBASE+15)
   #define BAPS_XE3_POS   (BAPS_XBASE+30)
   #define BAPS_XS4_POS   (BAPS_XBASE+45)
   #define BAPS_XS5_POS   (BAPS_XBASE+60)

   #define BAPS_XS6_POS   (BAPS_XBASE+90)
   #define BAPS_XT7_POS   (BAPS_XBASE+105)
   #define BAPS_XA8_POS   (BAPS_XBASE+120)
   #define BAPS_XR9_POS   (BAPS_XBASE+135)
   #define BAPS_XT0_POS   (BAPS_XBASE+150)
   // THESE ONES LOOK FRIENDLIER.
   /*
   #define BAPS_XP1_POS   (BAPS_XBASE)
   #define BAPS_XR2_POS   (BAPS_XBASE+14)
   #define BAPS_XE3_POS   (BAPS_XBASE+28)
   #define BAPS_XS4_POS   (BAPS_XBASE+42)
   #define BAPS_XS5_POS   (BAPS_XBASE+56)

   #define BAPS_XS6_POS   (BAPS_XBASE+88)
   #define BAPS_XT7_POS   (BAPS_XBASE+102)
   #define BAPS_XA8_POS   (BAPS_XBASE+116)
   #define BAPS_XR9_POS   (BAPS_XBASE+130)
   #define BAPS_XT0_POS   (BAPS_XBASE+144)
   */// THESE ONES ARE MORE BUNCHED UP.
   #define BAPS_Pc_TILENUM    (512+0*4)
   #define BAPS_Rs_TILENUM    (512+1*4)
   #define BAPS_Es_TILENUM    (512+2*4)
   #define BAPS_Ss_TILENUM    (512+3*4)
   #define BAPS_Sc_TILENUM    (512+4*4)
   #define BAPS_Ts_TILENUM    (512+5*4)
   #define BAPS_As_TILENUM    (512+6*4)

   #define BAPS_STARTTOAPPEAR 148

   #define BAPS_P1_APPEAR (BAPS_STARTTOAPPEAR+ 0*5)
   #define BAPS_R2_APPEAR (BAPS_STARTTOAPPEAR+ 1*5)
   #define BAPS_E3_APPEAR (BAPS_STARTTOAPPEAR+ 2*5)
   #define BAPS_S4_APPEAR (BAPS_STARTTOAPPEAR+ 3*5)
   #define BAPS_S5_APPEAR (BAPS_STARTTOAPPEAR+ 4*5)
   #define BAPS_S6_APPEAR (BAPS_STARTTOAPPEAR+ 7*5)
   #define BAPS_T7_APPEAR (BAPS_STARTTOAPPEAR+ 8*5)
   #define BAPS_A8_APPEAR (BAPS_STARTTOAPPEAR+ 9*5)
   #define BAPS_R9_APPEAR (BAPS_STARTTOAPPEAR+10*5)
   #define BAPS_T0_APPEAR (BAPS_STARTTOAPPEAR+11*5)

   #define BAPS_LETTER(OBJNUM, LETTER, CODE) if (titlescreentimeinVblanks == (BAPS_##CODE##_APPEAR)) {    \
                                                oi_buffer[OBJNUM].attr0 = BAPS_YPOS;                      \
                                                oi_buffer[OBJNUM].attr1 = (BAPS_X##CODE##_POS) | bitE;    \
                                                oi_buffer[OBJNUM].attr2 = (BAPS_##LETTER##_TILENUM);      \
                                             }

   while (1) {
      VSync();
      dont_optimize();
      if (titlescreentimeinVblanks == 128) {
         REG_BLDMOD  = 0;
         REG_COLEY   = 0;
      }
      if (titlescreentimeinVblanks < 128) {
         REG_COLEY   = (128-titlescreentimeinVblanks) >> 3;
      } else {
         if (tscreenstat != BAT_NOTHING) {
            hfadeline += 3;
            // Now would be a good time to fade the sound.
            if (hfadeline > 87 && tscreenstat == BAT_COLOUREDLEAVING) {
               for (u16 pal_emptier = 0; pal_emptier < 256; pal_emptier++) {
                  pal_bg_mem[pal_emptier] = 0;
                  pal_obj_mem[pal_emptier] = 0;
                  tscreenstat = BAT_LEAVING;
               }
            }
            if (hfadeline > 89) break;
         } else {
            if (_key_down(KEY_START)) {
               tscreenstat = BAT_COLOUREDLEAVING;
               REG_IE |= INT_HBLANK;
               hfadeline = -8;
               HBlanksituation = HBLANK_BLASTARENATITLE;
            }
         }
      }
      BAPS_LETTER(0, Pc, P1);
      BAPS_LETTER(1, Rs, R2);
      BAPS_LETTER(2, Es, E3);
      BAPS_LETTER(3, Ss, S4);
      BAPS_LETTER(4, Ss, S5);
      BAPS_LETTER(5, Sc, S6);
      BAPS_LETTER(6, Ts, T7);
      BAPS_LETTER(7, As, A8);
      BAPS_LETTER(8, Rs, R9);
      BAPS_LETTER(9, Ts, T0);
      cpy(&oi_buffer[0], (void *)MEM_OAM, 256);
      titlescreentimeinVblanks++;
   }  
   HBlanksituation = HBLANK_NONE;
   for (u16 pal_emptier = 0; pal_emptier < 256; pal_emptier++) {
      pal_bg_mem[pal_emptier] = 0;
      pal_obj_mem[pal_emptier] = 0;
   }
   REG_BLDMOD  = bit7 | bit6 | bit5 | bit4 | bit3 | bit2 | bit1 | bit0;
   REG_COLEY   = 16;
   for (u8 obj_emptier = 0; obj_emptier < 12; obj_emptier++) {
      oi_buffer[obj_emptier].attr0 = 0;
      oi_buffer[obj_emptier].attr1 = 0;
      oi_buffer[obj_emptier].attr2 = 0;
   }
   cpy(&oi_buffer[0], (void *)MEM_OAM, 256);
   REG_IE &= ~INT_HBLANK;
}

void SetUpMainMenu() {
   //cpy((void *)&tl_mem[4][511], (void *)&tl_mem[0][0], 32);
   //cpy((void *)&tl_mem[4][0], (void *)&tl_mem[4][0], 8);
   
   u32 *blockempty = (u32*)(&tl_mem[0][0]);
   
   for (u8 zeroer = 0; zeroer < 16; zeroer++) {
      blockempty[zeroer] = 0;
   }

   cpy((void *)finalbarsData  ,  (void *)&tl_mem[0][2] , 816);
   cpy((void *)finalbarsPal   ,  (void *)&pal_bg_mem[0], 41);
                                                              
   cpy((void *)whitelineData  ,  (void *)&tl_mem[0][104], 8);
   cpy((void *)blanklineData  ,  (void *)&tl_mem[4][125], 32);

   cpy((void *)menulettersData,  (void *)&tl_mem[4][1], 992);
   cpy((void *)menulettersPal ,  (void *)&pal_obj_mem[0], 16);

   if (cheatmodes != 0) {
      for (u8 palettereplace = 0; palettereplace < 28; palettereplace++) {
         pal_bg_mem[2+palettereplace] = _xRGB15(0, palettereplace+4, palettereplace+4);
      }

      for (u8 palettereplace = 0; palettereplace < 32; palettereplace++) {
         pal_bg_mem[29+palettereplace] = _xRGB15(palettereplace, 31, 31);
      }

      for (u8 palettereplace = 0; palettereplace < 19; palettereplace++) {
         pal_bg_mem[61+palettereplace] = _xRGB15(palettereplace, 22, 22);
      }
   }

   pal_obj_mem[33] = pal_bg_mem[2];
}

#define MENU_CHOSEGAME    1
#define MENU_CHOSENAME    2
#define MENU_CHOSEHISCORE 3
#define MENU_CHOSECREDITS 4

#define MENUMUSIC AAS_MOD_Enhanced_Play(AAS_DATA_MOD_btlemend);

int MainMenu() {
   REG_BLDMOD  = bit7 | bit6 | bit5 | bit4 | bit3 | bit2 | bit1 | bit0;
   REG_COLEY   = 16;
   if (!bitset(sfxflags, MENU_ON)) MENUMUSIC;
   BGINFO back0;
   bg_init(&back0, 0, 0, 30, BG_REG_1X1 | BG_PAL256 | 1);
   TEGEL *tegelset0 = back0.map;
   bg_set_pos(&back0, 6, 2);
   bg_update(&back0);

   for (u16 xtile = 0; xtile < 1024; xtile++) {
      settegel(tegelset0, xtile, 0, 0);
   }

   settegelrun(tegelset0, 0, 0, 1+17*0, 17);
   settegelrun(tegelset0, 0, 1, 1+17*1, 17);
   settegelrun(tegelset0, 0, 2, 1+17*2, 17);
   settegelrun(tegelset0, 0, 3, 1+17*0, 17);
   settegelrun(tegelset0, 0, 4, 1+17*1, 17);
   settegelrun(tegelset0, 0, 5, 1+17*2, 17);
   settegelrun(tegelset0, 0, 6, 1+17*0, 17);
   settegelrun(tegelset0, 0, 7, 1+17*1, 17);
   settegelrun(tegelset0, 0, 8, 1+17*2, 17);
   settegelrun(tegelset0, 0, 9, 1+17*0, 17);
   settegelrun(tegelset0, 0,10, 1+17*1, 17);
   settegelrun(tegelset0, 0,11, 1+17*2, 17);
   settegelrun(tegelset0, 0,12, 1+17*0, 17);
   settegelrun(tegelset0, 0,13, 1+17*1, 17);
   settegelrun(tegelset0, 0,14, 1+17*2, 17);
   settegelrun(tegelset0, 0,15, 1+17*0, 17);
   settegelrun(tegelset0, 0,16, 1+17*1, 17);
   settegelrun(tegelset0, 0,17, 1+17*2, 17);
   settegelrun(tegelset0, 0,18, 1+17*0, 17);
   settegelrun(tegelset0, 0,19, 1+17*1, 17);
   settegelrun(tegelset0, 0,20, 1+17*2, 17);

   BGINFO back1;
   bg_init(&back1, 1, 0, 31, BG_REG_1X1 | 2);
   TEGEL *tegelset1 = back1.map;
   bg_set_pos(&back1, 6, 0);
   bg_update(&back1);

   for (u16 xtile = 0; xtile < 1024; xtile++) {
      settegel(tegelset1, xtile, 0, 0);
   }

   for (u8 ytile = 0; ytile < 20; ytile++) {
      settegel(tegelset1, 17, ytile, 104);
   }

#define MENU_YBASE   36

#define MENU_YPOS_1  (MENU_YBASE)
#define MENU_YPOS_2  (MENU_YBASE + 14)
#define MENU_YPOS_3  (MENU_YBASE + 28)
#define MENU_YPOS_4  (MENU_YBASE + 42)
#define MENU_YPOS_5  (MENU_YBASE + 56)
#define MENU_YPOS_6  (MENU_YBASE + 70)
#define MENU_YPOS_7  (MENU_YBASE + 84)

#define MENU_SPRITE_TILE_START1            1
#define MENU_SPRITE_TILE_START2            9
#define MENU_SPRITE_TILE_START3           17

#define MENU_SPRITE_TILE_HISCORES1        21
#define MENU_SPRITE_TILE_HISCORES2        29

#define MENU_SPRITE_TILE_SOUND1        37
#define MENU_SPRITE_TILE_SOUND2        45

#define MENU_SPRITE_TILE_MUSIC1        49
#define MENU_SPRITE_TILE_MUSIC2        57

#define MENU_SPRITE_TILE_SCOPE1        61
#define MENU_SPRITE_TILE_SCOPE2        69

#define MENU_SPRITE_TILE_ENTERNAME1        73
#define MENU_SPRITE_TILE_ENTERNAME2        81
#define MENU_SPRITE_TILE_ENTERNAME3        89

#define MENU_SPRITE_TILE_CREDITS1        93
#define MENU_SPRITE_TILE_CREDITS2        101

#define MENU_SPRITE_TILE_OFF       109
#define MENU_SPRITE_TILE_ON        117

#define MENU_LINE_TILE_BLANX    125

#define MENU_SPRITE_XR1(xcord, onoff) oi_buffer[127].attr0 = MENU_YPOS_1 | bitE;                          \
                                         oi_buffer[127].attr1 = xcord | bitF;                                \
                                         oi_buffer[127].attr2 = MENU_SPRITE_TILE_START1 | 3 << 10 | (onoff << 12); \
                                         oi_buffer[126].attr0 = MENU_YPOS_1 | bitE;                          \
                                         oi_buffer[126].attr1 = xcord + 32 | bitF;                           \
                                         oi_buffer[126].attr2 = MENU_SPRITE_TILE_START2 | 3 << 10 | (onoff << 12); \
                                         oi_buffer[125].attr0 = MENU_YPOS_1;                                 \
                                         oi_buffer[125].attr1 = xcord + 64 | bitE;                           \
                                         oi_buffer[125].attr2 = MENU_SPRITE_TILE_START3 | 3 << 10 | (onoff << 12);

#define MENU_SPRITE_XR2(xcord, onoff) oi_buffer[124].attr0 = MENU_YPOS_2 | bitE;                          \
                                         oi_buffer[124].attr1 = xcord | bitF;                                \
                                         oi_buffer[124].attr2 = MENU_SPRITE_TILE_HISCORES1 | 3 << 10 | (onoff << 12); \
                                         oi_buffer[123].attr0 = MENU_YPOS_2 | bitE;                          \
                                         oi_buffer[123].attr1 = xcord + 32 | bitF;                           \
                                         oi_buffer[123].attr2 = MENU_SPRITE_TILE_HISCORES2 | 3 << 10 | (onoff << 12);

#define MENU_SPRITE_XR3(xcord, onoff, status) oi_buffer[122].attr0 = MENU_YPOS_3 | bitE;                          \
                                                 oi_buffer[122].attr1 = xcord | bitF;                                \
                                                 oi_buffer[122].attr2 = MENU_SPRITE_TILE_SOUND1 | 3 << 10 | (onoff << 12); \
                                                 oi_buffer[121].attr0 = MENU_YPOS_3 ;                          \
                                                 oi_buffer[121].attr1 = xcord + 32 | bitE;                           \
                                                 oi_buffer[121].attr2 = MENU_SPRITE_TILE_SOUND2 | 3 << 10 | (onoff << 12); \
                                                 oi_buffer[120].attr0 = MENU_YPOS_3 | bitE;                          \
                                                 oi_buffer[120].attr1 = xcord + 48 | bitF;                                \
                                                 oi_buffer[120].attr2 = ((status == 1) ? MENU_SPRITE_TILE_ON : MENU_SPRITE_TILE_OFF) | 3 << 10 | (onoff << 12); \

#define MENU_SPRITE_XR4(xcord, onoff, status) oi_buffer[119].attr0 = MENU_YPOS_4 | bitE;                          \
                                                 oi_buffer[119].attr1 = xcord | bitF;                                \
                                                 oi_buffer[119].attr2 = MENU_SPRITE_TILE_MUSIC1 | 3 << 10 | (onoff << 12); \
                                                 oi_buffer[118].attr0 = MENU_YPOS_4 ;                          \
                                                 oi_buffer[118].attr1 = xcord + 32 | bitE;                           \
                                                 oi_buffer[118].attr2 = MENU_SPRITE_TILE_MUSIC2 | 3 << 10 | (onoff << 12); \
                                                 oi_buffer[117].attr0 = MENU_YPOS_4 | bitE;                          \
                                                 oi_buffer[117].attr1 = xcord + 48 | bitF;                                \
                                                 oi_buffer[117].attr2 = ((status == 1) ? MENU_SPRITE_TILE_ON : MENU_SPRITE_TILE_OFF) | 3 << 10 | (onoff << 12); \

#define MENU_SPRITE_XR5(xcord, onoff, status) oi_buffer[116].attr0 = MENU_YPOS_5 | bitE;                          \
                                                 oi_buffer[116].attr1 = xcord | bitF;                                \
                                                 oi_buffer[116].attr2 = MENU_SPRITE_TILE_SCOPE1 | 3 << 10 | (onoff << 12); \
                                                 oi_buffer[115].attr0 = MENU_YPOS_5 ;                          \
                                                 oi_buffer[115].attr1 = xcord + 32 | bitE;                           \
                                                 oi_buffer[115].attr2 = MENU_SPRITE_TILE_SCOPE2 | 3 << 10 | (onoff << 12); \
                                                 oi_buffer[114].attr0 = MENU_YPOS_5 | bitE;                          \
                                                 oi_buffer[114].attr1 = xcord + 48 | bitF;                                \
                                                 oi_buffer[114].attr2 = ((status == 1) ? MENU_SPRITE_TILE_ON : MENU_SPRITE_TILE_OFF) | 3 << 10 | (onoff << 12); \

#define MENU_SPRITE_XR6(xcord, onoff) oi_buffer[113].attr0 = MENU_YPOS_6 | bitE;                          \
                                         oi_buffer[113].attr1 = xcord | bitF;                                \
                                         oi_buffer[113].attr2 = MENU_SPRITE_TILE_ENTERNAME1 | 3 << 10 | (onoff << 12); \
                                         oi_buffer[112].attr0 = MENU_YPOS_6 | bitE;                          \
                                         oi_buffer[112].attr1 = xcord + 32 | bitF;                           \
                                         oi_buffer[112].attr2 = MENU_SPRITE_TILE_ENTERNAME2 | 3 << 10 | (onoff << 12); \
                                         oi_buffer[111].attr0 = MENU_YPOS_6;                                 \
                                         oi_buffer[111].attr1 = xcord + 64 | bitE;                           \
                                         oi_buffer[111].attr2 = MENU_SPRITE_TILE_ENTERNAME3 | 3 << 10 | (onoff << 12);

#define MENU_SPRITE_XR7(xcord, onoff) oi_buffer[110].attr0 = MENU_YPOS_7 | bitE;                          \
                                         oi_buffer[110].attr1 = xcord | bitF;                                \
                                         oi_buffer[110].attr2 = MENU_SPRITE_TILE_CREDITS1 | 3 << 10 | (onoff << 12); \
                                         oi_buffer[109].attr0 = MENU_YPOS_7 | bitE;                          \
                                         oi_buffer[109].attr1 = xcord + 32 | bitF;                           \
                                         oi_buffer[109].attr2 = MENU_SPRITE_TILE_CREDITS2 | 3 << 10 | (onoff << 12);

   //MENU_SPRITE_XMOVE1(135);
   //MENU_SPRITE_XMOVE2(135);
   //MENU_SPRITE_XMOVE3(135);
   //MENU_SPRITE_XMOVE4(135);
   //MENU_SPRITE_XMOVE5(135);
   //MENU_SPRITE_XMOVE6(135);

#define MENU_SPRITE_XMOVE1(xcord) MENU_SPRITE_XR1(xcord, 1)
#define MENU_SPRITE_XMOVE2(xcord) MENU_SPRITE_XR2(xcord, 0)
#define MENU_SPRITE_XMOVE3(xcord) MENU_SPRITE_XR3(xcord, 0, (bitset(sfxflags, SOUND_ON) ? 1 : 0))
#define MENU_SPRITE_XMOVE4(xcord) MENU_SPRITE_XR4(xcord, 0, (bitset(sfxflags, MUSIC_ON) ? 1 : 0))
#define MENU_SPRITE_XMOVE5(xcord) MENU_SPRITE_XR5(xcord, 0, (bitset(sfxflags, SCOPE_ON) ? 1 : 0))
#define MENU_SPRITE_XMOVE6(xcord) MENU_SPRITE_XR6(xcord, 0)
#define MENU_SPRITE_XMOVE7(xcord) MENU_SPRITE_XR7(xcord, 0)

   //MENU_SPRITE_XR1(135,1);
   //MENU_SPRITE_XR2(135,0);
   //MENU_SPRITE_XR3(135,0,1);
   //MENU_SPRITE_XR4(135,0,1);
   //MENU_SPRITE_XR5(135,0);
   //MENU_SPRITE_XR6(135,0);
   
#define MENU_SPRITE_TOUCH1(one)       MENU_SPRITE_XR1(135, one)
#define MENU_SPRITE_TOUCH2(one)       MENU_SPRITE_XR2(135, one)
#define MENU_SPRITE_TOUCH3(one,two)   MENU_SPRITE_XR3(135, one, two)
#define MENU_SPRITE_TOUCH4(one,two)   MENU_SPRITE_XR4(135, one, two)
#define MENU_SPRITE_TOUCH5(one,two)   MENU_SPRITE_XR5(135, one, two)
#define MENU_SPRITE_TOUCH6(one)       MENU_SPRITE_XR6(135, one)
#define MENU_SPRITE_TOUCH7(one)       MENU_SPRITE_XR7(135, one)

#define MENU_STOPMOVE 20

#define MENU_TIMESTEPBETWEEN 4

#define MENU_STOPMOVE_START      (MENU_STOPMOVE + (0*MENU_TIMESTEPBETWEEN))
#define MENU_STOPMOVE_HISCORE    (MENU_STOPMOVE + (1*MENU_TIMESTEPBETWEEN))
#define MENU_STOPMOVE_SOUND      (MENU_STOPMOVE + (2*MENU_TIMESTEPBETWEEN))
#define MENU_STOPMOVE_MUSIC      (MENU_STOPMOVE + (3*MENU_TIMESTEPBETWEEN))
#define MENU_STOPMOVE_SCOPE      (MENU_STOPMOVE + (4*MENU_TIMESTEPBETWEEN))
#define MENU_STOPMOVE_ENTERNAME  (MENU_STOPMOVE + (5*MENU_TIMESTEPBETWEEN))
#define MENU_STOPMOVE_CREDITS    (MENU_STOPMOVE + (6*MENU_TIMESTEPBETWEEN))

#define MENU_STARTMOVE_START      (MENU_STOPMOVE_START     - 20)
#define MENU_STARTMOVE_HISCORE    (MENU_STOPMOVE_HISCORE   - 20)
#define MENU_STARTMOVE_SOUND      (MENU_STOPMOVE_SOUND     - 20)
#define MENU_STARTMOVE_MUSIC      (MENU_STOPMOVE_MUSIC     - 20)
#define MENU_STARTMOVE_SCOPE      (MENU_STOPMOVE_SCOPE     - 20)
#define MENU_STARTMOVE_ENTERNAME  (MENU_STOPMOVE_ENTERNAME - 20)
#define MENU_STARTMOVE_CREDITS    (MENU_STOPMOVE_CREDITS   - 20)

#define MENU_MOTIONMACRO(item, number)  if ((menutimeinVblanks > MENU_STARTMOVE_##item) && (menutimeinVblanks <= MENU_STOPMOVE_##item)) {  \
                                   MENU_SPRITE_XMOVE##number(35 + 5*(menutimeinVblanks-MENU_STARTMOVE_##item));                        \
                                }


#define MENU_FADEENDS 32

#define MENUFRAMESTOUPDATE 2

   u8  curframeupdate    = MENUFRAMESTOUPDATE-1;
   u32 menutimeinVblanks = 0;
   u32 menutimefadebase  = 0;

   u8  cursormenu = 0;
   
#define MENU_STATUS_NONE               0
#define MENU_STATUS_CLEARTOGAME        1
#define MENU_STATUS_CLEAREDTOGAME      2
#define MENU_STATUS_CLEARTOHISCORES    3
#define MENU_STATUS_CLEAREDTOHISCORES  4
#define MENU_STATUS_CLEARTONAMEENTRY   5
#define MENU_STATUS_CLEAREDTONAMEENTRY 6
#define MENU_STATUS_CLEARTOCREDITS     7
#define MENU_STATUS_CLEAREDTOCREDITS   8

   u8 MENUSTATUS = MENU_STATUS_NONE;

#define SWITCH_OFF_ON_MENU_MUSIC if (bitset(sfxflags, MUSIC_ON)) {         \
                                    MENUMUSIC;                         \
                                 } else {                                  \
                                    AAS_MOD_Stop();                         \
                                 }

   REG_DISPCNT = 0 | VID_BG0 | VID_BG1 | VID_OBJ | VID_LINEAR;
   cpy(&oi_buffer[0], (void *)MEM_OAM, 256);
   while ( ((MENUSTATUS == MENU_STATUS_NONE)
         || (MENUSTATUS == MENU_STATUS_CLEARTOGAME)
         || (MENUSTATUS == MENU_STATUS_CLEARTOHISCORES)
         || (MENUSTATUS == MENU_STATUS_CLEARTONAMEENTRY)
         || (MENUSTATUS == MENU_STATUS_CLEARTOCREDITS))) {
      VSync();
      key_poll();
      menutimeinVblanks++;

      if (menutimeinVblanks < MENU_FADEENDS) {
         REG_COLEY = 17 - (menutimeinVblanks >> 1);
      } else if (menutimeinVblanks == MENU_FADEENDS) {
         REG_BLDMOD = 0;
         REG_COLEY = 0;
      }

      if (MENUSTATUS == MENU_STATUS_CLEARTOGAME) {
         REG_COLEY = ((menutimeinVblanks - menutimefadebase));
         if ((menutimeinVblanks - menutimefadebase) > 16) {
            MENUSTATUS = MENU_STATUS_CLEAREDTOGAME;
            REG_DISPCNT = VID_BLANK;
            for (u8 obj_emptier = 0; obj_emptier < 128; obj_emptier++) {
               oi_buffer[obj_emptier].attr0 = 0;
               oi_buffer[obj_emptier].attr1 = 0;
               oi_buffer[obj_emptier].attr2 = 0;
            }                     
            cpy(&oi_buffer[0], (void *)MEM_OAM, 256);
            VSync();
         }
      }

      if (MENUSTATUS == MENU_STATUS_CLEARTOHISCORES) {
         REG_COLEY = ((menutimeinVblanks - menutimefadebase));
         if ((menutimeinVblanks - menutimefadebase) > 16) {
            MENUSTATUS = MENU_STATUS_CLEAREDTOHISCORES;
            REG_DISPCNT = 0;
            for (u8 obj_emptier = 0; obj_emptier < 128; obj_emptier++) {
               oi_buffer[obj_emptier].attr0 = 0;
               oi_buffer[obj_emptier].attr1 = 0;
               oi_buffer[obj_emptier].attr2 = 0;
            }
            cpy(&oi_buffer[0], (void *)MEM_OAM, 256);
            VSync();
         }
      }
      
      if (MENUSTATUS == MENU_STATUS_CLEARTONAMEENTRY) {
         REG_COLEY = ((menutimeinVblanks - menutimefadebase));
         if ((menutimeinVblanks - menutimefadebase) > 16) {
            MENUSTATUS = MENU_STATUS_CLEAREDTONAMEENTRY;
            REG_DISPCNT = 0;
            for (u8 obj_emptier = 0; obj_emptier < 128; obj_emptier++) {
               oi_buffer[obj_emptier].attr0 = 0;
               oi_buffer[obj_emptier].attr1 = 0;
               oi_buffer[obj_emptier].attr2 = 0;
            }
            cpy(&oi_buffer[0], (void *)MEM_OAM, 256);
            VSync();
         }
      }

      if ((menutimeinVblanks > MENU_FADEENDS) && (MENUSTATUS == MENU_STATUS_NONE)) {
         u8 oldcursor = cursormenu;
         if (key_hit(KEY_DOWN) && !key_hit(KEY_UP)) {
            cursormenu = (cursormenu==6) ? 6 : cursormenu + 1;
         }
         if (key_hit(KEY_UP) && !key_hit(KEY_DOWN)) {
            cursormenu = (cursormenu==0) ? 0 : cursormenu - 1;
         }
         if (((REG_P1 == 0x3fe) && (key_hit(KEY_A))) || ((REG_P1 == 0x3f7) && (key_hit(KEY_START)))) {
            if (cursormenu == 0) {
               MENUSTATUS = MENU_STATUS_CLEARTOGAME;
               menutimefadebase = menutimeinVblanks;
               REG_BLDMOD  = bit7 | bit5 | bit4 | bit3 | bit2 | bit1 | bit0;
            } else if (cursormenu == 1) {
               MENUSTATUS = MENU_STATUS_CLEARTOHISCORES;
               menutimefadebase = menutimeinVblanks;          
               REG_BLDMOD  = bit7 | bit6 | bit5 | bit4 | bit3 | bit2 | bit1 | bit0;
            } else if (cursormenu == 2) {
               sfxflags ^= SOUND_ON;
               MENU_SPRITE_TOUCH3(1, (bitset(sfxflags, SOUND_ON) ? 1 : 0))
            } else if (cursormenu == 3) {
               sfxflags ^= MUSIC_ON;
               MENU_SPRITE_TOUCH4(1, (bitset(sfxflags, MUSIC_ON) ? 1 : 0))
               SWITCH_OFF_ON_MENU_MUSIC;
            } else if (cursormenu == 4) {
               sfxflags ^= SCOPE_ON;
               MENU_SPRITE_TOUCH5(1, (bitset(sfxflags, SCOPE_ON) ? 1 : 0))
            } else if (cursormenu == 5) {
               MENUSTATUS = MENU_STATUS_CLEARTONAMEENTRY;
               menutimefadebase = menutimeinVblanks;          
               REG_BLDMOD  = bit7 | bit6 | bit5 | bit4 | bit3 | bit2 | bit1 | bit0;
            }
         }
         if (((REG_P1 == 0x3df) || (REG_P1 == 0x3ef)) &&
               ((key_hit(KEY_LEFT) && !key_hit(KEY_RIGHT)) || (!key_hit(KEY_LEFT) && key_hit(KEY_RIGHT)))) {
             if (cursormenu == 2) {
               sfxflags ^= SOUND_ON;
               MENU_SPRITE_TOUCH3(1, (bitset(sfxflags, SOUND_ON) ? 1 : 0))
            } else if (cursormenu == 3) {
               sfxflags ^= MUSIC_ON;
               MENU_SPRITE_TOUCH4(1, (bitset(sfxflags, MUSIC_ON) ? 1 : 0))
               SWITCH_OFF_ON_MENU_MUSIC;
            } else if (cursormenu == 4) {
               sfxflags ^= SCOPE_ON;
               MENU_SPRITE_TOUCH5(1, (bitset(sfxflags, SCOPE_ON) ? 1 : 0))
            }
         }
         if (cursormenu != oldcursor) {
            switch (oldcursor) {
               case 0:
                  MENU_SPRITE_TOUCH1(0)
               break;
               case 1:
                  MENU_SPRITE_TOUCH2(0)
               break;
               case 2:
                  MENU_SPRITE_TOUCH3(0, (bitset(sfxflags, SOUND_ON) ? 1 : 0))
               break;
               case 3:
                  MENU_SPRITE_TOUCH4(0, (bitset(sfxflags, MUSIC_ON) ? 1 : 0))
               break;         
               case 4:
                  MENU_SPRITE_TOUCH5(0, (bitset(sfxflags, SCOPE_ON) ? 1 : 0))
               break;
               case 5:
                  MENU_SPRITE_TOUCH6(0)
               break;
               case 6:
                  MENU_SPRITE_TOUCH7(0)
               break;
            }
            switch (cursormenu) {
               case 0:
                  MENU_SPRITE_TOUCH1(1)
               break;
               case 1:
                  MENU_SPRITE_TOUCH2(1)
               break;
               case 2:
                  MENU_SPRITE_TOUCH3(1, (bitset(sfxflags, SOUND_ON) ? 1 : 0))
               break;
               case 3:
                  MENU_SPRITE_TOUCH4(1, (bitset(sfxflags, MUSIC_ON) ? 1 : 0))
               break;
               case 4:
                  MENU_SPRITE_TOUCH5(1, (bitset(sfxflags, SCOPE_ON) ? 1 : 0))
               break;
               case 5:
                  MENU_SPRITE_TOUCH6(1)
               break;
               case 6:
                  MENU_SPRITE_TOUCH7(1)
               break;
            }
         }
      }

      MENU_MOTIONMACRO(START,     1);
      MENU_MOTIONMACRO(HISCORE,   2);
      MENU_MOTIONMACRO(SOUND,     3);
      MENU_MOTIONMACRO(MUSIC,     4);
      MENU_MOTIONMACRO(SCOPE,     5);
      MENU_MOTIONMACRO(ENTERNAME, 6);
      MENU_MOTIONMACRO(CREDITS,   7);

      //if (_key_down(KEY_START)) return MENU_CHOSEGAME;


      curframeupdate++;
      
      //curframeupdate = 0;
      if (curframeupdate == MENUFRAMESTOUPDATE) {
         u8 curspriteused = 0;
         for (u8 curmaskline = 0; curmaskline < 27; curmaskline++) {
            const AAS_s8* soundbuffer1    = AAS_GetOutputBufferAddress(0);
            const AAS_s8* soundbuffer2    = AAS_GetOutputBufferAddress(1);
            s16 ploty = 0;
            if (&(soundbuffer1[0]) != AAS_NULL) ploty += soundbuffer1[curmaskline*16];
            if (&(soundbuffer2[0]) != AAS_NULL) ploty += soundbuffer2[curmaskline*16];
            ploty = ploty<0?0-ploty:ploty;
            // PLOTY is a number between 0 and 128 which represents the length of the bar.
            s16 used = (128 - (ploty<<1));
            if (used > 32) {
               oi_buffer[curspriteused].attr0 = ((curmaskline*6-1) & 0xFF) | bitE;
               oi_buffer[curspriteused].attr1 = 0 | bitE;
               oi_buffer[curspriteused].attr2 = MENU_LINE_TILE_BLANX | 1 << 10 | 2 << 12;
               curspriteused++;
               if (used > 64) {
                  oi_buffer[curspriteused].attr0 = ((curmaskline*6-1) & 0xFF) | bitE;
                  oi_buffer[curspriteused].attr1 = 32 | bitE;
                  oi_buffer[curspriteused].attr2 = MENU_LINE_TILE_BLANX | 1 << 10 | 2 << 12;
                  curspriteused++;
                  if (used > 96) {
                     oi_buffer[curspriteused].attr0 = ((curmaskline*6-1) & 0xFF) | bitE;
                     oi_buffer[curspriteused].attr1 = 64 | bitE;
                     oi_buffer[curspriteused].attr2 = MENU_LINE_TILE_BLANX | 1 << 10 | 2 << 12;
                     curspriteused++;
                     oi_buffer[curspriteused].attr0 = ((curmaskline*6-1) & 0xFF) | bitE;
                     oi_buffer[curspriteused].attr1 = ((used - 32) & 0x1FF)| bitE;
                     oi_buffer[curspriteused].attr2 = MENU_LINE_TILE_BLANX | 1 << 10 | 2 << 12;
                     curspriteused++;
                  } else {
                     oi_buffer[curspriteused].attr0 = ((curmaskline*6-1) & 0xFF) | bitE;
                     oi_buffer[curspriteused].attr1 = ((used - 32) & 0x1FF)| bitE;
                     oi_buffer[curspriteused].attr2 = MENU_LINE_TILE_BLANX | 1 << 10 | 2 << 12;
                     curspriteused++;
                  }
               } else {
                  oi_buffer[curspriteused].attr0 = ((curmaskline*6-1) & 0xFF) | bitE;
                  oi_buffer[curspriteused].attr1 = ((used - 32) & 0x1FF)| bitE;
                  oi_buffer[curspriteused].attr2 = MENU_LINE_TILE_BLANX | 1 << 10 | 2 << 12;
                  curspriteused++;
               }
            } else {
               oi_buffer[curspriteused].attr0 = ((curmaskline*6-1) & 0xFF) | bitE;
               oi_buffer[curspriteused].attr1 = ((used - 32) & 0x1FF)| bitE;
               oi_buffer[curspriteused].attr2 = MENU_LINE_TILE_BLANX | 1 << 10 | 2 << 12;
               curspriteused++;
            }
         }
         curframeupdate = 0;          
         for (u8 obj_emptier = curspriteused; obj_emptier < 109; obj_emptier++) {
            oi_buffer[obj_emptier].attr0 = 0;
            oi_buffer[obj_emptier].attr1 = 0;
            oi_buffer[obj_emptier].attr2 = 0;
         }
      }
      cpy(&oi_buffer[0], (void *)MEM_OAM, 256);
   }
   
   if (MENUSTATUS == MENU_STATUS_CLEAREDTOGAME) {
      return MENU_CHOSEGAME;
   }
   if (MENUSTATUS == MENU_STATUS_CLEAREDTOHISCORES) {
      return MENU_CHOSEHISCORE;
   }
   if (MENUSTATUS == MENU_STATUS_CLEAREDTONAMEENTRY) {
      return MENU_CHOSENAME;
   }
   if (MENUSTATUS == MENU_STATUS_CLEAREDTOCREDITS) {
      return MENU_CHOSECREDITS;
   }
}

void SetUpHiscores() {                          
   for (u8 obj_emptier = 0; obj_emptier < 128; obj_emptier++) {
      oi_buffer[obj_emptier].attr0 = 0;
      oi_buffer[obj_emptier].attr1 = 0;
      oi_buffer[obj_emptier].attr2 = 0;
      *(u8 *)(0x06010000 + obj_emptier) = 0;
   }
   cpy(&oi_buffer[0], (void *)MEM_OAM, 256);


   cpy((void *)BGbackgData, (void *)&tl_mem[0][0], 9280);
   cpy((void *)BGbackgPal , (void *)&pal_bg_mem[0], 128);

   cpy((void *)BGspritesData, (void *)&tl_mem[4][2], 5120);
   cpy((void *)BGspritesPal , (void *)&pal_obj_mem[0], 112);
                                                 
   cpy((void *)texttilesData, (void *)&tl_mem[1][648], 728);

   cpy((void *)hiarrowData, (void *)&tl_mem[1][732], 16);

   cpy((void *)hiscoretextsData, (void *)&tl_mem[4][642], 416);
                                                                  
   for (u8 palfill = 0; palfill < 9; palfill++) {
      pal_obj_mem[0xe0+palfill] = pal_bg_mem[     palfill];
      pal_obj_mem[0xf0+palfill] = pal_bg_mem[0x20+palfill];
   }
   //cpy((void *)menulettersData,  (void *)&tl_mem[4][1], 992);
}

u32 tempcolor = 0;
s8 redtemp = 0;  s8 bluetemp = 0;  s8 greentemp = 0;

#define darkencolour(pallete, palentry, amount) tempcolor = pal_##pallete##_mem[palentry];                                 \
                                                redtemp   = (((tempcolor & 0x001f) >>  0) - amount);                         \
                                                greentemp = (((tempcolor & 0x03e0) >>  5) - amount);                         \
                                                bluetemp  = (((tempcolor & 0x7c00) >> 10) - amount);                         \
                                                pal_##pallete##_mem[palentry] = _xRGB15(((redtemp   < 0) ? 0 :   redtemp),  \
                                                                                        ((greentemp < 0) ? 0 : greentemp),  \
                                                                                        ((bluetemp  < 0) ? 0 :  bluetemp));

#define darkencolour2s(pallete, palentry, amount) tempcolor = pal_##pallete##_mem[palentry];                                 \
                                                pal_##pallete##_mem[palentry] = _xRGB15((((tempcolor & 0x001f) < (amount <<  0)) ? 0 : (((tempcolor & 0x001f) >>  0) - amount)),  \
                                                                                        (((tempcolor & 0x03e0) < (amount <<  5)) ? 0 : (((tempcolor & 0x03e0) >>  5) - amount)),  \
                                                                                        (((tempcolor & 0x7c00) < (amount << 10)) ? 0 : (((tempcolor & 0x7c00) >> 10) - amount)));

#define darkenhiscorespal(amount) for (u8 palentry = 9; palentry < 16; palentry++) {darkencolour(bg,     palentry, amount);   \
                                                                                    darkencolour(bg,0x10+palentry, amount);   \
                                                                                    darkencolour(bg,0x20+palentry, amount);}  \
                                for (u16 palentry = 0; palentry < 432; palentry++) {darkencolour(bg,0x30+palentry, amount);} \
                                                                                    darkencolour(bg,0, amount);               \
                                                                                    darkencolour(bg,16, amount);              \
                                                                                    darkencolour(bg,32, amount);

#define darkenhiscorespax(amount) for (u8 palentry = 9; palentry < 16; palentry++) {darkencolour(bg,     palentry, amount);   \
                                                                                    darkencolour(bg,0x10+palentry, amount);   \
                                                                                    darkencolour(bg,0x20+palentry, amount);}  \
                                for (u16 palentry = 0; palentry < 432; palentry++) {darkencolour(bg,0x30+palentry, amount);} \
                                                                                    darkencolour(bg,0, amount);               \
                                                                                    darkencolour(bg,16, amount);              \
                                                                                    darkencolour(bg,32, amount);

#define hiscorebrightness2(amount) cpy((void *)BGbackgPal , (void *)&pal_bg_mem[0], 128); cpy((void *)BGspritesPal , (void *)&pal_obj_mem[0], 112); darkenhiscorespal((31-amount));

#define hiscorebrightness(amount) cpy((void *)&hiscoretemppal[(31-amount)] , (void *)&pal_bg_mem[0], 256);

typedef struct tagPalPair {
   u16  color[512];
} PALPAIR;       // this is 1024 bytes big, yeah!


#define HI_PAL_RED    (0 << 12)
#define HI_PAL_YELLOW (1 << 12)
#define HI_PAL_BLUE   (2 << 12)

#define HI_TILE_NUB     643
#define HI_TILE_BEST3   644
#define HI_TILE_BEST2   652
#define HI_TILE_BEST1   656

#define HI_TILE_SCORES3 658
#define HI_TILE_SCORES2 666
#define HI_TILE_SCORES1 674

#define HI_TILE_TIMES3  678
#define HI_TILE_TIMES2  686
#define HI_TILE_TIMES1  690

#define HI_TILE_DOT     692

void fillhiscoremapblock(bool bestscores, TEGEL* s1, TEGEL* s2);

void Hiscores() {         
   REG_DISPCNT = 0;
   BGINFO back0;
   bg_init(&back0, 0, 0, 31, BG_REG_1X1 | BG_PAL256 | 3);
   TEGEL *tegelset0 = back0.map;
   bg_set_pos(&back0, 0-136, 0);
   bg_update(&back0);

   BGINFO back1;
   bg_init(&back1, 1, 1, 30, BG_REG_1X1 | 2);
   TEGEL *tegelset1 = back1.map;
   bg_set_pos(&back1, 4, 2);
   bg_update(&back1);

   BGINFO back2;
   bg_init(&back2, 2, 1, 29, BG_REG_1X1 | 2);
   TEGEL *tegelset2 = back2.map;
   bg_set_pos(&back2, 4, 6);
   bg_update(&back2);

   //BGINFO back3;
   //bg_init(&back3, 3, 1, 28, BG_REG_1X1 | 2);
   //TEGEL *tegelset3 = back3.map;
   //bg_set_pos(&back3, 0, 0);
   //bg_update(&back3);

   PALPAIR hiscoretemppal[22];

   for (u8 curpal = 0; curpal < 22; curpal++) {
      hiscorebrightness2((31-curpal));
      for (u16 curcol = 0; curcol < 512; curcol++) {
         hiscoretemppal[curpal].color[curcol] = pal_bg_mem[curcol];
      }
      hiscoretemppal[curpal].color[0] = 0;
   }

   hiscorebrightness(31);

   // Let's tegelise the two 'halves'

   for (u16 xtile = 0; xtile < 1024; xtile++) {
      settegel(tegelset0, xtile, 0, 0);
      settegel(tegelset1, xtile, 0, TX_sp);
      settegel(tegelset2, xtile, 0, TX_sp);
      //settegel(tegelset3, xtile, 0, TX_sp);
   }

   for (u8 ytile = 0; ytile < 20; ytile++) {
      settegelrun(tegelset0, 0,    ytile,     ytile*29, 29);
      //settegelrun(tegelset0, 0, 32+ytile, 640+ytile*13, 13);
   }
   
#define HI_BS_Y 13
#define HI_BT_Y 1

#define HI_BESTSCORES_SPRITES(xp, yp) oi_buffer[112].attr0 = bitF | ((yp+48) & 255);              \
                                      oi_buffer[112].attr1 = bitD | bitC | bitF | ((xp) & 511);           \
                                      oi_buffer[112].attr2 = (14 << 12) | HI_TILE_SCORES3;     \
                                                                                               \
                                      oi_buffer[113].attr0 = bitF | ((yp+16) & 255);           \
                                      oi_buffer[113].attr1 = bitD | bitC | bitF | ((xp) & 511);           \
                                      oi_buffer[113].attr2 = (14 << 12) | HI_TILE_SCORES2;     \
                                                                                               \
                                      oi_buffer[114].attr0 = ((yp) & 255);                  \
                                      oi_buffer[114].attr1 = bitD | bitC | bitE | ((xp) & 511);           \
                                      oi_buffer[114].attr2 = (14 << 12) | HI_TILE_SCORES1;     \
                                                                                               \
                                      oi_buffer[117].attr0 = bitF | ((yp+ 22 +HI_BS_Y) & 255);           \
                                      oi_buffer[117].attr1 = bitD | bitC | bitF | ((xp+19) & 511);           \
                                      oi_buffer[117].attr2 = (14 << 12) | HI_TILE_BEST3;       \
                                                                                               \
                                      oi_buffer[118].attr0 = ((yp + 7 + HI_BS_Y) & 255);             \
                                      oi_buffer[118].attr1 = bitD | bitC | bitE | ((xp+19) & 511);              \
                                      oi_buffer[118].attr2 = (14 << 12) | HI_TILE_BEST2;       \
                                                                                               \
                                      oi_buffer[119].attr0 = bitE | ((yp + HI_BS_Y - 1) & 255);      \
                                      oi_buffer[119].attr1 = bitD | bitC | ((xp+19) & 511);                     \
                                      oi_buffer[119].attr2 = (14 << 12) | HI_TILE_BEST1;       \
                                                                                               \
                                      oi_buffer[115].attr0 = ((yp + 36 + HI_BS_Y) & 255);             \
                                      oi_buffer[115].attr1 = bitD | bitC | ((xp + 12+19) & 511);                 \
                                      oi_buffer[115].attr2 = (14 << 12) | HI_TILE_NUB;         \
                                                                                               \
                                      oi_buffer[116].attr0 = ((yp + HI_BS_Y - 2) & 255);             \
                                      oi_buffer[116].attr1 = bitD | bitC | ((xp + 12+19) & 511);                 \
                                      oi_buffer[116].attr2 = (14 << 12) | HI_TILE_NUB;         \
                                                                                               \
                                      oi_buffer[111].attr0 = oi_buffer[111].attr1 = oi_buffer[111].attr2 = 0;           \
                                                                     \
                                      oi_buffer[110].attr0 = oi_buffer[110].attr1 = oi_buffer[110].attr2 = 0;           \


#define HI_BESTTIMES_SPRITES(xp, yp)  oi_buffer[112].attr0 = bitF | ((yp) & 255);              \
                                      oi_buffer[112].attr1 = bitF | ((xp+19) & 511);           \
                                      oi_buffer[112].attr2 = (15 << 12) | HI_TILE_TIMES3;     \
                                                                                               \
                                      oi_buffer[113].attr0 = ((yp+32) & 255);           \
                                      oi_buffer[113].attr1 = bitE | ((xp+19) & 511);           \
                                      oi_buffer[113].attr2 = (15 << 12) | HI_TILE_TIMES2;     \
                                                                                               \
                                      oi_buffer[114].attr0 = bitE | ((yp+48) & 255);                  \
                                      oi_buffer[114].attr1 = ((xp+19) & 511);           \
                                      oi_buffer[114].attr2 = (15 << 12) | HI_TILE_TIMES1;     \
                                                                                               \
                                      oi_buffer[111].attr0 = ((yp+48+5-14) & 255);                  \
                                      oi_buffer[111].attr1 = ((xp+19-4) & 511);           \
                                      oi_buffer[111].attr2 = (15 << 12) | HI_TILE_DOT;     \
                                                                                               \
                                      oi_buffer[110].attr0 = ((yp + 52) & 255);             \
                                      oi_buffer[110].attr1 = ((xp +19 - 4) & 511);                 \
                                      oi_buffer[110].attr2 = (15 << 12) | HI_TILE_NUB;         \
                                                                                               \
                                      oi_buffer[117].attr0 = bitF | ((yp +HI_BT_Y) & 255);           \
                                      oi_buffer[117].attr1 = bitF | ((xp) & 511);           \
                                      oi_buffer[117].attr2 = (15 << 12) | HI_TILE_BEST3;       \
                                                                                               \
                                      oi_buffer[118].attr0 = ((yp + 32 + HI_BT_Y) & 255);             \
                                      oi_buffer[118].attr1 = bitE | ((xp) & 511);              \
                                      oi_buffer[118].attr2 = (15 << 12) | HI_TILE_BEST2;       \
                                                                                               \
                                      oi_buffer[119].attr0 = bitE | ((yp + HI_BT_Y + 48) & 255);      \
                                      oi_buffer[119].attr1 = ((xp) & 511);                     \
                                      oi_buffer[119].attr2 = (15 << 12) | HI_TILE_BEST1;       \
                                                                                               \
                                      oi_buffer[115].attr0 = ((yp + 10 + HI_BT_Y) & 255);             \
                                      oi_buffer[115].attr1 = ((xp - 4) & 511);                 \
                                      oi_buffer[115].attr2 = (15 << 12) | HI_TILE_NUB;         \
                                                                                               \
                                      oi_buffer[116].attr0 = ((yp + HI_BT_Y +49) & 255);             \
                                      oi_buffer[116].attr1 = ((xp -4) & 511);                 \
                                      oi_buffer[116].attr2 = (15 << 12) | HI_TILE_NUB;         \

#define HI_NOTITSPR      oi_buffer[119].attr0 = oi_buffer[119].attr1 = oi_buffer[119].attr2 = 0;      \
                         oi_buffer[118].attr0 = oi_buffer[118].attr1 = oi_buffer[118].attr2 = 0;      \
                         oi_buffer[117].attr0 = oi_buffer[117].attr1 = oi_buffer[117].attr2 = 0;      \
                         oi_buffer[116].attr0 = oi_buffer[116].attr1 = oi_buffer[116].attr2 = 0;      \
                         oi_buffer[115].attr0 = oi_buffer[115].attr1 = oi_buffer[115].attr2 = 0;      \
                         oi_buffer[114].attr0 = oi_buffer[114].attr1 = oi_buffer[114].attr2 = 0;      \
                         oi_buffer[113].attr0 = oi_buffer[113].attr1 = oi_buffer[113].attr2 = 0;      \
                         oi_buffer[112].attr0 = oi_buffer[112].attr1 = oi_buffer[112].attr2 = 0;      \
                         oi_buffer[111].attr0 = oi_buffer[111].attr1 = oi_buffer[111].attr2 = 0;      \
                         oi_buffer[110].attr0 = oi_buffer[110].attr1 = oi_buffer[110].attr2 = 0;



#define HISCORE_SPRITE_SETUP(xcord)  oi_buffer[127].attr0 = bitD | 0;                  \
                                     oi_buffer[127].attr1 = bitF | bitE | 0 + xcord;   \
                                     oi_buffer[127].attr2 = 3 << 10 | 2;               \
                                                                                       \
                                     oi_buffer[126].attr0 = bitD | 0;                  \
                                     oi_buffer[126].attr1 = bitF | bitE | 64 + xcord;  \
                                     oi_buffer[126].attr2 = 3 << 10 | 130;             \
                                                                                       \
                                     oi_buffer[125].attr0 = bitD | 64;                 \
                                     oi_buffer[125].attr1 = bitF | bitE | 0 + xcord;   \
                                     oi_buffer[125].attr2 = 3 << 10 | 258;             \
                                                                                       \
                                     oi_buffer[124].attr0 = bitD | 64;                 \
                                     oi_buffer[124].attr1 = bitF | bitE | 64 + xcord;  \
                                     oi_buffer[124].attr2 = 3 << 10 | 386;             \
                                                                                       \
                                     oi_buffer[123].attr0 = bitD | 128;                \
                                     oi_buffer[123].attr1 = bitF | 0 + xcord;          \
                                     oi_buffer[123].attr2 = 3 << 10 | 514;             \
                                                                                       \
                                     oi_buffer[122].attr0 = bitD | 128;                \
                                     oi_buffer[122].attr1 = bitF | 32 + xcord;         \
                                     oi_buffer[122].attr2 = 3 << 10 | 546;             \
                                                                                       \
                                     oi_buffer[121].attr0 = bitD | 128;                \
                                     oi_buffer[121].attr1 = bitF | 64 + xcord;         \
                                     oi_buffer[121].attr2 = 3 << 10 | 578;             \
                                                                                       \
                                     oi_buffer[120].attr0 = bitD | 128;                \
                                     oi_buffer[120].attr1 = bitF | 96 + xcord;         \
                                     oi_buffer[120].attr2 = 3 << 10 | 610;


#define HISCORE_SPRITE(xcord)        if (( 0+xcord) > 240) { oi_buffer[127].attr0 |= bit9; } else { oi_buffer[127].attr0 &= 65023; } \
                                     oi_buffer[127].attr1 = bitF | bitE | ((0 + xcord) & 511);   \
                                                                                       \
                                     if ((64+xcord) > 240) { oi_buffer[126].attr0 |= bit9; } else { oi_buffer[126].attr0 &= 65023; } \
                                     oi_buffer[126].attr1 = bitF | bitE | ((64 + xcord) & 511);  \
                                                                                       \
                                     if (( 0+xcord) > 240) { oi_buffer[125].attr0 |= bit9; } else { oi_buffer[125].attr0 &= 65023; } \
                                     oi_buffer[125].attr1 = bitF | bitE | ((0 + xcord) & 511);   \
                                                                                       \
                                     if ((64+xcord) > 240) { oi_buffer[124].attr0 |= bit9; } else { oi_buffer[124].attr0 &= 65023; } \
                                     oi_buffer[124].attr1 = bitF | bitE | ((64 + xcord) & 511);  \
                                                                                       \
                                     if (( 0+xcord) > 240) { oi_buffer[123].attr0 |= bit9; } else { oi_buffer[123].attr0 &= 65023; } \
                                     oi_buffer[123].attr1 = bitF | ((0 + xcord) & 511);          \
                                                                                       \
                                     if ((32+xcord) > 240) { oi_buffer[122].attr0 |= bit9; } else { oi_buffer[122].attr0 &= 65023; } \
                                     oi_buffer[122].attr1 = bitF | ((32 + xcord) & 511);         \
                                                                                       \
                                     if ((64+xcord) > 240) { oi_buffer[121].attr0 |= bit9; } else { oi_buffer[121].attr0 &= 65023; } \
                                     oi_buffer[121].attr1 = bitF | ((64 + xcord) & 511);         \
                                                                                       \
                                     if ((96+xcord) > 240) { oi_buffer[120].attr0 |= bit9; } else { oi_buffer[120].attr0 &= 65023; } \
                                     oi_buffer[120].attr1 = bitF | ((96 + xcord) & 511);

   HISCORE_SPRITE_SETUP(0);

   #define HI_DEFY_BS 40
   #define HI_DEFY_BT 52

   //HI_BESTTIMES_SPRITES(120, 18);

   cpy(&oi_buffer[0], (void *)MEM_OAM, 256);

#define HISCORE_CAMERA(x) bg_set_pos(&back0, (x), 0); bg_update(&back0); HISCORE_SPRITE((232-(x)));

   HISCORE_CAMERA(0);

   //DoDefaultHiscores();     // TEMPORARY TEMPORARY TEMPORARY TEMPORARY TEMPORARY TEMPORARY TEMPORARY TEMPORARY

   //fillhiscoremapblock(false, tegelset1, tegelset2);

#define HISCORE_OPENINGRIGHTSLIDE   1
#define HISCORE_RIGHTHANDCLOSING    2
#define HISCORE_RIGHTHANDSTEADY     3
#define HISCORE_RIGHTHANDOPENING    4
#define HISCORE_RIGHTTOLEFTSLIDE    5
#define HISCORE_LEFTHANDCLOSING     6
#define HISCORE_LEFTHANDSTEADY      7
#define HISCORE_LEFTHANDOPENING     8
#define HISCORE_LEFTTORIGHTSLIDE    9
#define HISCORE_DYING              10
#define HISCORE_ALLDONE            11

   u8  hiscorestatus        = HISCORE_OPENINGRIGHTSLIDE; // FOR ABOVE 'STUFF'

   //u8  hiscorefadeflickerbeater = 0;
   u8  animationframe       = 0;

   REG_DISPCNT = 0 | VID_BG0 | VID_OBJ | VID_LINEAR;
   //REG_BLDMOD = REG_COLEY = 0;

   HISCORE_CAMERA(0);
   REG_IE |= INT_HBLANK;

   HI_NOTITSPR;

   while (hiscorestatus != HISCORE_ALLDONE) {
      VSync();
      key_poll();
      if (hiscorestatus == HISCORE_OPENINGRIGHTSLIDE) {
         if (animationframe == 0) REG_BLDMOD = REG_COLEY = 0;
         REG_BLDMOD = bit7 | bit6 | bit5 | bit4 | bit3 | bit2 | bit1 | bit0;
         REG_COLEY  = 16-(animationframe >> 1);
         animationframe++;
         //HISCORE_CAMERA(hislideData[animationframe]);
         HISCORE_CAMERA(hislideData[animationframe-1]);
         //funk_hiscorebrightness(animationframe);
         cpy(&oi_buffer[0], (void *)MEM_OAM, 256);
         if (animationframe == 30) {
            animationframe = 0;
            hiscorestatus = HISCORE_RIGHTHANDCLOSING;
            REG_DISPCNT = 0 | VID_BG0 | VID_BG1 | VID_BG2 | VID_OBJ | VID_LINEAR;
            fillhiscoremapblock(true, tegelset1, tegelset2);
            HBlanksituation = HBLANK_HISCORE1;
            hfadeline = 0;
            //hiscorebrightness(20);
         }
      } else if (hiscorestatus == HISCORE_RIGHTHANDCLOSING) {  
         animationframe++;
         HI_BESTSCORES_SPRITES((16 + 240 - ((animationframe*3) >> 1)), HI_DEFY_BS);
         cpy(&oi_buffer[0], (void *)MEM_OAM, 256);
         //if (hiscorefadeflickerbeater == 0) {
         //   hiscorefadeflickerbeater = 1;
            u8 brightness = 31-(animationframe>>1);
            hiscorebrightness(brightness);
         //} else {
         //   hiscorefadeflickerbeater = 0;
         //}

         hcinemabars = (animationframe * 27) >> 6;
         hfadeline   = animationframe * 5;
         if (animationframe == 42) {
            animationframe = 0;
            hcinemabars = 18;
            REG_BLDMOD = REG_COLEY = 0;
            hiscorestatus = HISCORE_RIGHTHANDSTEADY;
            HBlanksituation = HBLANK_HISCORESTEADY;
         }
      } else if (hiscorestatus == HISCORE_RIGHTHANDSTEADY) {
         if (key_hit(KEY_LEFT) || key_hit(KEY_L) || key_hit(KEY_SELECT)) {
            animationframe = 42;
            hiscorestatus = HISCORE_RIGHTHANDOPENING;
            HBlanksituation = HBLANK_HISCORE1;
         }
         if (key_hit(KEY_START) || key_hit(KEY_B)) {
            animationframe = 0;                       
            hcinemabars    = 0;
            hiscorestatus = HISCORE_DYING;
            HBlanksituation = HBLANK_HISCOREDYING;
         }
      } else if (hiscorestatus == HISCORE_RIGHTHANDOPENING) {   
         animationframe -= 2;
         HI_BESTSCORES_SPRITES((16 + 240 - ((animationframe*3) >> 1)), HI_DEFY_BS);
         cpy(&oi_buffer[0], (void *)MEM_OAM, 256);
         //if (hiscorefadeflickerbeater == 0) {
         //   hiscorefadeflickerbeater = 1;
            u8 brightness = 31-(animationframe>>1);
            hiscorebrightness(brightness);
         //} else {
         //   hiscorefadeflickerbeater = 0;
         //}

         hcinemabars = (animationframe * 27) >> 6;
         hfadeline   = animationframe * 5;
         if (animationframe == 0) {
            animationframe = 0;
            hcinemabars = 0;
            REG_BLDMOD = REG_COLEY = 0;               
            REG_DISPCNT = 0 | VID_BG0 | VID_OBJ | VID_LINEAR;
            hiscorestatus = HISCORE_RIGHTTOLEFTSLIDE;
            HBlanksituation = HBLANK_NONE;
         }
      } else if (hiscorestatus == HISCORE_RIGHTTOLEFTSLIDE) {
         if (animationframe == 0) REG_BLDMOD = REG_COLEY = 0;
         animationframe++;
         //HISCORE_CAMERA(hislideData[animationframe]);
         HISCORE_CAMERA((119-hislideData[animationframe-1]));
         //funk_hiscorebrightness(animationframe);
         cpy(&oi_buffer[0], (void *)MEM_OAM, 256);
         if (animationframe == 30) {               
            bg_set_pos(&back1, 0-46, 2);
            bg_update(&back1);
            bg_set_pos(&back2, 0-46, 6);
            bg_update(&back2);
            animationframe = 0;
            hiscorestatus = HISCORE_LEFTHANDCLOSING;
            REG_DISPCNT = 0 | VID_BG0 | VID_BG1 | VID_BG2 | VID_OBJ | VID_LINEAR;
            fillhiscoremapblock(false, tegelset1, tegelset2);
            HBlanksituation = HBLANK_HISCORE1;
            hfadeline = 0;            
            //hiscorebrightness(20);
         }
      } else if (hiscorestatus == HISCORE_LEFTHANDCLOSING) { 
         animationframe++;
         HI_BESTTIMES_SPRITES((((animationframe*3) >> 1) - 50), HI_DEFY_BT);
         cpy(&oi_buffer[0], (void *)MEM_OAM, 256);
         //if (hiscorefadeflickerbeater == 0) {
         //   hiscorefadeflickerbeater = 1;
            u8 brightness = 31-(animationframe>>1);
            hiscorebrightness(brightness);
         //} else {
         //   hiscorefadeflickerbeater = 0;
         //}

         hcinemabars = (animationframe * 27) >> 6;
         hfadeline   = animationframe * 5;
         if (animationframe == 42) {
            animationframe = 0;
            hcinemabars = 18;
            REG_BLDMOD = REG_COLEY = 0;
            hiscorestatus = HISCORE_LEFTHANDSTEADY;
            HBlanksituation = HBLANK_HISCORESTEADY;
         }
      } else if (hiscorestatus == HISCORE_LEFTHANDSTEADY) {
         if (key_hit(KEY_RIGHT) || key_hit(KEY_R) || key_hit(KEY_SELECT)) {
            animationframe = 42;
            hiscorestatus = HISCORE_LEFTHANDOPENING;
            HBlanksituation = HBLANK_HISCORE1;
         }            
         if (key_hit(KEY_START) || key_hit(KEY_B)) {
            animationframe = 0;
            hcinemabars    = 0;
            hiscorestatus = HISCORE_DYING;     
            HBlanksituation = HBLANK_HISCOREDYING;
         }
      } else if (hiscorestatus == HISCORE_LEFTHANDOPENING) {  
         animationframe -= 2;
         HI_BESTTIMES_SPRITES((((animationframe*3) >> 1) - 50), HI_DEFY_BT);
         cpy(&oi_buffer[0], (void *)MEM_OAM, 256);
         //if (hiscorefadeflickerbeater == 0) {
         //   hiscorefadeflickerbeater = 1;
            u8 brightness = 31-(animationframe>>1);
            hiscorebrightness(brightness);
         //} else {
         //   hiscorefadeflickerbeater = 0;
         //}

         hcinemabars = (animationframe * 27) >> 6;
         hfadeline   = animationframe * 5;
         if (animationframe == 0) {
            animationframe = 0;
            hcinemabars = 0;
            REG_BLDMOD = REG_COLEY = 0;               
            REG_DISPCNT = 0 | VID_BG0 | VID_OBJ | VID_LINEAR;
            hiscorestatus = HISCORE_LEFTTORIGHTSLIDE;
            HBlanksituation = HBLANK_NONE;
         }
      } else if (hiscorestatus == HISCORE_LEFTTORIGHTSLIDE) {
         if (animationframe == 0) REG_BLDMOD = REG_COLEY = 0;
         animationframe++;
         //HISCORE_CAMERA(hislideData[animationframe]);
         HISCORE_CAMERA((hislideData[animationframe-1]));
         //funk_hiscorebrightness(animationframe);
         cpy(&oi_buffer[0], (void *)MEM_OAM, 256);
         if (animationframe == 30) {
            animationframe = 0;
            hiscorestatus = HISCORE_RIGHTHANDCLOSING;
            REG_DISPCNT = 0 | VID_BG0 | VID_BG1 | VID_BG2 | VID_OBJ | VID_LINEAR;
            fillhiscoremapblock(true, tegelset1, tegelset2);
            HBlanksituation = HBLANK_HISCORE1;
            hfadeline = 0;                 
            bg_set_pos(&back1, 4, 2);
            bg_update(&back1);
            bg_set_pos(&back2, 4, 6);
            bg_update(&back2);
            //hiscorebrightness(20);
         }
      } else if (hiscorestatus == HISCORE_DYING) {
         animationframe++;
         hcinemabars = animationframe;
         if (animationframe == 16) {
            hiscorestatus = HISCORE_ALLDONE;
            HBlanksituation = HBLANK_NONE;
         }
      }
      /*
      if (_key_down(KEY_LEFT)) {
            cameraposition++;
      }
      if (_key_down(KEY_RIGHT)) {
            cameraposition--;
      }
      HISCORE_CAMERA(cameraposition);
      */
   } 
   REG_IE &= ~INT_HBLANK;

   for (u16 xtile = 0; xtile < 1024; xtile++) {
      settegel(tegelset0, xtile, 0, 0);
      settegel(tegelset1, xtile, 0, 0);
      settegel(tegelset2, xtile, 0, 0);
      //settegel(tegelset3, xtile, 0, 0);
   }
   
   for (u16 palemp = 0; palemp < 256; palemp++) {
      pal_obj_mem[palemp] = pal_bg_mem[palemp] = 0;
   }

   for (u8 obj_emptier = 0; obj_emptier < 128; obj_emptier++) {
      oi_buffer[obj_emptier].attr0 = 0;
      oi_buffer[obj_emptier].attr1 = 0;
      oi_buffer[obj_emptier].attr2 = 0;
   }
   cpy(&oi_buffer[0], (void *)MEM_OAM, 256);
}

void fillhiscoremapblock(bool bestscores, TEGEL* s1, TEGEL* s2) {
   HISCORE *source = bestscores ? bestscoretable : besttimestable;
   // Score one for fucking pointers, eh? ;D

   for (u8 h = 0; h < 10; h++) {
      TEGEL *sx;
      s8 offset;
      if ((h == 0) || (h == 2) || (h == 4) || (h == 6) || (h == 8)) {
         sx = s1;
         offset = 0-1;
      } else {
         sx = s2;
         offset = 1;
      }
      u32 *charhash_of_hi = (u32 *)&(source[h].character);
      u16 curpal;
      if ((charhash_of_hi[0] == playernamehash[0]) && (charhash_of_hi[1] == playernamehash[1])) {
         curpal = HI_PAL_YELLOW;
      } else {
         curpal = bestscores ? HI_PAL_BLUE : HI_PAL_RED;
      }

      u8 currow = 3*(h>>1)+4+offset;

   /* if (h != 9) {
         settegel(sx,  2, currow, curpal | (TX_1 + h));
      } else {
         settegel(sx,  1, currow, curpal | (TX_1));
         settegel(sx,  2, currow, curpal | (TX_0));
      }  */
               
//#define HI_TABLE_TIMES 14
//#define HI_TABLE_SCORE 21

// used to be four
#define HI_TABLE_TILES ( 2)
#define HI_TABLE_NAMES ( 0+HI_TABLE_TILES)
#define HI_TABLE_TIMES (16+HI_TABLE_TILES)
#define HI_TABLE_SCORE (11+HI_TABLE_TILES)


      settegel(sx, 0+HI_TABLE_NAMES, currow, curpal | TX_A + source[h].character[0]);
      settegel(sx, 1+HI_TABLE_NAMES, currow, curpal | TX_A + source[h].character[1]);
      settegel(sx, 2+HI_TABLE_NAMES, currow, curpal | TX_A + source[h].character[2]);
      settegel(sx, 3+HI_TABLE_NAMES, currow, curpal | TX_A + source[h].character[3]);
      settegel(sx, 4+HI_TABLE_NAMES, currow, curpal | TX_A + source[h].character[4]);
      settegel(sx, 5+HI_TABLE_NAMES, currow, curpal | TX_A + source[h].character[5]);
      settegel(sx, 6+HI_TABLE_NAMES, currow, curpal | TX_A + source[h].character[6]);
      settegel(sx, 7+HI_TABLE_NAMES, currow, curpal | TX_A + source[h].character[7]);

      u8 hundredscollected, tenscollected, unitscollected;
      u8 tensminspass, unitsminspass, tenssecspass, unitssecspass;

      u16 s = source[h].timeins;
      tensminspass = s / 600;
      if (tensminspass == 0) tensminspass = 11;
      unitsminspass = ((s/60) % 10);

      tenssecspass = ((s%60) - (s%10))/10;
      unitssecspass = s % 10;
      
      u16 flangecoll = source[h].flanges;
      hundredscollected = (flangecoll-(flangecoll % 100)) / 100;
      if (hundredscollected == 0) {
         hundredscollected = 11;
         tenscollected = (flangecoll-(flangecoll % 10)) / 10;
         if (tenscollected == 0) tenscollected = 11;
      } else {
         tenscollected = ((flangecoll % 100)-(flangecoll%10)) / 10;
      }
      unitscollected = flangecoll % 10;


      settegel(sx,   HI_TABLE_TIMES, currow, curpal | (tensminspass == 11 ? TX_sp : TX_0 + (tensminspass)));
      settegel(sx, 1+HI_TABLE_TIMES, currow, curpal | TX_0 + unitsminspass);
      settegel(sx, 2+HI_TABLE_TIMES, currow, curpal | TX_co);
      settegel(sx, 3+HI_TABLE_TIMES, currow, curpal | TX_0 + tenssecspass);
      settegel(sx, 4+HI_TABLE_TIMES, currow, curpal | TX_0 + unitssecspass);

      settegel(sx,   HI_TABLE_SCORE, currow, curpal | (hundredscollected == 11 ? TX_sp : TX_0 + (hundredscollected)));
      settegel(sx, 1+HI_TABLE_SCORE, currow, curpal | (tenscollected == 11 ? TX_sp : TX_0 + (tenscollected)));
      settegel(sx, 2+HI_TABLE_SCORE, currow, curpal | TX_0 + unitscollected);

   }
}

//---------------------------------------------------------------------------------
//---------------------------------------------------------------------------------

#define darkennameentrypal(amount) for (u8 palentry = 9; palentry < 16; palentry++) {  darkencolour(bg,     palentry, amount);   \
                                                                                       darkencolour(bg,0x10+palentry, amount);   \
                                                                                       darkencolour(bg,0x20+palentry, amount);}  \
                                   for (u16 palentry = 0; palentry < 208; palentry++) {darkencolour(bg,0x30+palentry, amount);} \
                                                                                       darkencolour(bg,0, amount);               \
                                                                                       darkencolour(bg,16, amount);              \
                                                                                       darkencolour(bg,32, amount);

#define nameentrybrightness2(amount) cpy((void *)speedyglowboxPal , (void *)&pal_bg_mem[0], 128);  darkennameentrypal((31-amount));




void SetUpNameEntry() {
   REG_DISPCNT = 0;               

   u32 *blockempty = (u32*)(&tl_mem[0][0]);

   for (u16 zeroer = 0; zeroer < 65535; zeroer++) {
      blockempty[zeroer] = 0;
   }

   for (u8 obj_emptier = 0; obj_emptier < 128; obj_emptier++) {
      oi_buffer[obj_emptier].attr0 = 0;
      oi_buffer[obj_emptier].attr1 = 0;
      oi_buffer[obj_emptier].attr2 = 0;
      *(u8 *)(0x06010000 + obj_emptier) = 0;
   }
   cpy(&oi_buffer[0], (void *)MEM_OAM, 256);


   cpy((void *)speedyglowboxData, (void *)&tl_mem[0][0], 9600);
   cpy((void *)speedyglowboxPal , (void *)&pal_bg_mem[0], 128);

   //cpy((void *)BGspritesData, (void *)&tl_mem[4][2], 5120);
   //cpy((void *)BGspritesPal , (void *)&pal_obj_mem[0], 112);

   cpy((void *)texttilesData, (void *)&tl_mem[4][1], 728);

   //cpy((void *)hiscoretextsData, (void *)&tl_mem[4][642], 416);

   for (u8 palfill = 0; palfill < 9; palfill++) {
      pal_obj_mem[0x00+palfill] = pal_bg_mem[     palfill];
      pal_obj_mem[0x10+palfill] = pal_bg_mem[0x10+palfill];
      pal_obj_mem[0x30+palfill] = pal_bg_mem[0x20+palfill];
   }
   pal_obj_mem[0x20 + 1] = _RGB15( 10,  0, 11);
   pal_obj_mem[0x20 + 2] = _RGB15( 12,  2, 13);
   pal_obj_mem[0x20 + 3] = _RGB15( 14,  4, 16);
   pal_obj_mem[0x20 + 4] = _RGB15( 16,  6, 19);
   pal_obj_mem[0x20 + 5] = _RGB15( 19,  8, 22);
   pal_obj_mem[0x20 + 6] = _RGB15( 22, 11, 25);
   pal_obj_mem[0x20 + 7] = _RGB15( 24, 18, 28);
   pal_obj_mem[0x20 + 8] = _RGB15( 31, 31, 31);

   pal_obj_mem[0x40 + 1] = _RGB15(  0, 12,  3);
   pal_obj_mem[0x40 + 2] = _RGB15(  2, 14,  4);
   pal_obj_mem[0x40 + 3] = _RGB15(  4, 17,  6);
   pal_obj_mem[0x40 + 4] = _RGB15(  6, 20,  8);
   pal_obj_mem[0x40 + 5] = _RGB15( 10, 23, 12);
   pal_obj_mem[0x40 + 6] = _RGB15( 15, 26, 16);
   pal_obj_mem[0x40 + 7] = _RGB15( 22, 28, 23);
   pal_obj_mem[0x40 + 8] = _RGB15( 31, 31, 31);
   //cpy((void *)menulettersData,  (void *)&tl_mem[4][1], 992);  

   nameentrybrightness2(31);
     
   cpy((void *)appearboxData, (void *)&tl_mem[1][690], 144);

   /*u16 *tileblacks = (u16 *)&tl_mem[1][771];

   for (u8 pixelblacks = 0; pixelblacks < 16; pixelblacks++ ) {
      tileblacks[pixelblacks] = (9<<12)|(9<<8)|(9<<4)|(9<<0);
   }   */

   //pal_bg_mem[0] = 0;
}

void name_entry_sprites(u8 set, u16 xpos);
void name_entry_myname(u8 ypos);  
void name_entry_options(u8 charmode, u8 xpos);

#define NE_DOWNABIT (0-4)

#define NAME_ENTRY_YBASE (44-NE_DOWNABIT)
#define NAME_ENTRY_MYNAMEX (20)
#define NAME_ENTRY_OPTIONSY (40-NE_DOWNABIT)

#define ne_box1(set, xpos) bg_set_pos(&back1, (0-(xpos)), (0-(NAME_ENTRY_YBASE-8))); bg_update(&back1); name_entry_sprites((set), ((xpos)+8));
#define ne_box2(ypos) bg_set_pos(&back2, (0-(NAME_ENTRY_MYNAMEX-8)), (0-(ypos))); bg_update(&back2); name_entry_myname(((ypos)+8));
#define ne_box3(charmodes, xpos) bg_set_pos(&back3, (0-(xpos)), (0-(NAME_ENTRY_OPTIONSY-8))); bg_update(&back3); name_entry_options(charmodes,((xpos)+8));

void NameEntry() {
   BGINFO back0;
   bg_init(&back0, 0, 0, 31, BG_REG_1X1 | BG_PAL256 | 3);
   TEGEL *tegelset0 = back0.map;
   bg_set_pos(&back0, 0, 0);
   bg_update(&back0);

   BGINFO back1;
   bg_init(&back1, 1, 1, 29, BG_REG_2X1 | BG_PAL256 | 2);
   TEGEL *tegelset1 = back1.map;
   bg_set_pos(&back1, 168, 0);
   bg_update(&back1);

   BGINFO back2;
   bg_init(&back2, 2, 1, 28, BG_REG_1X1 | BG_PAL256 | 2);
   TEGEL *tegelset2 = back2.map;
   bg_set_pos(&back2, 0, 0);
   bg_update(&back2);

   BGINFO back3;
   bg_init(&back3, 3, 1, 26, BG_REG_2X1 | BG_PAL256 | 2);
   TEGEL *tegelset3 = back3.map;
   bg_set_pos(&back3, 0, 0);
   bg_update(&back3);

   for (u16 xtile = 0; xtile < 2048; xtile++) {
      settegel(tegelset1, xtile, 0, (688>>1));
      settegel(tegelset2, xtile, 0, (688>>1));
      settegel(tegelset3, xtile, 0, (688>>1));
   }

#define make_ne_box(xs, ys, t) for (u8 ytile = 0; ytile < (ys-1); ytile++) {       \
                                  for (u8 xtile = 0; xtile < (xs-1); xtile++) {    \
                                     settegel(t, xtile, ytile, (698>>1));          \
                                  }                                                \
                               }                                                   \
                               for (u8 xtile = 1; xtile < (xs-1); xtile++) {       \
                                  settegel(t, xtile,      0, (692>>1));            \
                                  settegel(t, xtile, (ys-1), (704>>1));            \
                               }                                                   \
                               for (u8 ytile = 0; ytile < (ys-1); ytile++) {       \
                                  settegel(t,      0, ytile, (696>>1));            \
                                  settegel(t, (xs-1), ytile, (700>>1));            \
                               }                                                   \
                               settegel(t,      0,      0, (690>>1));              \
                               settegel(t, (xs-1),      0, (694>>1));              \
                               settegel(t,      0, (ys-1), (702>>1));              \
                               settegel(t, (xs-1), (ys-1), (706>>1));

   make_ne_box(15,  9, tegelset1);
   make_ne_box(18,  4, tegelset2);
   make_ne_box( 8, 15, tegelset3);


   for (u8 ytile = 0; ytile < 20; ytile++) {
      settegelrun(tegelset0, 0,    ytile,     ytile*30, 30);
   }

   //REG_BLDMOD = REG_COLEY = 0;

   #define NAME_STATUS_FADEIN        0
   #define NAME_STATUS_APPEAR        1
   #define NAME_STATUS_STEADY        2
   #define NAME_STATUS_SLIDEOUTTEXTS 3
   #define NAME_STATUS_SLIDEINTEXTS  4
   #define NAME_STATUS_DISAPPEAR     5
   #define NAME_STATUS_FADEOUT       6
   #define NAME_STATUS_DEAD          7

   u8 NAME_STATUS = NAME_STATUS_FADEIN;
   u8 animationframe = 0;

   u8 cx    = 0;
   u8 cy    = 0;

   u8 citem = 0;

#define NAME_I_LOWER      0
#define NAME_I_UPPER      1
#define NAME_I_UPPERSHIFT 2
#define NAME_I_SYMBOL     3

   u8 charmode = NAME_I_UPPERSHIFT;
   
   u8 beginningmode = 0;
   u8 endingmode = 0;

   ne_box1(0, 24);
   ne_box2(116-NE_DOWNABIT);
   ne_box3(charmode, 168);

   cpy(&oi_buffer[0], (void *)MEM_OAM, 256);

   while (NAME_STATUS != NAME_STATUS_DEAD) {
      if (NAME_STATUS == NAME_STATUS_FADEIN) {
         VSync();
         key_poll();
         if (animationframe == 0) {        
            REG_DISPCNT = 0 | VID_BG0;
            REG_BLDMOD = bit7 | bit6 | bit5 | bit4 | bit3 | bit2 | bit1 | bit0;
            REG_COLEY  = 16;
         }
         animationframe++;
         REG_COLEY = 16 - (animationframe >> 1);
         if (animationframe == 32) {    
            REG_DISPCNT = 0 | VID_BG0 | VID_BG1 | VID_BG2 | VID_BG3 | VID_OBJ | VID_LINEAR;
            animationframe = 0;                   
            REG_BLDMOD = bit8 | bit6 | bit3 | bit2 | bit1;
            REG_COLEY  = 0;
            REG_COLEV  = (10 << 8) | (16);
            NAME_STATUS = NAME_STATUS_APPEAR;
         }
      } else if (NAME_STATUS == NAME_STATUS_STEADY) {
         VSync();
         key_poll();                      
         cpy(&oi_buffer[0], (void *)MEM_OAM, 256);
      } else {
      }
   }

   holdforasec();
}

#define NAME_ENTRY_XSEP (8)
#define NAME_ENTRY_YSEP (8)

#define NAME_ENTRY_PAL0 (0 << 12)
#define NAME_ENTRY_PAL1 (1 << 12)
#define NAME_ENTRY_PAL2 (2 << 12)
#define NAME_ENTRY_PAL3 (3 << 12)
#define NAME_ENTRY_PAL4 (4 << 12)


#define name_entry_macro(spr, xtimes, ytimes, sym, n) oi_buffer[spr].attr0 = NAME_ENTRY_YBASE + ((ytimes)*NAME_ENTRY_YSEP);    \
                                                      oi_buffer[spr].attr1 = ((xpos + ((xtimes)*NAME_ENTRY_XSEP)) & 511);      \
                                                      oi_buffer[spr].attr2 = ((NAME_ENTRY_PAL##n) | _NEX_(sym));

void name_entry_sprites(u8 set, u16 xpos) {
   if (set == 0) {
      name_entry_macro ( 0, 0, 0, A, 0);
      name_entry_macro ( 1, 2, 0, B, 0);
      name_entry_macro ( 2, 4, 0, C, 0);
      name_entry_macro ( 3, 6, 0, D, 0);
      name_entry_macro ( 4, 8, 0, E, 0);
      name_entry_macro ( 5,10, 0, F, 0);
      name_entry_macro ( 6,12, 0, G, 0);
      name_entry_macro ( 7, 0, 2, H, 0);
      name_entry_macro ( 8, 2, 2, I, 0);
      name_entry_macro ( 9, 4, 2, J, 0);
      name_entry_macro (10, 6, 2, K, 0);
      name_entry_macro (11, 8, 2, L, 0);
      name_entry_macro (12,10, 2, M, 0);
      name_entry_macro (13,12, 2, N, 0);
      name_entry_macro (14, 0, 4, O, 0);
      name_entry_macro (15, 2, 4, P, 0);
      name_entry_macro (16, 4, 4, Q, 0);
      name_entry_macro (17, 6, 4, R, 0);
      name_entry_macro (18, 8, 4, S, 0);
      name_entry_macro (19,10, 4, T, 0);
      name_entry_macro (20,12, 4, U, 0);
      name_entry_macro (21, 0, 6,sp, 0);
      name_entry_macro (22, 2, 6, V, 0);
      name_entry_macro (23, 4, 6, W, 0);
      name_entry_macro (24, 6, 6, X, 0);
      name_entry_macro (25, 8, 6, Y, 0);
      name_entry_macro (26,10, 6, Z, 0);
      name_entry_macro (27,12, 6,sp, 0);
   } else if (set == 1) {
      name_entry_macro ( 0, 0, 0, a, 1);
      name_entry_macro ( 1, 2, 0, b, 1);
      name_entry_macro ( 2, 4, 0, c, 1);
      name_entry_macro ( 3, 6, 0, d, 1);
      name_entry_macro ( 4, 8, 0, e, 1);
      name_entry_macro ( 5,10, 0, f, 1);
      name_entry_macro ( 6,12, 0, g, 1);
      name_entry_macro ( 7, 0, 2, h, 1);
      name_entry_macro ( 8, 2, 2, i, 1);
      name_entry_macro ( 9, 4, 2, j, 1);
      name_entry_macro (10, 6, 2, k, 1);
      name_entry_macro (11, 8, 2, l, 1);
      name_entry_macro (12,10, 2, m, 1);
      name_entry_macro (13,12, 2, n, 1);
      name_entry_macro (14, 0, 4, o, 1);
      name_entry_macro (15, 2, 4, p, 1);
      name_entry_macro (16, 4, 4, q, 1);
      name_entry_macro (17, 6, 4, r, 1);
      name_entry_macro (18, 8, 4, s, 1);
      name_entry_macro (19,10, 4, t, 1);
      name_entry_macro (20,12, 4, u, 1);
      name_entry_macro (21, 0, 6,sp, 1);
      name_entry_macro (22, 2, 6, v, 1);
      name_entry_macro (23, 4, 6, w, 1);
      name_entry_macro (24, 6, 6, x, 1);
      name_entry_macro (25, 8, 6, y, 1);
      name_entry_macro (26,10, 6, z, 1);
      name_entry_macro (27,12, 6,sp, 1);
   } else if (set == 2) {
      name_entry_macro ( 0, 0, 0, 0, 3);name_entry_macro ( 7, 0, 2, 7, 3);name_entry_macro (14, 0, 4, _, 3);name_entry_macro (21, 0, 6,cl, 3);
      name_entry_macro ( 1, 2, 0, 1, 3);name_entry_macro ( 8, 2, 2, 8, 3);name_entry_macro (15, 2, 4,as, 3);name_entry_macro (22, 2, 6,ti, 3);
      name_entry_macro ( 2, 4, 0, 2, 3);name_entry_macro ( 9, 4, 2, 9, 3);name_entry_macro (16, 4, 4,pl, 3);name_entry_macro (23, 4, 6,hs, 3);
      name_entry_macro ( 3, 6, 0, 3, 3);name_entry_macro (10, 6, 2,pe, 3);name_entry_macro (17, 6, 4,mi, 3);name_entry_macro (24, 6, 6,co, 3);
      name_entry_macro ( 4, 8, 0, 4, 3);name_entry_macro (11, 8, 2,ex, 3);name_entry_macro (18, 8, 4,fs, 3);name_entry_macro (25, 8, 6,sm, 3);
      name_entry_macro ( 5,10, 0, 5, 3);name_entry_macro (12,10, 2,qu, 3);name_entry_macro (19,10, 4,bs, 3);name_entry_macro (26,10, 6,at, 3);
      name_entry_macro ( 6,12, 0, 6, 3);name_entry_macro (13,12, 2,ca, 3);name_entry_macro (20,12, 4,op, 3);name_entry_macro (27,12, 6,hp, 3);
   }
}

#define ne_simple(spr, xpos, ypos, ch, pal) oi_buffer[spr].attr0 = (ypos);                       \
                                            oi_buffer[spr].attr1 = ((xpos) & 511);               \
                                            oi_buffer[spr].attr2 = (pal << 12) | (_NEX_(ch));


void name_entry_options(u8 charmode, u8 xpos) {
   u8 curpal = 0;
   ne_simple(36, 4+xpos+0*8, (NAME_ENTRY_OPTIONSY+0*16), L, curpal);
   ne_simple(37, 4+xpos+1*8, (NAME_ENTRY_OPTIONSY+0*16), O, curpal);
   ne_simple(38, 4+xpos+2*8, (NAME_ENTRY_OPTIONSY+0*16), W, curpal);
   ne_simple(39, 4+xpos+3*8, (NAME_ENTRY_OPTIONSY+0*16), E, curpal);
   ne_simple(40, 4+xpos+4*8, (NAME_ENTRY_OPTIONSY+0*16), R, curpal);

   curpal = 0;                                                 
   ne_simple(41, 4+xpos+0*8, (NAME_ENTRY_OPTIONSY+1*16), U, curpal);
   ne_simple(42, 4+xpos+1*8, (NAME_ENTRY_OPTIONSY+1*16), P, curpal);
   ne_simple(43, 4+xpos+2*8, (NAME_ENTRY_OPTIONSY+1*16), P, curpal);
   ne_simple(44, 4+xpos+3*8, (NAME_ENTRY_OPTIONSY+1*16), E, curpal);
   ne_simple(45, 4+xpos+4*8, (NAME_ENTRY_OPTIONSY+1*16), R, curpal);

   curpal = 0;                                                 
   ne_simple(46, 4+xpos+0*8, (NAME_ENTRY_OPTIONSY+2*16), S, curpal);
   ne_simple(47, 4+xpos+1*8, (NAME_ENTRY_OPTIONSY+2*16), H, curpal);
   ne_simple(48, 4+xpos+2*8, (NAME_ENTRY_OPTIONSY+2*16), I, curpal);
   ne_simple(49, 4+xpos+3*8, (NAME_ENTRY_OPTIONSY+2*16), F, curpal);
   ne_simple(50, 4+xpos+4*8, (NAME_ENTRY_OPTIONSY+2*16), T, curpal);

   curpal = 0;                                                 
   ne_simple(51, xpos+0*8, (NAME_ENTRY_OPTIONSY+3*16), S, curpal);
   ne_simple(52, xpos+1*8, (NAME_ENTRY_OPTIONSY+3*16), Y, curpal);
   ne_simple(53, xpos+2*8, (NAME_ENTRY_OPTIONSY+3*16), M, curpal);
   ne_simple(54, xpos+3*8, (NAME_ENTRY_OPTIONSY+3*16), B, curpal);
   ne_simple(55, xpos+4*8, (NAME_ENTRY_OPTIONSY+3*16), O, curpal);
   ne_simple(56, xpos+5*8, (NAME_ENTRY_OPTIONSY+3*16), L, curpal);

   curpal = 0;
   ne_simple(57, 4+xpos+0*8, (NAME_ENTRY_OPTIONSY+4*16), S, curpal);
   ne_simple(58, 4+xpos+1*8, (NAME_ENTRY_OPTIONSY+4*16), P, curpal);
   ne_simple(59, 4+xpos+2*8, (NAME_ENTRY_OPTIONSY+4*16), A, curpal);
   ne_simple(60, 4+xpos+3*8, (NAME_ENTRY_OPTIONSY+4*16), C, curpal);
   ne_simple(61, 4+xpos+4*8, (NAME_ENTRY_OPTIONSY+4*16), E, curpal);

   curpal = 0;
   ne_simple(62, 4+xpos+0*8, (NAME_ENTRY_OPTIONSY+5*16), C, curpal);
   ne_simple(63, 4+xpos+1*8, (NAME_ENTRY_OPTIONSY+5*16), L, curpal);
   ne_simple(64, 4+xpos+2*8, (NAME_ENTRY_OPTIONSY+5*16), E, curpal);
   ne_simple(65, 4+xpos+3*8, (NAME_ENTRY_OPTIONSY+5*16), A, curpal);
   ne_simple(66, 4+xpos+4*8, (NAME_ENTRY_OPTIONSY+5*16), R, curpal); 

   curpal = 0;                                                 
   ne_simple(67, xpos+1*8, (NAME_ENTRY_OPTIONSY+6*16), D, curpal);
   ne_simple(68, xpos+2*8, (NAME_ENTRY_OPTIONSY+6*16), O, curpal);
   ne_simple(69, xpos+3*8, (NAME_ENTRY_OPTIONSY+6*16), N, curpal);
   ne_simple(70, xpos+4*8, (NAME_ENTRY_OPTIONSY+6*16), E, curpal);

}

void name_entry_myname(u8 ypos) {
   for (u8 p = 0; p<8; p++) {
      oi_buffer[28+p].attr0 = bit9 | bit8 | ypos;
      oi_buffer[28+p].attr1 = (p<<9) | NAME_ENTRY_MYNAMEX+16*p;
      oi_buffer[28+p].attr2 = (3 << 12) | (1+playername[p]);
      oa_buffer[p].pa = oa_buffer[p].pd = (1<<7);
   }
}

void TemporaryFadeWhiteToBlack() {
   HBlanksituation = 0;
   for (u16 pal_emptier = 0; pal_emptier < 256; pal_emptier++) {
      pal_bg_mem[pal_emptier] = 0;
      pal_obj_mem[pal_emptier] = 0;
   }
   REG_BLDMOD = bit7 | bit5 | bit4 | bit3 | bit2 | bit1 | bit0;
   REG_COLEY = 16;
   vu8 fade = 16<<3;
   REG_DISPCNT = VID_BG0;
   while (1) {
      VSync();
      dont_optimize();
      REG_COLEY = fade >> 3;
      fade--;
      if (fade == 0) break;
   }
   REG_BLDMOD  = 0;
   REG_COLEY   = 0;
   for (u8 obj_emptier = 0; obj_emptier < 128; obj_emptier++) {
      oi_buffer[obj_emptier].attr0 = 0;
      oi_buffer[obj_emptier].attr1 = 0;
      oi_buffer[obj_emptier].attr2 = 0;
   }
   cpy(&oi_buffer[0], (void *)MEM_OAM, 256);
}

extern "C" int AgbMain(void) {
   REG_DISPCNT = VID_BLANK;    // Nothing here.

   //AAS_SetConfig( AAS_CONFIG_MIX_32KHZ, AAS_CONFIG_CHANS_8, AAS_CONFIG_SPATIAL_MONO, AAS_CONFIG_DYNAMIC_ON );
   AAS_SetConfig(AAS_CONFIG_MIX_32KHZ, AAS_CONFIG_CHANS_8, AAS_CONFIG_SPATIAL_MONO, AAS_CONFIG_DYNAMIC_OFF );

   AAS_MOD_SetVolume(255);  //Thats the maximum!

   REG_DISPSTAT |= VID_IRQ_VB | VID_IRQ_HB;   // We want VBlank enabled for interrupts.
   REG_IE |= INT_VBLANK;

   //HBlanksituation = HBLANK_HISCORE1;
   //hfadeline = 100;

   SetUpMathewCarr();
   DoMathewCarr();

   AAS_ShowLogo();  // Play ball with their liscensing. They rock. And you know it.
                    // Remember, they'll leave a blank palette, so you can be sure you'll have to recopy it in.
                    // OR they might actually BUFFER the palette. But who knows?

   SetUpBlastArenaLetterSlamTitle();
   DoBlastArenaLetterSlamTitle();          //This will leave the screen in a state of WHITE.
   BlastArenaTitleFadeAndManagePressStart();

   for (u16 pal_emptier = 0; pal_emptier < 256; pal_emptier++) {
      pal_bg_mem[pal_emptier] = 0;
   }
   
   //TemporaryFadeWhiteToBlack();

   //REG_DISPCNT = 3 | VID_BG2 | VID_OBJ | VID_LINEAR;
                          
   if (isSaveGameValid()) {   
      retrieveStateFromCart();
   } else {                    
      //makeEliteState();
      makeDefaultState();
      SetUpNameEntry();
      NameEntry();
      writeCurrentStateToCart();
   }

   sfxflags &= ~MENU_ON;
   u8 menuresult = MENU_CHOSEGAME;
   do {
      SetUpMainMenu();
      menuresult = MainMenu();  
      sfxflags |= MENU_ON;
      if (menuresult == MENU_CHOSEGAME) {
         sfxflags &= ~MENU_ON;
         u8 gameresult = GAME_REST;
         do {
            AAS_MOD_Stop();
            SetUpGame();
            gameresult = Game();
         } while (gameresult == GAME_REST);
      } else if (menuresult == MENU_CHOSENAME) {
         SetUpNameEntry();
         NameEntry();        
         writeCurrentStateToCart();
      } else if (menuresult == MENU_CHOSEHISCORE) {
         SetUpHiscores();
         Hiscores();
      } else if (menuresult == MENU_CHOSECREDITS) {
      }
   } while( 1 );
   return 1;   // This should never ever happen. Instant Gameboy lockup deluxe.
}
