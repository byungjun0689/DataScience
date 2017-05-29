# -*- coding: utf-8 -*-
"""
Created on Mon May 29 11:50:09 2017

@author: MCR007
"""

import numpy as np # matrix tools
import matplotlib.pyplot as plt # for basic plots
import seaborn as sns # for nicer plots
import pandas as pd
overview = pd.read_csv("data/overview.csv")
del overview['Unnamed: 0']
overview.head()
overview['Age'].hist()

cnt = 1
with np.load('data/full_archive.npz') as im_data:
    # make a dictionary of the data vs idx
    full_image_dict = dict(zip(im_data['idx'], im_data['image']))
    
    
tmp_npz = np.load('data/full_archive.npz')
tmp_npz['idx']

# Memory Error....
plt.matshow(tmp_npz['image'][0])