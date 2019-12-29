import imageio
import numpy

image = imageio.imread('charset.png')
out = open("charset.bin", "w")

bytelist = []

'''
So basically what it should be is each of the top half bytes followed by
each of the bottom half bytes
'''

for row in range(0, 10):
     for col in range(0, 10):
        #print("===========")
        #print (row)
        #print (col)
        #print("===========")
        for subcol in range (0, 9):
            byte = 0
            for subrow in range (0, 8):
                pixel = (image[row*8+subrow,col*9+subcol,0])/255
                byte = byte + (pixel << subrow)
            #print (format(byte, 'b') + ", " + format(byte, 'x'))
            bytelist.append(byte)
        for subcol in range (0, 9):
            byte = 0
            for subrow in range (8, 16):
                pixel = (image[row*8+subrow,col*9+subcol,0])/255
                byte = byte + (pixel << (subrow-8))
            #print (format(byte, 'b') + ", " + format(byte,  'x'))
            bytelist.append(byte)

outbytes = bytearray(bytelist)
out.write(outbytes)
out.close()



