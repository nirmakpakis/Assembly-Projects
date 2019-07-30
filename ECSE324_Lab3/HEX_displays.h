#ifndef _HEX_DISPLAYS
#define _HEX_DISPLAYS

	//this defines enum of variables
	//using encoding i.e. each variable has only one bit
	//thats a 1 or active...
	typedef enum {		//there are 6 displays, one for each
		HEX0 = 0x00000001,
		HEX1 = 0x00000002,
		HEX2 = 0x00000004,
		HEX3 = 0x00000008,
		HEX4 = 0x00000010,
		HEX5 = 0x00000020
	} HEX_t;

	extern void HEX_clear_ASM(HEX_t hex);
	extern void HEX_flood_ASM(HEX_t hex);
	extern void HEX_write_ASM(HEX_t hex, char val); 

#endif
