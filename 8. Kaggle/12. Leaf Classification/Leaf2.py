# -*- coding: utf-8 -*-
"""
Created on Tue May 30 22:40:31 2017

@author: byung
"""

import numpy as np # matrix tools
import matplotlib.pyplot as plt # for basic plots
import seaborn as sns # for nicer plots
import pandas as pd
from glob import glob
import re
from skimage.io import imread
import os
import keras
import itertools

os.listdir("data/")

data = pd.read_csv("data/leaf.csv")
data.head()

BASE_IMAGE_PATH = os.path.join("Data","RGB")
Specis_list = os.listdir(BASE_IMAGE_PATH)
total_species = len(Specis_list)


all_images = []
for specis in Specis_list:
    all_images.append(glob(os.path.join(BASE_IMAGE_PATH, specis, '*.jpg')))
    

all_images = list(itertools.chain(*all_images))
all_masks  = [c_file.split("\\")[2].split(".")[0].strip() for c_file in all_images]
    
test_image = imread(all_images[0])
test_image.shape # 960 x 720 x 3

jimread = lambda x: imread(x)[::12,::12]
test_image = jimread(all_images[0])
test_image.shape # 240, 180, 3

'''
for i,image in enumerate(all_images):
    test_image = jimread(image)
    width,height, depth = test_image.shape # 960 x 720 x 3    
    if width != 240:
        print(i)
    if height != 180:
        print(i)

plt.imshow(test_image)
'''    

images = np.stack([jimread(j) for i,j in enumerate(all_images) if i != 87],0)
len(images)

del all_masks[87]
plt.imshow(images[0])

from sklearn.model_selection import train_test_split
X_train, X_test, y_train, y_test = train_test_split(images, all_masks, test_size=0.2, random_state=0)

n_train, width, height,depth = X_train.shape
n_test,_,_,_ = X_test.shape

input_shape = (width,height,depth)
input_shape

input_train = X_train.reshape((n_train, width,height,depth))
input_train.shape
input_train.astype('float32')
input_train = input_train / np.max(input_train)
input_train.max()

input_test = X_test.reshape(n_test, *input_shape)
input_test.astype('float32')
input_test = input_test / np.max(input_test)


output_train = keras.utils.to_categorical(y_train, total_species+1)
output_test = keras.utils.to_categorical(y_test, total_species+1)
output_train[5]

from keras.models import Sequential
from keras.layers import Dense, Flatten
from keras.optimizers import Adam
from keras.layers import Conv2D, MaxPooling2D

batch_size = 20
epochs = 30

enc = Sequential()
enc.add(Conv2D(50, (5, 5), activation='relu', input_shape= input_shape))
enc.add(MaxPooling2D((3, 3), strides=(2,2)))
enc.add(Conv2D(30, (4, 4), activation='relu'))
enc.add(MaxPooling2D((3, 3),strides=(2,2)))

enc.summary()

classifier = Sequential()
classifier.add(enc)
classifier.add(Flatten())
classifier.add(Dense(total_species+1, activation='softmax'))
classifier.compile(optimizer='adam', loss='categorical_crossentropy', metrics=['accuracy'])
classifier.summary()

classifier.fit(input_train, output_train,
               batch_size=batch_size,
               epochs=epochs,
               verbose=1,
               validation_data=(input_test, output_test))



