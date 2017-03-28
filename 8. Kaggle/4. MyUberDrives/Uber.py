# -*- coding: utf-8 -*-
"""
Created on Mon Mar 27 20:30:01 2017

@author: byung
"""

import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns 
import datetime as dt
import networkx
from collections import Counter

uber = pd.read_csv("Uber.csv")
uber.columns = ['START_DATE','END_DATE','CATEGORY','START','STOP','MILES','PURPOSE']

uber = uber.drop(uber.index[len(uber)-1])

def changeDate(date):
    start = date
    starts = pd.to_datetime(start)
    return(starts)

uber['START_DATE'] = changeDate(uber['START_DATE'])
uber['END_DATE'] = changeDate(uber['END_DATE'])


uber['SDATE'] = pd.to_datetime(uber['START_DATE']).dt.date
uber['EDATE'] = pd.to_datetime(uber['END_DATE']).dt.date

uber['STIME'] = pd.to_datetime(uber['START_DATE']).dt.time
uber['ETIME'] = pd.to_datetime(uber['END_DATE']).dt.time

uber['DIFF'] = uber['END_DATE'] - uber['START_DATE'] 

sns.factorplot('CATEGORY', kind='count', data=uber, hue='PURPOSE')

cnt_start = pd.DataFrame({'cnt' : uber.groupby(['START']).size()}).reset_index()
cnt_start = cnt_start.sort_values(by='cnt',ascending=False)
cnt_start.head()

sns.barplot(x='START', y='cnt', data=cnt_start.head(10))
plt.xticks(rotation=45)

cnt_stop = pd.DataFrame({'cnt' : uber.groupby(['STOP']).size()}).reset_index()
cnt_stop = cnt_stop.sort_values(by='cnt',ascending=False)
cnt_stop.head()

sns.barplot(x='STOP', y='cnt', data=cnt_stop.head(10))
plt.xticks(rotation=45)


sns.boxplot(x='PURPOSE',y='MILES',data=uber[uber['MILES']<60],hue='CATEGORY')
plt.xticks(rotation=45)


# 출발 도착 쌍으로 묶어서 보기.

pairs_SE = pd.DataFrame({'cnt' : uber.groupby(['START','STOP']).size()}).reset_index()
pairs_SE = pairs_SE.sort_values(by='cnt',ascending=False)
pairs_SE.head()

def attachDestination(df):
    location = df['START'] + "-" + df['STOP']
    return(location)

pairs_SE['location'] = attachDestination(pairs_SE)

sns.barplot(x='location', y='cnt', data=pairs_SE[pairs_SE['location']!='Unknown Location-Unknown Location'].head(10))
plt.xticks(rotation=45)

pairs_SE = pairs_SE[pairs_SE['cnt'] < 10]

pairs_zip = list(zip(pairs_SE.ix[:,0],pairs_SE.ix[:,1],pairs_SE.ix[:,2]))

edges = []
for i in range(len(pairs_zip)):
    edges.append((pairs_zip[i][0],pairs_zip[i][1], pairs_zip[i][2]))

edge_list = [(word1, word2) for word1, word2, weight in edges]
weight_list = [weight for word1, word2, weight in edges]


G = networkx.Graph()
edge_set = set()
for word1, word2, weight in edges:
    G.add_edge(word1, word2, weight=weight)
    edge_set.add((word1,word2))
    
position = networkx.spring_layout(G, k=0.09,  iterations=100)
plt.figure(figsize=(20, 15))
networkx.draw_networkx_nodes(G, position, node_size=0)
networkx.draw_networkx_edges(G, position, edgelist=edge_list, width=weight_list, edge_color='lightgray')
networkx.draw_networkx_labels(G, position, font_size=15)
plt.axis('off')
plt.show()

#1. date_uber = pd.DataFrame({'cnt' : uber.groupby(['SDATE']).size()}).reset_index()
date_uber = uber.groupby(['SDATE']).size()

date_uber.plot()
plt.xticks(rotation=45)

date_uber.index = pd.to_datetime(date_uber.index)
date_uber['2016-01':'2016-05'].plot()
date_uber.resample('M').mean()
date_uber.resample('D').mean()


sns.factorplot(x='PURPOSE', y='MILES', data=uber, size=10, kind='bar', hue='CATEGORY")