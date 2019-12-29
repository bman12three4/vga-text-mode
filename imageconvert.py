import imageio
import numpy

image = imageio.imread('charset.png')
out = open("charset.bin", "w")

bytelist = []

'''
so it's 16 bytes, the top row of 8 down the the bottom row, then the next char
'''

for row in range(0, 10):
     for col in range(0, 10):
          for subrow in range (16):
               byte = 0
               for position in range (8):
                    pixel = (image[row*16+subrow,col*8+position,0])/255
                    byte = byte + (pixel << position)
               #print (format(byte, 'b').zfill(8) + ", " + format(byte,  'x'))
               bytelist.append(byte)

outbytes = bytearray(bytelist)
out.write(outbytes)
out.close()



