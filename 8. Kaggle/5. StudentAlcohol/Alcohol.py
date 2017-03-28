# -*- coding: utf-8 -*-
"""
Created on Tue Mar 28 13:25:31 2017

@author: MCR007
"""

import pandas as pd
import numpy as np 
import matplotlib.pyplot as plt
import seaborn as sns 
import datetime as dt 

df1 = pd.read_csv("data/student-mat.csv")
df2 = pd.read_csv("data/student-por.csv")

df1.head()
df2.head()

df1['class'] = 'math'
df2['class'] = 'por'

df = df1.append(df2)

df['class'].value_counts()



df['sex'].value_counts()
sns.factorplot('age',data=df, kind='count')
sns.factorplot('school',kind='count', data=df)

df.groupby(['school','Dalc']).size()
school_dalc = pd.DataFrame({'cnt':df.groupby(['school','Dalc']).size()}).reset_index()

sumOfGP = sum(school_dalc[school_dalc['school']=='GP']['cnt'])
sumOfMS = sum(school_dalc[school_dalc['school']=='MS']['cnt'])

def changePercent(data):
    #sumOfGP = sum(data[data['school']=='GP']['cnt'])
    #sumOfMS = sum(data[data['school']=='MS']['cnt'])
    if data[0] == "GP":
        return(data[2]/sumOfGP)
    else:
        return(data[2]/sumOfMS)
        
school_dalc['percent'] = school_dalc.apply(changePercent,axis=1)

columns = df.columns

discrete = []
continuous = []
for i in columns:
    if df[i].dtype =='object':
        discrete.append(i)
    else:
        continuous.append(i)
        
dummy = pd.get_dummies(df[discrete])
        
df[continuous]

X = pd.concat([df[continuous], dummy], axis=1)
corr = X.corr()
sns.heatmap(corr, 
            xticklabels=corr.columns.values,
            yticklabels=corr.columns.values)
            
sns.pairplot(X)