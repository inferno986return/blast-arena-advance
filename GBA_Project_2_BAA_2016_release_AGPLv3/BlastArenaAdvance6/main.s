# 1 "main.cpp"
# 1 "<built-in>"
# 1 "<command line>"
# 1 "main.cpp"






# 1 "../tonclib/tonc_gba.h" 1
# 10 "../tonclib/tonc_gba.h"
extern "C" {



# 1 "../tonclib/types.h" 1
# 9 "../tonclib/types.h"
typedef unsigned char u8, byte;
typedef unsigned short u16, hword;
typedef unsigned int u32, word;
typedef unsigned long long u64;

typedef signed char s8;
typedef signed short s16;
typedef signed int s32;
typedef signed long long s64;


typedef volatile u8 vu8;
typedef volatile u16 vu16;
typedef volatile u32 vu32;
typedef volatile u64 vu64;

typedef volatile s8 vs8;
typedef volatile s16 vs16;
typedef volatile s32 vs32;
typedef volatile s64 vs64;

typedef s32 FIXED;
typedef u16 COLOR;
typedef u16 TEGEL, MAPENTRY;
typedef u8 AFFTEGEL, AFFMAPENTRY;


typedef void (*fnptr)(void);






typedef int BOOL;
# 15 "../tonclib/tonc_gba.h" 2

# 1 "../tonclib/regs.h" 1
# 17 "../tonclib/tonc_gba.h" 2


# 1 "../tonclib/core.h" 1
# 107 "../tonclib/core.h"
void memset16(void *dest, u16 val, int nn);
void memcpy16(void *dest, const void* src, int nn);
void memrot16(void *mem, int first, int last);
# 137 "../tonclib/core.h"
typedef struct tagDMAINFO
{
  const void *src;
  void *dst;
  u32 cnt;
} DMAINFO;
# 176 "../tonclib/core.h"
void dma_memcpy(void *dst, const void *src, u16 count);
# 20 "../tonclib/tonc_gba.h" 2

# 1 "../tonclib/geom.h" 1
# 14 "../tonclib/geom.h"
typedef struct tagPOINT
{
 int x, y;
} POINT;

typedef struct tagRECT
{
 int l, t, r, b;
} RECT;

typedef struct tagVECTOR
{
 FIXED x, y, z;
} VECTOR;





static inline void pt_set(POINT *a, int x, int y);
static inline void pt_add(POINT *dst, const POINT *a, const POINT *b);
static inline void pt_scale(POINT *dst, const POINT *a, int c);
static inline BOOL pt_in_rect(const POINT *pt, const RECT *rc);


static inline void rc_set(RECT *rc, int l, int t, int r, int b);
static inline void rc_set2(RECT *rc, int x, int y, int w, int h);
static inline int rc_width(const RECT *rc);
static inline int rc_height(const RECT *rc);
void rc_pos(RECT *rc, int x, int y);
static inline void rc_size(RECT *rc, int w, int h);
static inline void rc_move(RECT *rc, int dx, int dy);
static inline void rc_inflate(RECT *rc, int dw, int dh);
static inline void rc_inflate2(RECT *rc, const RECT *dr);

void rc_norm(RECT *rc);


static inline void vec_set(VECTOR *a, FIXED x, FIXED y, FIXED z);

void vec_add(VECTOR *res, const VECTOR *a, const VECTOR *b);
void vec_sub(VECTOR *dst, const VECTOR *a, const VECTOR *b);
void vec_scale(VECTOR *dst, const VECTOR *a, FIXED c);
FIXED vec_dot(const VECTOR *a, const VECTOR *b);
void vec_cross(VECTOR *dst, const VECTOR *a, const VECTOR *b);




static inline void pt_set(POINT *a, int x, int y)
{ a->x= x; a->y= y; }

static inline void pt_add(POINT *dst, const POINT *a, const POINT *b)
{ dst->x= a->x + b->x; dst->y= a->x + a->y; }

static inline void pt_scale(POINT *dst, const POINT *a, int c)
{ dst->x= a->x*c; dst->y= a->y*c; }

static inline BOOL pt_in_rect(const POINT *pt, const RECT *rc)
{
 return (pt->x < rc->l || pt->y < rc->t ||
         pt->x >= rc->r || pt->y >= rc->b) ? 0 : 1;
}


static inline void rc_set(RECT *rc, int l, int t, int r, int b)
{ rc->l=l; rc->t=t; rc->r=r; rc->b=b; }

static inline void rc_set2(RECT *rc, int x, int y, int w, int h)
{ rc->l=x; rc->t=y; rc->r=x+w; rc->b=y+h; }

static inline int rc_width(const RECT *rc)
{ return rc->r - rc->l; }
static inline int rc_height(const RECT *rc)
{ return rc->b - rc->t; }

static inline void rc_size(RECT *rc, int w, int h)
{ rc->r= rc->l+w; rc->b= rc->t+h; }

static inline void rc_move(RECT *rc, int dx, int dy)
{ rc->l += dx; rc->t += dy; rc->r += dx; rc->b += dy; }
static inline void rc_inflate(RECT *rc, int dw, int dh)
{ rc->l -= dw; rc->t -= dh; rc->r += dw; rc->b += dh; }
static inline void rc_inflate2(RECT *rc, const RECT *dr)
{ rc->l += dr->l; rc->t += dr->t; rc->r += dr->r; rc->b += dr->b; }


static inline void vec_set(VECTOR *a, FIXED x, FIXED y, FIXED z)
{ a->x= x; a->y= y; a->z= z; }
# 22 "../tonclib/tonc_gba.h" 2

# 1 "../tonclib/color.h" 1
# 55 "../tonclib/color.h"
void pal_load_def();
# 82 "../tonclib/color.h"
static inline COLOR RGB15(u8 rr, u8 gg, u8 bb)
{ return (rr&0x1f) | ((gg&0x1f)<<5) | ((bb&0x1f)<<10); }


static inline COLOR _RGB15(u8 rr, u8 gg, u8 bb)
{ return rr+(gg<<5)+(bb<<10); }
# 24 "../tonclib/tonc_gba.h" 2

# 1 "../tonclib/keypad.h" 1
# 58 "../tonclib/keypad.h"
static inline void key_irq_cond(u16 key);
void key_wait_for_clear(u16 key);


static inline u16 _key_down(const u16 key);
static inline u16 _key_up(const u16 key);


void key_poll();
u16 key_curr_state();
u16 key_prev_state();

u16 key_is_down(u16 key);
u16 key_is_up(u16 key);

u16 key_was_down(u16 key);
u16 key_was_up(u16 key);

u16 key_transit(u16 key);
u16 key_held(u16 key);
u16 key_hit(u16 key);
u16 key_released(u16 key);
# 91 "../tonclib/keypad.h"
static inline void key_irq_cond(u16 key)
{ *(vu16*)(0x04000000 +0x0132)= key; }




static inline u16 _key_down(const u16 key)
{ return ~(*(vu16*)(0x04000000 +0x0130)) & key; }


static inline u16 _key_up(const u16 key)
{ return (*(vu16*)(0x04000000 +0x0130)) & key; }
# 26 "../tonclib/tonc_gba.h" 2

# 1 "../tonclib/affine.h" 1
# 31 "../tonclib/affine.h"
typedef struct tagBGAFF
{
 s16 pa, pb;
 s16 pc, pd;
} BGAFF;


typedef struct tagBGAFF_EX
{
 s16 pa, pb;
 s16 pc, pd;
 s32 dx, dy;
} BGAFF_EX;





typedef struct tagOBJAFF
{
 u16 fill0[3];
 s16 pa;
 u16 fill1[3];
 s16 pb;
 u16 fill2[3];
 s16 pc;
 u16 fill3[3];
 s16 pd;
} OBJAFF;




typedef struct tagAFF_SRC
{
 s16 sx, sy;
 u16 alpha;
} AFF_SRC;



typedef struct tagAFF_SRC_EX
{
 s32 px, py;
 s16 qx, qy;
 s16 sx, sy;
 u16 alpha;
} AFF_SRC_EX;
# 87 "../tonclib/affine.h"
void oa_copy(OBJAFF *dest, OBJAFF *src);
void oa_transform(OBJAFF *oa, s16 ux, s16 uy, s16 vx, s16 vy);
void oa_identity(OBJAFF *oa);
void oa_postmultiply(OBJAFF *dest, OBJAFF *src);

void oa_rotate(OBJAFF *oa, int alpha);
void oa_rotscale(OBJAFF *oa, int alpha, FIXED sx, FIXED sy);
void oa_rotscale2(OBJAFF *oa, AFF_SRC *as);
void oa_scale(OBJAFF *oa, FIXED sx, FIXED sy);
void oa_shearx(OBJAFF *oa, FIXED hx);
void oa_sheary(OBJAFF *oa, FIXED hy);



void oa_rotate_inv(OBJAFF *oa, int alpha);
void oa_rotscale_inv(OBJAFF *oa, int alpha, FIXED sx, FIXED sy);

static inline void oa_scale_inv(OBJAFF *oa, FIXED sx, FIXED sy);
static inline void oa_shearx_inv(OBJAFF *oa, FIXED hx);
static inline void oa_sheary_inv(OBJAFF *oa, FIXED hy);





void bga_copy(BGAFF *dest, BGAFF *src);
void bga_transform(BGAFF *bga, s16 ux, s16 uy, s16 vx, s16 vy);
void bga_identity(BGAFF *bga);
void bga_postmultiply(BGAFF *dest, BGAFF *src);

void bga_rotscale(BGAFF *bga, int alpha, FIXED sx, FIXED sy);
void bga_rotate(BGAFF *bga, int alpha);
void bga_rotscale2(BGAFF *bga, AFF_SRC *as);
void bga_scale(BGAFF *bga, FIXED sx, FIXED sy);
void bga_shearx(BGAFF *bga, FIXED hx);
void bga_sheary(BGAFF *bga, FIXED hy);


void bga_rotate_inv(BGAFF *bga, int alpha);
void bga_rotscale_inv(BGAFF *bga, int alpha, FIXED sx, FIXED sy);

static inline void bga_scale_inv(BGAFF *bga, FIXED sx, FIXED sy);
static inline void bga_shearx_inv(BGAFF *bga, FIXED hx);
static inline void bga_sheary_inv(BGAFF *bga, FIXED hy);


void bga_rs_ex(BGAFF_EX *bgax, AFF_SRC_EX *asx);




static inline void oa_scale_inv(OBJAFF *oa, FIXED sx, FIXED sy)
{ oa_scale(oa, (1<<16)/sx, (1<<16)/sy); }

static inline void oa_shearx_inv(OBJAFF *oa, FIXED hx)
{ oa_shearx(oa, -hx); }

static inline void oa_sheary_inv(OBJAFF *oa, FIXED hy)
{ oa_sheary(oa, -hy); }


static inline void bga_scale_inv(BGAFF *bga, FIXED sx, FIXED sy)
{ bga_scale(bga, (1<<16)/sx, (1<<16)/sy); }

static inline void bga_shearx_inv(BGAFF *bga, FIXED hx)
{ bga_shearx(bga, -hx); }

static inline void bga_sheary_inv(BGAFF *bga, FIXED hy)
{ bga_sheary(bga, -hy); }
# 28 "../tonclib/tonc_gba.h" 2


# 1 "../tonclib/interrupt.h" 1
# 14 "../tonclib/interrupt.h"
enum eIntrIndex
{
 II_VBLANK=0, II_HBLANK, II_VCOUNT, II_TM0,
 II_TM1, II_TM2, II_TM3, II_COM,
 II_DMA0, II_DMA1, II_DMA2, II_DMA3,
 II_KEYS, II_CART
};
# 41 "../tonclib/interrupt.h"
extern fnptr IntrTable[];




void IntrMain();

void int_init();
void int_dummy();


static inline void int_enable(u16 flags);
static inline void int_disable(u16 flags);



void int_enable_ex(enum eIntrIndex eii, fnptr isr);
void int_disable_ex(enum eIntrIndex eii);





static inline void int_enable(u16 flags)
{ *(vu16*)(0x04000000 +0x0200) |= flags; }

static inline void int_disable(u16 flags)
{ *(vu16*)(0x04000000 +0x0200) &= ~flags; }
# 31 "../tonclib/tonc_gba.h" 2

# 1 "../tonclib/swi.h" 1
# 39 "../tonclib/swi.h"
typedef AFF_SRC ObjAffineSource;
typedef AFF_SRC_EX BGAffineSource;

typedef BGAFF ObjAffineDest;
typedef BGAFF_EX BGAffineDest;




typedef struct tagUNPACKINFO
{
 u16 src_len;
 u8 src_bpp;
 u8 dst_bpp;
 u32 dst_offset;
} UNPACKINFO;







void swi_reset();


void swi_vsync();



int swi_div(int num, int denom);


int swi_div_safe(int num, int denom);


int swi_mod(int num, int denom);


int swi_sqrt(u32 num);


s16 swi_arctan2(s16 x, s16 y);
# 91 "../tonclib/swi.h"
void swi_aff_ex(AFF_SRC_EX *src, BGAFF_EX *dst);







void swi_aff(AFF_SRC *src, void *dst, int num, int offset);



void swi_bitunpack(const void *src, void *dst, UNPACKINFO *upi);
# 33 "../tonclib/tonc_gba.h" 2



# 1 "../tonclib/vid.h" 1
# 48 "../tonclib/vid.h"
typedef struct { u32 data[8]; } TILE, TILE_S;

typedef TILE TILEBLOCK[512];
typedef TILE TILEROW[32];
typedef TILE TILEMAT[16][32];



typedef struct { u32 data[16]; } TILE_D;

typedef TILE_D TILEBLOCK_D[256];
typedef TILE_D TILEROW_D[16];
typedef TILE_D TILEMAT_D[16][16];

enum eTileBlocks
{
 TB_BG0=0, TB_BG1, TB_BG2, TB_BG3,
 TB_OBJ, TB_OBJ_LO=TB_OBJ, TB_OBJ_HI
};
# 158 "../tonclib/vid.h"
extern u16* vid_page;
# 171 "../tonclib/vid.h"
static inline void vid_cnt(u16 mode, u16 layer, u16 win, u16 flags);

static inline void vid_set_mode(u16 mode);

static inline u32 vid_is_vblank();
static inline void vid_irq_cond(u8 vcount);


void vid_sanity();


static inline void _vid_plot8(int x, int y, u8 clr);
static inline void _vid_plot16(int x, int y, COLOR clr);

u16* vid_flip();
static inline void vid_wait_for_vblank();
static inline void vid_wait_for_vdraw();
static inline void vid_vsync();
void vid_wait(int count);



static inline void vid_mosaic(u8 bh, u8 bv, u8 oh, u8 ov);


static inline void bld_cnt(u16 top, u16 bot, u16 mode);
static inline void bld_cnt_top(u16 top);
static inline void bld_cnt_mode(u16 mode);
static inline void bld_cnt_bottom(u16 bot);
static inline void bld_set_weights(u8 top, u8 bot);
static inline void bld_set_fade(u8 fade);


void win_init(u16 wins);

static inline void win0_set_rect(u8 l, u8 t, u8 r, u8 b);
static inline void win1_set_rect(u8 l, u8 t, u8 r, u8 b);

static inline void win_in_cnt(u8 mode0, u8 mode1);
static inline void win0_cnt(u8 mode);
static inline void win1_cnt(u8 mode);
static inline void win_out_cnt(u8 mode);
static inline void win_obj_cnt(u8 mode);





static inline void vid_cnt(u16 mode, u16 layer, u16 win, u16 flags)
{ *(vu32*)(0x04000000 +0x0000)= (win&0xe000) | (layer&0x1f00) | (mode&7) | flags; }

static inline void vid_set_mode(u16 mode)
{ *(vu32*)(0x04000000 +0x0000) &= ~7; *(vu32*)(0x04000000 +0x0000) |= mode&7; }

static inline void vid_irq_cond(u8 vcount)
{ *(vu16*)(0x04000000 +0x0004) &= 0x00ff; *(vu16*)(0x04000000 +0x0004) |= vcount<<8; }



static inline void _vid_plot8(int x, int y, u8 clr)
{ ((u8*)vid_page)[x + y*240]= clr; }


static inline void _vid_plot16(int x, int y, COLOR clr)
{ vid_page[x + y*240]= clr; }


static inline u32 vid_is_vblank()
{ return *(vu16*)(0x04000000 +0x0004) & 0x0001; }

static inline void vid_wait_for_vblank()
{ while(*(vu16*)(0x04000000 +0x0006) < 160); }

static inline void vid_wait_for_vdraw()
{ while(*(vu16*)(0x04000000 +0x0006) >= 160); }



static inline void vid_vsync()
{ vid_wait_for_vdraw(); vid_wait_for_vblank(); }




static inline void vid_mosaic(u8 bh, u8 bv, u8 oh, u8 ov)
{ *(vu32*)(0x04000000 +0x004C)= bh + (bv<<4) + (oh<<8) + (ov<<12); }


static inline void bld_cnt(u16 top, u16 bot, u16 mode)
{ *(vu16*)(0x04000000 +0x0050)= (top&0x3f) | (bot<<8) | mode; }

static inline void bld_cnt_top(u16 top)
{ *(vu16*)(0x04000000 +0x0050) &= ~0x003f; *(vu16*)(0x04000000 +0x0050) |= top; }

static inline void bld_cnt_mode(u16 mode)
{ *(vu16*)(0x04000000 +0x0050) &= ~0x00c0; *(vu16*)(0x04000000 +0x0050) |= mode; }

static inline void bld_cnt_bottom(u16 bot)
{ *(vu16*)(0x04000000 +0x0050) &= ~0x3f00; *(vu16*)(0x04000000 +0x0050) |= (bot<<8); }


static inline void bld_set_weights(u8 top, u8 bot)
{ *(vu16*)(0x04000000 +0x0052)= (top&0x1f) | (bot<<8); }

static inline void bld_set_fade(u8 fade)
{ *(vu16*)(0x04000000 +0x0054)= fade; }





static inline void win0_set_rect(u8 l, u8 t, u8 r, u8 b)
{ *(vu16*)(0x04000000 +0x0040)= (l<<8) | r; *(vu16*)(0x04000000 +0x0044)= (t<<8) | b; }

static inline void win1_set_rect(u8 l, u8 t, u8 r, u8 b)
{ *(vu16*)(0x04000000 +0x0042)= (l<<8) | r; *(vu16*)(0x04000000 +0x0046)= (t<<8) | b; }


static inline void win_in_cnt(u8 mode0, u8 mode1)
{ *(vu16*)(0x04000000 +0x0048)= (mode1<<8) | mode0; }

static inline void win0_cnt(u8 mode)
{ *(vu16*)(0x04000000 +0x0048) &= 0xff00; *(vu16*)(0x04000000 +0x0048) |= mode; }

static inline void win1_cnt(u8 mode)
{ *(vu16*)(0x04000000 +0x0048) &= 0x00ff; *(vu16*)(0x04000000 +0x0048) |= (mode<<8); }

static inline void win_out_cnt(u8 mode)
{ *(vu16*)(0x04000000 +0x004A) &= 0xff00; *(vu16*)(0x04000000 +0x004A) |= mode; }

static inline void win_obj_cnt(u8 mode)
{ *(vu16*)(0x04000000 +0x004A) &= 0x00ff; *(vu16*)(0x04000000 +0x004A) |= (mode<<8); }
# 37 "../tonclib/tonc_gba.h" 2

# 1 "../tonclib/bg.h" 1
# 60 "../tonclib/bg.h"
typedef TEGEL MAPBLOCK[32*32];
typedef TEGEL MAPROW[32];
typedef TEGEL MAPMAT[32][32];
# 77 "../tonclib/bg.h"
typedef struct tagBGINFO
{
 u16 nr;
 u16 reg;
 union { TILE *tiles; TILEBLOCK *tb; };
 union { TEGEL *map; MAPBLOCK *mb; };
 BOOL bAffine;


 BGAFF bga;
 s32 dx;
 s32 dy;
} BGINFO;

typedef struct { u16 hofs,vofs; } BGPOINT;
# 105 "../tonclib/bg.h"
void bg_init(BGINFO *bg, int bgnr, int tb_base, int map_base, u16 flags);
void bg_update(const BGINFO *bg);
void bga_post_translate(BGINFO *bg, s32 x, s32 y);
static inline void bg_set_pos(BGINFO *bg, FIXED dx, FIXED dy);
int bg_tegel_id(BGINFO *bg, u16 tx, u16 ty);

static inline void bg_rotscale(BGINFO *bg, AFF_SRC_EX *asx);
static inline void bga_ex_update(const BGINFO *bg);


void map_fill(MAPBLOCK *mb, TEGEL tegel);
void map_fill_line(MAPBLOCK *mb, int line, TEGEL tegel);
void map_fill_rect(MAPBLOCK *mb, const RECT *rc, TEGEL tegel);
# 131 "../tonclib/bg.h"
static inline void bg_set_pos(BGINFO *bg, FIXED dx, FIXED dy)
{ bg->dx= dx; bg->dy= dy; }

static inline void bg_rotscale(BGINFO *bg, AFF_SRC_EX *asx)
{ bga_rs_ex((BGAFF_EX*)(&bg->bga), asx); }

static inline void bga_ex_update(const BGINFO *bg)
{ ((BGAFF_EX*)0x04000000)[bg->nr]= *(BGAFF_EX*)(&bg->bga); }
# 39 "../tonclib/tonc_gba.h" 2

# 1 "../tonclib/oam.h" 1
# 72 "../tonclib/oam.h"
typedef struct tagOBJINFO
{
 u16 attr0;
 u16 attr1;
 u16 attr2;
 s16 fill;
} OBJINFO;
# 106 "../tonclib/oam.h"
extern OBJINFO oi_buffer[];
extern OBJAFF * const oa_buffer;




void oam_init();
void oam_update(int start, int num);


static inline int oi_oam2aff(const OBJINFO *oi);
static inline int oi_oam2prio(const OBJINFO *oi);
static inline int oi_oam2pal(const OBJINFO *oi);

static inline void oi_set_attr(OBJINFO *oi, u16 a0, u16 a1, u16 a2);
void oi_set_pos(OBJINFO *oi, int x, int y);
void oi_hide(OBJINFO *oi);
void oi_copy(OBJINFO *dest, OBJINFO *src);
void oi_update(int start, int num);


void oa_update(int start, int num);
# 146 "../tonclib/oam.h"
static inline int oi_oam2aff(const OBJINFO *oi)
{ return (oi->attr1 & 0x3e00)>>9; }

static inline int oi_oam2prio(const OBJINFO *oi)
{ return (oi->attr2 & 0x0c00)>>10; }

static inline int oi_oam2pal(const OBJINFO *oi)
{ return oi->attr2>>12; }

static inline void oi_set_attr(OBJINFO *oi, u16 a0, u16 a1, u16 a2)
{ oi->attr0= a0; oi->attr1= a1; oi->attr2= a2; }
# 41 "../tonclib/tonc_gba.h" 2


}
# 8 "main.cpp" 2
# 1 "c:/prog/dkA/bin/../lib/gcc/arm-elf/3.4.3/../../../../arm-elf/include/stdlib.h" 1 3
# 10 "c:/prog/dkA/bin/../lib/gcc/arm-elf/3.4.3/../../../../arm-elf/include/stdlib.h" 3
# 1 "c:/prog/dkA/bin/../lib/gcc/arm-elf/3.4.3/../../../../arm-elf/include/_ansi.h" 1 3
# 15 "c:/prog/dkA/bin/../lib/gcc/arm-elf/3.4.3/../../../../arm-elf/include/_ansi.h" 3
# 1 "c:/prog/dkA/bin/../lib/gcc/arm-elf/3.4.3/../../../../arm-elf/include/newlib.h" 1 3
# 16 "c:/prog/dkA/bin/../lib/gcc/arm-elf/3.4.3/../../../../arm-elf/include/_ansi.h" 2 3
# 1 "c:/prog/dkA/bin/../lib/gcc/arm-elf/3.4.3/../../../../arm-elf/include/sys/config.h" 1 3



