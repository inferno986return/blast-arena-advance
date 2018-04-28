//======================================================================
//	snakeblocks, 32x32@4, tiles. (mode 0,1,2; obj)
//	(Creation date: 2005-05-28, 23:53:58)
//
//	Exported by Cearn's Usenti v1.6.1
//	(comments, kudos, flames to "daytshen@hotmail.com")
//======================================================================

#include "snakeblocks.h"

const int snakeblocksWidth= 32;
const int snakeblocksHeight= 32;
const int snakeblocksLen= 512;

const unsigned int snakeblocksData[128]=
{
	0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 
	0x04440000, 0x23440000, 0x13340000, 0x21200000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 
	0x00000444, 0x00002344, 0x00001334, 0x00002120, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 
	0x04440444, 0x23442344, 0x13341334, 0x21202120, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 
	0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x04440000, 0x23440000, 0x13340000, 0x21200000, 
	0x04440000, 0x23440000, 0x13340000, 0x21200000, 0x04440000, 0x23440000, 0x13340000, 0x21200000, 
	0x00000444, 0x00002344, 0x00001334, 0x00002120, 0x04440000, 0x23440000, 0x13340000, 0x21200000, 
	0x04440444, 0x23442344, 0x13341334, 0x21202120, 0x04440000, 0x23440000, 0x13340000, 0x21200000, 

	0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000444, 0x00002344, 0x00001334, 0x00002120, 
	0x04440000, 0x23440000, 0x13340000, 0x21200000, 0x00000444, 0x00002344, 0x00001334, 0x00002120, 
	0x00000444, 0x00002344, 0x00001334, 0x00002120, 0x00000444, 0x00002344, 0x00001334, 0x00002120, 
	0x04440444, 0x23442344, 0x13341334, 0x21202120, 0x00000444, 0x00002344, 0x00001334, 0x00002120, 
	0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x04440444, 0x23442344, 0x13341334, 0x21202120, 
	0x04440000, 0x23440000, 0x13340000, 0x21200000, 0x04440444, 0x23442344, 0x13341334, 0x21202120, 
	0x00000444, 0x00002344, 0x00001334, 0x00002120, 0x04440444, 0x23442344, 0x13341334, 0x21202120, 
	0x04440444, 0x23442344, 0x13341334, 0x21202120, 0x04440444, 0x23442344, 0x13341334, 0x21202120, 
};

const int snakeblocksPalLen= 12;
const unsigned int snakeblocksPal[3]=
{
	0x4d473000, 0x7f2b4905, 0x40107f75, 
};
