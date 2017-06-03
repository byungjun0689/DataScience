# -*- coding: utf-8 -*-
"""
Created on Sat Jun  3 16:23:52 2017

@author: BYUNGJUN
"""

from glob import glob
import pandas as pd
import seaborn as sns 
import matplotlib.pyplot as plt
import datetime as dt

from matplotlib import font_manager, rc
font_name = font_manager.FontProperties(fname="c:/Windows/Fonts/malgun.ttf").get_name()
rc('font', family=font_name)


lists = glob('data/chicken/*.csv') 
lists


df = pd.DataFrame()
for data in lists:
    tmp = pd.read_csv(data)
    df = df.append(tmp)
    
    
del df['Unnamed: 0']

col_list = df.columns.tolist()
df = df.rename(columns={col_list[-1]:'기준일'})

df.to_csv("data/chicken/total.csv",encoding='utf8',index=False)


df = pd.read_csv("data/chicken/total.csv")
df['시도'].unique()
df['기준일'] = pd.to_datetime(df['기준일'],format='%Y%m%d')
df['기준월'] = pd.to_datetime(df['기준일']).dt.month

df.groupby(['요일'])['통화건수'].sum()


plt.figure(figsize=(15,10))
#sns.set(font_scale = 1)
ax = sns.countplot(data=df[['요일','통화건수']],x='요일', order=['일','월','화','수','목','금','토'])
ax.set_xticklabels(ax.get_xticklabels(), fontsize=20)
ax.set_yticklables(ax.get_yticklabels(), fontsize=20)

sumOfcall = pd.DataFrame({'cnt':df.groupby(['요일'])['통화건수'].sum()}).reset_index()

plt.figure(figsize=(15,10))
sns.barplot(x='요일',y='cnt',data=sumOfcall, order=['일','월','화','수','목','금','토'])
plt.xlabel("Name of Days",fontsize=30)
plt.ylabel("Sum of Call",fontsize=30)
plt.xticks(fontsize=20)
plt.yticks(fontsize=20)


sumOfcallAges = pd.DataFrame({'cnt':df.groupby(['연령대'])['통화건수'].sum()}).reset_index()
order_list = sumOfcallAges['연령대']
plt.figure(figsize=(15,10))
sns.barplot(x='연령대',y='cnt',data=sumOfcallAges, order=order_list)
plt.xlabel("Ages",fontsize=30)
plt.ylabel("Sum of Call",fontsize=30)
plt.xticks(fontsize=20)
plt.yticks(fontsize=20)

sumOfplace = pd.DataFrame({'cnt':df.groupby(['시군구'])['통화건수'].sum()}).reset_index()
plt.figure(figsize=(15,10))
sns.barplot(x='시군구',y='cnt',data=sumOfplace, order=sumOfplace.sort_values(by='cnt', ascending=False)['시군구'])
plt.xlabel("Place",fontsize=30)
plt.ylabel("Sum of Call",fontsize=30)
plt.xticks(fontsize=20, rotation = 90)
plt.yticks(fontsize=20)


plt.figure(figsize=(15,10))
df.groupby(['기준월'])['통화건수'].sum().plot('bar')
plt.xticks(fontsize=20, rotation = 90)
plt.yticks(fontsize=20)