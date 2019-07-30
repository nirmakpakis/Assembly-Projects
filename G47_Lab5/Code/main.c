#include <stdlib.h>

#include "./drivers/inc/vga.h"
#include "./drivers/inc/ISRs.h"
#include "./drivers/inc/LEDs.h"
#include "./drivers/inc/audio.h"
#include "./drivers/inc/HPS_TIM.h"
#include "./drivers/inc/int_setup.h"
#include "./drivers/inc/wavetable.h"
#include "./drivers/inc/pushbuttons.h"
#include "./drivers/inc/ps2_keyboard.h"
#include "./drivers/inc/HEX_displays.h"
#include "./drivers/inc/slider_switches.h"


int SAMPLING_FREQUENCY = 48000;		//sampling rate
char amplitude = 1;					//volume control - from 0-10
char keysPressed[8] = {};			//currently pressed keys
float frequencies[] = {130.813, 	//frequencies corresponding to select keys - 
	146.832, 164.814, 174.614, 
	195.998, 220.000, 246.942, 
	261.626
};
int PIXEL_BUFFER_X = 320;
int PIXEL_BUFFER_Y = 240;
char keyValue;						//stores character hex value pressed
char keyReleased = 0;				//boolean store to indicate a break code was sent
int volumeChanged = 0;					// boolean check to change volume display


//returns next sample from table using frequency and sample number 
//allows frequency to have decimals
double getNextSample(float frequency, int sampleInstant) {
	double indexWithDecimal = frequency * sampleInstant;							//find desired index even if with decimal
	double decimalOfIndex = indexWithDecimal - (int)indexWithDecimal;				//find fraction of desired index
	int index = ((int)indexWithDecimal) % SAMPLING_FREQUENCY;						//wrap index so its within sample range and truncate				
	return (1.0 - decimalOfIndex) * sine[index] + decimalOfIndex * sine[index + 1]; //linear interpolation
}

// Loop throuogh all keys and sum generated signals
double generateSignal(int t) {
	double signal = 0;
	int i;
	for(i = 0; i < 8 ; i++)
		if(keysPressed[i] == 1)
			signal += getNextSample(frequencies[i], t);
	return signal;
}

// displays volume sign on screen
void setUpDisplay() {
	VGA_write_char_ASM(5, 3, 'V');
	VGA_write_char_ASM(6, 3, 'o');
	VGA_write_char_ASM(7, 3, 'l');
	VGA_write_char_ASM(8, 3, ':');
}

void drawVolume() {
	if(amplitude == 10)
		VGA_write_byte_ASM(10, 3, 16);
	else 
		VGA_write_byte_ASM(10, 3, amplitude);	
}


// When a key is read form the ps/2 buffer, this method is called
// If the key is one of the frequency choices we update the list that stores the currently pressed keys
// If the key is a break code we set the boolean keyReleased to true and when the next code is sent
//  	We disable this key in the array
void evaluateKeyPress() {
	switch (keyValue) {
	case 0x1C:						// A - 130.813
		if(keyReleased == 1){
			keysPressed[0] = 0;
			keyReleased = 0;
		} else{
			keysPressed[0] = 1;
		}
		break;
	case 0x1B:						// S - 146.832
		if(keyReleased == 1){
			keysPressed[1] = 0;
			keyReleased = 0;
		} else{
			keysPressed[1] = 1;
		}
		break;
	case 0x23:						// D - 164.814
		if(keyReleased == 1){
			keysPressed[2] = 0;
			keyReleased = 0;
		} else{
			keysPressed[2] = 1;
		}
		break;
	case 0x2B:						// F - 174.614
		if(keyReleased == 1){
			keysPressed[3] = 0;
			keyReleased = 0;
		} else{
			keysPressed[3] = 1;
		}
		break;
	case 0x3B:						// J - 195.998
		if(keyReleased == 1){
			keysPressed[4] = 0;
			keyReleased = 0;
		} else{
			keysPressed[4] = 1;
		}
		break;
	case 0x42:						// K - 220.000
		if(keyReleased == 1){
			keysPressed[5] = 0;
			keyReleased = 0;
		} else{
			keysPressed[5] = 1;
		}
		break;
	case 0x4B:						// L - 246.942
		if(keyReleased == 1){
			keysPressed[6] = 0;
			keyReleased = 0;
		} else{
			keysPressed[6] = 1;
		}
		break;
	case 0x4C:						// ; - 261.626
		if(keyReleased == 1){
			keysPressed[7] = 0;
			keyReleased = 0;
		}else{
			keysPressed[7] = 1;
		}
		break;
	case 0x49:						// volume up 
		if(keyReleased == 1){
			if(amplitude<10) {
				amplitude++;
				volumeChanged = 1;
			}
			keyReleased = 0;
		}
		break;
	case 0x41:						// volume down
		if(keyReleased == 1){
			if(amplitude>0) {
				amplitude--;
				volumeChanged = 1;
			}
			keyReleased = 0;
		}
		break;
	case 0xF0: 						// break code
		keyReleased = 1;
		break;
	default:
		keyReleased = 0;
	}
}


int main() {

	setUpDisplay();

	// Configure timer for audio generation
	int_setup(1, (int []){199});	// enable TIM0 to do interrupts
	HPS_TIM_config_t hps_tim;
	hps_tim.tim = TIM0; 
	hps_tim.timeout = 20; 			// 1/48000 = 20.8
	hps_tim.LD_en = 1; 
	hps_tim.INT_en = 1; 			// interrupts enabled for use of exported var
	hps_tim.enable = 1;
	HPS_TIM_config_ASM(&hps_tim);
	

	int t = 0;								// stores current sample count
	double previousSignal[320] = { 0 };		// stores previously drawn signal
	double currentSignal = 0.0;				// holds last created signal
	int signalX = 0;						// x coordinate to display signal
	double signalY = 0;						// y coordinate to display signal - the signal itself



	// Overall logic: continuous loop
	// if a key is pressed either 1) update volume, 2) update keysPressed array so that when signal generated it knows what frequencies to use
	while(1) {

		// if a key is pressed, update the keypressed Array
		if (read_ps2_data_ASM(&keyValue)) 
			evaluateKeyPress();
			
		// every 20 microseconds generate signal and send audio
		// done at this time so we simplify worrying about buffer being full 
		if(hps_tim0_int_flag == 1) {
			hps_tim0_int_flag = 0;
			currentSignal = generateSignal(t) * amplitude; 
			audio_write_data_ASM(currentSignal, currentSignal);
			t++;
		}

		// Only every 10 samples we find the next x point to draw the signal
		// Then clear it by retrieving its history using the same index and draw the new point
		if((t % 10 == 0)) {
			signalX = (t/10) % PIXEL_BUFFER_X;	
			VGA_draw_point_ASM(signalX, previousSignal[signalX], 0);	// clear previous drawn point
			signalY = PIXEL_BUFFER_Y/2 + currentSignal/1000000;			// center and size to fit screen
			previousSignal[signalX] = signalY;							// save new signal 
			VGA_draw_point_ASM(signalX, signalY, 63);					// draw new point
		}

		//only change volume display when boolean signaled
		if(volumeChanged == 1) {
			drawVolume();
			volumeChanged = 0;
		}

		// reset sample counter
		if(t == 48000)
			t = 0;
		
	}

	return 0;
}



/*
//returns next sample from table using frequency and sample number
double getNextSample(float frequency, int sampleInstant) {
	int index = (((int)frequency) * sampleInstant) % SAMPLING_FREQUENCY;			//truncate frequency and find index within range
	return sine[index];																//return value retrieved from sine table
}
*/
