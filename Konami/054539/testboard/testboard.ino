// Konami 054539 testboard firmware for Mega2560

// TODO: Check DTAC output after internal RAM write

#include <Wire.h>
#include <stdlib.h>
#include <string.h>

const uint8_t PIN_SEL[4] = {63, 65, 64, 62};
const uint8_t PIN_MUXED[8] = {48, 49, 50, 51, 52, 53, 54, 55};
const uint8_t PIN_DB[8] = {21, 20, 13, 12, 11, 10, 9, 8};
const uint8_t PIN_RD[8] = {54, 55, 56, 57, 58, 59, 60, 61};
const uint8_t PIN_AB[9] = {0, 1, 2, 3, 4, 5, 6, 7, 16};

#define PIN_CLK	17
#define PIN_NRES 18
#define PIN_AXWA 19
#define PIN_ALRA 14
#define PIN_AXXA 15
#define PIN_AXDA 35
#define PIN_DTS1 36
#define PIN_DTS2 37
#define PIN_USE2 38
#define PIN_DLY 39
#define PIN_NRD 40
#define PIN_NWR 41
#define PIN_NCS 42
#define PIN_ADDA 43
#define PIN_YMD 44
#define PIN_RRMD 45
#define PIN_TS1 46
#define PIN_TS2 47

#define PIN_CLK2 22
#define PIN_CLK3 23
#define PIN_WAIT 24
#define PIN_TIM 25
#define PIN_WDCK 26
#define PIN_LRCK 27
#define PIN_DTCK 28
#define PIN_AXDT 29
#define PIN_REDL 30
#define PIN_REDT 31
#define PIN_FRDL 32
#define PIN_FRDT 33
#define PIN_DTAC 34

int count = 0;
uint8_t slave_address = 0x00;

const char nvmStringA0[]  PROGMEM = "410500420500C6812C4A52348C1058D4";

uint8_t readMux(uint8_t i) {
	for (uint8_t c = 0; c < 4; c++) {
		digitalWrite(PIN_SEL[c], HIGH);
	}

	digitalWrite(PIN_SEL[i], LOW);
	delay(1);

	uint8_t data = 0;
	for (uint8_t c = 0; c < 8; c++) {
		if (digitalRead(PIN_MUXED[c]))
			data |= (1 << c);
	}

	return data;
}

void setDBRead() {
	for (uint8_t c = 0; c < 8; c++) {
		pinMode(PIN_DB[c], INPUT);
	}
}

void setRDDir(int dir) {
	for (uint8_t c = 0; c < 8; c++) {
		pinMode(PIN_RD[c], dir);
	}
}

void setRDData(uint8_t data) {
	for (uint8_t c = 0; c < 8; c++) {
		digitalWrite(PIN_RD[c], data & (1 << c) ? HIGH : LOW);
	}
}

void setABData(uint16_t data) {
	for (uint8_t c = 0; c < 9; c++) {
		digitalWrite(PIN_AB[c], data & (1 << c) ? HIGH : LOW);
	}
}

void setupAB() {
	for (uint8_t c = 0; c < 9; c++) {
		pinMode(PIN_AB[c], OUTPUT);			// Will always be outputs
	}
}

void setup() {
	Serial.begin(115200);

	for (uint8_t c = 0; c < 8; c++) {
		pinMode(PIN_MUXED[c], INPUT);		// Will always be inputs
	}
	setupAB();
	setDBRead();
	setRDDir(INPUT);

	// Outputs
	pinMode(PIN_CLK, OUTPUT);
	digitalWrite(PIN_CLK, LOW);
	pinMode(PIN_NRES, OUTPUT);
	digitalWrite(PIN_NRES, LOW);
	pinMode(PIN_AXWA, OUTPUT);
	digitalWrite(PIN_AXWA, LOW);
	pinMode(PIN_ALRA, OUTPUT);
	digitalWrite(PIN_ALRA, LOW);
	pinMode(PIN_AXXA, OUTPUT);
	digitalWrite(PIN_AXXA, LOW);
	pinMode(PIN_DTS1, OUTPUT);
	digitalWrite(PIN_DTS1, LOW);
	pinMode(PIN_DTS2, OUTPUT);
	digitalWrite(PIN_DTS2, LOW);
	pinMode(PIN_USE2, OUTPUT);
	digitalWrite(PIN_USE2, LOW);

	pinMode(PIN_DLY, OUTPUT);
	digitalWrite(PIN_DLY, LOW);
	pinMode(PIN_NRD, OUTPUT);
	digitalWrite(PIN_NRD, HIGH);
	pinMode(PIN_NWR, OUTPUT);
	digitalWrite(PIN_NWR, HIGH);
	pinMode(PIN_NCS, OUTPUT);
	digitalWrite(PIN_NCS, HIGH);
	
	pinMode(PIN_ADDA, OUTPUT);
	digitalWrite(PIN_ADDA, LOW);
	pinMode(PIN_YMD, OUTPUT);
	digitalWrite(PIN_YMD, LOW);
	pinMode(PIN_RRMD, OUTPUT);
	digitalWrite(PIN_RRMD, LOW);
	
	pinMode(PIN_TS1, OUTPUT);
	digitalWrite(PIN_TS1, LOW);
	pinMode(PIN_TS2, OUTPUT);
	digitalWrite(PIN_TS2, LOW);

	for (uint8_t c = 0; c < 4; c++) {
		digitalWrite(PIN_SEL[c], HIGH);
		pinMode(PIN_SEL[c], OUTPUT);
	}

	// Inputs
	pinMode(PIN_CLK2, INPUT);
	pinMode(PIN_CLK3, INPUT);
	pinMode(PIN_WAIT, INPUT);
	pinMode(PIN_TIM, INPUT);

	pinMode(PIN_WDCK, INPUT);
	pinMode(PIN_LRCK, INPUT);
	pinMode(PIN_DTCK, INPUT);
	pinMode(PIN_AXDT, INPUT);
	pinMode(PIN_REDL, INPUT);
	pinMode(PIN_REDT, INPUT);
	pinMode(PIN_FRDL, INPUT);
	pinMode(PIN_FRDT, INPUT);
	
	pinMode(PIN_DTAC, INPUT);

  Serial.println();
  Serial.print("Ready");
}

