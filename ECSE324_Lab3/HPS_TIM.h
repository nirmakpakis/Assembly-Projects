#ifndef __HPS_TIM
#define __HPS_TIM

	typedef enum {
		TIM0 = 0x00000001,
		TIM1 = 0x00000002,
		TIM2 = 0x00000004,
		TIM3 = 0x00000008
	}	HPS_TIM_t;

	typedef struct {
		HPS_TIM_t tim;
		int timeout; 	// in usec (micro) - hides hardware of i.e. 4 calculations for 2micro sec etc.
		int LD_en;		//sets M, if yes then use timeout as starting count value 
		int INT_en;
		int enable;		//timer starts when you set this equal to 1
	}	HPS_TIM_config_t;
	
	extern void HPS_TIM_config_ASM(HPS_TIM_config_t *param);	//arg is struct pointer
	extern int HPS_TIM_read_INT_ASM(HPS_TIM_t tim);
	extern void HPS_TIM_clear_INT_ASM(HPS_TIM_t tim);

#endif
