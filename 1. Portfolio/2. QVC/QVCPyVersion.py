# -*- coding: utf-8 -*-
"""
Created on Fri Mar 24 17:33:29 2017

@author: MCR007
"""
### Handling Data ###


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

customer.to_csv("Data2/customer2.csv", index=False)
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
air_product['PRODUCT_START_TMS'] = pd.to_datetime(air_product['PRODUCT_START_TMS'])
air_product['PRODUCT_STOP_TMS'] = pd.to_datetime(air_product['PRODUCT_STOP_TMS'])

order_df = pd.merge(orderlist,customer,on='CUSTOMER_NBR')
order_df.head()

order_df['SHOPPER_SEGMENT_CODE'] = order_df['SHOPPER_SEGMENT_CODE'].astype(int)

sns.factorplot('timezone', kind='count', data=order_df, size=10)
sns.factorplot('timezone', kind='count', data=order_df, hue='SHOPPER_SEGMENT_CODE')

order_df.ix[1,[3,6]]
def getNear(order):
    productID = order.ix[0]
    orderDate = order.ix[1]
    result = 0
    tmp_df = air_product[air_product['PRODUCT_ID']==productID].copy()    
    if len(tmp_df) > 0:
        tmp_df = tmp_df[tmp_df['PRODUCT_START_TMS'] < orderDate]
        if len(tmp_df) >0:
            tmp_df = tmp_df.sort_values(by='PRODUCT_START_TMS', ascending=False)
            result = tmp_df.iloc[0,5]
    return(result)

order_df.ix[1:20,[3,6]].apply(getNear,axis=1)

order_df['SEQ'] = order_df.ix[:,[3,6]].apply(getNear,axis=1)

order_df.to_csv('Data2/pre_order_data.csv')
order_df = pd.read_csv('Data2/pre_order_data.csv')
order_df = pd.merge(order_df,product,on='PRODUCT_ID')
order_df = pd.merge(order_df,air_product.ix[:,air_product.columns != 'PRODUCT_ID'],on='SEQ')
order_df.head()

order_df.info()

order_df.to_csv('Data2/order_data.csv',index=False)

#### Making Cluster #####
customer = pd.read_csv('Data2/customer2.csv')
order_df = pd.read_csv('Data2/order_data.csv')
customer.head()
order_df.head()

order_df.groupby(['CUSTOMER_NBR','MERCH_DIV_DESC']).size()

cate_per_customer = order_df.groupby(['CUSTOMER_NBR','MERCH_DIV_DESC']).size()
cate_per_customer = pd.DataFrame(cate_per_customer)
cate_per_customer = cate_per_customer.unstack(1)
cate_per_customer = cate_per_customer.fillna(0)
tmp = cate_per_customer.copy()

item_per_customer = order_df.groupby(['CUSTOMER_NBR','PRODUCT_ID']).size()
item_per_customer = pd.DataFrame(item_per_customer)
item_per_customer = item_per_customer.unstack(1)
item_per_customer = item_per_customer.fillna(0)

per_customer = pd.concat([cate_per_customer, item_per_customer], axis=1)

from sklearn.cluster import KMeans
kmeans = KMeans(n_clusters=9, random_state=0).fit(per_customer)
kmeans
kmeans.labels_[200:400]
per_customer['Cluster'] = kmeans.labels_
per_customer.head()
per_customer.index
custer_df = pd.DataFrame({'CUSTOMER_NBR':per_customer.index,'Cluster':per_customer['Cluster']})
custer_df.head()
custer_df[custer_df['CUSTOMER_NBR']==627088]

tmp = order_df.copy()
tmp['CUSTOMER_NBR'] = tmp.astype(int)
tmp = pd.concat([tmp,custer_df.ix[:,1]], axis=1)

tmp = tmp[tmp['Cluster'].notnull()]



