# Takes in a raw scanner image, produces individually cut and straightened plate images
# Scan 3x6 plates in 600dpi JPEG photo mode without lid closed, portrait orientation
# furrtek 05/2025

import cv2
import numpy as np
import os

def hsv2rgb(hsv):
	re = cv2.cvtColor(np.uint8([[hsv]]), cv2.COLOR_HSV2RGB)[0][0]
	return re.tolist()

filelist = [entry for entry in os.listdir('.') if entry.startswith("PLATES_") and os.path.isfile(entry)]
# "PLATES_20250501_0001.jpg"

n = 0
for filename in filelist:	#[5:6]:
	print(filename)
	# Load image, make a grayscale copy for faster processing
	img_raw = cv2.imread(filename)
	#img_raw = cv2.resize(img_raw, None, fx=0.5, fy=0.5, interpolation=cv2.INTER_AREA).copy()	# Resize to 50% for faster DEBUG
	img_gray = cv2.cvtColor(img_raw, cv2.COLOR_BGR2GRAY)

	# Get background color avg from 50x50 pixels in top right corner
	bg = cv2.mean(img_gray[50:, 50:])[0]
	print("Background value: %d" % bg)

	# Mask out background color with tolerance
	threshold = cv2.inRange(img_gray, bg-30, bg+10)
	threshold = cv2.bitwise_not(threshold)

	#threshold = cv2.medianBlur(threshold, 3)
	
	# Extract contours
	contours = cv2.findContours(threshold, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
	contours = contours[0] if len(contours) == 2 else contours[1]

	#cv2.imwrite(filename[7:] + "_debug.jpg", threshold)

	debug_out = cv2.cvtColor(img_gray, cv2.COLOR_GRAY2BGR)

	#debug_out = cv2.drawContours(debug_out, contours, -1, (0, 255, 0), 3)
	#cv2.imwrite(filename[7:] + "_debug.jpg", debug_out)

	plates = []
	j = 0
	for i, c in enumerate(contours):
		area = cv2.contourArea(c)
		if area > 1200000 and area < 1400000:	# Filter out contours that are too small or too large, this depends on input image size and plate size !
			#print(area)
			rect = cv2.minAreaRect(c)	# Smallest rectangle (any orientation) in which the contour fits
			box = cv2.boxPoints(rect)	# Orthogonal bounding rectangle in which the minAreaRect fits
			bounding = cv2.boundingRect(box)

			angle = rect[2]				# Angle of minAreaRect
			if angle > 45:
				angle = angle - 90

			color = hsv2rgb([j % 180, 255, 255])
			cv2.drawContours(debug_out, [c], 0, color, 3)
			cv2.rectangle(debug_out, bounding, color, 6)
			box = cv2.boxPoints(rect)
			box = np.int_(box)
			cv2.drawContours(debug_out,[box], 0, (255, 255, 255), 3)
			debug_out = cv2.putText(debug_out, "{}: {:.2f}".format("Angle", angle), (int(rect[0][0]), int(rect[0][1])), cv2.FONT_HERSHEY_SIMPLEX, 2, (0, 255, 255), 3)

			plates.append(i)

			#cv2.imwrite(filename[7:] + "_debug.jpg", debug_out)

			[X, Y, W, H] = bounding
			cropped = img_raw[Y:Y+H, X:X+W]		# First crop based on boundingRect to do the rotation on the ROI only
			M = cv2.getRotationMatrix2D((W/2, H/2), angle, 1.0)
			cropped = cv2.warpAffine(cropped, M, (W, H))	# Rotate to straighten up

			# Crop to fixed dimensions
			# 60x40mm scanned at 600dpi
			# 600dpi = 600 pixels in 25.4mm, so 1mm is 23.62 pixels
			# 1417*944
			center = cropped.shape
			w=920
			h=1400
			x = center[0]/2 - w/2
			y = center[1]/2 - h/2
			cropped = cropped[int(x):int(x+w), int(y):int(y+h)]
			cropped = cv2.rotate(cropped, cv2.ROTATE_90_CLOCKWISE)	# Simple CW 90deg rotate
	
			cv2.imwrite('out{:04}.jpg'.format(n), cropped, [int(cv2.IMWRITE_JPEG_QUALITY), 90])

			j += 10
			n += 1

	print("Found %d plates" % len(plates))

	debug_out = cv2.rectangle(debug_out, (0, 0), (200, 200), (bg, bg, bg), -1)
	cv2.imwrite(filename[7:] + "_debug.jpg", debug_out)

exit()
