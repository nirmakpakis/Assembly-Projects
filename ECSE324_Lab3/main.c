#include <stdio.h>

#include "./drivers/inc/LEDs.h"
#include "./drivers/inc/slider_switches.h"
#include "./drivers/inc/HEX_displays.h"
#include "./drivers/inc/pushbuttons.h"
#include "./drivers/inc/HPS_TIM.h"
#include "./drivers/inc/ISRs.h"
#include "./drivers/inc/int_setup.h"


//This method takes in the number to be printed on HEX Display 
//and encodes it to the correct corresponding segments 
char convertTo7Segment(int number) {
	switch(number) {
	case 1: return 0x06;
	case 2: return 0x5b;
	case 3: return 0x4f;
	case 4: return 0x66;
	case 5: return 0x6d;
	case 6: return 0x7d;
	case 7: return 0x07;
	case 8: return 0x7f;
	case 9: return 0x6f;
	case 0: return 0x3f;
	case 10: return 0x77;
	case 11: return 0x7C;
	case 12: return 0x39;
	case 13: return 0x5E;
	case 14: return 0x79;
	case 15: return 0x71;
	}
}

//This method is used for parts 3 and 4 of the lab 
//It takes in the minutes, seconds and milliSeconds
//and separates the digits to display on the individual 
//HEX displays 
void writeToDisplay(int minutes, int seconds, int milliSeconds){
    milliSeconds /= 10;
    HEX_write_ASM(HEX0, convertTo7Segment(milliSeconds % 10));
    milliSeconds /= 10;
    HEX_write_ASM(HEX1, convertTo7Segment(milliSeconds % 10));
    HEX_write_ASM(HEX2, convertTo7Segment(seconds % 10));
    seconds /= 10;
    HEX_write_ASM(HEX3, convertTo7Segment(seconds % 10));
	if(minutes >= 10) {
		HEX_write_ASM(HEX4, convertTo7Segment(minutes % 10));
    	minutes /= 10;
    	HEX_write_ASM(HEX5, convertTo7Segment(minutes % 10));  
	} else {
		HEX_write_ASM(HEX4, convertTo7Segment(minutes % 10));
	}

}

//
void part_1_2() {
	//uses last 4 slider switches SW3-SW0 to create number from 0-15
	char valueToDisplay = convertTo7Segment(read_slider_switches_7Seg_ASM());	
	HEX_flood_ASM(HEX0 | HEX1 | HEX2 | HEX3 | HEX4 | HEX5); //HEX4 and HEX5 should have all segments on at all times
	while(1) {
		valueToDisplay = convertTo7Segment(read_slider_switches_7Seg_ASM());
		write_LEDs_ASM(read_slider_switches_ASM());
		//if a pushbutton is pressed, display the number on the correspond HEX i.e. KEY0 pressed -> HEX0 displays number

		if(read_slider_switches_clearHEX_ASM()!= 0){ //asserting slider switch SW9 will clear all values of HEX displays
			HEX_clear_ASM(HEX0 | HEX1 | HEX2 | HEX3);
		}
		HEX_write_ASM(read_PB_data_ASM(), valueToDisplay); //write to whichever are selected from pushbutton
	}
}