# 1 "c:/prog/dkA/bin/../lib/gcc/arm-elf/3.4.3/../../../../arm-elf/include/machine/ieeefp.h" 1 3
# 5 "c:/prog/dkA/bin/../lib/gcc/arm-elf/3.4.3/../../../../arm-elf/include/sys/config.h" 2 3
# 17 "c:/prog/dkA/bin/../lib/gcc/arm-elf/3.4.3/../../../../arm-elf/include/_ansi.h" 2 3
# 11 "c:/prog/dkA/bin/../lib/gcc/arm-elf/3.4.3/../../../../arm-elf/include/stdlib.h" 2 3



# 1 "c:/prog/dkA/bin/../lib/gcc/arm-elf/3.4.3/include/stddef.h" 1 3 4
# 213 "c:/prog/dkA/bin/../lib/gcc/arm-elf/3.4.3/include/stddef.h" 3 4
typedef long unsigned int size_t;
# 15 "c:/prog/dkA/bin/../lib/gcc/arm-elf/3.4.3/../../../../arm-elf/include/stdlib.h" 2 3

# 1 "c:/prog/dkA/bin/../lib/gcc/arm-elf/3.4.3/../../../../arm-elf/include/sys/reent.h" 1 3
# 9 "c:/prog/dkA/bin/../lib/gcc/arm-elf/3.4.3/../../../../arm-elf/include/sys/reent.h" 3
extern "C" {



# 1 "c:/prog/dkA/bin/../lib/gcc/arm-elf/3.4.3/../../../../arm-elf/include/_ansi.h" 1 3
# 14 "c:/prog/dkA/bin/../lib/gcc/arm-elf/3.4.3/../../../../arm-elf/include/sys/reent.h" 2 3
# 1 "c:/prog/dkA/bin/../lib/gcc/arm-elf/3.4.3/../../../../arm-elf/include/sys/_types.h" 1 3
# 12 "c:/prog/dkA/bin/../lib/gcc/arm-elf/3.4.3/../../../../arm-elf/include/sys/_types.h" 3
typedef long _off_t;
__extension__ typedef long long _off64_t;


typedef int _ssize_t;





# 1 "c:/prog/dkA/bin/../lib/gcc/arm-elf/3.4.3/include/stddef.h" 1 3 4
# 354 "c:/prog/dkA/bin/../lib/gcc/arm-elf/3.4.3/include/stddef.h" 3 4
typedef unsigned int wint_t;
# 23 "c:/prog/dkA/bin/../lib/gcc/arm-elf/3.4.3/../../../../arm-elf/include/sys/_types.h" 2 3


typedef struct
{
  int __count;
  union
  {
    wint_t __wch;
    unsigned char __wchb[4];
  } __value;
} _mbstate_t;

typedef int _flock_t;


typedef void *_iconv_t;
# 15 "c:/prog/dkA/bin/../lib/gcc/arm-elf/3.4.3/../../../../arm-elf/include/sys/reent.h" 2 3




typedef unsigned long __ULong;
# 40 "c:/prog/dkA/bin/../lib/gcc/arm-elf/3.4.3/../../../../arm-elf/include/sys/reent.h" 3
struct _Bigint
{
  struct _Bigint *_next;
  int _k, _maxwds, _sign, _wds;
  __ULong _x[1];
};


struct __tm
{
  int __tm_sec;
  int __tm_min;
  int __tm_hour;
  int __tm_mday;
  int __tm_mon;
  int __tm_year;
  int __tm_wday;
  int __tm_yday;
  int __tm_isdst;
};







struct _on_exit_args {
 void * _fnargs[32];
 __ULong _fntypes;

};
# 80 "c:/prog/dkA/bin/../lib/gcc/arm-elf/3.4.3/../../../../arm-elf/include/sys/reent.h" 3
struct _atexit {
 struct _atexit *_next;
 int _ind;
 void (*_fns[32])(void);
        struct _on_exit_args _on_exit_args;
};
# 95 "c:/prog/dkA/bin/../lib/gcc/arm-elf/3.4.3/../../../../arm-elf/include/sys/reent.h" 3
struct __sbuf {
 unsigned char *_base;
 int _size;
};






typedef long _fpos_t;
# 160 "c:/prog/dkA/bin/../lib/gcc/arm-elf/3.4.3/../../../../arm-elf/include/sys/reent.h" 3
struct __sFILE {
  unsigned char *_p;
  int _r;
  int _w;
  short _flags;
  short _file;
  struct __sbuf _bf;
  int _lbfsize;






  void * _cookie;

  int (*_read) (void * _cookie, char *_buf, int _n);
  int (*_write) (void * _cookie, const char *_buf, int _n);

  _fpos_t (*_seek) (void * _cookie, _fpos_t _offset, int _whence);
  int (*_close) (void * _cookie);


  struct __sbuf _ub;
  unsigned char *_up;
  int _ur;


  unsigned char _ubuf[3];
  unsigned char _nbuf[1];


  struct __sbuf _lb;


  int _blksize;
  int _offset;


  struct _reent *_data;



  _flock_t _lock;

};
# 253 "c:/prog/dkA/bin/../lib/gcc/arm-elf/3.4.3/../../../../arm-elf/include/sys/reent.h" 3
typedef struct __sFILE __FILE;


struct _glue
{
  struct _glue *_next;
  int _niobs;
  __FILE *_iobs;
};
# 284 "c:/prog/dkA/bin/../lib/gcc/arm-elf/3.4.3/../../../../arm-elf/include/sys/reent.h" 3
struct _rand48 {
  unsigned short _seed[3];
  unsigned short _mult[3];
  unsigned short _add;




};
# 533 "c:/prog/dkA/bin/../lib/gcc/arm-elf/3.4.3/../../../../arm-elf/include/sys/reent.h" 3
struct _reent
{
  int _errno;




  __FILE *_stdin, *_stdout, *_stderr;

  int _inc;
  char _emergency[25];

  int _current_category;
  const char *_current_locale;

  int __sdidinit;

  void (*__cleanup) (struct _reent *);


  struct _Bigint *_result;
  int _result_k;
  struct _Bigint *_p5s;
  struct _Bigint **_freelist;


  int _cvtlen;
  char *_cvtbuf;

  union
    {
      struct
        {
          unsigned int _unused_rand;
          char * _strtok_last;
          char _asctime_buf[26];
          struct __tm _localtime_buf;
          int _gamma_signgam;
          __extension__ unsigned long long _rand_next;
          struct _rand48 _r48;
          _mbstate_t _mblen_state;
          _mbstate_t _mbtowc_state;
          _mbstate_t _wctomb_state;
          char _l64a_buf[8];
          char _signal_buf[24];
          int _getdate_err;
          _mbstate_t _mbrlen_state;
          _mbstate_t _mbrtowc_state;
          _mbstate_t _mbsrtowcs_state;
          _mbstate_t _wcrtomb_state;
          _mbstate_t _wcsrtombs_state;
        } _reent;



      struct
        {

          unsigned char * _nextf[30];
          unsigned int _nmalloc[30];
        } _unused;
    } _new;


  struct _atexit *_atexit;
  struct _atexit _atexit0;


  void (**(_sig_func))(int);




  struct _glue __sglue;
  __FILE __sf[3];
};
# 730 "c:/prog/dkA/bin/../lib/gcc/arm-elf/3.4.3/../../../../arm-elf/include/sys/reent.h" 3
extern struct _reent *_impure_ptr ;

void _reclaim_reent (struct _reent *);
# 750 "c:/prog/dkA/bin/../lib/gcc/arm-elf/3.4.3/../../../../arm-elf/include/sys/reent.h" 3
}
# 17 "c:/prog/dkA/bin/../lib/gcc/arm-elf/3.4.3/../../../../arm-elf/include/stdlib.h" 2 3
# 1 "c:/prog/dkA/bin/../lib/gcc/arm-elf/3.4.3/../../../../arm-elf/include/machine/stdlib.h" 1 3
# 18 "c:/prog/dkA/bin/../lib/gcc/arm-elf/3.4.3/../../../../arm-elf/include/stdlib.h" 2 3

# 1 "c:/prog/dkA/bin/../lib/gcc/arm-elf/3.4.3/../../../../arm-elf/include/alloca.h" 1 3
# 20 "c:/prog/dkA/bin/../lib/gcc/arm-elf/3.4.3/../../../../arm-elf/include/stdlib.h" 2 3


extern "C" {

typedef struct
{
  int quot;
  int rem;
} div_t;

typedef struct
{
  long quot;
  long rem;
} ldiv_t;


typedef struct
{
  long long int quot;
  long long int rem;
} lldiv_t;
# 53 "c:/prog/dkA/bin/../lib/gcc/arm-elf/3.4.3/../../../../arm-elf/include/stdlib.h" 3
extern int __mb_cur_max;



void abort (void) __attribute__ ((noreturn));
int abs (int);
int atexit (void (*__func)(void));
double atof (const char *__nptr);

float atoff (const char *__nptr);

int atoi (const char *__nptr);
int _atoi_r (struct _reent *, const char *__nptr);
long atol (const char *__nptr);
long _atol_r (struct _reent *, const char *__nptr);
void * bsearch (const void * __key, const void * __base, size_t __nmemb, size_t __size, int (* _compar) (const void *, const void *));




void * calloc (size_t __nmemb, size_t __size);
div_t div (int __numer, int __denom);
void exit (int __status) __attribute__ ((noreturn));
void free (void *);
char * getenv (const char *__string);
char * _getenv_r (struct _reent *, const char *__string);



char * _findenv (const char *, int *);
char * _findenv_r (struct _reent *, const char *, int *);
long labs (long);
ldiv_t ldiv (long __numer, long __denom);
void * malloc (size_t __size);
int mblen (const char *, size_t);
int _mblen_r (struct _reent *, const char *, size_t, _mbstate_t *);
int mbtowc (wchar_t *, const char *, size_t);
int _mbtowc_r (struct _reent *, wchar_t *, const char *, size_t, _mbstate_t *);
int wctomb (char *, wchar_t);
int _wctomb_r (struct _reent *, char *, wchar_t, _mbstate_t *);
size_t mbstowcs (wchar_t *, const char *, size_t);
size_t _mbstowcs_r (struct _reent *, wchar_t *, const char *, size_t, _mbstate_t *);
size_t wcstombs (char *, const wchar_t *, size_t);
size_t _wcstombs_r (struct _reent *, char *, const wchar_t *, size_t, _mbstate_t *);


int mkstemp (char *);
char * mktemp (char *);


void qsort (void * __base, size_t __nmemb, size_t __size, int(*_compar)(const void *, const void *));
int rand (void);
void * realloc (void * __r, size_t __size);



void srand (unsigned __seed);
double strtod (const char *__n, char **__end_PTR);
double _strtod_r (struct _reent *,const char *__n, char **__end_PTR);
float strtof (const char *__n, char **__end_PTR);






long strtol (const char *__n, char **__end_PTR, int __base);
long _strtol_r (struct _reent *,const char *__n, char **__end_PTR, int __base);
unsigned long strtoul (const char *__n, char **__end_PTR, int __base);
unsigned long _strtoul_r (struct _reent *,const char *__n, char **__end_PTR, int __base);

int system (const char *__string);


long a64l (const char *__input);
char * l64a (long __input);
char * _l64a_r (struct _reent *,long __input);
int on_exit (void (*__func)(int, void *),void * __arg);
void _Exit (int __status) __attribute__ ((noreturn));
int putenv (const char *__string);
int _putenv_r (struct _reent *, const char *__string);
int setenv (const char *__string, const char *__value, int __overwrite);
int _setenv_r (struct _reent *, const char *__string, const char *__value, int __overwrite);

char * gcvt (double,int,char *);
char * gcvtf (float,int,char *);
char * fcvt (double,int,int *,int *);
char * fcvtf (float,int,int *,int *);
char * ecvt (double,int,int *,int *);
char * ecvtbuf (double, int, int*, int*, char *);
char * fcvtbuf (double, int, int*, int*, char *);
char * ecvtf (float,int,int *,int *);
char * dtoa (double, int, int, int *, int*, char**);
int rand_r (unsigned *__seed);

double drand48 (void);
double _drand48_r (struct _reent *);
double erand48 (unsigned short [3]);
double _erand48_r (struct _reent *, unsigned short [3]);
long jrand48 (unsigned short [3]);
long _jrand48_r (struct _reent *, unsigned short [3]);
void lcong48 (unsigned short [7]);
void _lcong48_r (struct _reent *, unsigned short [7]);
long lrand48 (void);
long _lrand48_r (struct _reent *);
long mrand48 (void);
long _mrand48_r (struct _reent *);
long nrand48 (unsigned short [3]);
long _nrand48_r (struct _reent *, unsigned short [3]);
unsigned short *
       seed48 (unsigned short [3]);
unsigned short *
       _seed48_r (struct _reent *, unsigned short [3]);
void srand48 (long);
void _srand48_r (struct _reent *, long);
long long atoll (const char *__nptr);
long long _atoll_r (struct _reent *, const char *__nptr);
long long llabs (long long);
lldiv_t lldiv (long long __numer, long long __denom);
long long strtoll (const char *__n, char **__end_PTR, int __base);
long long _strtoll_r (struct _reent *, const char *__n, char **__end_PTR, int __base);
unsigned long long strtoull (const char *__n, char **__end_PTR, int __base);
unsigned long long _strtoull_r (struct _reent *, const char *__n, char **__end_PTR, int __base);


void cfree (void *);
# 192 "c:/prog/dkA/bin/../lib/gcc/arm-elf/3.4.3/../../../../arm-elf/include/stdlib.h" 3
char * _dtoa_r (struct _reent *, double, int, int, int *, int*, char**);

void * _malloc_r (struct _reent *, size_t);
void * _calloc_r (struct _reent *, size_t, size_t);
void _free_r (struct _reent *, void *);
void * _realloc_r (struct _reent *, void *, size_t);
void _mstats_r (struct _reent *, char *);

int _system_r (struct _reent *, const char *);

void __eprintf (const char *, const char *, unsigned int, const char *);
# 233 "c:/prog/dkA/bin/../lib/gcc/arm-elf/3.4.3/../../../../arm-elf/include/stdlib.h" 3
}
# 9 "main.cpp" 2
# 1 "LibAAS/AAS.h" 1
# 16 "LibAAS/AAS.h"
extern "C" {
# 73 "LibAAS/AAS.h"
int AAS_SetConfig( int config_mix, int config_chans, int config_spatial, int config_dynamic );
void AAS_DoDMA3( void* source, void* dest, unsigned int flags_and_length );
void AAS_ShowLogo();


void AAS_Timer1InterruptHandler();
void AAS_FastTimer1InterruptHandler();
void AAS_DoWork();


int AAS_SFX_Play( int channel, int sample_volume, int sample_frequency, const signed char* sample_start, const signed char* sample_end, const signed char* sample_restart );
unsigned char AAS_SFX_ChannelExists( int channel );
unsigned char AAS_SFX_IsActive( int channel );
int AAS_SFX_EndLoop( int channel );
int AAS_SFX_SetFrequency( int channel, int sample_frequency );
int AAS_SFX_SetVolume( int channel, int sample_volume );
int AAS_SFX_Stop( int channel );
int AAS_SFX_Resume( int channel );
int AAS_SFX_GetNumChannels();


int AAS_MOD_Play( int song_num );
int AAS_MOD_SetLoop( unsigned char loop );
void AAS_MOD_Stop();
unsigned char AAS_MOD_IsPlaying();
unsigned char AAS_MOD_HasLooped();
int AAS_MOD_GetVolume();
int AAS_MOD_SetVolume( int vol );
int AAS_MOD_GetSongPos();
int AAS_MOD_SetSongPos( int song_pos );
int AAS_MOD_QueueSongPos( int song_pos );
int AAS_MOD_GetLineNum();
int AAS_MOD_GetLastFilterValue();
void AAS_MOD_Pause();
void AAS_MOD_Resume();
int AAS_MOD_GetNumChannels();


const signed char* AAS_GetOutputBufferAddress( int buffer );
int AAS_GetOutputBufferLength();
int AAS_GetActualMixRate();

}
# 10 "main.cpp" 2
# 1 "AAS_Data.h" 1
# 10 "AAS_Data.h"
extern "C" {

extern const unsigned char AAS_DATA_MOD_baPinball;

extern const unsigned char AAS_DATA_MOD_baTunnelEnd2;

extern const signed char* const AAS_DATA_SFX_START_beepcoll;

extern const signed char* const AAS_DATA_SFX_END_beepcoll;

extern const signed char* const AAS_DATA_SFX_START_bouncer;

extern const signed char* const AAS_DATA_SFX_END_bouncer;

extern const unsigned char AAS_DATA_MOD_btlemend;

extern const signed char* const AAS_DATA_SFX_START_explos;

extern const signed char* const AAS_DATA_SFX_END_explos;

}
# 11 "main.cpp" 2
# 1 "bitwise.h" 1
# 12 "main.cpp" 2
# 1 "palls.h" 1







extern const unsigned int pallsPal[];
# 13 "main.cpp" 2
# 1 "affine.h" 1
# 14 "main.cpp" 2
# 1 "luts.h" 1
# 9 "luts.h"
# 1 "../tonclib/types.h" 1
# 10 "luts.h" 2


extern "C" {



# 1 "../tonclib/sinlut.h" 1
# 16 "../tonclib/sinlut.h"
extern const signed short _sinLUT[];
# 17 "luts.h" 2
# 1 "../tonclib/divlut.h" 1
# 15 "../tonclib/divlut.h"
extern const signed int DIV[];
# 18 "luts.h" 2
# 43 "luts.h"
}
# 15 "main.cpp" 2
# 1 "holdforasec.h" 1
# 16 "main.cpp" 2
# 1 "starbig.h" 1







extern const int starbigWidth;
extern const int starbigHeight;
extern const int starbigLen;
extern const unsigned int starbigData[];
# 17 "main.cpp" 2
# 1 "numbers.h" 1







extern const int numbersWidth;
extern const int numbersHeight;
extern const int numbersLen;
extern const unsigned int numbersData[];
extern const int numbersPalLen;
extern const unsigned int numbersPal[];
# 18 "main.cpp" 2
# 1 "grey.h" 1







extern const unsigned int greyPal[];
# 19 "main.cpp" 2
# 1 "fragment.h" 1







extern const int fragmentWidth;
extern const int fragmentHeight;
extern const int fragmentLen;
extern const unsigned int fragmentData[];
# 20 "main.cpp" 2
# 1 "bullets.h" 1







extern const int bulletsWidth;
extern const int bulletsHeight;
extern const int bulletsLen;
extern const unsigned int bulletsData[];
# 21 "main.cpp" 2
# 1 "starscale1.h" 1
# 12 "starscale1.h"
extern const signed short RECIPSTARSCALE[175];
# 22 "main.cpp" 2
# 1 "starrot1.h" 1
# 12 "starrot1.h"
extern const signed short STARROT[175];
# 23 "main.cpp" 2
# 1 "cursorp.h" 1







extern const int cursorpWidth;
extern const int cursorpHeight;
extern const int cursorpLen;
extern const unsigned int cursorpData[];
extern const int cursorpPalLen;
extern const unsigned int cursorpPal[];
# 24 "main.cpp" 2
# 1 "collect.h" 1







extern const int collectWidth;
extern const int collectHeight;
extern const int collectLen;
extern const unsigned int collectData[];
# 25 "main.cpp" 2
# 1 "sparkle.h" 1







extern const int sparkleWidth;
extern const int sparkleHeight;
extern const int sparkleLen;
extern const unsigned int sparkleData[];
# 26 "main.cpp" 2
# 1 "sparkle2.h" 1







extern const int sparkle2Width;
extern const int sparkle2Height;
extern const int sparkle2Len;
extern const unsigned int sparkle2Data[];
# 27 "main.cpp" 2
# 1 "gameovertiles.h" 1







extern const int gameovertilesWidth;
extern const int gameovertilesHeight;
extern const int gameovertilesLen;
extern const unsigned int gameovertilesData[];
extern const int gameovertilesPalLen;
extern const unsigned int gameovertilesPal[];
# 28 "main.cpp" 2
# 1 "largenum.h" 1







extern const int largenumWidth;
extern const int largenumHeight;
extern const int largenumLen;
extern const unsigned int largenumData[];
# 29 "main.cpp" 2
# 1 "bigtarg.h" 1







