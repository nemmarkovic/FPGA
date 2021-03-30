import numpy as np
import imageio
import matplotlib.pyplot as plt

#imageio.help(name=None)
#im = imageio.imread('imageio:astronaut.png')

fname = "tigar_128x160.jpg"
#fname = "tigar_447x612.jpg"
#fname = "tigar_porodica_960x540.jpg"

im = imageio.imread(fname)

plt.figure()
plt.imshow(im)
# plot original image
plt.title('Original image')
plt.show(block=True)

# rgb2gray
gray = lambda rgb : np.dot(rgb[... , :3] , [0.299 , 0.587, 0.114]) 
gray = gray(im)  

print(gray.dtype)

# plot the image
plt.imshow(gray, cmap = plt.get_cmap(name = 'gray'))
plt.show(block=True)

# Get original image dimensions
old_y =   gray.shape[0]
old_x =   gray.shape[1]

print("(oldx, oldy) = ", old_x, old_y)

# Add new image dimensions
new_y = 55#2 * old_y
new_x = 95#2 * old_x

print("(new_x, new_y) = ", new_x, new_y)

# Create empty rezultant image
rez_im = np.empty((new_y, old_x), order='C', dtype = np.float64)
#rez_im = np.empty((new_x, new_y), order='C')

# Create buffers
buf0 =[]
buf1 =[]

# init
y = 0
i = 0
ready = 'True'
#SF_Y = int(new_y/old_y)
SF_Y = old_y/new_y
#coeff = [1, 0]

# vertical resize
if(SF_Y <= 1.0):
    while (i < new_y -1):
    
        if ready == 'True':
            ready = 'False'
            buf0 = gray[y]
            if y < old_y -1 :
                buf1 = gray[y +1]
    
        # bilinear interpolation
        rez_im[i] = (buf0 * (i * SF_Y -y) + buf1 * (1 - (i * SF_Y - y)))
        i = i+1
        
        if (i*SF_Y -y > 1.0):
            ready = 'True'
            y = y+1
            #print("i*SF_Y -y: ",i*SF_Y -y, ready)
    

# if(SF_Y > 1.0):
    # while (i < new_y -1):
    
        # if ready == 'True':
            # ready = 'False'
            # buf0 = gray[y]
            # if y < old_y -1 :
                # buf1 = gray[y +1]
    
        # # bilinear interpolation
        # rez_im[i] = (buf0 * (i * SF_Y -y) + buf1 * (1 - (i * SF_Y - y)))
        # i = i+1
        
        # if (i*SF_Y -y > 1.0):
            # ready = 'True'
            # y = y+1
            #print("i*SF_Y -y: ",i*SF_Y -y, ready)


plt.imshow(rez_im, cmap = plt.get_cmap(name = 'gray'))
plt.show(block=True)

rez_im2 = np.empty((new_y, new_x), order='C', dtype = np.float64)

# Create buffers
buf_x_0 =[]
buf_x_1 =[]

SF_X = old_x/new_x
x = 0
i = 0
ready = 'True'

while (i < new_x -1):
    
    if ready == 'True' :
        ready = 'False'
        buf_x_0 = rez_im[:,x]
        if x < old_x -1 :
            buf_x_1 = rez_im[:,x +1]

    # bilinear interpolation
    rez_im2[:,i] = (buf_x_0 * (i * SF_X -x) + buf_x_1 * (1 - (i * SF_X - x)))
    i = i+1
    
    if (i*SF_X -x > 1.0):
        ready = 'True'
        x = x+1
        
plt.imshow(rez_im2, cmap = plt.get_cmap(name = 'gray'))
plt.show(block=True)