void writeTS1(uint8_t data) {
	setRDDir(OUTPUT);
	setRDData(data);
	delay(1);
	digitalWrite(PIN_TS1, HIGH);
	delay(1);
	digitalWrite(PIN_TS1, LOW);
	delay(1);
	setRDDir(INPUT);
}

void resetChip() {
	digitalWrite(PIN_NRES, LOW);
	delay(1);
	digitalWrite(PIN_CLK, HIGH);	// Clock dividers are reset synchronously
	delay(1);
	digitalWrite(PIN_CLK, LOW);
	delay(1);
	digitalWrite(PIN_CLK, HIGH);	// Clock dividers are reset synchronously
	delay(1);
	digitalWrite(PIN_CLK, LOW);
	delay(1);
	digitalWrite(PIN_NRES, HIGH);
	delay(1);
	digitalWrite(PIN_CLK, HIGH);	// Internal reset is synchronized
	delay(1);
	digitalWrite(PIN_CLK, LOW);
	delay(1);
}

char strBuf[256];
uint16_t dataBuf[256];

void loop() {
  char selection = query("\nMENU: r = reset, R = run, c = clock test, d = dump ROMA, D = dump ROMB\n");

  Serial.println();

  switch (selection) {
    case 'r':
			digitalWrite(PIN_NRES, LOW);
			Serial.println(F("Chip now in reset !"));
			break;
    case 'R':
			digitalWrite(PIN_NRES, HIGH);
			Serial.println(F("Chip now out of reset !"));
			break;
    case 'c':
			Serial.println(F("Clock test"));
			Serial.println(F("#  CLK2 CLK3"));
			resetChip();
			for (uint8_t c = 0; c < 16; c++) {
				digitalWrite(PIN_CLK, HIGH);
				delay(1);
				digitalWrite(PIN_CLK, LOW);
				delay(1);

				uint8_t ck2 = digitalRead(PIN_CLK2);
				uint8_t ck3 = digitalRead(PIN_CLK3);

				sprintf(strBuf, "%02u   %u   %u", c, ck2, ck3);
				Serial.println(strBuf);
			}
			break;
    case 'd':
			// ROMA dump:
			// Outputs data on RA[6:0] when Y74=0, T92=1 (so TESTREG1_D0=1, TESTREG1_D2=0, TESTREG2_D4=0), this causes TESTEN to be 1, which also forces PIN_RA_EN
			// Test registers are reset by NRES, so we just need to set TESTREG1 to 0x01
			Serial.println(F("Dumping ROMA"));
			resetChip();
			writeTS1(0x01);

			for (uint16_t c = 0; c < 384; c++) {
				digitalWrite(PIN_CLK, HIGH);
				delay(1);
				digitalWrite(PIN_CLK, LOW);
				delay(1);

				uint8_t data = readMux(0);
				sprintf(strBuf, "%04X: %02X", c, data & 0x7F);
				Serial.println(strBuf);
			}
			break;
    case 'D':
			// ROMB dump:
			// Outputs data on RA[15:0] when Y74=1, T92=0 (so TESTREG1_D0=0, TESTREG1_D2=1, TESTREG2_D4=0), this causes TESTEN to be 1, which also forces PIN_RA_EN
			// Address comes from AB[7:0]
			// ROM block is clocked by CLKDIV2, so a few clock pulses must be sent after address is set
			// Test registers are reset by NRES, so we just need to set TESTREG1 to 0x04
			
			Serial.println(F("Dumping ROMB"));

			Serial.end();		// We need D0 and D1 (TX/RX UART pins) as GPIOs !
			setupAB();
			
			resetChip();
			writeTS1(0x04);

			for (uint16_t c = 0; c < 192; c++) {
				setABData(c);
				delay(1);

				for (uint16_t ck = 0; ck < 4; ck++) {
					digitalWrite(PIN_CLK, HIGH);
					delay(1);
					digitalWrite(PIN_CLK, LOW);
					delay(1);
				}

				uint16_t data = readMux(0);
				data += (readMux(1) << 8);
				dataBuf[c] = data;
			}
			
			Serial.begin(115200);
  		Serial.println();

			for (uint16_t c = 0; c < 192; c++) {
				sprintf(strBuf, "%02X: %04X", c, dataBuf[c]);
				Serial.println(strBuf);
			}

			break;
    default:
        break;
  }
}

char query(String queryString) {
  Serial.println();

  Serial.print(queryString);
  while (1) {
    if (Serial.available() > 0) {
      String myString = Serial.readString();
      return myString[0];
    }
  }
}

void PrintHex8(uint8_t data) {
  if (data < 0x10) {
    Serial.print("0");
  }
  Serial.print(data, HEX);
}
