# -*- coding: utf-8 -*-
"""
Created on Fri Mar 31 23:16:36 2017

@author: byung
"""

import pandas as pd 
import seaborn as sns
import matplotlib.pyplot as plt
from mpl_toolkits.basemap import Basemap
from matplotlib import cm
import datetime as dt

uber_data = pd.read_csv("data/uber-raw-data-aug14.csv")
uber_data.head()
len(uber_data)

uber_data.info()

uber_data['Date/Time'] = pd.to_datetime(uber_data['Date/Time'],format='%m/%d/%Y %H:%M:%S')

# The day of the week with Monday=0, Sunday=6
uber_data['DayOfWeekNum'] = uber_data['Date/Time'].dt.dayofweek
uber_data['DayOfWeek'] = uber_data['Date/Time'].dt.weekday_name
uber_data['MonthDayNum'] = uber_data['Date/Time'].dt.day
uber_data['Hour'] = uber_data['Date/Time'].dt.hour

sns.factorplot('DayOfWeek', kind='count', data=uber_data , size = 6)
plt.xticks(rotation=45)

uber_data['Base'].value_counts()

uber_weekdays = uber_data.pivot_table(index=['DayOfWeekNum','DayOfWeek'],
                                  values='Base',
                                  aggfunc='count')

uber_weekdays

uber_weekdays.plot(kind='bar', figsize=(8,6))
plt.ylabel('Total Journeys')
plt.title('Journeys by Week Day');
plt.xticks(rotation =45)


sns.factorplot('MonthDayNum',kind='count',data=uber_data , color='b', size=7)
plt.xticks(rotation=45)

sns.factorplot('Hour', kind='count', data=uber_data , size = 6)
plt.xticks(rotation=45)

west, south, east, north = -74.26, 40.50, -73.70, 40.92

fig = plt.figure(figsize=(14,10))
ax = fig.add_subplot(111)
m = Basemap(projection='merc', llcrnrlat=south, urcrnrlat=north,
            llcrnrlon=west, urcrnrlon=east, lat_ts=south, resolution='i')
x, y = m(uber_data['Lon'].values, uber_data['Lat'].values)
m.hexbin(x, y, gridsize=1000,
         bins='log', cmap=cm.YlOrRd_r);

         
         
sns.factorplot('DayOfWeek',kind='count',data=uber_data, size=7, hue='Base')
sns.factorplot('DayOfWeek',kind='count',data=uber_data, size=7)


df2 = pd.read_csv('data/Uber-Jan-Feb-FOIL.csv')
df2.head()

df2['dispatching_base_number'].value_counts()

plt.scatter(x='active_vehicles',y='trips',data=df2)
plt.xlabel('active_vehicles')
plt.ylabel('trips')
plt.title('scatters')