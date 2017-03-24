# -*- coding: utf-8 -*-
"""
Created on Fri Mar 24 17:33:29 2017

@author: MCR007
"""

import numpy as np 
import pandas as pd 
import matplotlib.pyplot as plt
import datetime as dt
import seaborn as sns

customer = pd.read_csv('Data/Customer master.csv')
customer.head()

customer.info()

customer.SHOPPER_SEGMENT_CODE = customer.SHOPPER_SEGMENT_CODE.fillna(0)


zips = pd.read_csv('Data/zipcode.csv')
zips = zips.ix[:,[0,1,3,4]]
zips.head()
zips = zips.rename(columns={'zip':'ZIP_CODE'})
zips.ZIP_CODE = zips.ZIP_CODE.astype(str)
customer = pd.merge(customer,zips)
customer.head()

timezone = pd.read_csv("Data/timezone.csv")
timezone = timezone.drop_duplicates(['state'],keep='first')
timezone = timezone.ix[:,(1,2)]
timezone.head()
timezone = timezone.rename(columns={'state':'STATE'})
customer = pd.merge(customer,timezone,on='STATE')


# Orderlist

orderlist = pd.read_csv("data/6 month history of customer orders.csv")
orderlist.ORDER_DATE = pd.to_datetime(orderlist.ORDER_DATE)
orderlist.head()
orderlist.ORDER_TIME = pd.to_datetime(orderlist.ORDER_TIME,format='%H:%M:%S').dt.time

def combine_date_time(df, datecol, timecol):
    return pd.to_datetime(df[datecol].dt.date.astype(str)
                          + ' '
                          + df[timecol].astype(str))
                          
                          
orderlist['ORDER_DATES'] = combine_date_time(orderlist,'ORDER_DATE','ORDER_TIME') 
orderlist.ORDER_DATES = pd.to_datetime(orderlist.ORDER_DATES,format='%Y-%m-%d %H:%M:%S')   

orderlist['YEAR'] = orderlist.ORDER_DATES.dt.year
orderlist['MONTH'] = orderlist.ORDER_DATES.dt.month
orderlist['DAY'] = orderlist.ORDER_DATES.dt.day
orderlist['HOUR'] = orderlist.ORDER_DATES.dt.hour 

orderlist.head()    


    
product = pd.read_csv('Data/Product master2.csv')   
product.head()          
air_product = pd.read_csv('Data/Product airtime.csv')
air_product['SEQ'] = np.arange(len(air_product))

air_product.head()

air_product['AIR_DATE'] = pd.to_datetime(air_product['AIR_DATE'])
air_product['PRODUCT_START_TMS'] = pd.to_datetime(air_product['PRODUCT_START_TMS'], format='%Y-%m-%d %H:%M')
air_product['PRODUCT_STOP_TMS'] = pd.to_datetime(air_product['PRODUCT_STOP_TMS'], format='%Y-%m-%d %H:%M')

order_df = pd.merge(orderlist,customer,on='CUSTOMER_NBR')
order_df.head()

order_df['SHOPPER_SEGMENT_CODE'] = order_df['SHOPPER_SEGMENT_CODE'].astype(int)

sns.factorplot('timezone', kind='count', data=order_df)
sns.factorplot('timezone', kind='count', data=order_df, hue='SHOPPER_SEGMENT_CODE')

order_df.ix[1,[3,6]][1]
def getNear(order):
    productID = order[0]
    orderDate = order[1]
    
    tmp_df = air_product[air_product['PRODUCT_ID']==productID]    
    
    return(productID)

order_df.ix[1:4,[3,6]].apply(getNear,axis=1)
    
air_product[air_product['PRODUCT_ID']==2186 & air_product['PRODUCT_START_TMS']< pd.to_datetime('2012-11-16 06:26:00', format='%Y-%m-%d %H:%M:%S')]

