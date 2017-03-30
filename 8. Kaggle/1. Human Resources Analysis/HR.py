# -*- coding: utf-8 -*-
"""
Created on Wed Mar 29 16:03:49 2017

@author: MCR007
"""

import pandas as pd 
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
from scipy import stats
from collections import Counter


df = pd.read_csv("HR.csv",delimiter=";")
#df['left'] = df['left'].map({1:'left',0:'remain'})
df.head()

sns.factorplot('left',kind='count',data=df)
sns.boxplot(x='left',y='satisfaction_level',data=df)


indep = df.columns.difference(['left'])

discrete = []
continuous = []
for v in indep:
    if df[v].dtype == 'object':
        discrete.append(v)
    else:
        continuous.append(v)


discrete
continuous

dummy = pd.get_dummies(df[discrete])
X = pd.concat([df[continuous], dummy], axis=1)
X['left'] = df['left']
X.head()
            
Left_corr = X.corr()['left']
corr_list = Left_corr[abs(Left_corr)>0.1].index.tolist()
X[corr_list].head()

sns.heatmap(X.corr(), 
            xticklabels=X.corr().columns.values,
            yticklabels=X.corr().columns.values)
            
sns.pairplot(df.corr())
sns.factorplot('Work_accident',kind='count',data=df,hue='left')

# waccident = pd.DataFrame({'cnt':df.groupby(['left','Work_accident']).size()}).reset_index()

df[['left','Work_accident']].value_counts()
df.groupby(['left','Work_accident']).size().name('cnt')


waccident = df.groupby(['left','Work_accident']).size().name('cnt')

wsum = waccident.groupby(['left']).agg({'cnt': 'sum'})
waccident.div(wsum, level='left') * 100