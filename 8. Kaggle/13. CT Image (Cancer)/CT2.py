# -*- coding: utf-8 -*-
"""
Created on Tue May 30 08:05:30 2017

@author: BYUNGJUN
"""

from PIL import Image
import numpy as np # matrix tools
import matplotlib.pyplot as plt # for basic plots
import seaborn as sns # for nicer plots
import pandas as pd
from glob import glob
import re
from skimage.io import imread
import os
import itertools
import keras

img_list = glob('Data/tiff_images/*.tif')
img_list = [x.replace('\\','/') for x in img_list]
check_id = re.compile(r'data\/tiff_images/ID_([\d]+)_AGE_([\d]+)_CONTRAST_([\d])_CT.tif')

with np.load('data/full_archive.npz') as im_data:
    # make a dictionary of the data vs idx
    full_image_dict = dict(zip(im_data['idx'], im_data['image']))
    
    
full_image_dict.keys()


overview = pd.read_csv('data/overview.csv')
del overview['Unnamed: 0']
overview.to_csv("data/overview.csv",index=False)
overview = pd.read_csv('data/overview.csv')
overview.head()

overview['Contrast'] = overview['Contrast'].map(lambda x: 1 if x else 0)

plt.figure(figsize=(10,8))
sns.distplot(overview['Age'])

g = sns.FacetGrid(overview, col="Contrast", size=8)
g = g.map(sns.distplot, "Age")


g = sns.FacetGrid(overview, hue="Contrast",size=8)
g = g.map(sns.distplot, "Age")


# get Image Information

BASE_IMAGE_PATH = os.path.join("data","tiff_images")
all_images_list = glob(os.path.join(BASE_IMAGE_PATH,"*.tif"))
all_images_list

jimread = lambda x: np.expand_dims(imread(x)[::4,::4],0)

test_image = jimread(all_images_list[0])
plt.imshow(test_image[0])

check_contrast = re.compile(r'data\\tiff_images\\ID_([\d]+)_AGE_[\d]+_CONTRAST_([\d]+)_CT.tif')
label = []
id_list = []
for image in all_images_list:
    id_list.append(check_contrast.findall(image)[0][0])
    label.append(check_contrast.findall(image)[0][1])

label_list = pd.DataFrame(label,id_list)

images = np.stack([jimread(i) for i in all_images_list],0)

from sklearn.model_selection import train_test_split

X_train, X_test, y_train, y_test = train_test_split(images, label_list, test_size=0.2, random_state=0)

input_train = X_train.reshape((80, 128,128,1))
input_train.shape
input_train.astype('float32')
input_train = input_train / np.max(input_train)
input_train.max()

input_shape = (128,128,1)
input_test = X_test.reshape(20, *input_shape)
input_test.astype('float32')
input_test = input_test / np.max(input_test)

output_train = keras.utils.to_categorical(y_train, 2)
output_train

output_test = keras.utils.to_categorical(y_test, 2)

from keras.models import Sequential
from keras.layers import Dense, Flatten
from keras.optimizers import Adam
from keras.layers import Conv2D, MaxPooling2D


model = Sequential()
model.add(Conv2D(32, (4, 4), activation='relu', input_shape=input_shape))
 # 32개의 4x4 Filter 를 이용하여 Convolutional Network생성
model.add(MaxPooling2D(pool_size=(2, 2))) # 2x2 Maxpooling 
model.add(Flatten()) # 쭉풀어서 Fully Connected Neural Network를 만든다. 
model.add(Dense(2, activation='softmax'))

model.summary()

model.compile(loss='categorical_crossentropy',
              optimizer=Adam(),
              metrics=['accuracy'])


batch_size = 20
epochs = 20

history = model.fit(input_train, output_train,
                    batch_size=batch_size,
                    epochs=epochs,
                    verbose=1,
                    validation_data=(input_test, output_test))


history.history

score = model.evaluate(input_test, output_test, verbose=0)
score
