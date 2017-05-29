# -*- coding: utf-8 -*-
"""
Created on Mon May 29 11:50:09 2017

@author: MCR007
"""

import numpy as np # matrix tools
import matplotlib.pyplot as plt # for basic plots
import seaborn as sns # for nicer plots
import pandas as pd
from glob import glob
import keras
from sklearn.model_selection import train_test_split

glob('data/dicom_dir/*')

overview = pd.read_csv("data/overview.csv")
del overview['Unnamed: 0']
overview.head()

sns.countplot('Contrast',data=overview)


with np.load('data/full_archive.npz') as im_data:
    # make a dictionary of the data vs idx
    full_image_dict = dict(zip(im_data['idx'], im_data['image']))
    
overview['MeanHU'] = overview['id'].map(lambda x:np.mean(full_image_dict.get(x,np.zeros((512,512)))))
overview['StdHU'] = overview['id'].map(lambda x:np.std(full_image_dict.get(x,np.zeros((512,512)))))


overview['Contrast'] = overview['Contrast'].map(lambda x: 1 if x else 0)
sns.pairplot(overview[['Age', 'Contrast', 'MeanHU', 'StdHU']], hue="Contrast")

overview.head()


for x in full_image_dict.keys():
    full_image_dict[x] = (full_image_dict[x] - np.min(full_image_dict[x])) / (np.max(full_image_dict[x]) - np.min(full_image_dict[x])) * 255

plt.imshow(im_data['image'][5], cmap='gray')

full_image_dict.items()

X_train, X_test, y_train, y_test = train_test_split(im_data['image'][:100], overview['Contrast'], test_size=0.2, random_state=0)


X_test
X_train[0]

# 다시 
import re
import dicom

glob('data/dicom_dir/*')

overview = pd.read_csv("data/overview.csv")
del overview['Unnamed: 0']
overview.head()

overview['pad_id'] = overview['id'].apply(lambda x:'%04d' % x)

dcm_list = glob('data/dicom_dir/*')
dcm_list

dcm_list.apply(lambda x:x.replace('\\','/'))


dcm_list = [x.replace('\\','/') for x in dcm_list]


check_id = re.compile(r'data\/dicom_dir\/ID_([\d]+)_AGE_([\d]+)_CONTRAST_([\d])_CT.dcm')

id_list = []
age_list = []
contrast_list = []

check_id.findall(dcm_list[0])

for dcm in dcm_list:
    tmp = check_id.findall(dcm)[0]
    id_list.append(tmp[0])
    age_list.append(tmp[1])
    contrast_list.append(tmp[2])


plan = dicom.read_file(dcm_list[0])
plan.PatientName

ConstPixelDims = (int(plan.Rows), int(plan.Columns), len(dcm_list))
ConstPixelSpacing = (float(plan.PixelSpacing[0]), float(plan.PixelSpacing[1]), float(plan.SliceThickness))

x = np.arange(0.0, (ConstPixelDims[0]+1)*ConstPixelSpacing[0], ConstPixelSpacing[0])
y = np.arange(0.0, (ConstPixelDims[1]+1)*ConstPixelSpacing[1], ConstPixelSpacing[1])
z = np.arange(0.0, (ConstPixelDims[2]+1)*ConstPixelSpacing[2], ConstPixelSpacing[2])

ArrayDicom = np.zeros(ConstPixelDims, dtype=plan.pixel_array.dtype)

# loop through all the DICOM files
for filenameDCM in dcm_list:
    # read the file
    ds = dicom.read_file(filenameDCM)
    # store the raw image data
    ArrayDicom[:, :, dcm_list.index(filenameDCM)] = ds.pixel_array  


plt.figure(dpi=300)
plt.axes().set_aspect('equal', 'datalim')
plt.set_cmap(plt.gray())
plt.pcolormesh(x, y, np.flipud(ArrayDicom[:, :, 80]))



np.flipud(ArrayDicom[:, :, 80])




