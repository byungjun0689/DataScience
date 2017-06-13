# -*- coding: utf-8 -*-
"""
Created on Tue Jun 13 23:27:51 2017

@author: byung
"""

import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt
import datetime as dt

from matplotlib import font_manager, rc
font_name = font_manager.FontProperties(fname="c:/Windows/Fonts/malgun.ttf").get_name()
rc('font', family=font_name)


df = pd.read_csv("data/total_taxi.csv")
df.head()

df['기준년월일'] = pd.to_datetime(df['기준년월일'],format='%Y%m%d')
df['일'] = df['기준년월일'].dt.day
df['월'] = df['기준년월일'].dt.month
df['장소'] = df['발신지_시도'] + " " + df['발신지_시군구'] + " " + df['발신지_읍면동']
df['요일'] = df['기준년월일'].dt.weekday_name

df.to_csv("data/total_taxi.csv",encoding='utf8',index=False)

df_loc_call = pd.DataFrame({'call_cnt':df.groupby(['기준년월일'])['통화건수'].sum()}).reset_index()
df.groupby(['기준년월일'])['통화건수'].sum().plot()

df.groupby(['요일'])['통화건수'].sum().plot('bar')

df[df['일']!=31].groupby(['일'])['통화건수'].sum().plot()