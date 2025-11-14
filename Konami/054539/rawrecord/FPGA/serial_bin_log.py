import serial
import os
import time

outputFile = open("out.bin", "wb")

ser = serial.Serial("COM8", 3000000, timeout = 1)
ser.set_buffer_size(rx_size = 32000, tx_size = 32000)	# IMPORTANT
ser.reset_input_buffer()

print("Ready")

while True:
	time.sleep(0.1)
	outputFile.write((ser.read(ser.inWaiting())))
	outputFile.flush()

ser.close()
