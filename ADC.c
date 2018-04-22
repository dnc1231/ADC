// ADC.c
// Runs on LM4F120/TM4C123
// Provide functions that initialize ADC0
// Last Modified: 3/6/2015 
// Student names: change this to your names or look very silly
// Last modification date: change this to the last modification date or look very silly

#include <stdint.h>
#include "tm4c123gh6pm.h"

// ADC initialization function 
// Input: none
// Output: none
void ADC_Init(void){
		
	SYSCTL_RCGCGPIO_R|=0x10;//port e initialiation, pe2 is input, no outputs, enable alternate function and analong function on pe2, disable i/o function
	while ((SYSCTL_PRGPIO_R&0x10) ==0){};//2 cycles
	GPIO_PORTE_DIR_R&=~(0x04);
	GPIO_PORTE_AFSEL_R|=(0x04);
	GPIO_PORTE_DEN_R&=~(0x04);
	GPIO_PORTE_AMSEL_R|=(0x04);
		
	SYSCTL_RCGCADC_R|=0x01;//activate adc0
	while ((SYSCTL_RCGCADC_R&0x01)==0){};	//4 cycles
	ADC0_PC_R=0x01;//configure for 125K
	ADC0_SSPRI_R=0x0123;//sequencer 3 is highest priority
	ADC0_ACTSS_R&=~(0x0008);//disable sample sequencer 3
	ADC0_EMUX_R&=~(0xF000);//seq3 is software trigger
	ADC0_SSMUX3_R=(ADC0_SSMUX3_R & 0xFFFFFFF0) +1;//clear ss3 field and set channel ain0 (pe2)
	ADC0_SSCTL3_R= (0x0006);//no ts0 d0, yes ie0 end0
	ADC0_IM_R &= ~(0x0008);//disable ss3 interrupts
	ADC0_ACTSS_R |= (0x0008);//enable sample sequencer 3
		
	ADC0_SAC_R=0x04;//AVERAGES 16 SAMPLES NOW

}

//------------ADC_In------------
// Busy-wait Analog to digital conversion
// Input: none
// Output: 12-bit result of ADC conversion
uint32_t ADC_In(void){  
	uint32_t result;
	ADC0_PSSI_R = 0x0008;//initiate ss3
	while ((ADC0_RIS_R & 0x08) == 0){//wait for conversion done
	}
	result=(ADC0_SSFIFO3_R & 0xFFF);//read 12-bit result
	ADC0_ISC_R = 0x0008;//acknowledge completion
	return (result);
}