extern const int bigtargWidth;
extern const int bigtargHeight;
extern const int bigtargLen;
extern const unsigned int bigtargData[];
# 30 "main.cpp" 2
# 1 "swooshd.h" 1







extern const int swooshdWidth;
extern const int swooshdHeight;
extern const int swooshdLen;
extern const unsigned int swooshdData[];
extern const int swooshdPalLen;
extern const unsigned int swooshdPal[];
# 31 "main.cpp" 2
# 1 "bigtime.h" 1







extern const int bigtimeWidth;
extern const int bigtimeHeight;
extern const int bigtimeLen;
extern const unsigned int bigtimeData[];
# 32 "main.cpp" 2
# 1 "retrytext.h" 1







extern const int retrytextWidth;
extern const int retrytextHeight;
extern const int retrytextLen;
extern const unsigned int retrytextData[];
extern const int retrytextPalLen;
extern const unsigned int retrytextPal[];
# 33 "main.cpp" 2
# 1 "mattpresents.h" 1







extern const int mattpresentsWidth;
extern const int mattpresentsHeight;
extern const int mattpresentsLen;
extern const unsigned int mattpresentsData[];
extern const int mattpresentsPalLen;
extern const unsigned int mattpresentsPal[];
# 34 "main.cpp" 2
# 1 "blastarenaletters.h" 1







extern const int blastarenalettersWidth;
extern const int blastarenalettersHeight;
extern const int blastarenalettersLen;
extern const unsigned int blastarenalettersData[];
extern const int blastarenalettersPalLen;
extern const unsigned int blastarenalettersPal[];
# 35 "main.cpp" 2
# 1 "blastarenatitlescreen.h" 1







extern const int blastarenatitlescreenWidth;
extern const int blastarenatitlescreenHeight;
extern const int blastarenatitlescreenLen;
extern const unsigned int blastarenatitlescreenData[];
extern const int blastarenatitlescreenPalLen;
extern const unsigned int blastarenatitlescreenPal[];
# 36 "main.cpp" 2
# 1 "advancehalves.h" 1







extern const int advancehalvesWidth;
extern const int advancehalvesHeight;
extern const int advancehalvesLen;
extern const unsigned int advancehalvesData[];
extern const int advancehalvesPalLen;
extern const unsigned int advancehalvesPal[];
# 37 "main.cpp" 2
# 1 "presstaletters.h" 1







extern const int presstalettersWidth;
extern const int presstalettersHeight;
extern const int presstalettersLen;
extern const unsigned int presstalettersData[];
extern const int presstalettersPalLen;
extern const unsigned int presstalettersPal[];
# 38 "main.cpp" 2
# 1 "finalbars.h" 1







extern const int finalbarsWidth;
extern const int finalbarsHeight;
extern const int finalbarsLen;
extern const unsigned int finalbarsData[];
extern const int finalbarsPalLen;
extern const unsigned int finalbarsPal[];
# 39 "main.cpp" 2
# 1 "menuletters.h" 1







extern const int menulettersWidth;
extern const int menulettersHeight;
extern const int menulettersLen;
extern const unsigned int menulettersData[];
extern const int menulettersPalLen;
extern const unsigned int menulettersPal[];
# 40 "main.cpp" 2
# 1 "whiteline.h" 1







extern const int whitelineWidth;
extern const int whitelineHeight;
extern const int whitelineLen;
extern const unsigned int whitelineData[];
# 41 "main.cpp" 2
# 1 "blankline.h" 1







extern const int blanklineWidth;
extern const int blanklineHeight;
extern const int blanklineLen;
extern const unsigned int blanklineData[];
# 42 "main.cpp" 2
# 1 "BGbackg.h" 1







extern const int BGbackgWidth;
extern const int BGbackgHeight;
extern const int BGbackgLen;
extern const unsigned int BGbackgData[];
extern const int BGbackgPalLen;
extern const unsigned int BGbackgPal[];
# 43 "main.cpp" 2
# 1 "BGsprites.h" 1







extern const int BGspritesWidth;
extern const int BGspritesHeight;
extern const int BGspritesLen;
extern const unsigned int BGspritesData[];
extern const int BGspritesPalLen;
extern const unsigned int BGspritesPal[];
# 44 "main.cpp" 2
# 1 "texttiles.h" 1







extern const int texttilesWidth;
extern const int texttilesHeight;
extern const int texttilesLen;
extern const unsigned int texttilesData[];
# 45 "main.cpp" 2
# 1 "texttiles2.h" 1
# 46 "main.cpp" 2
# 1 "messages.h" 1



extern const char copyright2[];
extern const char copyright[];
# 47 "main.cpp" 2
# 71 "main.cpp"
typedef struct tagHiscore {
   u8 character[8];
   u16 flanges;
   u16 timeins;
} HISCORE;

u8 playername[8] = {0, 0, 0, 0, 0, 0, 0, 0};






inline vu16 rng_rand(vu16 rng)
{ return (rand()&0x7fff)*rng>>15; }
# 95 "main.cpp"
vu8 cheatmodes = 0;
# 107 "main.cpp"
vu8 sfxflags = 1 | 2 | 128;







void VBlankInterruptHandler() {
   *(vu16*)(0x04000000 +0x0208) = 0;
   AAS_DoWork();
   *(vu16*)(0x04000000 -0x0008) = 0x0001;

   *(vu16*)(0x04000000 +0x0202) = 1;

   *(vu16*)(0x04000000 +0x0208) = 1;
}





s16 hfadeline = 0;
u8 HBlanksituation = 0;
u8 VCOUNTER;

void HBlankInterruptHandler() {
   *(vu16*)(0x04000000 +0x0208) = 0;
   VCOUNTER = (*(vu16*)(0x04000000 +0x0006) == 227) ? 0 : (*(vu16*)(0x04000000 +0x0006)+1);

   if (HBlanksituation == 0) {
   } else if (HBlanksituation == 1) {



      if (VCOUNTER > (hfadeline)) {
         *(vu16*)(0x04000000 +0x0050) = 2 | 64 | 256;
         (*(vu16*)(0x04000052)) = 16;
      } else if (VCOUNTER > (hfadeline-12)) {
         *(vu16*)(0x04000000 +0x0050) = 2 | 128;
         (*(vu16*)(0x04000054)) = 16;
      } else if (VCOUNTER > (hfadeline - 32 -12)) {
         *(vu16*)(0x04000000 +0x0050) = 2 | 128;
         (*(vu16*)(0x04000054)) = ((VCOUNTER - (hfadeline-32 -12))>>1);
      } else {
         *(vu16*)(0x04000000 +0x0050) = 0;
      }
   } else if (HBlanksituation == 2) {



      if (VCOUNTER < 79) {
         if (VCOUNTER < (79-hfadeline-32)) {
            *(vu16*)(0x04000000 +0x0050) = 0;
         } else {
            if (VCOUNTER < (79-hfadeline)) {
               *(vu16*)(0x04000000 +0x0050) = 4 | 16 | 128 | 64;
               (*(vu16*)(0x04000054)) = (((VCOUNTER - (79-hfadeline-32))>>1));
            } else {
               *(vu16*)(0x04000000 +0x0050) = 4 | 16 | 128 | 64;
               (*(vu16*)(0x04000054)) = 16;
            }
         }
      } else {
         if (VCOUNTER < (80+hfadeline)) {
            *(vu16*)(0x04000000 +0x0050) = 4 | 16 | 128 | 64;
            (*(vu16*)(0x04000054)) = 16;
         } else {
            if (VCOUNTER < (80+hfadeline+32)) {
               *(vu16*)(0x04000000 +0x0050) = 4 | 16 | 128 | 64;
               (*(vu16*)(0x04000054)) = ((((80+hfadeline+32)-VCOUNTER)>>1));
            } else {
               *(vu16*)(0x04000000 +0x0050) = 0;
            }
         }
      }
   }
   *(vu16*)(0x04000000 +0x0208) = 1;
};

void UnusedInterruptHandler() {
};

void (*AAS_IntrTable[13])(void) = {
   VBlankInterruptHandler,
   HBlankInterruptHandler,
   UnusedInterruptHandler,
   UnusedInterruptHandler,
   UnusedInterruptHandler,
   UnusedInterruptHandler,
   UnusedInterruptHandler,
   UnusedInterruptHandler,
   UnusedInterruptHandler,
   UnusedInterruptHandler,
   UnusedInterruptHandler,
   UnusedInterruptHandler,
   UnusedInterruptHandler
};


OBJINFO oi_buffer[128];
OBJAFF *const oa_buffer= (OBJAFF*)oi_buffer;

void oam_update(int start, int num)
{

   AAS_DoDMA3(&oi_buffer[start], &((OBJINFO*)0x07000000)[start], num<<1 | 0x84000000);
}


void oi_update(int start, int num)
{
   int ii;
   OBJINFO *oi= (OBJINFO*)((OBJINFO*)0x07000000);
   for(ii=start; ii<start+num; ii++)
   {
      oi[ii].attr0= oi_buffer[ii].attr0;
      oi[ii].attr1= oi_buffer[ii].attr1;
      oi[ii].attr2= oi_buffer[ii].attr2;
   }
}


void oa_update(int start, int num)
{
   int ii;
   OBJAFF *oa= (OBJAFF*)((OBJINFO*)0x07000000);
   for(ii=start; ii<start+num; ii++)
   {
      oa[ii].pa= oa_buffer[ii].pa;
      oa[ii].pb= oa_buffer[ii].pb;
      oa[ii].pc= oa_buffer[ii].pc;
      oa[ii].pd= oa_buffer[ii].pd;
   }
}



typedef struct tagExplo {
   u8 y;
   u16 x;
   u16 frameal;
   u8 offset;

   u8 palette;
} FRAG;

typedef struct tagBul {
   FIXED yF;
   FIXED xF;
   u8 flaction;

   u8 palette;
} BULL;

