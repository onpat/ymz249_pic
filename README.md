# ymz249_pic
Play RSF file with YMZ294 and PIC16F84A<br>
<br>
Wiring<br>
<br>
RB0-7 -> YMZ294 D0-7<br>
RA0 -> YMZ294 WR, CS<br>
RA1 -> YMZ294 A0<br>
RA2 -> YMZ294 IC<br>
<br>
RA3 -> I2C EEPROM SCL<br>
RA4 -> I2C EEPROM SDA<br>
<br>
VDD -> 5V<br>
VSS -> GND<br>
MCLR -> 5V<br>
OSCIN -> Oscillator Output<br>
<br>
YMZ294 needs 4MHz/6Mhz Clock, Not Crystal.<br>
If you want to use crystal, Please Refer this circuit(SN74HC02N)<br>
https://pcnews.ru/blogs/zvuk_na_cipe_yamaha_ay_3_8910_ili_ym2149f_rodom_s_zx_spectrum_na_pc_cerez_lpt_port-527263.html#gsc.tab=0<br>
YMZ294 VDD -> 5V<br>
YMZ294 GND -> GND<br>
YMZ294 4/8 -> 5V<br>
YMZ294 SO  -> Sound Output (connect 1k resistor)<br>
I2C EEPROM VDD -> 5V<br>
I2C EEPROM GND -> GND<br>
<br>
<br>
RSF file<br>
RSF(Register Stream Flow) File is used by AY-AVR Player and intended to use in microcontroller.<br>
Their page has source code for Arduino.<br>
https://www.avray.ru/<br>
With RSF file, you can play Vortex Tracker or other Tracker module in AY/YM/YMZ with PIC/AVR !<br>
AY-AVR Player Download:<br>
https://www.avray.ru/avr-ay-player/<br>
<br>
<br>
How to write the song to EEPROM?<br>
First, You need remove header from rsf file.<br>
header is some string before "3F FF".<br>
Then, Please use Raspberry pi and eeprog to write song.<br>
https://www.richud.com/wiki/Rasberry_Pi_I2C_EEPROM_Program<br>
with this command: ./eeprog -f -16 -i songfile -w 0x00 -t 5 /dev/i2c-1 0x50<br>
It may take a while(about 3 min for 32KB song)<br>
