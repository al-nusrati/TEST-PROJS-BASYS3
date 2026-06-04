from PIL import Image

# Open the image
img = Image.open("Aashir2_tiny.bmp")  # <-- Change this to your BMP file

# Convert to RGB565
img = img.convert("RGB")
pixels = img.load()

# Open the .mem file for writing
with open("Aashir2_tiny.mem", "w") as f:   # <-- Change output file name if desired
    for y in range(img.height):
        for x in range(img.width):
            r, g, b = pixels[x, y]
            # Convert to RGB565
            rgb565 = ((r & 0xF8) << 8) | ((g & 0xFC) << 3) | (b >> 3)
            # Write to file
            f.write(f"{rgb565:04X}\n")