typedef struct wasFlange {
   u8 x;
   u8 y;
   u8 frameal;
} DUST;

 void SetUpGame() {
   *(vu32*)(0x04000000 +0x0000) = 3 | (0x0004<<8) | (0x0010<<8) | 0x0040;
   *(vu16*)(0x04000000 +0x0050) = 0;
   (*(vu16*)(0x04000054)) = 0;

   (((u16*)(0x06000000))[(0)+240*(0)]) = 0;
   (((u16*)(0x06000000))[(0)+240*(1)]) = 0;

   *(u32 *)0x06000000 = 0;
   AAS_DoDMA3((void *)0x06000000, (void *)0x06000004, 19199 | 0x84000000);






   for (u8 i=0; i<12; i++) {
      AAS_DoDMA3((void *)((u16 *)pallsPal + 16*i), (void *)(((COLOR*)(0x05000000 +0x0200))+16*i), 4 | 0x84000000);
      AAS_DoDMA3((void *)((u16 *)pallsPal + 16*(i<6?i+6:i-6) + 8), (void *)(((COLOR*)(0x05000000 +0x0200))+16*i+8), 4 | 0x84000000);
   }

   AAS_DoDMA3((void *)((u16 *)greyPal), (void *)(((COLOR*)(0x05000000 +0x0200))+192), 4 | 0x84000000);
   AAS_DoDMA3((void *)((u16 *)greyPal), (void *)(((COLOR*)(0x05000000 +0x0200))+192+8), 4 | 0x84000000);

   AAS_DoDMA3((void *)starbigData, (void *)&( (TILEBLOCK*)0x06000000 )[TB_OBJ][0+512], 512 | 0x84000000);
   AAS_DoDMA3((void *)bulletsData, (void *)&( (TILEBLOCK*)0x06000000 )[TB_OBJ][16+512+48], 24 | 0x84000000);

   AAS_DoDMA3((void *)cursorpData, (void *)&( (TILEBLOCK*)0x06000000 )[TB_OBJ][19+512+48], 8 | 0x84000000);
   AAS_DoDMA3((void *)cursorpPal, (void *)(((COLOR*)(0x05000000 +0x0200))+208), 2 | 0x84000000);
# 306 "main.cpp"
   for (u8 pall = 0; pall<12; pall++) {
      for (u8 col = 0; col<7; col++) {
         ((COLOR*)(0x05000000 +0x0200))[pall*16+8+col] = ( ((((COLOR*)(0x05000000 +0x0200))[pall*16+8+col] & ( 31)))+3 > 31 ? 31 : ((((COLOR*)(0x05000000 +0x0200))[pall*16+8+col] & ( 31)))+3) |
                                      (((((COLOR*)(0x05000000 +0x0200))[pall*16+8+col] & ( 31<<5))>>5)+3 > 31 ? 31 : ((((COLOR*)(0x05000000 +0x0200))[pall*16+8+col] & ( 31<<5))>>5)+3)<< 5 |
                                      ( ((((COLOR*)(0x05000000 +0x0200))[pall*16+8+col] & (31<<10))>>10)+3 > 31 ? 31 : ((((COLOR*)(0x05000000 +0x0200))[pall*16+8+col] & (31<<10))>>10)+3)<<10;
      }
      ((COLOR*)(0x05000000 +0x0200))[pall*16+15] = 0x7ffff;
   }



   for (u8 pall = 0; pall<12; pall++) {
      for (u8 col = 0; col<8; col++) {
           ((COLOR*)(0x05000000 +0x0200))[pall*16+col] = ( ((((COLOR*)(0x05000000 +0x0200))[pall*16+col] & ( 31)))-6 < 0 ? 0 : ((((COLOR*)(0x05000000 +0x0200))[pall*16+col] & ( 31)))-6) |
                                      (((((COLOR*)(0x05000000 +0x0200))[pall*16+col] & ( 31<<5))>>5)-6 < 0 ? 0 : ((((COLOR*)(0x05000000 +0x0200))[pall*16+col] & ( 31<<5))>>5)-6)<< 5 |
                                      ( ((((COLOR*)(0x05000000 +0x0200))[pall*16+col] & (31<<10))>>10)-6 < 0 ? 0 : ((((COLOR*)(0x05000000 +0x0200))[pall*16+col] & (31<<10))>>10)-6)<<10;
      }
   }

   AAS_DoDMA3((void *)fragmentData, (void *)&( (TILEBLOCK*)0x06000000 )[TB_OBJ][20+512+48], 8 | 0x84000000);

   AAS_DoDMA3((void *)collectData, (void *)&( (TILEBLOCK*)0x06000000 )[TB_OBJ][21+512+48], 8 | 0x84000000);
   (*((u16*)(0x050003A6))) = _RGB15(26,26,0);
   (*((u16*)(0x050003A8))) = _RGB15(31,31,0);
   (*((u16*)(0x050003AA))) = _RGB15(12,12,0);

   (*((u16*)(0x050003AC))) = _RGB15(15,15,15);
   (*((u16*)(0x050003AE))) = _RGB15( 8, 8, 8);

   (*((u16*)(0x050003B0))) = _RGB15(21,21,0);
   (*((u16*)(0x050003B2))) = _RGB15(29,29,0);
   (*((u16*)(0x050003B4))) = _RGB15(17,17,0);
   (*((u16*)(0x050003B6))) = _RGB15( 8, 8,0);

   AAS_DoDMA3((void *)sparkleData, (void *)&( (TILEBLOCK*)0x06000000 )[TB_OBJ][22+512+48], 8 | 0x84000000);
   AAS_DoDMA3((void *)sparkle2Data, (void *)&( (TILEBLOCK*)0x06000000 )[TB_OBJ][23+512+48], 8 | 0x84000000);

   AAS_DoDMA3((void *)largenumData, (void *)&( (TILEBLOCK*)0x06000000 )[TB_OBJ][24+512+48], 640 | 0x84000000);

   AAS_DoDMA3((void *)gameovertilesPal, (void *)&((COLOR*)0x05000000)[0], 20 | 0x84000000);

   AAS_DoDMA3((void *)bigtargData, (void *)&( (TILEBLOCK*)0x06000000 )[TB_OBJ][664], 32 | 0x84000000);
   AAS_DoDMA3((void *)bigtimeData, (void *)&( (TILEBLOCK*)0x06000000 )[TB_OBJ][700], 32 | 0x84000000);

   AAS_DoDMA3((void *)swooshdData, (void *)&( (TILEBLOCK*)0x06000000 )[TB_OBJ][668], 256 | 0x84000000);
   AAS_DoDMA3((void *)swooshdPal, (void *)&((COLOR*)(0x05000000 +0x0200))[224], 8 | 0x84000000);

   ((COLOR*)0x05000000)[39] = _RGB15(3, 3, 3);
   AAS_DoDMA3((void *)retrytextPal, (void *)&((COLOR*)0x05000000)[40], 4 | 0x84000000);

   srand(*(vu16*)(0x04000000 +0x0100));
# 370 "main.cpp"
}
# 387 "main.cpp"
 char Game() {

   AAS_MOD_Stop();

   u8 GameStatus = 1;



   s16 a;
   u8 obj_counter = 127, aff_counter = 0;

   FRAG explosions[30];

   for (u8 currex = 0; currex<30; currex++) {
      explosions[currex].frameal = 0;
   }

   BULL bullets[100];

   for (u8 currbull = 0; currbull<100; currbull++) {
      bullets[currbull].flaction = 0;
   }

   DUST flangedust[3];

   for (u8 currdust = 0; currdust<3; currdust++) {
      flangedust[currdust].frameal = 0;
   }

   FIXED playerx = (120<<8);
   FIXED playery = (80<<8);
   FIXED playerxs = 0;
   FIXED playerys = 0;
# 429 "main.cpp"
   u32 gametimeinVblanks = 0;
   u32 gameoverinVblanks = 0;
   u8 firsttimer = 400;

   u8 nextpopVb = 3;
   u8 NEXTnextpopVb = 200;
   u8 decrement = nextpopVb;
   u8 decrement2 = 90;

   u8 pallam2 = 0;

   u8 fadeframe = 0;

   u8 gameflags = 0;
   u16 flangecoll = 0;
   u16 flangerescount = 0;

   u8 flangex = 0;
   u8 flangey = 0;

   s16 previouswave[240];



   BGINFO back0;
   bg_init(&back0, 0, 0, 30, 0x0000 | 0x0080 | 3);
   TEGEL *tegelset0 = back0.map;

   BGINFO back1;
   bg_init(&back1, 1, 2, 31, 0x0000 | 0x0080 | 3);
   TEGEL *tegelset1 = back1.map;

   BGINFO back2;
   bg_init(&back2, 2, 0, 29, 0x0000 | 0x0080 | 0);
   TEGEL *tegelset2 = back2.map;

   BGINFO back3;
   bg_init(&back3, 3, 0, 29, 0x0000 | 0x0080 | 0);

   u16 keydowngos = 0;

   u8 hundredscollected = 0;
   u8 tenscollected = 0;
   u8 unitscollected = 0;

   u8 tensminspass = 0;
   u8 unitsminspass = 0;
   u8 tenssecspass = 0;
   u8 unitssecspass = 0;
# 494 "main.cpp"
   while ((GameStatus != 2) && (GameStatus != 3) && (GameStatus != 4)) {
    if ((GameStatus == 0) || (GameStatus == 1) || (GameStatus == 5)) {
      asm volatile("swi 0x05");
      key_poll();






      if (firsttimer>0) {
         firsttimer--;
         if (firsttimer==70) {
            if (((((sfxflags) & (2)) == (2)))) {AAS_MOD_Play(AAS_DATA_MOD_baPinball);};
         } else if (firsttimer==1) {
            firsttimer = 0;
         }
      } else {
         decrement--;
         if (GameStatus == 5) {
            fadeframe += 2;
            *(vu16*)(0x04000000 +0x0050) = 128 | 32 | 16 | 8 | 4 | 2 | 1;

            (*(vu16*)(0x04000054)) = fadeframe;
            if (fadeframe >= 16) {
               GameStatus = 6;
            }
         }
      }

      if (decrement == 0) {
         if (gametimeinVblanks > (60*60*4)) {
            nextpopVb = 40;
         } else {

            nextpopVb = NEXTnextpopVb;





         }


         u8 currex = 0;
         while (currex<30) {
            if (explosions[currex].frameal == 0) {
               explosions[currex].frameal = 360;
               explosions[currex].x = rng_rand(240);
               explosions[currex].y = rng_rand(160);
               explosions[currex].offset = gametimeinVblanks;
               explosions[currex].palette = (pallam2>>1);
               if (pallam2++ == 2*11) pallam2=0;;
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


      for (u8 currex = 0; currex<30; currex++) {
         if (explosions[currex].frameal > 0) {
            explosions[currex].frameal--;
            if ((explosions[currex].frameal > 176) && (explosions[currex].frameal < 196)) {
               if (gameflags < 2) {
                  gameflags++;
                  if (gameflags == 2) {
                     flangex = rng_rand(230)+5;
                     flangey = rng_rand(150)+5;
                  }
               }
               if (((((sfxflags) & (1)) == (1)))) {AAS_SFX_Play(1, 52, 16000, AAS_DATA_SFX_START_explos, AAS_DATA_SFX_END_explos, 0);};
               explosions[currex].frameal = 174;
               u8 currbull = 0;
               while (currbull < 100) {
                  if (bullets[currbull].flaction == 0) {
                     bullets[currbull].flaction = 1;
                     bullets[currbull].xF = ((explosions[currex].x))<<8;
                     bullets[currbull].yF = ((explosions[currex].y))<<8;
                     bullets[currbull].palette = (pallam2>>1);
                     break;
                  }
                  currbull++;
               }
               currbull = 0;
               while (currbull < 100) {
                  if (bullets[currbull].flaction == 0) {
                     bullets[currbull].flaction = 1 | 2;
                     bullets[currbull].xF = ((explosions[currex].x))<<8;
                     bullets[currbull].yF = ((explosions[currex].y))<<8;
                     bullets[currbull].palette = (pallam2>>1);
                     break;
                  }
                  currbull++;
               }
               currbull = 0;
               while (currbull < 100) {
                  if (bullets[currbull].flaction == 0) {
                     bullets[currbull].flaction = 1 | 4 | 8;
                     bullets[currbull].xF = ((explosions[currex].x))<<8;
                     bullets[currbull].yF = ((explosions[currex].y))<<8;
                     bullets[currbull].palette = (pallam2>>1);
                     break;
                  }
                  currbull++;
               }
               currbull = 0;
               while (currbull < 100) {
                  if (bullets[currbull].flaction == 0) {
                     bullets[currbull].flaction = 1 | 8;
                     bullets[currbull].xF = ((explosions[currex].x))<<8;
                     bullets[currbull].yF = ((explosions[currex].y))<<8;
                     bullets[currbull].palette = (pallam2>>1);
                     break;
                  }
                  currbull++;
               }
               currbull = 0;
               while (currbull < 100) {
                  if (bullets[currbull].flaction == 0) {
                     bullets[currbull].flaction = 1 | 16;
                     bullets[currbull].xF = ((explosions[currex].x))<<8;
                     bullets[currbull].yF = ((explosions[currex].y))<<8;
                     bullets[currbull].palette = (pallam2>>1);
                     break;
                  }
                  currbull++;
               }
               currbull = 0;
               while (currbull < 100) {
                  if (bullets[currbull].flaction == 0) {
                     bullets[currbull].flaction = 1 | 16 | 2;
                     bullets[currbull].xF = ((explosions[currex].x))<<8;
                     bullets[currbull].yF = ((explosions[currex].y))<<8;
                     bullets[currbull].palette = (pallam2>>1);
                     break;
                  }
                  currbull++;
               }
               currbull = 0;
               while (currbull < 100) {
                  if (bullets[currbull].flaction == 0) {
                     bullets[currbull].flaction = 1 | 16 | 2 | 4;
                     bullets[currbull].xF = ((explosions[currex].x))<<8;
                     bullets[currbull].yF = ((explosions[currex].y))<<8;
                     bullets[currbull].palette = (pallam2>>1);
                     break;
                  }
                  currbull++;
               }
               currbull = 0;
               while (currbull < 100) {
                  if (bullets[currbull].flaction == 0) {
                     bullets[currbull].flaction = 1 | 16 | 4;
                     bullets[currbull].xF = ((explosions[currex].x))<<8;
                     bullets[currbull].yF = ((explosions[currex].y))<<8;
                     bullets[currbull].palette = (pallam2>>1);
                     break;
                  }
                  currbull++;
               }
            }
         }
      }

      for (u8 currbull = 0; currbull<100; currbull++) {
         u8 f = bullets[currbull].flaction;
         if (((((f) & (1)) == (1)))) {
            if (((((f) & (16)) == (16)))) {
               if (((((f) & (2)) == (2)))) {
                  if (((((f) & (4)) == (4)))) {
                     bullets[currbull].xF += (256|16|8);
                     bullets[currbull].yF += (256|16|8);
                  } else {
                     bullets[currbull].xF += (256|16|8);
                     bullets[currbull].yF -= (256|16|8);
                  }
               } else {
                  if (((((f) & (4)) == (4)))) {
                     bullets[currbull].xF -= (256|16|8);
                     bullets[currbull].yF += (256|16|8);
                  } else {
                     bullets[currbull].xF -= (256|16|8);
                     bullets[currbull].yF -= (256|16|8);
                  }
               }
            } else {
               if (((((f) & (8)) == (8)))) {
                  if (((((f) & (4)) == (4)))) {
                     bullets[currbull].yF += (256|128);
                  } else {
                     bullets[currbull].yF -= (256|128);
                  }
               } else {
                  if (((((f) & (2)) == (2)))) {
                     bullets[currbull].xF += (256|128);
                  } else {
                     bullets[currbull].xF -= (256|128);
                  }
               }
            }
            if (bullets[currbull].xF < (-5<<8)) bullets[currbull].flaction = 0;
            if (bullets[currbull].yF < (-5<<8)) bullets[currbull].flaction = 0;
            if (bullets[currbull].xF > (245<<8)) bullets[currbull].flaction = 0;
            if (bullets[currbull].yF > (165<<8)) bullets[currbull].flaction = 0;
         }
      }


      for (u8 currdust = 0; currdust < 3; currdust++) {
         if (flangedust[currdust].frameal != 0) {
            flangedust[currdust].frameal--;
         }
      }


      if (playerx < (3<<8)) {
         playerx = (3<<8);
         playerxs = (((playerxs) >= 0) ? (playerxs) : (-(playerxs)));
         if (((((sfxflags) & (1)) == (1)))) {AAS_SFX_Play(0, 40, 19000, AAS_DATA_SFX_START_bouncer, AAS_DATA_SFX_END_bouncer, 0);};
      } else if (playerx > (236<<8)) {
         playerx = (236<<8);
         playerxs = 0-(((playerxs) >= 0) ? (playerxs) : (-(playerxs)));
         if (((((sfxflags) & (1)) == (1)))) {AAS_SFX_Play(0, 40, 18000, AAS_DATA_SFX_START_bouncer, AAS_DATA_SFX_END_bouncer, 0);};
      }
      if (playery < (3<<8)) {
         playery = (3<<8);
         playerys = (((playerys) >= 0) ? (playerys) : (-(playerys)));
         if (((((sfxflags) & (1)) == (1)))) {AAS_SFX_Play(0, 40, 17000, AAS_DATA_SFX_START_bouncer, AAS_DATA_SFX_END_bouncer, 0);};
      } else if (playery > (157<<8)) {
         playery = (157<<8);
         playerys = 0-(((playerys) >= 0) ? (playerys) : (-(playerys)));
         if (((((sfxflags) & (1)) == (1)))) {AAS_SFX_Play(0, 40, 16000, AAS_DATA_SFX_START_bouncer, AAS_DATA_SFX_END_bouncer, 0);};
      }

      playerx += playerxs;
      playery += playerys;
# 751 "main.cpp"
      bool adown = _key_down(0x0001)!=0;
      bool bdown = _key_down(0x0002)!=0;
# 762 "main.cpp"
      if (GameStatus != 5) {
         if (!((((cheatmodes) & (4)) == (4)))) {
# 778 "main.cpp"
               if (_key_down(0x0080)) {
                  playerys += (((((cheatmodes) & (8)) == (8))) ? ((adown?(bdown?(192):(256)):(bdown?(64):(192))) >> 2) : ((adown?(bdown?(192):(256)):(bdown?(64):(192)))));
               }
               if (_key_down(0x0040)) {
                  playerys -= (((((cheatmodes) & (8)) == (8))) ? ((adown?(bdown?(192):(256)):(bdown?(64):(192))) >> 2) : ((adown?(bdown?(192):(256)):(bdown?(64):(192)))));
               }
               if (_key_down(0x0010)) {
                  playerxs += (((((cheatmodes) & (8)) == (8))) ? ((adown?(bdown?(192):(256)):(bdown?(64):(192))) >> 2) : ((adown?(bdown?(192):(256)):(bdown?(64):(192)))));
               }
               if (_key_down(0x0020)) {
                  playerxs -= (((((cheatmodes) & (8)) == (8))) ? ((adown?(bdown?(192):(256)):(bdown?(64):(192))) >> 2) : ((adown?(bdown?(192):(256)):(bdown?(64):(192)))));
               }

         } else {
# 806 "main.cpp"
               if (_key_down(0x0080)) {
                  playerys -= (((((cheatmodes) & (8)) == (8))) ? ((adown?(bdown?(192):(256)):(bdown?(64):(192))) >> 2) : ((adown?(bdown?(192):(256)):(bdown?(64):(192)))));
               }
               if (_key_down(0x0040)) {
                  playerys += (((((cheatmodes) & (8)) == (8))) ? ((adown?(bdown?(192):(256)):(bdown?(64):(192))) >> 2) : ((adown?(bdown?(192):(256)):(bdown?(64):(192)))));
               }
               if (_key_down(0x0010)) {
                  playerxs -= (((((cheatmodes) & (8)) == (8))) ? ((adown?(bdown?(192):(256)):(bdown?(64):(192))) >> 2) : ((adown?(bdown?(192):(256)):(bdown?(64):(192)))));
               }
               if (_key_down(0x0020)) {
                  playerxs += (((((cheatmodes) & (8)) == (8))) ? ((adown?(bdown?(192):(256)):(bdown?(64):(192))) >> 2) : ((adown?(bdown?(192):(256)):(bdown?(64):(192)))));
               }

         }
      }



      if (!((((cheatmodes) & (2)) == (2)))) {
         playerxs = (playerxs * 15) >> 4;
         playerys = (playerys * 15) >> 4;
      }

      if ((playerxs < 17) && (playerxs > -17)) playerxs = 0;
      if ((playerys < 17) && (playerys > -17)) playerys = 0;







      if (GameStatus != 5) {
         for (u8 currbull = 0; currbull<100; currbull++) {
            if (bullets[currbull].flaction != 0) {
               if ((((bullets[currbull].yF>>8) )<=((playery >>8)+2)) &&
                   (((bullets[currbull].yF>>8)+1)>=((playery >>8)-2)) &&
                   (((bullets[currbull].xF>>8) )<=((playerx >>8)+3)) &&
                   (((bullets[currbull].xF>>8)+1)>=((playerx >>8)-2))) {
                   GameStatus = 5;
                   if (((((sfxflags) & (2)) == (2)))) {AAS_MOD_Play(AAS_DATA_MOD_baTunnelEnd2);};
               }
            }
         }
      }
# 861 "main.cpp"
      if (GameStatus != 5) {
         if (gameflags == 2) {
            if ((((flangey)-4)<=((playery >>8)+2)) &&
                (((flangey)+4)>=((playery >>8)-2)) &&
                (((flangex)-4)<=((playerx >>8)+3)) &&
                (((flangex)+4)>=((playerx >>8)-2))) {
               flangecoll++;
               if (((((sfxflags) & (1)) == (1)))) {AAS_SFX_Play(2, 40, 22000, AAS_DATA_SFX_START_beepcoll, AAS_DATA_SFX_END_beepcoll, 0);};
               u8 currdust = 0;
               for (u8 finddust = 1; finddust < 3; finddust++) {
                  if (flangedust[finddust].frameal < flangedust[currdust].frameal) {
                     currdust = finddust;
                  }
               }


                     flangedust[currdust].frameal = 110;
                     flangedust[currdust].x = flangex;
                     flangedust[currdust].y = flangey;







               while (((((flangey)-9-10)<=((playery >>8)+2)) &&
                      (((flangey)+9+10)>=((playery >>8)-2)) &&
                      (((flangex)-9-10)<=((playerx >>8)+3)) &&
                      (((flangex)+9+10)>=((playerx >>8)-2)))) {
                  flangex = rng_rand(230)+5;
                  flangey = rng_rand(150)+5;


               }
            }
         }
      }


      obj_counter = 0;
      aff_counter = 0;


      oi_buffer[obj_counter].attr0 = (((playery-(2<<8)) >> 8) & 255);
      oi_buffer[obj_counter].attr1 = (((playerx-(2<<8)) >> 8) & 511);
      oi_buffer[obj_counter].attr2 = 579 | 13 << 12;
      obj_counter++;


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




      for (u8 currbull = 0; currbull<100; currbull++) {
         u16 f = bullets[currbull].flaction;
         if (((((f) & (1)) == (1)))) {
            if (obj_counter < 128) {
               if (((((f) & (16)) == (16)))) {
                  if (((((f) & (4)) == (4)))) {
                     if (((((f) & (2)) == (2)))) {
                        oi_buffer[obj_counter].attr0 = (((bullets[currbull].yF-(5<<8)) >> 8) & 255);
                        oi_buffer[obj_counter].attr1 = (((bullets[currbull].xF-(5<<8)) >> 8) & 511) | 4096 | 8192;
                        oi_buffer[obj_counter].attr2 = 576 | 0 << 10 | (bullets[currbull].palette) << 12;
                     } else {
                        oi_buffer[obj_counter].attr0 = (((bullets[currbull].yF-(5<<8)) >> 8) & 255);
                        oi_buffer[obj_counter].attr1 = (((bullets[currbull].xF-(3<<8)) >> 8) & 511) | 8192;
                        oi_buffer[obj_counter].attr2 = 576 | 0 << 10 | (bullets[currbull].palette) << 12;
                     }
                  } else {
                     if (((((f) & (2)) == (2)))) {
                        oi_buffer[obj_counter].attr0 = (((bullets[currbull].yF-(3<<8)) >> 8) & 255);
                        oi_buffer[obj_counter].attr1 = (((bullets[currbull].xF-(5<<8)) >> 8) & 511) | 4096;
                        oi_buffer[obj_counter].attr2 = 576 | 0 << 10 | (bullets[currbull].palette) << 12;
                     } else {
                        oi_buffer[obj_counter].attr0 = (((bullets[currbull].yF-(3<<8)) >> 8) & 255);
                        oi_buffer[obj_counter].attr1 = (((bullets[currbull].xF-(3<<8)) >> 8) & 511);
                        oi_buffer[obj_counter].attr2 = 576 | 0 << 10 | (bullets[currbull].palette) << 12;
                     }
                  }
               } else {
                  if (((((f) & (8)) == (8)))) {
                     if (((((f) & (4)) == (4)))) {
                        oi_buffer[obj_counter].attr0 = (((bullets[currbull].yF-(2<<8)) >> 8) & 255);
                        oi_buffer[obj_counter].attr1 = (((bullets[currbull].xF-(4<<8)) >> 8) & 511) | 8192;
                        oi_buffer[obj_counter].attr2 = 577 | 0 << 10 | (bullets[currbull].palette) << 12;
                     } else {
                        oi_buffer[obj_counter].attr0 = (((bullets[currbull].yF-(6<<8)) >> 8) & 255);
                        oi_buffer[obj_counter].attr1 = (((bullets[currbull].xF-(4<<8)) >> 8) & 511);
                        oi_buffer[obj_counter].attr2 = 577 | 0 << 10 | (bullets[currbull].palette) << 12;
                     }
                  } else {
                     if (((((f) & (2)) == (2)))) {
                        oi_buffer[obj_counter].attr0 = (((bullets[currbull].yF-(4<<8)) >> 8) & 255);
                        oi_buffer[obj_counter].attr1 = (((bullets[currbull].xF-(2<<8)) >> 8) & 511) | 4096;
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
# 1006 "main.cpp"
      for (u8 currdust = 0; currdust < 3; currdust++) {
         u8 e = flangedust[currdust].frameal;
         if (e != 0) {
            if (e>30) {
               if (obj_counter < 128) {
                  oi_buffer[obj_counter].attr0 = ((((((s32)_sinLUT[(e*10 +000&511)])*(100*(110 -e)-0))>>16) +(flangedust[currdust].y)-3) & 255);
                  oi_buffer[obj_counter].attr1 = ((((((s32)_sinLUT[((e*10 +000 +(512>>2)) & (512 -1))&511])*(100*(110 -e)-0))>>16) +(flangedust[currdust].x)-3) & 511);
                  oi_buffer[obj_counter].attr2 = 582 | 0 << 10 | 13 << 12;
                  obj_counter++;
               }
              if (obj_counter < 128) {
                  oi_buffer[obj_counter].attr0 = ((((((s32)_sinLUT[(e*10 +170&511)])*(100*(110 -e)-0))>>16) +(flangedust[currdust].y)-3) & 255);
                  oi_buffer[obj_counter].attr1 = ((((((s32)_sinLUT[((e*10 +170 +(512>>2)) & (512 -1))&511])*(100*(110 -e)-0))>>16) +(flangedust[currdust].x)-3) & 511);
                  oi_buffer[obj_counter].attr2 = 582 | 0 << 10 | 13 << 12;
                  obj_counter++;
               }
               if (obj_counter < 128) {
                  oi_buffer[obj_counter].attr0 = ((((((s32)_sinLUT[(e*10 +341&511)])*(100*(110 -e)-0))>>16) +(flangedust[currdust].y)-3) & 255);
                  oi_buffer[obj_counter].attr1 = ((((((s32)_sinLUT[((e*10 +341 +(512>>2)) & (512 -1))&511])*(100*(110 -e)-0))>>16) +(flangedust[currdust].x)-3) & 511);
                  oi_buffer[obj_counter].attr2 = 582 | 0 << 10 | 13 << 12;
                  obj_counter++;
               }
            } else {
               if (obj_counter < 128) {
                  oi_buffer[obj_counter].attr0 = ((((((s32)_sinLUT[(e*10 +000&511)])*(100*(110 -e)-0))>>16) +(flangedust[currdust].y)-3) & 255);
                  oi_buffer[obj_counter].attr1 = ((((((s32)_sinLUT[((e*10 +000 +(512>>2)) & (512 -1))&511])*(100*(110 -e)-0))>>16) +(flangedust[currdust].x)-3) & 511);
                  oi_buffer[obj_counter].attr2 = 583 | 0 << 10 | 13 << 12;
                  obj_counter++;
               }
              if (obj_counter < 128) {
                  oi_buffer[obj_counter].attr0 = ((((((s32)_sinLUT[(e*10 +170&511)])*(100*(110 -e)-0))>>16) +(flangedust[currdust].y)-3) & 255);
                  oi_buffer[obj_counter].attr1 = ((((((s32)_sinLUT[((e*10 +170 +(512>>2)) & (512 -1))&511])*(100*(110 -e)-0))>>16) +(flangedust[currdust].x)-3) & 511);
                  oi_buffer[obj_counter].attr2 = 583 | 0 << 10 | 13 << 12;
                  obj_counter++;
               }
               if (obj_counter < 128) {
                  oi_buffer[obj_counter].attr0 = ((((((s32)_sinLUT[(e*10 +341&511)])*(100*(110 -e)-0))>>16) +(flangedust[currdust].y)-3) & 255);
                  oi_buffer[obj_counter].attr1 = ((((((s32)_sinLUT[((e*10 +341 +(512>>2)) & (512 -1))&511])*(100*(110 -e)-0))>>16) +(flangedust[currdust].x)-3) & 511);
                  oi_buffer[obj_counter].attr2 = 583 | 0 << 10 | 13 << 12;
                  obj_counter++;
               }
            }
         }
      }






      for (u8 currex = 0; currex<30; currex++) {
         u16 e = explosions[currex].frameal;
         if (e > 0) {
            if (e > 345) {
               if (obj_counter < 128) {
                  oi_buffer[obj_counter].attr0 = ((((((s32)_sinLUT[(0-e*15 +000&511)])*(17*e-2421))>>16) +(explosions[currex].y)-4) & 255);
                  oi_buffer[obj_counter].attr1 = ((((((s32)_sinLUT[((0-e*15 +000 +(512>>2)) & (512 -1))&511])*(17*e-2421))>>16) +(explosions[currex].x)-4) & 511);
                  oi_buffer[obj_counter].attr2 = 580 | 0 << 10 | 12 << 12;
                  obj_counter++;
               }
               if (obj_counter < 128) {
                  oi_buffer[obj_counter].attr0 = ((((((s32)_sinLUT[(0-e*15 +170&511)])*(17*e-2421))>>16) +(explosions[currex].y)-4) & 255);
                  oi_buffer[obj_counter].attr1 = ((((((s32)_sinLUT[((0-e*15 +170 +(512>>2)) & (512 -1))&511])*(17*e-2421))>>16) +(explosions[currex].x)-4) & 511);
                  oi_buffer[obj_counter].attr2 = 580 | 0 << 10 | 12 << 12;
                  obj_counter++;
               }
               if (obj_counter < 128) {
                  oi_buffer[obj_counter].attr0 = ((((((s32)_sinLUT[(0-e*15 +341&511)])*(17*e-2421))>>16) +(explosions[currex].y)-4) & 255);
                  oi_buffer[obj_counter].attr1 = ((((((s32)_sinLUT[((0-e*15 +341 +(512>>2)) & (512 -1))&511])*(17*e-2421))>>16) +(explosions[currex].x)-4) & 511);
                  oi_buffer[obj_counter].attr2 = 580 | 0 << 10 | 12 << 12;
                  obj_counter++;
               }
            } else if (e > 175) {
               if (obj_counter < 128) {
                  oi_buffer[obj_counter].attr0 = ((((((s32)_sinLUT[(0-e*15 +000&511)])*(17*e-2421))>>16) +(explosions[currex].y)-4) & 255);
                  oi_buffer[obj_counter].attr1 = ((((((s32)_sinLUT[((0-e*15 +000 +(512>>2)) & (512 -1))&511])*(17*e-2421))>>16) +(explosions[currex].x)-4) & 511);
                  oi_buffer[obj_counter].attr2 = 580 | 0 << 10 | (explosions[currex].palette) << 12;
                  obj_counter++;
               }
               if (obj_counter < 128) {
                  oi_buffer[obj_counter].attr0 = ((((((s32)_sinLUT[(0-e*15 +170&511)])*(17*e-2421))>>16) +(explosions[currex].y)-4) & 255);
                  oi_buffer[obj_counter].attr1 = ((((((s32)_sinLUT[((0-e*15 +170 +(512>>2)) & (512 -1))&511])*(17*e-2421))>>16) +(explosions[currex].x)-4) & 511);
                  oi_buffer[obj_counter].attr2 = 580 | 0 << 10 | (explosions[currex].palette) << 12;
                  obj_counter++;
               }
               if (obj_counter < 128) {
                  oi_buffer[obj_counter].attr0 = ((((((s32)_sinLUT[(0-e*15 +341&511)])*(17*e-2421))>>16) +(explosions[currex].y)-4) & 255);
                  oi_buffer[obj_counter].attr1 = ((((((s32)_sinLUT[((0-e*15 +341 +(512>>2)) & (512 -1))&511])*(17*e-2421))>>16) +(explosions[currex].x)-4) & 511);
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
                  oi_buffer[obj_counter].attr0 = ((explosions[currex].y-33) & 255) | 256;
                  oi_buffer[obj_counter].attr1 = ((explosions[currex].x-33) & 511) | (aff_counter << 9) | 16384 | 32768;
                  oi_buffer[obj_counter].attr2 = 512 | 0 << 10 | (explosions[currex].palette) << 12;
                  oa_rotscale(&oa_buffer[aff_counter], (explosions[currex].offset+STARROT[175-e])&511, RECIPSTARSCALE[175-e], RECIPSTARSCALE[175-e]);
                  obj_counter++;
                  aff_counter++;
               }
            } else {
               if (obj_counter < 128 && aff_counter < 32) {
                  oi_buffer[obj_counter].attr0 = ((explosions[currex].y-33) & 255) | 256;
                  oi_buffer[obj_counter].attr1 = ((explosions[currex].x-33) & 511) | (aff_counter << 9) | 16384 | 32768;
                  oi_buffer[obj_counter].attr2 = 512 | 0 << 10 | (12 << 12);
                  oa_rotscale(&oa_buffer[aff_counter], (explosions[currex].offset+STARROT[175-e])&511, RECIPSTARSCALE[175-e], RECIPSTARSCALE[175-e]);
                  obj_counter++;
                  aff_counter++;
               }
            }
         }
      }



      for (u8 obj_emptier = obj_counter; obj_emptier < 128; obj_emptier++) {
         oi_buffer[obj_emptier].attr0 = 0;
         oi_buffer[obj_emptier].attr1 = 0;
         oi_buffer[obj_emptier].attr2 = 0;
      }


      AAS_DoDMA3(&oi_buffer[0], (void *)0x07000000, 256 | 0x84000000);
      gametimeinVblanks++;




      if (((((sfxflags) & (128)) == (128)))) {
         const signed char* soundbuffer1 = AAS_GetOutputBufferAddress(0);
         const signed char* soundbuffer2 = AAS_GetOutputBufferAddress(1);

         for (u8 soundposition = 0; soundposition < 240; soundposition++) {
            (((u16*)(0x06000000))[(soundposition)+240*(previouswave[soundposition])]) = ((COLOR*)0x05000000)[0];
            s16 ploty = 80;
            if (&(soundbuffer1[0]) != 0) ploty += soundbuffer1[soundposition+120]>>1;
            if (&(soundbuffer2[0]) != 0) ploty += soundbuffer2[soundposition+120]>>1;
            ploty = ploty<1?1:(ploty>239?239:ploty);
            (((u16*)(0x06000000))[(soundposition)+240*(ploty)]) = ((COLOR*)0x05000000)[1];
            previouswave[soundposition] = ploty;
         }
      }






      if (((((cheatmodes) & (1)) == (1)))) {
         playerys += 75;
      }

      if (GameStatus == 0) {
         if (_key_down(0x0008)) {
            GameStatus = 9;
            asm volatile("swi 0x05");
            *(vu16*)(0x04000000 +0x0050) = 128 | 64 | 32 | 16 | 8 | 4 | 2 | 1;
            (*(vu16*)(0x04000054)) = 11;
            AAS_MOD_Pause();
         }
      }
      if (GameStatus == 1) {
         if (!_key_down(0x0008)) {
            GameStatus = 0;
         }
      }

      } else if ((GameStatus == 9) || (GameStatus == 8)) {
         asm volatile("swi 0x05");
         if (GameStatus == 9) {
            if (!_key_down(0x0008)) {
               GameStatus = 8;
            }
         } else if (GameStatus == 8) {
            if (_key_down(0x0008)) {
               GameStatus = 1;
               AAS_MOD_Resume();
               *(vu16*)(0x04000000 +0x0050) = 0;
               (*(vu16*)(0x04000054)) = 0;
            }
         }
      } else if (GameStatus == 6) {

         asm volatile("swi 0x05");
         *(vu32*)(0x04000000 +0x0000) = 0x0080;



         fadeframe = 16<<2;
         for (u8 obj_emptier = 0; obj_emptier < 128; obj_emptier++) {
            oi_buffer[obj_emptier].attr0 = 0;
            oi_buffer[obj_emptier].attr1 = 0;
            oi_buffer[obj_emptier].attr2 = 0;
         }
         AAS_DoDMA3(&oi_buffer[0], (void *)0x07000000, 256 | 0x84000000);

         AAS_DoDMA3((void *)gameovertilesData, (void *)&( (TILEBLOCK*)0x06000000 )[0][2], 6240 | 0x84000000);
         AAS_DoDMA3((void *)retrytextData, (void *)&( (TILEBLOCK*)0x06000000 )[2][2], 896 | 0x84000000);






         for (u8 ytile = 4; ytile<4+13; ytile++) {
            for (u8 xtile = 0; xtile<30; xtile++) {
               tegelset0[((xtile) + ((ytile)<<5))] = xtile+(ytile-4)*30 + 1;
            }
         }
         bg_set_pos(&back0, 0, 4);
         bg_update(&back0);




         for (u8 ytile = 0; ytile<2; ytile++) {
            for (u8 xtile = 0; xtile<28; xtile++) {
               tegelset1[((xtile) + ((ytile)<<5))] = xtile+ytile*28 + 1;
            }
         }
         bg_set_pos(&back1, 0-9, 0-138);
         bg_update(&back1);

         bg_set_pos(&back2, 0, 80);
         bg_update(&back2);

         bg_set_pos(&back3, 0, 0-160);
         bg_update(&back3);

         gameoverinVblanks = 0;






         hundredscollected = (flangecoll-(flangecoll % 100)) / 100;
         if (hundredscollected == 0) {
            hundredscollected = 11;
            tenscollected = (flangecoll-(flangecoll % 10)) / 10;
            if (tenscollected == 0) tenscollected = 11;
         } else {
            tenscollected = ((flangecoll % 100)-(flangecoll%10)) / 10;
         }
         unitscollected = flangecoll % 10;



         u16 s = (gametimeinVblanks*2) / 119;

         tensminspass = s / 600;
         if (tensminspass == 0) tensminspass = 11;
         unitsminspass = ((s/60) % 10);

         tenssecspass = ((s%60) - (s%10))/10;
         unitssecspass = s % 10;

         keydowngos = 0;

         GameStatus = 7;
      } else if ((GameStatus == 7)||(GameStatus == 10)||(GameStatus == 11)) {

         asm volatile("swi 0x05");
         if ((fadeframe == 16<<2) && (GameStatus == 7)) {
            *(vu32*)(0x04000000 +0x0000) = 0 | (0x0001<<8) | (0x0010<<8) | 0x0040;
         }
         if ((fadeframe > 0) && (GameStatus == 7)) {
            fadeframe -= 1;
            if (fadeframe == 0) {
               *(vu16*)(0x04000000 +0x0050) = 0;
            } else {
               *(vu16*)(0x04000000 +0x0050) = 128 | 32 | 16 | 8 | 4 | 2 | 1;

               (*(vu16*)(0x04000054)) = fadeframe>>2;
            }
         }





         if (gameoverinVblanks < 46) {
            oi_buffer[127].attr0 = 80 | 16384;
            oi_buffer[127].attr1 = ((((s16)gameoverinVblanks*6) - 58) & 511) | 16384 | 32768;
            oi_buffer[127].attr2 = 668 | (14 << 12);
         } else {
            oi_buffer[127].attr1 = oi_buffer[127].attr1 = oi_buffer[127].attr2 = 0;
         }
# 1314 "main.cpp"
         if (gameoverinVblanks >= (6 +1)) {
            u8 randjig = rng_rand(5);

            oi_buffer[0].attr0 = 88;
            oi_buffer[0].attr1 = 20 | 16384;
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
         }






         if (gameoverinVblanks == (12+1)) {
            oi_buffer[1].attr0 = 80 | 32768;
            oi_buffer[1].attr1 = 55 | 32768;
            if (hundredscollected != 11) {
               oi_buffer[1].attr2 = 584 + (8*hundredscollected) | (1 << 10) | (13 << 12);
            } else {
               oi_buffer[1].attr2 = 1016 | (1 << 10) | (13 << 12);
            }
         }


         if (gameoverinVblanks == (14+1)) {
            oi_buffer[2].attr0 = 80 | 32768;
            oi_buffer[2].attr1 = 55 + 16 | 32768;
            if (tenscollected != 11) {
               oi_buffer[2].attr2 = 584 + (8*tenscollected) | (1 << 10) | (13 << 12);
            } else {
               oi_buffer[2].attr2 = 1016 | (1 << 10) | (13 << 12);
            }
         }


         if (gameoverinVblanks == (16+1)) {
            oi_buffer[3].attr0 = 80 | 32768;
            oi_buffer[3].attr1 = 55 + 32 | 32768;
            oi_buffer[3].attr2 = 584 + (8*unitscollected) | (1 << 10) | (13 << 12);
         }





         if (gameoverinVblanks == (22+1)) {
            oi_buffer[4].attr0 = 88;
            oi_buffer[4].attr1 = 126 | 16384;
            oi_buffer[4].attr2 = 700 | (1 << 10) | (13 << 12);
         }


         if (gameoverinVblanks == (26+1)) {
            oi_buffer[5].attr0 = 80 | 32768;
            oi_buffer[5].attr1 = 152 | 32768;
            if (tensminspass != 11) {
               oi_buffer[5].attr2 = 584 + (8*tensminspass) | (1 << 10) | (13 << 12);
            } else {
               oi_buffer[5].attr2 = 1016 | (1 << 10) | (13 << 12);
            }
         }


         if (gameoverinVblanks == (29+1)) {
            oi_buffer[6].attr0 = 80 | 32768;
            oi_buffer[6].attr1 = 152 + 16 | 32768;
            if (unitsminspass != 11) {
               oi_buffer[6].attr2 = 584 + (8*unitsminspass) | (1 << 10) | (13 << 12);
            } else {
               oi_buffer[6].attr2 = 1016 | (1 << 10) | (13 << 12);
            }
         }


         if (gameoverinVblanks == (33+1)) {
            oi_buffer[7].attr0 = 80 | 32768;
            oi_buffer[7].attr1 = 152 + 40 | 32768;
            if (tenssecspass != 11) {
               oi_buffer[7].attr2 = 584 + (8*tenssecspass) | (1 << 10) | (13 << 12);
            } else {
               oi_buffer[7].attr2 = 1016 | (1 << 10) | (13 << 12);
            }
         }


         if (gameoverinVblanks == (36+1)) {
            oi_buffer[8].attr0 = 80 | 32768;
            oi_buffer[8].attr1 = 152 + 56 | 32768;
            if (unitssecspass != 11) {
               oi_buffer[8].attr2 = 584 + (8*unitssecspass) | (1 << 10) | (13 << 12);
            } else {
               oi_buffer[8].attr2 = 1016 | (1 << 10) | (13 << 12);
            }
         }




         AAS_DoDMA3(&oi_buffer[0], (void *)0x07000000, 256 | 0x84000000);




         if (GameStatus == 7) {
            if (gameoverinVblanks < ((160)+128)) {
               if (gameoverinVblanks == (160)) {
                  *(vu32*)(0x04000000 +0x0000) = 0 | (0x0001<<8) | (0x0002<<8) | (0x0010<<8) | 0x0040;
               }
               if (gameoverinVblanks >= (160)) {
                  *(vu16*)(0x04000000 +0x0050) = 128 | 64 | 2;

                  (*(vu16*)(0x04000054)) = 16-((gameoverinVblanks - (160))>>3);
               }
               gameoverinVblanks++;
               if (16-((gameoverinVblanks - (160))>>3) == 0) {
                  *(vu16*)(0x04000000 +0x0050) = 0;
                  (*(vu16*)(0x04000054)) = 0;
               }
            }




            if (gameoverinVblanks == 100) {
               if (_key_down(0x0002)) {
                  keydowngos |= 0x0002;
               }
               if (_key_down(0x0008)) {
                  keydowngos |= 0x0008;
               }
            }
            if (gameoverinVblanks > 100) {
               if (((((keydowngos) & (0x0002)) == (0x0002)))) {
                  if (_key_down(0x0002)) {
                  } else {
                     keydowngos ^= 0x0002;
                  }
               } else {
                  if (_key_down(0x0002)) {


                     GameStatus = 10;
                     fadeframe = 64;
                     *(vu16*)(0x04000000 +0x0050) = 128 | 32 | 16 | 8 | 4 | 2 | 1;
                  }
               }
               if (((((keydowngos) & (0x0008)) == (0x0008)))) {
                  if (_key_down(0x0008)) {
                  } else {
                     keydowngos ^= 0x0008;
                  }
               } else {
                  if (_key_down(0x0008)) {


                     GameStatus = 11;
                     fadeframe = 80;
                     *(vu32*)(0x04000000 +0x0000) = 0 | (0x0001<<8) | (0x0002<<8) | (0x0004<<8) | (0x0008<<8) | (0x0010<<8) | 0x0040;

                     for (u8 curpix = 0; curpix < 32; curpix++) {
                        (*(u16 *)(0x060061c0 + curpix*2)) = (u16)((48<<8) + 48);
                     }
                     ((COLOR*)0x05000000)[48] = 0;
                     for (u8 curtegelx = 0; curtegelx < 30; curtegelx++) {
                        for (u8 curtegely = 0; curtegely < 10; curtegely++) {
                           tegelset2[((curtegelx) + ((curtegely)<<5))] = 391;
                        }
                     }
                  }
               }
            }
         }
         if ((fadeframe > 0) && (GameStatus == 10)) {
            fadeframe--;
            if (((((sfxflags) & (2)) == (2)))) {
               AAS_MOD_SetVolume(fadeframe<<2);
            }
            if (fadeframe > 32) {
               (*(vu16*)(0x04000054)) = 16-((fadeframe-32)>>1);
            }
            if (fadeframe == 32) {
               *(vu32*)(0x04000000 +0x0000) = 0 | 0x0080 | (0x0001<<8) | (0x0002<<8) | 0x0040;
               GameStatus = 4;
               AAS_DoDMA3((void *)&((COLOR*)0x05000000)[127], (void *)&((COLOR*)0x05000000)[0], 64 | 0x84000000);
               asm volatile("swi 0x05");
               key_poll();
               asm volatile("swi 0x05");
            }
            if (fadeframe == 31) {
               *(vu32*)(0x04000000 +0x0000) = 0 | (0x0001<<8) | (0x0002<<8) | 0x0040;
            }
            if (fadeframe < 32) {
               (*(vu16*)(0x04000054)) = (fadeframe>>1);
            }
            if (fadeframe == 0) {
               AAS_MOD_Stop();
               AAS_MOD_SetVolume(255);
               GameStatus = 4;
            }
         }
         if ((fadeframe > 0) && (GameStatus == 11)) {
            fadeframe--;
            if (((((sfxflags) & (2)) == (2)))) {
               AAS_MOD_SetVolume(fadeframe*3);
            }
            bg_set_pos(&back2, 0, fadeframe);
            bg_update(&back2);
            bg_set_pos(&back3, 0, (0-80)-fadeframe);
            bg_update(&back3);
            if (fadeframe == 0) {
               AAS_MOD_Stop();
               AAS_MOD_SetVolume(255);
               GameStatus = 2;
            }
         }

      }
   }
   return GameStatus;
}

void SetUpMathewCarr() {
   AAS_DoDMA3((void *)&mattpresentsPal[0], (void *)&((COLOR*)0x05000000)[0], 128 | 0x84000000);
   AAS_DoDMA3((void *)&mattpresentsData[0], (void *)&( (TILEBLOCK*)0x06000000 )[0][0], 3840 | 0x84000000);
}

void DoMathewCarr() {
   BGINFO back0;
   bg_init(&back0, 0, 0, 31, 0x0000 | 0x0080 | 3);
   TEGEL *tegelset0 = back0.map;
   bg_set_pos(&back0, 0, 0);
   bg_update(&back0);

   for (u16 curtile = 0; curtile < 1024; curtile++) {
      tegelset0[((curtile) + ((0)<<5))] = 60;
   }

   for (vu8 tegelrun = 0; tegelrun < 2; tegelrun++) { tegelset0[((14 + tegelrun) + ((5)<<5))] = (0 + (tegelrun)); };
   for (vu8 tegelrun = 0; tegelrun < 22; tegelrun++) { tegelset0[((8 + tegelrun) + ((6)<<5))] = (2 + (tegelrun)); };
   for (vu8 tegelrun = 0; tegelrun < 22; tegelrun++) { tegelset0[((8 + tegelrun) + ((7)<<5))] = (24 + (tegelrun)); };
   for (vu8 tegelrun = 0; tegelrun < 22; tegelrun++) { tegelset0[((8 + tegelrun) + ((8)<<5))] = (46 + (tegelrun)); };
   for (vu8 tegelrun = 0; tegelrun < 2; tegelrun++) { tegelset0[((0 + tegelrun) + ((9)<<5))] = (68 + (tegelrun)); };
   for (vu8 tegelrun = 0; tegelrun < 6; tegelrun++) { tegelset0[((9 + tegelrun) + ((9)<<5))] = (70 + (tegelrun)); };
   for (vu8 tegelrun = 0; tegelrun < 3; tegelrun++) { tegelset0[((0 + tegelrun) + ((10)<<5))] = (76 + (tegelrun)); };
   for (vu8 tegelrun = 0; tegelrun < 7; tegelrun++) { tegelset0[((7 + tegelrun) + ((10)<<5))] = (79 + (tegelrun)); };
   for (vu8 tegelrun = 0; tegelrun < 14; tegelrun++) { tegelset0[((0 + tegelrun) + ((11)<<5))] = (86 + (tegelrun)); };
   for (vu8 tegelrun = 0; tegelrun < 13; tegelrun++) { tegelset0[((0 + tegelrun) + ((12)<<5))] = (100 + (tegelrun)); };
   for (vu8 tegelrun = 0; tegelrun < 13; tegelrun++) { tegelset0[((0 + tegelrun) + ((13)<<5))] = (113 + (tegelrun)); };
   for (vu8 tegelrun = 0; tegelrun < 13; tegelrun++) { tegelset0[((0 + tegelrun) + ((14)<<5))] = (126 + (tegelrun)); };
   for (vu8 tegelrun = 0; tegelrun < 12; tegelrun++) { tegelset0[((0 + tegelrun) + ((15)<<5))] = (139 + (tegelrun)); };
   for (vu8 tegelrun = 0; tegelrun < 12; tegelrun++) { tegelset0[((0 + tegelrun) + ((16)<<5))] = (151 + (tegelrun)); };
   for (vu8 tegelrun = 0; tegelrun < 13; tegelrun++) { tegelset0[((0 + tegelrun) + ((17)<<5))] = (163 + (tegelrun)); };
   for (vu8 tegelrun = 0; tegelrun < 14; tegelrun++) { tegelset0[((0 + tegelrun) + ((18)<<5))] = (176 + (tegelrun)); };
   for (vu8 tegelrun = 0; tegelrun < 14; tegelrun++) { tegelset0[((0 + tegelrun) + ((19)<<5))] = (190 + (tegelrun)); };
   for (vu8 tegelrun = 0; tegelrun < 14; tegelrun++) { tegelset0[((16 + tegelrun) + ((18)<<5))] = (204 + (tegelrun)); };
   for (vu8 tegelrun = 0; tegelrun < 14; tegelrun++) { tegelset0[((16 + tegelrun) + ((19)<<5))] = (218 + (tegelrun)); };

   (*(vu16*)(0x04000054)) = 16;
   *(vu16*)(0x04000000 +0x0050) = 128 | 32 | 16 | 8 | 4 | 2 | 1;
   *(vu32*)(0x04000000 +0x0000) = 0 | (0x0001<<8);


   vu16 matttimeinVblanks = 0;
# 1602 "main.cpp"
   while (matttimeinVblanks < ((32 +128)+32)) {
      asm volatile("swi 0x05");
      key_poll();
      if (matttimeinVblanks < 32) {
         (*(vu16*)(0x04000054)) = 17 - (matttimeinVblanks >> 1);
      } else if (matttimeinVblanks == 32) {
         (*(vu16*)(0x04000054)) = 0;
         *(vu16*)(0x04000000 +0x0050) = 0;
      } else if (matttimeinVblanks >= (32 +128)) {
         (*(vu16*)(0x04000054)) = ((matttimeinVblanks-(32 +128)) >> 1);
      }
      if (matttimeinVblanks == (32 +128)) {
         *(vu16*)(0x04000000 +0x0050) = 128 | 32 | 16 | 8 | 4 | 2 | 1;
      }
      matttimeinVblanks += 1;







   }
   *(vu32*)(0x04000000 +0x0000) = 0x0080;
   *(vu16*)(0x04000000 +0x0050) = 0;
   (*(vu16*)(0x04000054)) = 0;
}

void SetUpBlastArenaLetterSlamTitle() {
   AAS_DoDMA3((void *)&blastarenalettersPal[0], (void *)&((COLOR*)(0x05000000 +0x0200))[0], 8 | 0x84000000);
   AAS_DoDMA3((void *)&blastarenalettersData[0], (void *)&( (TILEBLOCK*)0x06000000 )[4][512], 2048 | 0x84000000);
   AAS_DoDMA3((void *)&advancehalvesPal[0], (void *)&((COLOR*)0x05000000)[0], 8 | 0x84000000);
   AAS_DoDMA3((void *)&advancehalvesData[0], (void *)&( (TILEBLOCK*)0x06000000 )[0][1], 608 | 0x84000000);
}

void DoBlastArenaLetterSlamTitle() {

   vu16 titletimeinVblanks = 0;
# 1698 "main.cpp"
   *(vu32*)(0x04000000 +0x0000) = 0 | 0x0040 | (0x0010<<8);

   BGINFO back0;
   bg_init(&back0, 0, 0, 30, 0x0000 | 0);
   TEGEL *tegelset0 = back0.map;
   bg_set_pos(&back0, 0, 0);
   bg_update(&back0);
   BGINFO back1;
   bg_init(&back1, 1, 0, 31, 0x0000 | 0);
   TEGEL *tegelset1 = back1.map;
   bg_set_pos(&back1, 0, 0);
   bg_update(&back1);

   *(vu16*)(0x04000000 +0x0010) = -46;
   *(vu16*)(0x04000000 +0x0014) = -46;

   for (u16 curtile = 0; curtile < 1024; curtile++) {
      tegelset0[((curtile) + ((0)<<5))] = 0;
      tegelset1[((curtile) + ((0)<<5))] = 0;
   }

   for (vu8 tegelrun = 0; tegelrun < 19; tegelrun++) { tegelset0[((0 + tegelrun) + ((0)<<5))] = 1 + tegelrun; };
   for (vu8 tegelrun = 0; tegelrun < 19; tegelrun++) { tegelset0[((0 + tegelrun) + ((1)<<5))] = 20 + tegelrun; };

   for (vu8 tegelrun = 0; tegelrun < 19; tegelrun++) { tegelset1[((0 + tegelrun) + ((0)<<5))] = 39 + tegelrun; };
   for (vu8 tegelrun = 0; tegelrun < 19; tegelrun++) { tegelset1[((0 + tegelrun) + ((1)<<5))] = 58 + tegelrun; };
# 1746 "main.cpp"
   while (titletimeinVblanks < (82 + 10 - 12)) {
      asm volatile("swi 0x05");
      key_poll();
      if (titletimeinVblanks == ((10 +0*6))) { oi_buffer[10].attr0 = ((18-32) & 255) | 512 | 256 | 32768; oi_buffer[10].attr1 = ((((26-16) & 511)+10)) | (10 << 9) | 16384 | 32768; oi_buffer[10].attr2 = ((512+1*32)) | (1 << 10); } if (titletimeinVblanks == (((10 +0*6)+16))) { oi_buffer[10].attr0 = (((18-32) & 255) + 32) | 256 | 32768; oi_buffer[10].attr1 = ((((26-16) & 511)+10) + 16) | (10 << 9) | 16384 | 32768; oi_buffer[10].attr2 = ((512+1*32)) | (1 << 10); } if (titletimeinVblanks <= (((10 +0*6)+16))) { if (titletimeinVblanks >= ((10 +0*6))) { oa_scale(&oa_buffer[10], (128+3*((titletimeinVblanks-((10 +0*6)))<<3)), (128+3*((titletimeinVblanks-((10 +0*6)))<<3))); } };
      if (titletimeinVblanks == ((10 +1*6))) { oi_buffer[9].attr0 = ((18-32) & 255) | 512 | 256 | 32768; oi_buffer[9].attr1 = ((((26-16) & 511)+22)) | (9 << 9) | 16384 | 32768; oi_buffer[9].attr2 = ((512+0*32)) | (1 << 10); } if (titletimeinVblanks == (((10 +1*6)+16))) { oi_buffer[9].attr0 = (((18-32) & 255) + 32) | 256 | 32768; oi_buffer[9].attr1 = ((((26-16) & 511)+22) + 16) | (9 << 9) | 16384 | 32768; oi_buffer[9].attr2 = ((512+0*32)) | (1 << 10); } if (titletimeinVblanks <= (((10 +1*6)+16))) { if (titletimeinVblanks >= ((10 +1*6))) { oa_scale(&oa_buffer[9], (128+3*((titletimeinVblanks-((10 +1*6)))<<3)), (128+3*((titletimeinVblanks-((10 +1*6)))<<3))); } };
      if (titletimeinVblanks == ((10 +2*6))) { oi_buffer[8].attr0 = ((18-32) & 255) | 512 | 256 | 32768; oi_buffer[8].attr1 = ((((26-16) & 511)+35)) | (8 << 9) | 16384 | 32768; oi_buffer[8].attr2 = ((512+2*32)) | (1 << 10); } if (titletimeinVblanks == (((10 +2*6)+16))) { oi_buffer[8].attr0 = (((18-32) & 255) + 32) | 256 | 32768; oi_buffer[8].attr1 = ((((26-16) & 511)+35) + 16) | (8 << 9) | 16384 | 32768; oi_buffer[8].attr2 = ((512+2*32)) | (1 << 10); } if (titletimeinVblanks <= (((10 +2*6)+16))) { if (titletimeinVblanks >= ((10 +2*6))) { oa_scale(&oa_buffer[8], (128+3*((titletimeinVblanks-((10 +2*6)))<<3)), (128+3*((titletimeinVblanks-((10 +2*6)))<<3))); } };
      if (titletimeinVblanks == ((10 +3*6))) { oi_buffer[7].attr0 = ((18-32) & 255) | 512 | 256 | 32768; oi_buffer[7].attr1 = ((((26-16) & 511)+51)) | (7 << 9) | 16384 | 32768; oi_buffer[7].attr2 = ((512+3*32)) | (1 << 10); } if (titletimeinVblanks == (((10 +3*6)+16))) { oi_buffer[7].attr0 = (((18-32) & 255) + 32) | 256 | 32768; oi_buffer[7].attr1 = ((((26-16) & 511)+51) + 16) | (7 << 9) | 16384 | 32768; oi_buffer[7].attr2 = ((512+3*32)) | (1 << 10); } if (titletimeinVblanks <= (((10 +3*6)+16))) { if (titletimeinVblanks >= ((10 +3*6))) { oa_scale(&oa_buffer[7], (128+3*((titletimeinVblanks-((10 +3*6)))<<3)), (128+3*((titletimeinVblanks-((10 +3*6)))<<3))); } };
      if (titletimeinVblanks == ((10 +4*6))) { oi_buffer[6].attr0 = ((18-32) & 255) | 512 | 256 | 32768; oi_buffer[6].attr1 = ((((26-16) & 511)+63)) | (6 << 9) | 16384 | 32768; oi_buffer[6].attr2 = ((512+4*32)) | (1 << 10); } if (titletimeinVblanks == (((10 +4*6)+16))) { oi_buffer[6].attr0 = (((18-32) & 255) + 32) | 256 | 32768; oi_buffer[6].attr1 = ((((26-16) & 511)+63) + 16) | (6 << 9) | 16384 | 32768; oi_buffer[6].attr2 = ((512+4*32)) | (1 << 10); } if (titletimeinVblanks <= (((10 +4*6)+16))) { if (titletimeinVblanks >= ((10 +4*6))) { oa_scale(&oa_buffer[6], (128+3*((titletimeinVblanks-((10 +4*6)))<<3)), (128+3*((titletimeinVblanks-((10 +4*6)))<<3))); } };
      if (titletimeinVblanks == ((10 +5*6))) { oi_buffer[5].attr0 = ((18-32) & 255) | 512 | 256 | 32768; oi_buffer[5].attr1 = ((((26-16) & 511)+84)) | (5 << 9) | 16384 | 32768; oi_buffer[5].attr2 = ((512+2*32)) | (1 << 10); } if (titletimeinVblanks == (((10 +5*6)+16))) { oi_buffer[5].attr0 = (((18-32) & 255) + 32) | 256 | 32768; oi_buffer[5].attr1 = ((((26-16) & 511)+84) + 16) | (5 << 9) | 16384 | 32768; oi_buffer[5].attr2 = ((512+2*32)) | (1 << 10); } if (titletimeinVblanks <= (((10 +5*6)+16))) { if (titletimeinVblanks >= ((10 +5*6))) { oa_scale(&oa_buffer[5], (128+3*((titletimeinVblanks-((10 +5*6)))<<3)), (128+3*((titletimeinVblanks-((10 +5*6)))<<3))); } };
      if (titletimeinVblanks == ((10 +6*6))) { oi_buffer[4].attr0 = ((18-32) & 255) | 512 | 256 | 32768; oi_buffer[4].attr1 = ((((26-16) & 511)+99)) | (4 << 9) | 16384 | 32768; oi_buffer[4].attr2 = ((512+5*32)) | (1 << 10); } if (titletimeinVblanks == (((10 +6*6)+16))) { oi_buffer[4].attr0 = (((18-32) & 255) + 32) | 256 | 32768; oi_buffer[4].attr1 = ((((26-16) & 511)+99) + 16) | (4 << 9) | 16384 | 32768; oi_buffer[4].attr2 = ((512+5*32)) | (1 << 10); } if (titletimeinVblanks <= (((10 +6*6)+16))) { if (titletimeinVblanks >= ((10 +6*6))) { oa_scale(&oa_buffer[4], (128+3*((titletimeinVblanks-((10 +6*6)))<<3)), (128+3*((titletimeinVblanks-((10 +6*6)))<<3))); } };
      if (titletimeinVblanks == ((10 +7*6))) { oi_buffer[3].attr0 = ((18-32) & 255) | 512 | 256 | 32768; oi_buffer[3].attr1 = ((((26-16) & 511)+113)) | (3 << 9) | 16384 | 32768; oi_buffer[3].attr2 = ((512+6*32)) | (1 << 10); } if (titletimeinVblanks == (((10 +7*6)+16))) { oi_buffer[3].attr0 = (((18-32) & 255) + 32) | 256 | 32768; oi_buffer[3].attr1 = ((((26-16) & 511)+113) + 16) | (3 << 9) | 16384 | 32768; oi_buffer[3].attr2 = ((512+6*32)) | (1 << 10); } if (titletimeinVblanks <= (((10 +7*6)+16))) { if (titletimeinVblanks >= ((10 +7*6))) { oa_scale(&oa_buffer[3], (128+3*((titletimeinVblanks-((10 +7*6)))<<3)), (128+3*((titletimeinVblanks-((10 +7*6)))<<3))); } };
      if (titletimeinVblanks == ((10 +8*6))) { oi_buffer[2].attr0 = ((18-32) & 255) | 512 | 256 | 32768; oi_buffer[2].attr1 = ((((26-16) & 511)+129)) | (2 << 9) | 16384 | 32768; oi_buffer[2].attr2 = ((512+7*32)) | (1 << 10); } if (titletimeinVblanks == (((10 +8*6)+16))) { oi_buffer[2].attr0 = (((18-32) & 255) + 32) | 256 | 32768; oi_buffer[2].attr1 = ((((26-16) & 511)+129) + 16) | (2 << 9) | 16384 | 32768; oi_buffer[2].attr2 = ((512+7*32)) | (1 << 10); } if (titletimeinVblanks <= (((10 +8*6)+16))) { if (titletimeinVblanks >= ((10 +8*6))) { oa_scale(&oa_buffer[2], (128+3*((titletimeinVblanks-((10 +8*6)))<<3)), (128+3*((titletimeinVblanks-((10 +8*6)))<<3))); } };
      if (titletimeinVblanks == ((10 +9*6))) { oi_buffer[1].attr0 = ((18-32) & 255) | 512 | 256 | 32768; oi_buffer[1].attr1 = ((((26-16) & 511)+146)) | (1 << 9) | 16384 | 32768; oi_buffer[1].attr2 = ((512+2*32)) | (1 << 10); } if (titletimeinVblanks == (((10 +9*6)+16))) { oi_buffer[1].attr0 = (((18-32) & 255) + 32) | 256 | 32768; oi_buffer[1].attr1 = ((((26-16) & 511)+146) + 16) | (1 << 9) | 16384 | 32768; oi_buffer[1].attr2 = ((512+2*32)) | (1 << 10); } if (titletimeinVblanks <= (((10 +9*6)+16))) { if (titletimeinVblanks >= ((10 +9*6))) { oa_scale(&oa_buffer[1], (128+3*((titletimeinVblanks-((10 +9*6)))<<3)), (128+3*((titletimeinVblanks-((10 +9*6)))<<3))); } };

      if (titletimeinVblanks == (58 + 10)) {
         *(vu32*)(0x04000000 +0x0000) |= (0x0001<<8) | (0x0002<<8);
      }
      if (titletimeinVblanks >= (58 + 10)) {
         s16 yoffsetbg = 2 +(6)*(titletimeinVblanks - (58 + 10));
         *(vu16*)(0x04000000 +0x0012) = 0-(yoffsetbg);
         *(vu16*)(0x04000000 +0x0016) = 0-(147-yoffsetbg);
      }
      if (titletimeinVblanks == ((82 + 10 - 12)-16)) {
         *(vu16*)(0x04000000 +0x0050) = 128 | 32 | 16 | 2 | 1;
         (*(vu16*)(0x04000054)) = 0;
      }
      if (titletimeinVblanks > ((82 + 10 - 12)-16)) {
         (*(vu16*)(0x04000054)) = (titletimeinVblanks - ((82 + 10 - 12)-16));
      }

      AAS_DoDMA3(&oi_buffer[0], (void *)0x07000000, 256 | 0x84000000);
      titletimeinVblanks += 1;
   }

   *(vu32*)(0x04000000 +0x0000) = 0x0080;
   *(vu16*)(0x04000000 +0x0050) = 0;
   (*(vu16*)(0x04000054)) = 0;
   for (u8 obj_emptier = 0; obj_emptier < 12; obj_emptier++) {
      oi_buffer[obj_emptier].attr0 = 0;
      oi_buffer[obj_emptier].attr1 = 0;
      oi_buffer[obj_emptier].attr2 = 0;
   }
   AAS_DoDMA3(&oi_buffer[0], (void *)0x07000000, 256 | 0x84000000);
}

void BlastArenaTitleFadeAndManagePressStart() {
   AAS_DoDMA3((void *)&blastarenatitlescreenPal[0], (void *)&((COLOR*)0x05000000)[0], 128 | 0x84000000);
   AAS_DoDMA3((void *)&blastarenatitlescreenData[0], (void *)0x06000000, 9600 | 0x84000000);
   AAS_DoDMA3((void *)&presstalettersPal[0], (void *)&((COLOR*)(0x05000000 +0x0200))[0], 8 | 0x84000000);
   AAS_DoDMA3((void *)&presstalettersData[0], (void *)&( (TILEBLOCK*)0x06000000 )[5][0], 224 | 0x84000000);
   *(vu32*)(0x04000000 +0x0000) = 4 | 0x0040 | (0x0004<<8) | (0x0010<<8);
   *(vu16*)(0x04000000 +0x0050) = 128 | 32 | 4;
   (*(vu16*)(0x04000054)) = 16;





   vu16 titlescreentimeinVblanks = 0;
   vu8 tscreenstat = 0;
   vu16 frameofleaving = 0;
# 1863 "main.cpp"
   while (1) {
      asm volatile("swi 0x05");
      key_poll();
      if (titlescreentimeinVblanks == 128) {
         *(vu16*)(0x04000000 +0x0050) = 0;
         (*(vu16*)(0x04000054)) = 0;
      }
      if (titlescreentimeinVblanks < 128) {
         (*(vu16*)(0x04000054)) = (128-titlescreentimeinVblanks) >> 3;
      } else {
         if (tscreenstat != 0) {
            hfadeline += 3;

            if (hfadeline > 87 && tscreenstat == 1) {
               for (u16 pal_emptier = 0; pal_emptier < 256; pal_emptier++) {
                  ((COLOR*)0x05000000)[pal_emptier] = 0;
                  ((COLOR*)(0x05000000 +0x0200))[pal_emptier] = 0;
                  tscreenstat = 2;
               }
            }
            if (hfadeline > 89) break;
         } else {
            if (_key_down(0x0008)) {
               tscreenstat = 1;
               hfadeline = -8;
               HBlanksituation = 2;
            }
         }
      }
      if (titlescreentimeinVblanks == ((148 + 0*5))) { oi_buffer[0].attr0 = ((117) & 255); oi_buffer[0].attr1 = ((((37) & 511))) | 16384; oi_buffer[0].attr2 = ((512+0*4)); };
      if (titlescreentimeinVblanks == ((148 + 1*5))) { oi_buffer[1].attr0 = ((117) & 255); oi_buffer[1].attr1 = ((((37) & 511)+15)) | 16384; oi_buffer[1].attr2 = ((512+1*4)); };
      if (titlescreentimeinVblanks == ((148 + 2*5))) { oi_buffer[2].attr0 = ((117) & 255); oi_buffer[2].attr1 = ((((37) & 511)+30)) | 16384; oi_buffer[2].attr2 = ((512+2*4)); };
      if (titlescreentimeinVblanks == ((148 + 3*5))) { oi_buffer[3].attr0 = ((117) & 255); oi_buffer[3].attr1 = ((((37) & 511)+45)) | 16384; oi_buffer[3].attr2 = ((512+3*4)); };
      if (titlescreentimeinVblanks == ((148 + 4*5))) { oi_buffer[4].attr0 = ((117) & 255); oi_buffer[4].attr1 = ((((37) & 511)+60)) | 16384; oi_buffer[4].attr2 = ((512+3*4)); };
      if (titlescreentimeinVblanks == ((148 + 7*5))) { oi_buffer[5].attr0 = ((117) & 255); oi_buffer[5].attr1 = ((((37) & 511)+90)) | 16384; oi_buffer[5].attr2 = ((512+4*4)); };
      if (titlescreentimeinVblanks == ((148 + 8*5))) { oi_buffer[6].attr0 = ((117) & 255); oi_buffer[6].attr1 = ((((37) & 511)+105)) | 16384; oi_buffer[6].attr2 = ((512+5*4)); };
      if (titlescreentimeinVblanks == ((148 + 9*5))) { oi_buffer[7].attr0 = ((117) & 255); oi_buffer[7].attr1 = ((((37) & 511)+120)) | 16384; oi_buffer[7].attr2 = ((512+6*4)); };
      if (titlescreentimeinVblanks == ((148 +10*5))) { oi_buffer[8].attr0 = ((117) & 255); oi_buffer[8].attr1 = ((((37) & 511)+135)) | 16384; oi_buffer[8].attr2 = ((512+1*4)); };
      if (titlescreentimeinVblanks == ((148 +11*5))) { oi_buffer[9].attr0 = ((117) & 255); oi_buffer[9].attr1 = ((((37) & 511)+150)) | 16384; oi_buffer[9].attr2 = ((512+5*4)); };
      AAS_DoDMA3(&oi_buffer[0], (void *)0x07000000, 256 | 0x84000000);
      titlescreentimeinVblanks++;
   }
   HBlanksituation = 0;
   for (u16 pal_emptier = 0; pal_emptier < 256; pal_emptier++) {
      ((COLOR*)0x05000000)[pal_emptier] = 0;
      ((COLOR*)(0x05000000 +0x0200))[pal_emptier] = 0;
   }
   *(vu16*)(0x04000000 +0x0050) = 128 | 64 | 32 | 16 | 8 | 4 | 2 | 1;
   (*(vu16*)(0x04000054)) = 16;
   for (u8 obj_emptier = 0; obj_emptier < 12; obj_emptier++) {
      oi_buffer[obj_emptier].attr0 = 0;
      oi_buffer[obj_emptier].attr1 = 0;
      oi_buffer[obj_emptier].attr2 = 0;
   }
   AAS_DoDMA3(&oi_buffer[0], (void *)0x07000000, 256 | 0x84000000);
}

void SetUpMainMenu() {



   u32 *blockempty = (u32*)(&( (TILEBLOCK*)0x06000000 )[0][0]);

   for (u8 zeroer = 0; zeroer < 16; zeroer++) {
      blockempty[zeroer] = 0;
   }

   AAS_DoDMA3((void *)finalbarsData, (void *)&( (TILEBLOCK*)0x06000000 )[0][2], 816 | 0x84000000);
   AAS_DoDMA3((void *)finalbarsPal, (void *)&((COLOR*)0x05000000)[0], 41 | 0x84000000);

   AAS_DoDMA3((void *)whitelineData, (void *)&( (TILEBLOCK*)0x06000000 )[0][104], 8 | 0x84000000);
   AAS_DoDMA3((void *)blanklineData, (void *)&( (TILEBLOCK*)0x06000000 )[4][125], 32 | 0x84000000);

   AAS_DoDMA3((void *)menulettersData, (void *)&( (TILEBLOCK*)0x06000000 )[4][1], 992 | 0x84000000);
   AAS_DoDMA3((void *)menulettersPal, (void *)&((COLOR*)(0x05000000 +0x0200))[0], 16 | 0x84000000);

   if (cheatmodes != 0) {
      for (u8 palettereplace = 0; palettereplace < 28; palettereplace++) {
         ((COLOR*)0x05000000)[2+palettereplace] = _RGB15(0, palettereplace+4, palettereplace+4);
      }

      for (u8 palettereplace = 0; palettereplace < 32; palettereplace++) {
         ((COLOR*)0x05000000)[29+palettereplace] = _RGB15(palettereplace, 31, 31);
      }

      for (u8 palettereplace = 0; palettereplace < 19; palettereplace++) {
         ((COLOR*)0x05000000)[61+palettereplace] = _RGB15(palettereplace, 22, 22);
      }
   }

   ((COLOR*)(0x05000000 +0x0200))[33] = ((COLOR*)0x05000000)[2];
}
# 1963 "main.cpp"
int MainMenu() {
   *(vu16*)(0x04000000 +0x0050) = 128 | 64 | 32 | 16 | 8 | 4 | 2 | 1;
   (*(vu16*)(0x04000054)) = 16;
   if (((((sfxflags) & (2)) == (2)))) {AAS_MOD_Play(AAS_DATA_MOD_btlemend);};;
   BGINFO back0;
   bg_init(&back0, 0, 0, 30, 0x0000 | 0x0080 | 1);
   TEGEL *tegelset0 = back0.map;
   bg_set_pos(&back0, 6, 2);
   bg_update(&back0);

   for (u16 xtile = 0; xtile < 1024; xtile++) {
      tegelset0[((xtile) + ((0)<<5))] = 0;
   }

   for (vu8 tegelrun = 0; tegelrun < 17; tegelrun++) { tegelset0[((0 + tegelrun) + ((0)<<5))] = 1+17*0 + tegelrun; };
   for (vu8 tegelrun = 0; tegelrun < 17; tegelrun++) { tegelset0[((0 + tegelrun) + ((1)<<5))] = 1+17*1 + tegelrun; };
   for (vu8 tegelrun = 0; tegelrun < 17; tegelrun++) { tegelset0[((0 + tegelrun) + ((2)<<5))] = 1+17*2 + tegelrun; };
   for (vu8 tegelrun = 0; tegelrun < 17; tegelrun++) { tegelset0[((0 + tegelrun) + ((3)<<5))] = 1+17*0 + tegelrun; };
   for (vu8 tegelrun = 0; tegelrun < 17; tegelrun++) { tegelset0[((0 + tegelrun) + ((4)<<5))] = 1+17*1 + tegelrun; };
   for (vu8 tegelrun = 0; tegelrun < 17; tegelrun++) { tegelset0[((0 + tegelrun) + ((5)<<5))] = 1+17*2 + tegelrun; };
   for (vu8 tegelrun = 0; tegelrun < 17; tegelrun++) { tegelset0[((0 + tegelrun) + ((6)<<5))] = 1+17*0 + tegelrun; };
   for (vu8 tegelrun = 0; tegelrun < 17; tegelrun++) { tegelset0[((0 + tegelrun) + ((7)<<5))] = 1+17*1 + tegelrun; };
   for (vu8 tegelrun = 0; tegelrun < 17; tegelrun++) { tegelset0[((0 + tegelrun) + ((8)<<5))] = 1+17*2 + tegelrun; };
   for (vu8 tegelrun = 0; tegelrun < 17; tegelrun++) { tegelset0[((0 + tegelrun) + ((9)<<5))] = 1+17*0 + tegelrun; };
   for (vu8 tegelrun = 0; tegelrun < 17; tegelrun++) { tegelset0[((0 + tegelrun) + ((10)<<5))] = 1+17*1 + tegelrun; };
   for (vu8 tegelrun = 0; tegelrun < 17; tegelrun++) { tegelset0[((0 + tegelrun) + ((11)<<5))] = 1+17*2 + tegelrun; };
   for (vu8 tegelrun = 0; tegelrun < 17; tegelrun++) { tegelset0[((0 + tegelrun) + ((12)<<5))] = 1+17*0 + tegelrun; };
   for (vu8 tegelrun = 0; tegelrun < 17; tegelrun++) { tegelset0[((0 + tegelrun) + ((13)<<5))] = 1+17*1 + tegelrun; };
   for (vu8 tegelrun = 0; tegelrun < 17; tegelrun++) { tegelset0[((0 + tegelrun) + ((14)<<5))] = 1+17*2 + tegelrun; };
   for (vu8 tegelrun = 0; tegelrun < 17; tegelrun++) { tegelset0[((0 + tegelrun) + ((15)<<5))] = 1+17*0 + tegelrun; };
   for (vu8 tegelrun = 0; tegelrun < 17; tegelrun++) { tegelset0[((0 + tegelrun) + ((16)<<5))] = 1+17*1 + tegelrun; };
   for (vu8 tegelrun = 0; tegelrun < 17; tegelrun++) { tegelset0[((0 + tegelrun) + ((17)<<5))] = 1+17*2 + tegelrun; };
   for (vu8 tegelrun = 0; tegelrun < 17; tegelrun++) { tegelset0[((0 + tegelrun) + ((18)<<5))] = 1+17*0 + tegelrun; };
   for (vu8 tegelrun = 0; tegelrun < 17; tegelrun++) { tegelset0[((0 + tegelrun) + ((19)<<5))] = 1+17*1 + tegelrun; };
   for (vu8 tegelrun = 0; tegelrun < 17; tegelrun++) { tegelset0[((0 + tegelrun) + ((20)<<5))] = 1+17*2 + tegelrun; };

   BGINFO back1;
   bg_init(&back1, 1, 0, 31, 0x0000 | 2);
   TEGEL *tegelset1 = back1.map;
   bg_set_pos(&back1, 6, 0);
   bg_update(&back1);

   for (u16 xtile = 0; xtile < 1024; xtile++) {
      tegelset1[((xtile) + ((0)<<5))] = 0;
   }

   for (u8 ytile = 0; ytile < 20; ytile++) {
      tegelset1[((17) + ((ytile)<<5))] = 104;
   }
# 2174 "main.cpp"
   u8 curframeupdate = 2 -1;
   u32 menutimeinVblanks = 0;
   u32 menutimefadebase = 0;

   u8 cursormenu = 0;
# 2190 "main.cpp"
   u8 MENUSTATUS = 0;







   *(vu32*)(0x04000000 +0x0000) = 0 | (0x0001<<8) | (0x0002<<8) | (0x0010<<8) | 0x0040;
   AAS_DoDMA3(&oi_buffer[0], (void *)0x07000000, 256 | 0x84000000);
   while ( ((MENUSTATUS == 0)
         || (MENUSTATUS == 1)
         || (MENUSTATUS == 3)
         || (MENUSTATUS == 5)
         || (MENUSTATUS == 7))) {
      asm volatile("swi 0x05");
      key_poll();
      menutimeinVblanks++;

      if (menutimeinVblanks < 32) {
         (*(vu16*)(0x04000054)) = 17 - (menutimeinVblanks >> 1);
      } else if (menutimeinVblanks == 32) {
         *(vu16*)(0x04000000 +0x0050) = 0;
         (*(vu16*)(0x04000054)) = 0;
      }

      if (MENUSTATUS == 1) {
         (*(vu16*)(0x04000054)) = ((menutimeinVblanks - menutimefadebase));
         if ((menutimeinVblanks - menutimefadebase) > 16) {
            MENUSTATUS = 2;
            *(vu32*)(0x04000000 +0x0000) = 0x0080;
            for (u8 obj_emptier = 0; obj_emptier < 128; obj_emptier++) {
               oi_buffer[obj_emptier].attr0 = 0;
               oi_buffer[obj_emptier].attr1 = 0;
               oi_buffer[obj_emptier].attr2 = 0;
            }
            AAS_DoDMA3(&oi_buffer[0], (void *)0x07000000, 256 | 0x84000000);
            asm volatile("swi 0x05");
         }
      }

      if (MENUSTATUS == 3) {
         (*(vu16*)(0x04000054)) = ((menutimeinVblanks - menutimefadebase));
         if ((menutimeinVblanks - menutimefadebase) > 16) {
            MENUSTATUS = 4;
            *(vu32*)(0x04000000 +0x0000) = 0;
            for (u8 obj_emptier = 0; obj_emptier < 128; obj_emptier++) {
               oi_buffer[obj_emptier].attr0 = 0;
               oi_buffer[obj_emptier].attr1 = 0;
               oi_buffer[obj_emptier].attr2 = 0;
            }
            AAS_DoDMA3(&oi_buffer[0], (void *)0x07000000, 256 | 0x84000000);
            asm volatile("swi 0x05");
         }
      }

      if ((menutimeinVblanks > 32) && (MENUSTATUS == 0)) {
         u8 oldcursor = cursormenu;
         if (key_hit(0x0080) && !key_hit(0x0040)) {
            cursormenu = (cursormenu==6) ? 6 : cursormenu + 1;
         }
         if (key_hit(0x0040) && !key_hit(0x0080)) {
            cursormenu = (cursormenu==0) ? 0 : cursormenu - 1;
         }
         if (((*(vu16*)(0x04000000 +0x0130) == 0x3fe) && (key_hit(0x0001))) || ((*(vu16*)(0x04000000 +0x0130) == 0x3f7) && (key_hit(0x0008)))) {
            if (cursormenu == 0) {
               MENUSTATUS = 1;
               menutimefadebase = menutimeinVblanks;
               *(vu16*)(0x04000000 +0x0050) = 128 | 32 | 16 | 8 | 4 | 2 | 1;
            } else if (cursormenu == 1) {
               MENUSTATUS = 3;
               menutimefadebase = menutimeinVblanks;
               *(vu16*)(0x04000000 +0x0050) = 128 | 64 | 32 | 16 | 8 | 4 | 2 | 1;
            } else if (cursormenu == 2) {
               sfxflags ^= 1;
               oi_buffer[122].attr0 = (36 + 28) | 16384; oi_buffer[122].attr1 = 135 | 32768; oi_buffer[122].attr2 = 37 | 3 << 10 | (1 << 12); oi_buffer[121].attr0 = (36 + 28) ; oi_buffer[121].attr1 = 135 + 32 | 16384; oi_buffer[121].attr2 = 45 | 3 << 10 | (1 << 12); oi_buffer[120].attr0 = (36 + 28) | 16384; oi_buffer[120].attr1 = 135 + 48 | 32768; oi_buffer[120].attr2 = (((((((sfxflags) & (1)) == (1))) ? 1 : 0) == 1) ? 117 : 109) | 3 << 10 | (1 << 12);
            } else if (cursormenu == 3) {
               sfxflags ^= 2;
               oi_buffer[119].attr0 = (36 + 42) | 16384; oi_buffer[119].attr1 = 135 | 32768; oi_buffer[119].attr2 = 49 | 3 << 10 | (1 << 12); oi_buffer[118].attr0 = (36 + 42) ; oi_buffer[118].attr1 = 135 + 32 | 16384; oi_buffer[118].attr2 = 57 | 3 << 10 | (1 << 12); oi_buffer[117].attr0 = (36 + 42) | 16384; oi_buffer[117].attr1 = 135 + 48 | 32768; oi_buffer[117].attr2 = (((((((sfxflags) & (2)) == (2))) ? 1 : 0) == 1) ? 117 : 109) | 3 << 10 | (1 << 12);
               if (((((sfxflags) & (2)) == (2)))) { if (((((sfxflags) & (2)) == (2)))) {AAS_MOD_Play(AAS_DATA_MOD_btlemend);};; } else { AAS_MOD_Stop(); };
            } else if (cursormenu == 4) {
               sfxflags ^= 128;
               oi_buffer[116].attr0 = (36 + 56) | 16384; oi_buffer[116].attr1 = 135 | 32768; oi_buffer[116].attr2 = 61 | 3 << 10 | (1 << 12); oi_buffer[115].attr0 = (36 + 56) ; oi_buffer[115].attr1 = 135 + 32 | 16384; oi_buffer[115].attr2 = 69 | 3 << 10 | (1 << 12); oi_buffer[114].attr0 = (36 + 56) | 16384; oi_buffer[114].attr1 = 135 + 48 | 32768; oi_buffer[114].attr2 = (((((((sfxflags) & (128)) == (128))) ? 1 : 0) == 1) ? 117 : 109) | 3 << 10 | (1 << 12);
            }
         }
         if (((*(vu16*)(0x04000000 +0x0130) == 0x3df) || (*(vu16*)(0x04000000 +0x0130) == 0x3ef)) &&
               ((key_hit(0x0020) && !key_hit(0x0010)) || (!key_hit(0x0020) && key_hit(0x0010)))) {
             if (cursormenu == 2) {
               sfxflags ^= 1;
               oi_buffer[122].attr0 = (36 + 28) | 16384; oi_buffer[122].attr1 = 135 | 32768; oi_buffer[122].attr2 = 37 | 3 << 10 | (1 << 12); oi_buffer[121].attr0 = (36 + 28) ; oi_buffer[121].attr1 = 135 + 32 | 16384; oi_buffer[121].attr2 = 45 | 3 << 10 | (1 << 12); oi_buffer[120].attr0 = (36 + 28) | 16384; oi_buffer[120].attr1 = 135 + 48 | 32768; oi_buffer[120].attr2 = (((((((sfxflags) & (1)) == (1))) ? 1 : 0) == 1) ? 117 : 109) | 3 << 10 | (1 << 12);
            } else if (cursormenu == 3) {
               sfxflags ^= 2;
               oi_buffer[119].attr0 = (36 + 42) | 16384; oi_buffer[119].attr1 = 135 | 32768; oi_buffer[119].attr2 = 49 | 3 << 10 | (1 << 12); oi_buffer[118].attr0 = (36 + 42) ; oi_buffer[118].attr1 = 135 + 32 | 16384; oi_buffer[118].attr2 = 57 | 3 << 10 | (1 << 12); oi_buffer[117].attr0 = (36 + 42) | 16384; oi_buffer[117].attr1 = 135 + 48 | 32768; oi_buffer[117].attr2 = (((((((sfxflags) & (2)) == (2))) ? 1 : 0) == 1) ? 117 : 109) | 3 << 10 | (1 << 12);
               if (((((sfxflags) & (2)) == (2)))) { if (((((sfxflags) & (2)) == (2)))) {AAS_MOD_Play(AAS_DATA_MOD_btlemend);};; } else { AAS_MOD_Stop(); };
            } else if (cursormenu == 4) {
               sfxflags ^= 128;
               oi_buffer[116].attr0 = (36 + 56) | 16384; oi_buffer[116].attr1 = 135 | 32768; oi_buffer[116].attr2 = 61 | 3 << 10 | (1 << 12); oi_buffer[115].attr0 = (36 + 56) ; oi_buffer[115].attr1 = 135 + 32 | 16384; oi_buffer[115].attr2 = 69 | 3 << 10 | (1 << 12); oi_buffer[114].attr0 = (36 + 56) | 16384; oi_buffer[114].attr1 = 135 + 48 | 32768; oi_buffer[114].attr2 = (((((((sfxflags) & (128)) == (128))) ? 1 : 0) == 1) ? 117 : 109) | 3 << 10 | (1 << 12);
            }
         }
         if (cursormenu != oldcursor) {
            switch (oldcursor) {
               case 0:
                  oi_buffer[127].attr0 = (36) | 16384; oi_buffer[127].attr1 = 135 | 32768; oi_buffer[127].attr2 = 1 | 3 << 10 | (0 << 12); oi_buffer[126].attr0 = (36) | 16384; oi_buffer[126].attr1 = 135 + 32 | 32768; oi_buffer[126].attr2 = 9 | 3 << 10 | (0 << 12); oi_buffer[125].attr0 = (36); oi_buffer[125].attr1 = 135 + 64 | 16384; oi_buffer[125].attr2 = 17 | 3 << 10 | (0 << 12);
               break;
               case 1:
                  oi_buffer[124].attr0 = (36 + 14) | 16384; oi_buffer[124].attr1 = 135 | 32768; oi_buffer[124].attr2 = 21 | 3 << 10 | (0 << 12); oi_buffer[123].attr0 = (36 + 14) | 16384; oi_buffer[123].attr1 = 135 + 32 | 32768; oi_buffer[123].attr2 = 29 | 3 << 10 | (0 << 12);
               break;
               case 2:
                  oi_buffer[122].attr0 = (36 + 28) | 16384; oi_buffer[122].attr1 = 135 | 32768; oi_buffer[122].attr2 = 37 | 3 << 10 | (0 << 12); oi_buffer[121].attr0 = (36 + 28) ; oi_buffer[121].attr1 = 135 + 32 | 16384; oi_buffer[121].attr2 = 45 | 3 << 10 | (0 << 12); oi_buffer[120].attr0 = (36 + 28) | 16384; oi_buffer[120].attr1 = 135 + 48 | 32768; oi_buffer[120].attr2 = (((((((sfxflags) & (1)) == (1))) ? 1 : 0) == 1) ? 117 : 109) | 3 << 10 | (0 << 12);
               break;
               case 3:
                  oi_buffer[119].attr0 = (36 + 42) | 16384; oi_buffer[119].attr1 = 135 | 32768; oi_buffer[119].attr2 = 49 | 3 << 10 | (0 << 12); oi_buffer[118].attr0 = (36 + 42) ; oi_buffer[118].attr1 = 135 + 32 | 16384; oi_buffer[118].attr2 = 57 | 3 << 10 | (0 << 12); oi_buffer[117].attr0 = (36 + 42) | 16384; oi_buffer[117].attr1 = 135 + 48 | 32768; oi_buffer[117].attr2 = (((((((sfxflags) & (2)) == (2))) ? 1 : 0) == 1) ? 117 : 109) | 3 << 10 | (0 << 12);
               break;
               case 4:
                  oi_buffer[116].attr0 = (36 + 56) | 16384; oi_buffer[116].attr1 = 135 | 32768; oi_buffer[116].attr2 = 61 | 3 << 10 | (0 << 12); oi_buffer[115].attr0 = (36 + 56) ; oi_buffer[115].attr1 = 135 + 32 | 16384; oi_buffer[115].attr2 = 69 | 3 << 10 | (0 << 12); oi_buffer[114].attr0 = (36 + 56) | 16384; oi_buffer[114].attr1 = 135 + 48 | 32768; oi_buffer[114].attr2 = (((((((sfxflags) & (128)) == (128))) ? 1 : 0) == 1) ? 117 : 109) | 3 << 10 | (0 << 12);
               break;
               case 5:
                  oi_buffer[113].attr0 = (36 + 70) | 16384; oi_buffer[113].attr1 = 135 | 32768; oi_buffer[113].attr2 = 73 | 3 << 10 | (0 << 12); oi_buffer[112].attr0 = (36 + 70) | 16384; oi_buffer[112].attr1 = 135 + 32 | 32768; oi_buffer[112].attr2 = 81 | 3 << 10 | (0 << 12); oi_buffer[111].attr0 = (36 + 70); oi_buffer[111].attr1 = 135 + 64 | 16384; oi_buffer[111].attr2 = 89 | 3 << 10 | (0 << 12);
               break;
               case 6:
                  oi_buffer[110].attr0 = (36 + 84) | 16384; oi_buffer[110].attr1 = 135 | 32768; oi_buffer[110].attr2 = 93 | 3 << 10 | (0 << 12); oi_buffer[109].attr0 = (36 + 84) | 16384; oi_buffer[109].attr1 = 135 + 32 | 32768; oi_buffer[109].attr2 = 101 | 3 << 10 | (0 << 12);
               break;
            }
            switch (cursormenu) {
               case 0:
                  oi_buffer[127].attr0 = (36) | 16384; oi_buffer[127].attr1 = 135 | 32768; oi_buffer[127].attr2 = 1 | 3 << 10 | (1 << 12); oi_buffer[126].attr0 = (36) | 16384; oi_buffer[126].attr1 = 135 + 32 | 32768; oi_buffer[126].attr2 = 9 | 3 << 10 | (1 << 12); oi_buffer[125].attr0 = (36); oi_buffer[125].attr1 = 135 + 64 | 16384; oi_buffer[125].attr2 = 17 | 3 << 10 | (1 << 12);
               break;
               case 1:
                  oi_buffer[124].attr0 = (36 + 14) | 16384; oi_buffer[124].attr1 = 135 | 32768; oi_buffer[124].attr2 = 21 | 3 << 10 | (1 << 12); oi_buffer[123].attr0 = (36 + 14) | 16384; oi_buffer[123].attr1 = 135 + 32 | 32768; oi_buffer[123].attr2 = 29 | 3 << 10 | (1 << 12);
               break;
               case 2:
                  oi_buffer[122].attr0 = (36 + 28) | 16384; oi_buffer[122].attr1 = 135 | 32768; oi_buffer[122].attr2 = 37 | 3 << 10 | (1 << 12); oi_buffer[121].attr0 = (36 + 28) ; oi_buffer[121].attr1 = 135 + 32 | 16384; oi_buffer[121].attr2 = 45 | 3 << 10 | (1 << 12); oi_buffer[120].attr0 = (36 + 28) | 16384; oi_buffer[120].attr1 = 135 + 48 | 32768; oi_buffer[120].attr2 = (((((((sfxflags) & (1)) == (1))) ? 1 : 0) == 1) ? 117 : 109) | 3 << 10 | (1 << 12);
               break;
               case 3:
                  oi_buffer[119].attr0 = (36 + 42) | 16384; oi_buffer[119].attr1 = 135 | 32768; oi_buffer[119].attr2 = 49 | 3 << 10 | (1 << 12); oi_buffer[118].attr0 = (36 + 42) ; oi_buffer[118].attr1 = 135 + 32 | 16384; oi_buffer[118].attr2 = 57 | 3 << 10 | (1 << 12); oi_buffer[117].attr0 = (36 + 42) | 16384; oi_buffer[117].attr1 = 135 + 48 | 32768; oi_buffer[117].attr2 = (((((((sfxflags) & (2)) == (2))) ? 1 : 0) == 1) ? 117 : 109) | 3 << 10 | (1 << 12);
               break;
               case 4:
                  oi_buffer[116].attr0 = (36 + 56) | 16384; oi_buffer[116].attr1 = 135 | 32768; oi_buffer[116].attr2 = 61 | 3 << 10 | (1 << 12); oi_buffer[115].attr0 = (36 + 56) ; oi_buffer[115].attr1 = 135 + 32 | 16384; oi_buffer[115].attr2 = 69 | 3 << 10 | (1 << 12); oi_buffer[114].attr0 = (36 + 56) | 16384; oi_buffer[114].attr1 = 135 + 48 | 32768; oi_buffer[114].attr2 = (((((((sfxflags) & (128)) == (128))) ? 1 : 0) == 1) ? 117 : 109) | 3 << 10 | (1 << 12);
               break;
               case 5:
                  oi_buffer[113].attr0 = (36 + 70) | 16384; oi_buffer[113].attr1 = 135 | 32768; oi_buffer[113].attr2 = 73 | 3 << 10 | (1 << 12); oi_buffer[112].attr0 = (36 + 70) | 16384; oi_buffer[112].attr1 = 135 + 32 | 32768; oi_buffer[112].attr2 = 81 | 3 << 10 | (1 << 12); oi_buffer[111].attr0 = (36 + 70); oi_buffer[111].attr1 = 135 + 64 | 16384; oi_buffer[111].attr2 = 89 | 3 << 10 | (1 << 12);
               break;
               case 6:
                  oi_buffer[110].attr0 = (36 + 84) | 16384; oi_buffer[110].attr1 = 135 | 32768; oi_buffer[110].attr2 = 93 | 3 << 10 | (1 << 12); oi_buffer[109].attr0 = (36 + 84) | 16384; oi_buffer[109].attr1 = 135 + 32 | 32768; oi_buffer[109].attr2 = 101 | 3 << 10 | (1 << 12);
               break;
            }
         }
      }

      if ((menutimeinVblanks > ((20 + (0*4)) - 20)) && (menutimeinVblanks <= (20 + (0*4)))) { oi_buffer[127].attr0 = (36) | 16384; oi_buffer[127].attr1 = 35 + 5*(menutimeinVblanks-((20 + (0*4)) - 20)) | 32768; oi_buffer[127].attr2 = 1 | 3 << 10 | (1 << 12); oi_buffer[126].attr0 = (36) | 16384; oi_buffer[126].attr1 = 35 + 5*(menutimeinVblanks-((20 + (0*4)) - 20)) + 32 | 32768; oi_buffer[126].attr2 = 9 | 3 << 10 | (1 << 12); oi_buffer[125].attr0 = (36); oi_buffer[125].attr1 = 35 + 5*(menutimeinVblanks-((20 + (0*4)) - 20)) + 64 | 16384; oi_buffer[125].attr2 = 17 | 3 << 10 | (1 << 12);; };
      if ((menutimeinVblanks > ((20 + (1*4)) - 20)) && (menutimeinVblanks <= (20 + (1*4)))) { oi_buffer[124].attr0 = (36 + 14) | 16384; oi_buffer[124].attr1 = 35 + 5*(menutimeinVblanks-((20 + (1*4)) - 20)) | 32768; oi_buffer[124].attr2 = 21 | 3 << 10 | (0 << 12); oi_buffer[123].attr0 = (36 + 14) | 16384; oi_buffer[123].attr1 = 35 + 5*(menutimeinVblanks-((20 + (1*4)) - 20)) + 32 | 32768; oi_buffer[123].attr2 = 29 | 3 << 10 | (0 << 12);; };
      if ((menutimeinVblanks > ((20 + (2*4)) - 20)) && (menutimeinVblanks <= (20 + (2*4)))) { oi_buffer[122].attr0 = (36 + 28) | 16384; oi_buffer[122].attr1 = 35 + 5*(menutimeinVblanks-((20 + (2*4)) - 20)) | 32768; oi_buffer[122].attr2 = 37 | 3 << 10 | (0 << 12); oi_buffer[121].attr0 = (36 + 28) ; oi_buffer[121].attr1 = 35 + 5*(menutimeinVblanks-((20 + (2*4)) - 20)) + 32 | 16384; oi_buffer[121].attr2 = 45 | 3 << 10 | (0 << 12); oi_buffer[120].attr0 = (36 + 28) | 16384; oi_buffer[120].attr1 = 35 + 5*(menutimeinVblanks-((20 + (2*4)) - 20)) + 48 | 32768; oi_buffer[120].attr2 = (((((((sfxflags) & (1)) == (1))) ? 1 : 0) == 1) ? 117 : 109) | 3 << 10 | (0 << 12);; };
      if ((menutimeinVblanks > ((20 + (3*4)) - 20)) && (menutimeinVblanks <= (20 + (3*4)))) { oi_buffer[119].attr0 = (36 + 42) | 16384; oi_buffer[119].attr1 = 35 + 5*(menutimeinVblanks-((20 + (3*4)) - 20)) | 32768; oi_buffer[119].attr2 = 49 | 3 << 10 | (0 << 12); oi_buffer[118].attr0 = (36 + 42) ; oi_buffer[118].attr1 = 35 + 5*(menutimeinVblanks-((20 + (3*4)) - 20)) + 32 | 16384; oi_buffer[118].attr2 = 57 | 3 << 10 | (0 << 12); oi_buffer[117].attr0 = (36 + 42) | 16384; oi_buffer[117].attr1 = 35 + 5*(menutimeinVblanks-((20 + (3*4)) - 20)) + 48 | 32768; oi_buffer[117].attr2 = (((((((sfxflags) & (2)) == (2))) ? 1 : 0) == 1) ? 117 : 109) | 3 << 10 | (0 << 12);; };
      if ((menutimeinVblanks > ((20 + (4*4)) - 20)) && (menutimeinVblanks <= (20 + (4*4)))) { oi_buffer[116].attr0 = (36 + 56) | 16384; oi_buffer[116].attr1 = 35 + 5*(menutimeinVblanks-((20 + (4*4)) - 20)) | 32768; oi_buffer[116].attr2 = 61 | 3 << 10 | (0 << 12); oi_buffer[115].attr0 = (36 + 56) ; oi_buffer[115].attr1 = 35 + 5*(menutimeinVblanks-((20 + (4*4)) - 20)) + 32 | 16384; oi_buffer[115].attr2 = 69 | 3 << 10 | (0 << 12); oi_buffer[114].attr0 = (36 + 56) | 16384; oi_buffer[114].attr1 = 35 + 5*(menutimeinVblanks-((20 + (4*4)) - 20)) + 48 | 32768; oi_buffer[114].attr2 = (((((((sfxflags) & (128)) == (128))) ? 1 : 0) == 1) ? 117 : 109) | 3 << 10 | (0 << 12);; };
      if ((menutimeinVblanks > ((20 + (5*4)) - 20)) && (menutimeinVblanks <= (20 + (5*4)))) { oi_buffer[113].attr0 = (36 + 70) | 16384; oi_buffer[113].attr1 = 35 + 5*(menutimeinVblanks-((20 + (5*4)) - 20)) | 32768; oi_buffer[113].attr2 = 73 | 3 << 10 | (0 << 12); oi_buffer[112].attr0 = (36 + 70) | 16384; oi_buffer[112].attr1 = 35 + 5*(menutimeinVblanks-((20 + (5*4)) - 20)) + 32 | 32768; oi_buffer[112].attr2 = 81 | 3 << 10 | (0 << 12); oi_buffer[111].attr0 = (36 + 70); oi_buffer[111].attr1 = 35 + 5*(menutimeinVblanks-((20 + (5*4)) - 20)) + 64 | 16384; oi_buffer[111].attr2 = 89 | 3 << 10 | (0 << 12);; };
      if ((menutimeinVblanks > ((20 + (6*4)) - 20)) && (menutimeinVblanks <= (20 + (6*4)))) { oi_buffer[110].attr0 = (36 + 84) | 16384; oi_buffer[110].attr1 = 35 + 5*(menutimeinVblanks-((20 + (6*4)) - 20)) | 32768; oi_buffer[110].attr2 = 93 | 3 << 10 | (0 << 12); oi_buffer[109].attr0 = (36 + 84) | 16384; oi_buffer[109].attr1 = 35 + 5*(menutimeinVblanks-((20 + (6*4)) - 20)) + 32 | 32768; oi_buffer[109].attr2 = 101 | 3 << 10 | (0 << 12);; };




      curframeupdate++;


      if (curframeupdate == 2) {
         u8 curspriteused = 0;
         for (u8 curmaskline = 0; curmaskline < 27; curmaskline++) {
            const signed char* soundbuffer1 = AAS_GetOutputBufferAddress(0);
            const signed char* soundbuffer2 = AAS_GetOutputBufferAddress(1);
            s16 ploty = 0;
            if (&(soundbuffer1[0]) != 0) ploty += soundbuffer1[curmaskline*16];
            if (&(soundbuffer2[0]) != 0) ploty += soundbuffer2[curmaskline*16];
            ploty = ploty<0?0-ploty:ploty;

            s16 used = (128 - (ploty<<1));
            if (used > 32) {
               oi_buffer[curspriteused].attr0 = ((curmaskline*6-1) & 0xFF) | 16384;
               oi_buffer[curspriteused].attr1 = 0 | 16384;
               oi_buffer[curspriteused].attr2 = 125 | 1 << 10 | 2 << 12;
               curspriteused++;
               if (used > 64) {
                  oi_buffer[curspriteused].attr0 = ((curmaskline*6-1) & 0xFF) | 16384;
                  oi_buffer[curspriteused].attr1 = 32 | 16384;
                  oi_buffer[curspriteused].attr2 = 125 | 1 << 10 | 2 << 12;
                  curspriteused++;
                  if (used > 96) {
                     oi_buffer[curspriteused].attr0 = ((curmaskline*6-1) & 0xFF) | 16384;
                     oi_buffer[curspriteused].attr1 = 64 | 16384;
                     oi_buffer[curspriteused].attr2 = 125 | 1 << 10 | 2 << 12;
                     curspriteused++;
                     oi_buffer[curspriteused].attr0 = ((curmaskline*6-1) & 0xFF) | 16384;
                     oi_buffer[curspriteused].attr1 = ((used - 32) & 0x1FF)| 16384;
                     oi_buffer[curspriteused].attr2 = 125 | 1 << 10 | 2 << 12;
                     curspriteused++;
                  } else {
                     oi_buffer[curspriteused].attr0 = ((curmaskline*6-1) & 0xFF) | 16384;
                     oi_buffer[curspriteused].attr1 = ((used - 32) & 0x1FF)| 16384;
                     oi_buffer[curspriteused].attr2 = 125 | 1 << 10 | 2 << 12;
                     curspriteused++;
                  }
               } else {
                  oi_buffer[curspriteused].attr0 = ((curmaskline*6-1) & 0xFF) | 16384;
                  oi_buffer[curspriteused].attr1 = ((used - 32) & 0x1FF)| 16384;
                  oi_buffer[curspriteused].attr2 = 125 | 1 << 10 | 2 << 12;
                  curspriteused++;
               }
            } else {
               oi_buffer[curspriteused].attr0 = ((curmaskline*6-1) & 0xFF) | 16384;
               oi_buffer[curspriteused].attr1 = ((used - 32) & 0x1FF)| 16384;
               oi_buffer[curspriteused].attr2 = 125 | 1 << 10 | 2 << 12;
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
      AAS_DoDMA3(&oi_buffer[0], (void *)0x07000000, 256 | 0x84000000);
   }

   if (MENUSTATUS == 2) {
      return 1;
   }
   if (MENUSTATUS == 4) {
      return 3;
   }
   if (MENUSTATUS == 6) {
      return 2;
   }
   if (MENUSTATUS == 8) {
      return 4;
   }
}

void SetUpHiscores() {
   AAS_DoDMA3((void *)BGbackgData, (void *)&( (TILEBLOCK*)0x06000000 )[0][0], 9280 | 0x84000000);
   AAS_DoDMA3((void *)BGbackgPal, (void *)&((COLOR*)0x05000000)[0], 128 | 0x84000000);

   AAS_DoDMA3((void *)BGspritesData, (void *)&( (TILEBLOCK*)0x06000000 )[4][2], 5120 | 0x84000000);
   AAS_DoDMA3((void *)BGspritesPal, (void *)&((COLOR*)(0x05000000 +0x0200))[0], 128 | 0x84000000);

   AAS_DoDMA3((void *)texttilesData, (void *)&( (TILEBLOCK*)0x06000000 )[1][648], 728 | 0x84000000);


   for (u8 obj_emptier = 0; obj_emptier < 128; obj_emptier++) {
      oi_buffer[obj_emptier].attr0 = 0;
      oi_buffer[obj_emptier].attr1 = 0;
      oi_buffer[obj_emptier].attr2 = 0;
   }
   AAS_DoDMA3(&oi_buffer[0], (void *)0x07000000, 256 | 0x84000000);
}

void Hiscores() {
   *(vu32*)(0x04000000 +0x0000) = 0 | (0x0001<<8) | (0x0002<<8) | (0x0010<<8) | 0x0040;
   BGINFO back0;
   bg_init(&back0, 0, 0, 31, 0x0000 | 0x0080 | 3);
   TEGEL *tegelset0 = back0.map;
   bg_set_pos(&back0, 0-136, 0);
   bg_update(&back0);

   BGINFO back1;
   bg_init(&back1, 1, 1, 30, 0x0000 | 2);
   TEGEL *tegelset1 = back1.map;
   bg_set_pos(&back1, 0, 0);
   bg_update(&back1);



   for (u16 xtile = 0; xtile < 1024; xtile++) {
      tegelset0[((xtile) + ((0)<<5))] = 0;
   }

   for (u8 ytile = 0; ytile < 20; ytile++) {
      for (vu8 tegelrun = 0; tegelrun < 29; tegelrun++) { tegelset0[((0 + tegelrun) + ((ytile)<<5))] = ytile*29 + tegelrun; };

   }

   for (u16 xtile = 0; xtile < 1024; xtile++) {
      tegelset1[((xtile) + ((0)<<5))] = 731;
   }

   tegelset1[((2) + ((2)<<5))] = (1 << 12) | 665;
   tegelset1[((3) + ((2)<<5))] = (1 << 12) | 678;
   tegelset1[((4) + ((2)<<5))] = (1 << 12) | 677;
   tegelset1[((5) + ((2)<<5))] = (1 << 12) | 688;
   tegelset1[((6) + ((2)<<5))] = (1 << 12) | 731;
   tegelset1[((7) + ((2)<<5))] = (1 << 12) | 693;
   tegelset1[((8) + ((2)<<5))] = (1 << 12) | 681;
   tegelset1[((9) + ((2)<<5))] = (1 << 12) | 678;
   tegelset1[((10) + ((2)<<5))] = (1 << 12) | 731;
   tegelset1[((11) + ((2)<<5))] = (1 << 12) | 698;
   tegelset1[((12) + ((2)<<5))] = (1 << 12) | 678;
   tegelset1[((13) + ((2)<<5))] = (1 << 12) | 685;
   tegelset1[((14) + ((2)<<5))] = (1 << 12) | 685;
   tegelset1[((15) + ((2)<<5))] = (1 << 12) | 688;
   tegelset1[((16) + ((2)<<5))] = (1 << 12) | 696;
   tegelset1[((17) + ((2)<<5))] = (1 << 12) | 731;
   tegelset1[((18) + ((2)<<5))] = (1 << 12) | 689;
   tegelset1[((19) + ((2)<<5))] = (1 << 12) | 674;
   tegelset1[((20) + ((2)<<5))] = (1 << 12) | 685;
   tegelset1[((21) + ((2)<<5))] = (1 << 12) | 678;
   tegelset1[((22) + ((2)<<5))] = (1 << 12) | 693;
   tegelset1[((23) + ((2)<<5))] = (1 << 12) | 693;
   tegelset1[((24) + ((2)<<5))] = (1 << 12) | 678;
   tegelset1[((25) + ((2)<<5))] = (1 << 12) | 711;

   tegelset1[((2) + ((4)<<5))] = (2 << 12) | 656;
   tegelset1[((3) + ((4)<<5))] = (2 << 12) | 693;
   tegelset1[((4) + ((4)<<5))] = (2 << 12) | 692;
   tegelset1[((5) + ((4)<<5))] = (2 << 12) | 731;
   tegelset1[((6) + ((4)<<5))] = (2 << 12) | 687;
   tegelset1[((7) + ((4)<<5))] = (2 << 12) | 688;
   tegelset1[((8) + ((4)<<5))] = (2 << 12) | 693;
   tegelset1[((9) + ((4)<<5))] = (2 << 12) | 731;
   tegelset1[((10) + ((4)<<5))] = (2 << 12) | 695;
   tegelset1[((11) + ((4)<<5))] = (2 << 12) | 678;
   tegelset1[((12) + ((4)<<5))] = (2 << 12) | 691;
   tegelset1[((13) + ((4)<<5))] = (2 << 12) | 698;
   tegelset1[((14) + ((4)<<5))] = (2 << 12) | 731;
   tegelset1[((15) + ((4)<<5))] = (2 << 12) | 680;
   tegelset1[((16) + ((4)<<5))] = (2 << 12) | 688;
   tegelset1[((17) + ((4)<<5))] = (2 << 12) | 688;
   tegelset1[((18) + ((4)<<5))] = (2 << 12) | 677;
   tegelset1[((19) + ((4)<<5))] = (2 << 12) | 711;

   tegelset1[((2) + ((6)<<5))] = (3 << 12) | 667;
   tegelset1[((3) + ((6)<<5))] = (3 << 12) | 681;
   tegelset1[((4) + ((6)<<5))] = (3 << 12) | 682;
   tegelset1[((5) + ((6)<<5))] = (3 << 12) | 692;
   tegelset1[((6) + ((6)<<5))] = (3 << 12) | 731;
   tegelset1[((7) + ((6)<<5))] = (3 << 12) | 682;
   tegelset1[((8) + ((6)<<5))] = (3 << 12) | 692;
   tegelset1[((9) + ((6)<<5))] = (3 << 12) | 731;
   tegelset1[((10) + ((6)<<5))] = (3 << 12) | 693;
   tegelset1[((11) + ((6)<<5))] = (3 << 12) | 681;
   tegelset1[((12) + ((6)<<5))] = (3 << 12) | 678;
   tegelset1[((13) + ((6)<<5))] = (3 << 12) | 731;
   tegelset1[((14) + ((6)<<5))] = (3 << 12) | 698;
   tegelset1[((15) + ((6)<<5))] = (3 << 12) | 678;
   tegelset1[((16) + ((6)<<5))] = (3 << 12) | 685;
   tegelset1[((17) + ((6)<<5))] = (3 << 12) | 685;
   tegelset1[((18) + ((6)<<5))] = (3 << 12) | 688;
   tegelset1[((19) + ((6)<<5))] = (3 << 12) | 696;
# 2593 "main.cpp"
   oi_buffer[127].attr0 = 8192 | 0; oi_buffer[127].attr1 = 32768 | 16384 | 0 + 0; oi_buffer[127].attr2 = 3 << 10 | 2; oi_buffer[126].attr0 = 8192 | 0; oi_buffer[126].attr1 = 32768 | 16384 | 64 + 0; oi_buffer[126].attr2 = 3 << 10 | 130; oi_buffer[125].attr0 = 8192 | 64; oi_buffer[125].attr1 = 32768 | 16384 | 0 + 0; oi_buffer[125].attr2 = 3 << 10 | 258; oi_buffer[124].attr0 = 8192 | 64; oi_buffer[124].attr1 = 32768 | 16384 | 64 + 0; oi_buffer[124].attr2 = 3 << 10 | 386; oi_buffer[123].attr0 = 8192 | 128; oi_buffer[123].attr1 = 32768 | 0 + 0; oi_buffer[123].attr2 = 3 << 10 | 514; oi_buffer[122].attr0 = 8192 | 128; oi_buffer[122].attr1 = 32768 | 32 + 0; oi_buffer[122].attr2 = 3 << 10 | 546; oi_buffer[121].attr0 = 8192 | 128; oi_buffer[121].attr1 = 32768 | 64 + 0; oi_buffer[121].attr2 = 3 << 10 | 578; oi_buffer[120].attr0 = 8192 | 128; oi_buffer[120].attr1 = 32768 | 96 + 0; oi_buffer[120].attr2 = 3 << 10 | 610;;



   bg_set_pos(&back0, 70, 0); bg_update(&back0); if (( 0+232-70) > 240) { oi_buffer[127].attr0 |= 512; } else { oi_buffer[127].attr0 &= 65023; } oi_buffer[127].attr1 = 32768 | 16384 | ((0 + 232-70) & 511); if ((64+232-70) > 240) { oi_buffer[126].attr0 |= 512; } else { oi_buffer[126].attr0 &= 65023; } oi_buffer[126].attr1 = 32768 | 16384 | ((64 + 232-70) & 511); if (( 0+232-70) > 240) { oi_buffer[125].attr0 |= 512; } else { oi_buffer[125].attr0 &= 65023; } oi_buffer[125].attr1 = 32768 | 16384 | ((0 + 232-70) & 511); if ((64+232-70) > 240) { oi_buffer[124].attr0 |= 512; } else { oi_buffer[124].attr0 &= 65023; } oi_buffer[124].attr1 = 32768 | 16384 | ((64 + 232-70) & 511); if (( 0+232-70) > 240) { oi_buffer[123].attr0 |= 512; } else { oi_buffer[123].attr0 &= 65023; } oi_buffer[123].attr1 = 32768 | ((0 + 232-70) & 511); if ((32+232-70) > 240) { oi_buffer[122].attr0 |= 512; } else { oi_buffer[122].attr0 &= 65023; } oi_buffer[122].attr1 = 32768 | ((32 + 232-70) & 511); if ((64+232-70) > 240) { oi_buffer[121].attr0 |= 512; } else { oi_buffer[121].attr0 &= 65023; } oi_buffer[121].attr1 = 32768 | ((64 + 232-70) & 511); if ((96+232-70) > 240) { oi_buffer[120].attr0 |= 512; } else { oi_buffer[120].attr0 &= 65023; } oi_buffer[120].attr1 = 32768 | ((96 + 232-70) & 511);; AAS_DoDMA3(&oi_buffer[0], (void *)0x07000000, 256 | 0x84000000);;
   AAS_DoDMA3(&oi_buffer[0], (void *)0x07000000, 256 | 0x84000000);

   *(vu16*)(0x04000000 +0x0050) = (*(vu16*)(0x04000054)) = 0;






   u8 hiscorestats = 0;
   s16 cameraposition = 0;

   u16 hiscoretimeinVblanks = 0;

   while (1) {
      asm volatile("swi 0x05");
      key_poll();
# 2625 "main.cpp"
   }


   asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll(); asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll(); asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll(); asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll(); asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll(); asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll(); asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll(); asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll(); asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll(); asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll(); asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll(); asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll(); asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll(); asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll(); asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll(); asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();asm volatile("swi 0x05");key_poll();;
}

void TemporaryFadeWhiteToBlack() {
   HBlanksituation = 0;
   for (u16 pal_emptier = 0; pal_emptier < 256; pal_emptier++) {
      ((COLOR*)0x05000000)[pal_emptier] = 0;
      ((COLOR*)(0x05000000 +0x0200))[pal_emptier] = 0;
   }
   *(vu16*)(0x04000000 +0x0050) = 128 | 32 | 16 | 8 | 4 | 2 | 1;
   (*(vu16*)(0x04000054)) = 16;
   vu8 fade = 16<<3;
   *(vu32*)(0x04000000 +0x0000) = (0x0001<<8);
   while (1) {
      asm volatile("swi 0x05");
      key_poll();
      (*(vu16*)(0x04000054)) = fade >> 3;
      fade--;
      if (fade == 0) break;
   }
   *(vu16*)(0x04000000 +0x0050) = 0;
   (*(vu16*)(0x04000054)) = 0;
   for (u8 obj_emptier = 0; obj_emptier < 128; obj_emptier++) {
      oi_buffer[obj_emptier].attr0 = 0;
      oi_buffer[obj_emptier].attr1 = 0;
      oi_buffer[obj_emptier].attr2 = 0;
   }
   AAS_DoDMA3(&oi_buffer[0], (void *)0x07000000, 256 | 0x84000000);
}

extern "C" int AgbMain(void) {
   *(vu32*)(0x04000000 +0x0000) = 0x0080;


   AAS_SetConfig(1, 2, 1, 0 );

   AAS_MOD_SetVolume(255);

   *(vu16*)(0x04000000 +0x0004) |= 0x0008 | 0x0010;
   *(vu16*)(0x04000000 +0x0200) |= 0x0001 | 0x0002;




   SetUpMathewCarr();
   DoMathewCarr();

   AAS_ShowLogo();



   SetUpBlastArenaLetterSlamTitle();
   DoBlastArenaLetterSlamTitle();
   BlastArenaTitleFadeAndManagePressStart();

   for (u16 pal_emptier = 0; pal_emptier < 256; pal_emptier++) {
      ((COLOR*)0x05000000)[pal_emptier] = 0;
   }





   u8 menuresult = 1;
   do {
      SetUpMainMenu();
      menuresult = MainMenu();
      if (menuresult == 1) {
         u8 gameresult = 4;
         do {
            AAS_MOD_Stop();
            SetUpGame();
            gameresult = Game();
         } while (gameresult == 4);
      } else if (menuresult == 2) {
      } else if (menuresult == 3) {
         SetUpHiscores();
         Hiscores();
      } else if (menuresult == 4) {
      }
   } while(1);
   return 1;
}
