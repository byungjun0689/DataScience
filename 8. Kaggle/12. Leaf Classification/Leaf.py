# -*- coding: utf-8 -*-
"""
Created on Mon May 29 13:27:56 2017

@author: MCR007
"""

import pandas as pd
import numpy as np
from PIL import Image
import os
from skimage.io import imread
from glob import glob
import itertools
import matplotlib.pyplot as plt

jimread = lambda x: np.expand_dims(imread(x)[::4, ::4],0)

BASE_IMAGE_PATH = os.path.join('Data', 'BW')
Specis_list = os.listdir(BASE_IMAGE_PATH)
all_images = []
for specis in Specis_list:
    all_images.append(glob(os.path.join(BASE_IMAGE_PATH, specis, '*.tiff')))
    
all_images = list(itertools.chain(*all_images))
all_masks  = [c_file.split("\\")[2].split(".")[1].strip() for c_file in all_images]
    
    
test_image = jimread(all_images[0])
#test_mask = jimread(all_masks[0])

fig, (ax1 ,ax2) = plt.subplots(1, 2)
ax1.imshow(test_image[0])

print('Total samples are', len(all_images))
print('Image resolution is', test_image.shape)

for i,image in enumerate(all_images):
    #print(all_masks[i])
    #print(image)
    if i == 87:
        continue
    test_image = jimread(image)
    _, width, height = test_image.shape
    if width != 240:
        print(i)
        print(width)
    if height != 180:
        print(i)
        print(height)
    #print('Image resolution is', test_image.shape)

test_image = jimread(all_images[87])    
fig, ax1 = plt.subplots(1, 1)
ax1.imshow(test_image[0])
    
images = np.stack([jimread(image) for i,image in enumerate(all_images) if i != 87], 0)

X_train, X_test, y_train,  y_test = train_test_split(images, masks, test_size=0.1)
