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
df['age'].value_counts()
df['school'].value_counts()

sns.factorplot('age',data=df, kind='count')
sns.factorplot('school',kind='count', data=df)
sns.factorplot('sex',kind='count', data=df)
sns.factorplot('class',kind='count', data=df)
sns.factorplot('famsize',kind='count', data=df)
sns.factorplot('Pstatus',kind='count', data=df)
sns.factorplot('Medu',kind='count', data=df)
sns.factorplot('Fedu',kind='count', data=df)
sns.factorplot('Mjob',kind='count', data=df)
sns.factorplot('Fjob',kind='count', data=df)
sns.factorplot('reason',kind='count', data=df)
sns.factorplot('guardian',kind='count', data=df)
sns.factorplot('traveltime',kind='count', data=df)
sns.factorplot('studytime',kind='count', data=df)
sns.factorplot('failures',kind='count', data=df)

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


Rel_Dalc = corr['Dalc']
Rel_Walc = corr['Walc']

Rel_Dalc[Rel_Dalc>0.1]
Rel_Walc[Rel_Walc>0.1]

Rel_Col_Dal = Rel_Dalc[Rel_Dalc>0.1].index.tolist()
Rel_Col_Wal = Rel_Walc[Rel_Walc>0.1].index.tolist()


Dal_df = X[Rel_Col_Dal]
Wal_df = X[Rel_Col_Wal]

Dal_corr = Dal_df.corr()
Wal_corr = Wal_df.corr()

sns.heatmap(Dal_corr, 
            xticklabels=Dal_corr.columns.values,
            yticklabels=Dal_corr.columns.values)
            
sns.heatmap(Wal_corr, 
            xticklabels=Wal_corr.columns.values,
            yticklabels=Wal_corr.columns.values)
            
sns.boxplot(x='goout',y='Walc',data=df)            
sns.boxplot(x='goout',y='Dalc',data=df)         


sns.factorplot('Walc',kind='count',hue='sex',data=df)            
            
sns.boxplot(y='absences',data=df)      
sns.boxplot(x='Dalc',y='absences',data=df)      
sns.boxplot(x='Walc',y='absences',data=df)                  
            
sns.pairplot(X)


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

