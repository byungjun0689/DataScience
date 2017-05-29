# -*- coding: utf-8 -*-
"""
Created on Mon May 29 13:27:56 2017

@author: MCR007
"""

import pandas as pd
import numpy as np
from PIL import Image
import os

Image_dir_path = 'Data/BW/1. Quercus suber/'
Qs_list = os.listdir("Data/BW/1. Quercus suber")
str(Image_dir_path + Qs_list[0])
im = Image.open(Image_dir_path + Qs_list[0])
im.show()

imarray = np.array(im,dtype=np.int)
imarray.shape

np.max(imarray)
np.min(imarray)
pd.DataFrame(imarray[500:600])