void part_3() {
	 //configure timers 
  HPS_TIM_config_t hps_tim_timeCounter;
  hps_tim_timeCounter.tim = TIM1;
  hps_tim_timeCounter.timeout = 5000; //5 milliseconds
  hps_tim_timeCounter.LD_en = 1;
  hps_tim_timeCounter.INT_en = 1;
  hps_tim_timeCounter.enable = 1;
  HPS_TIM_config_t hps_tim_buttonPoller;
  hps_tim_buttonPoller.tim = TIM0;
  hps_tim_buttonPoller.timeout = 10000; //10 milliseconds
  hps_tim_buttonPoller.LD_en = 1;
  hps_tim_buttonPoller.INT_en = 1;
  hps_tim_buttonPoller.enable = 1;
  HPS_TIM_config_ASM(&hps_tim_timeCounter);
  HPS_TIM_config_ASM(&hps_tim_buttonPoller);
  
  
  int milliSeconds = 0, seconds = 0, minutes = 0;
  int start = 0;
  HEX_flood_ASM(HEX0 | HEX1 | HEX2 | HEX3 | HEX4 | HEX5); //flood display initially
	
  while(1) {
    //if pushbutton timer done counting check load data of pushbuttons
		//if PB3 - start timer set to true, PB2 - start timer set to false, PB1 - start set to false and reset values
    if(HPS_TIM_read_INT_ASM(TIM1)) {
        HPS_TIM_clear_INT_ASM(TIM1); //reset timer
        switch(read_PB_data_ASM()) {	//read PB data 
          case 8:
            start = 1;
            break;
          case 4:
            start = 0;
            break;
          case 2:
            start = 0;
            //clear data that HEX gets display from
            milliSeconds = 0; 
            seconds = 0;
            minutes = 0;
            HEX_flood_ASM(HEX0 | HEX1 | HEX2 | HEX3 | HEX4 | HEX5); //stop and flood all hex displays 
            break;
        }
    }
    
    //if start is on and slower timer is finished counting 10 milliSeconds
		//update the time by 10 milliSeconds and check if second is reached and minute is reached
		//then display values
    if(HPS_TIM_read_INT_ASM(TIM0) && start) {
      HPS_TIM_clear_INT_ASM(TIM0); //reset the timer
      //increment current count
      milliSeconds += 10;
      if(milliSeconds == 1000) { 
        milliSeconds = 0;
        seconds++;
        if(seconds == 60) {
          seconds = 0;
          minutes++;
        }
      }
      writeToDisplay(minutes, seconds, milliSeconds); //update all HEX displays accordingly
    }
  }
}

void part_4() {

  HEX_flood_ASM(HEX0 | HEX1 | HEX2 | HEX3 | HEX4 | HEX5);
  int milliSeconds = 0, seconds = 0, minutes = 0;
  int start = 0;
  
  int_setup(2, (int[]){199, 73}); //enable processor to make interupts to push buttons and HPS timer 0
  
  //configure timer 
  HPS_TIM_config_t hps_tim_timeCounter;
  hps_tim_timeCounter.tim = TIM0;
  hps_tim_timeCounter.timeout = 10000; //10 milliseconds
  hps_tim_timeCounter.LD_en = 1;
  hps_tim_timeCounter.INT_en = 1;      //setting interupt to enable actually sets I to 0, which enables interupts
  hps_tim_timeCounter.enable = 1;
  HPS_TIM_config_ASM(&hps_tim_timeCounter);
  
  //enable the pushbuttons hardware to generate interupts
  CONFIG_KEYS_ASM();
	
  while(1) {
		//checks every loop for the number that is pressed
	  if(key_pressed_number) {
	    switch(key_pressed_number) {
	      case 3: 
	        start = 1;
	        break;
	      case 2:
	        start = 0;
	        break;
	      case 1:
	        start = 0;
	        //clear data that HEX gets display from
	        milliSeconds = 0; 
	        seconds = 0;
	        minutes = 0;
	        HEX_flood_ASM(HEX0 | HEX1 | HEX2 | HEX3 | HEX4 | HEX5); //stop and flood all hex displays 
	        break;
	    }
	  }
	  
	  if(hps_tim0_int_flag && start) {
	    hps_tim0_int_flag = 0;
	    //increment current count
	    milliSeconds += 10;
	    if(milliSeconds == 1000) { 
	      milliSeconds = 0;
	      seconds++;
	      if(seconds == 60) {
	        seconds = 0;
	        minutes++;
	      }
	    }
	    writeToDisplay(minutes, seconds, milliSeconds); //update all HEX displays accordingly
	  }
	}
}

//Use the main to call the corresponding
//program to run for the specific part of lab
int main() {
	part_1_2();
	//part_3();
	//part_4();
	return 0;
}
