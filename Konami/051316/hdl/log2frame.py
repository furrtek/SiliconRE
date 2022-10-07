# Converts k051316 simulation log_video.txt to a PNG frame

from PIL import Image, ImageDraw

f = Image.open("input.png")

imgdata = f.load()

f = open("log_video.txt", "r")
lines = f.read().split("\n")
f.close()

img = Image.new("RGB", (400, 400))
draw = ImageDraw.Draw(img)

x = 0
y = 0
for line in lines:
	pixel = line.split(" ")[0]
	# Pixel or sync
	if pixel == "L":
		x = 0				# New line
		y += 1
	elif pixel == "V":
		print("Frame done")
		x = 0
		y = 0
	elif len(pixel):
		oblk = line.split(" ")[1]
		if "x" in pixel or "z" in pixel:
			r = 255			# Undefined value
			g = 0
			b = 255
		else:
			ca = int(pixel, 16)
			tilecode = (ca >> 8) & 1023
			if oblk == "1":
				r = 255			# "Out of plane" bit
				g = 0
				b = 255
			else:
				subx = ca & 15
				suby = (ca >> 4) & 15
				tx = tilecode & 31
				ty = tilecode >> 5
				px = (tx * 16) + subx
				py = (ty * 16) + suby
				color = imgdata[px, py]
				r = color[0]
				g = color[1]
				b = color[2]

		if x < 400 and y < 400:
			img.putpixel((x, y), (r, g, b))
		x += 1

img.save("frame.png")
