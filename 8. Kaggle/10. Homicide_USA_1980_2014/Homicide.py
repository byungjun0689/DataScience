# -*- coding: utf-8 -*-
"""
Created on Wed Apr 26 11:24:08 2017

@author: MCR007
"""

# This Python 3 environment comes with many helpful analytics libraries installed
# It is defined by the kaggle/python docker image: https://github.com/kaggle/docker-python
# For example, here's several helpful packages to load in 

import numpy as np # linear algebra
import pandas as pd # data processing, CSV file I/O (e.g. pd.read_csv)
from matplotlib import pyplot as plt

# Input data files are available in the "../input/" directory.
# For example, running this (by clicking run or pressing Shift+Enter) will list the files in the input directory

from subprocess import check_output
#print(check_output(["dir", "../data"]).decode("utf8"))

df=pd.read_csv("./data/database.csv")
# Any results you write to the current directory are saved as output.

df.head()