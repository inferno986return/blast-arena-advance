//
// bullets declarations
//

#ifndef __BULLETS__
#define __BULLETS__

extern const int bulletsWidth;
extern const int bulletsHeight;
extern const int bulletsLen;
extern const unsigned int bulletsData[];

#define B_ALIVE bit0
#define B_LEFT  bit1
#define B_DOWN  bit2
#define B_VERT  bit3
#define B_DIAG  bit4

#endif // __BULLETS__

