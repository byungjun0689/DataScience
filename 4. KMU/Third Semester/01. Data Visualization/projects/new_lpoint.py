# -*- coding: utf-8 -*-
"""
Created on Tue Apr 18 12:19:02 2017

@author: BYUNGJUN
"""

import pandas as pd
import numpy as np 
import matplotlib.pyplot as plt 
import seaborn as sns 

customer = pd.read_csv("customer.csv")

tr = pd.read_csv("order.csv", encoding='utf-8')
len(tr)

tr.groupby(['제휴사']).aggregate({'cnt':count(),'mean':mean()})

tt = pd.pivot_table(tr,index=['제휴사'],values=['구매금액'],aggfunc=[len,np.mean])
tt

tt2 = pd.pivot_table(tr,index=['제휴사'],values=['구매금액'],aggfunc=[len,np.mean],colums=[''])


tr_df = pd.merge(tr,customer,on="고객번호")

tt2 = pd.pivot_table(tr_df,index=['제휴사'],values=['구매금액'],aggfunc=[len,np.mean],columns=['성별'])
tt2['mean'] = tt2['mean'].applymap(lambda x:round(x))
tt2

tt2.info()

tt3 = pd.pivot_table(tr_df,index=['연령대'],values=['구매금액'],aggfunc=[len,np.mean],columns=['제휴사'])
tt3['mean'] = tt3['mean'].applymap(lambda x:round(x))
tt2


tt4 = pd.pivot_table(tr_df,index=['시군구'],values=['구매금액'],aggfunc=[len,np.mean],columns=['제휴사'])
tt4['mean'] = tt4['mean'].applymap(lambda x:round(x))


from matplotlib import font_manager, rc

font_name = font_manager.FontProperties(fname="c:/Windows/Fonts/malgun.ttf").get_name()
rc('font', family=font_name)

heat = tt4['mean'].copy() 
heat['sum'] = np.sum(heat,axis=1)
heat = heat.sort_values(by='sum', ascending=False)
del heat['sum']
heat = heat.div(heat.sum(axis=0))
heat = heat.applymap(lambda x:round(x,2))
plt.figure(figsize = (15,12))
sns.heatmap(heat, annot=True, fmt='f', linewidths=.5)
plt.title('구별 구매 평균')
plt.show()


one_house = pd.read_csv("One_house.csv",encoding='cp949')
del one_house['기간']
del one_house['동']

sns.factorplot(x='자치구',y='1인가구',kind='bar',data=one_house,size=10)
plt.xticks(rotation=90)
