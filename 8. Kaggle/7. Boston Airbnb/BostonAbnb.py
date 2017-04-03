# -*- coding: utf-8 -*-
"""
Created on Mon Apr  3 13:21:21 2017

@author: byung
"""

import pandas as pd 
import numpy as np 
import matplotlib.pyplot as plt 
import seaborn as sns 
import datetime as dt
from mpl_toolkits.basemap import Basemap, cm

calendar = pd.read_csv('data\calendar.csv')
listings = pd.read_csv('data\listings.csv')
reviews = pd.read_csv(r'data\reviews.csv')


calendar.head()
listings.head()

listings = listings.rename(columns={'id':'listing_id'})

list_cal_df = pd.merge(calendar,listings,on='listing_id')
list_cal_df = list_cal_df[list_cal_df['available']!='f']
list_cal_df = list_cal_df.rename(columns={'price_x':'price_cal','price_y':'price_listings'})

# 1-year data
list_cal_df['date'].min()
list_cal_df['date'].max()


#list_cal_df['price_x'].str.replace('$','').str.replace(".00","")

list_cnt = pd.DataFrame({'cnt':list_cal_df.groupby(['listing_id']).size()}).reset_index()

sns.boxplot('cnt',data=list_cnt)
sns.distplot(list_cnt['cnt'])

listings[['latitude','longitude']]

len(list_cnt)
len(listings[['latitude','longitude','zipcode','is_location_exact']])

tmp_listings = listings[listings['is_location_exact']=='t'][['listing_id','latitude','longitude','zipcode','price']]

tmp_listings = pd.merge(tmp_listings,list_cnt,on='listing_id',how='left')
tmp_listings = tmp_listings.fillna(0)
tmp_listings['cnt'] = tmp_listings['cnt'].astype(int)
tmp_listings['price'] = tmp_listings['price'].str.replace('$','').str.replace("\.00","").str.replace(",","")
tmp_listings['price'] = tmp_listings['price'].astype(int)


### Coordinate ploing 
long_max = tmp_listings['longitude'].max() + .02
long_min = tmp_listings['longitude'].min() - .02
long_mid = (tmp_listings['longitude'].min() + tmp_listings['longitude'].max())/2

lat_max = tmp_listings['latitude'].max() + .02
lat_min = tmp_listings['latitude'].min() - .02
lat_mid = (tmp_listings['latitude'].min() + tmp_listings['latitude'].max())/2

m = Basemap(projection='cyl',lat_0=lat_mid,lon_0=long_mid,\
            llcrnrlat=lat_min,urcrnrlat=lat_max,\
            llcrnrlon=long_min,urcrnrlon=long_max,\
            rsphere=6371200.,resolution='h',area_thresh=10)

m.drawcoastlines()
m.drawstates()
m.drawcounties()
m.shadedrelief()

## location
x,y = m(tmp_listings['longitude'],tmp_listings['latitude'])
sp = plt.scatter(x,y,c=tmp_listings['cnt'],s=15)
plt.rcParams["figure.figsize"] = [18,15]
cb = plt.colorbar(sp)
cb.set_label('Size')
plt.show()
plt.clf()


## Data Handling

list_cal_df['date'] = pd.to_datetime(list_cal_df['date'])
list_cal_df['month'] = list_cal_df['date'].dt.month
list_cal_df['year'] = list_cal_df['date'].dt.year
list_cal_df['nameOfweek'] = list_cal_df['date'].dt.weekday_name

list_cal_df.groupby(['month']).size()
list_cal_df.groupby(['year']).size()
list_cal_df.groupby(['year','month']).size()
list_cal_df.groupby(['nameOfweek']).size()

sns.factorplot('nameOfweek',kind='count',data=list_cal_df)
plt.ylim(90000,95000)
plt.xticks(rotation=45)







