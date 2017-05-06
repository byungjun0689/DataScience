# -*- coding: utf-8 -*-
"""
Created on Tue Apr 18 12:19:02 2017

@author: BYUNGJUN
"""

import pandas as pd
import numpy as np 
import matplotlib.pyplot as plt 
import seaborn as sns 
from matplotlib import font_manager, rc

font_name = font_manager.FontProperties(fname="c:/Windows/Fonts/malgun.ttf").get_name()
rc('font', family=font_name)

customer = pd.read_csv("customer.csv")

tr = pd.read_csv("order.csv", encoding='utf-8')
len(tr)

tt = pd.pivot_table(tr,index=['제휴사'],values=['구매금액'],aggfunc=[len,np.mean])
tt['mean'] = tt['mean'].applymap(lambda x:round(x))

tt.columns = tt.columns.droplevel(1)
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

tt4 = pd.pivot_table(tr_customer,index=['시군구'],values=['구매금액'],aggfunc=[len,np.mean],columns=['제휴사'])
tt4['mean'] = tt4['mean'].applymap(lambda x:round(x))



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

tr_customer = pd.merge(tr,customer,on="고객번호")
store_zip = pd.DataFrame({'count':tr_customer.groupby(['점포코드','ZIP']).size()}).reset_index()
store_zip = store_zip.sort_values(by=['점포코드','count'],ascending=False)
tmp = store_zip.groupby(['점포코드']).first() 
tmp.iloc[1]

tmp = tmp.reset_index()

zip_code = pd.read_csv("zipcode.csv",encoding="cp949")
tmp2 = pd.merge(tmp,zip_code,on="ZIP",how='left')
tmp2 = tmp2[tmp2['시도']=='서울특별시']
tmp2[tmp2['시군구']=='관악구']

tmp2[['점포코드','시군구']].groupby(['시군구']).size()

tr_customer = tr_customer[tr_customer['시도']=='서울특별시']
tmp2 = tmp2.rename(columns={'시군구': '점포위치','시도': '점포시위치'})
tmp2.to_csv("store_code.csv")
tr_customer = pd.merge(tr_customer,tmp2[['점포코드','점포위치']],on='점포코드')

tr_customer.groupby(['점포위치','제휴사']).size()


product = pd.read_csv("product.csv")

tr_customer = pd.merge(tr_customer, product, on=['제휴사','대분류코드','중분류코드','소분류코드'])


# tr_customer.groupby(['시군구','제휴사']).size().groupby(level=0).apply(lambda x:100 * x / float(x.sum())).apply(lambda x:round(x,1))
gu_per = tr_customer.groupby(['점포위치','제휴사']).size()
gu_per = gu_per.groupby(level=0).apply(lambda x:100 * x / float(x.sum()))
gu_per = gu_per.apply(lambda x:round(x,1))
gu_per_df = pd.DataFrame({'percent':gu_per}).reset_index()
gu_per_df = gu_per_df.sort_values(by=["점포위치","percent"], ascending=False)
heat_gu_per = pd.pivot_table(gu_per_df,index=['점포위치'],values=['percent'],columns=['제휴사']).fillna(0)

plt.figure(figsize = (15,12))
sns.heatmap(heat_gu_per, annot=True, fmt='f', linewidths=.5)
plt.title('구 / 제휴사 별 구매 분포')
plt.xlabel("제휴사별")
plt.show()


time_tr = pd.DataFrame({'cnt':tr.groupby(['제휴사','구매시간']).size()}).reset_index()
time_tr.info()
sns.factorplot(x='구매시간',y='cnt',kind='bar',hue='제휴사',data=time_tr, size=12)

plt.figure(figsize = (15,12))
g = sns.FacetGrid(time_tr, col="제휴사",size=4)
g = (g.map(plt.bar, "구매시간", "cnt").add_legend())

gu_company = tr_customer.groupby(['시군구','제휴사']).size()
gu_company = gu_company.groupby(level=0).apply(lambda x:100 * x / float(x.sum()))
gu_company = gu_company.apply(lambda x:round(x,1))
gu_company = pd.DataFrame({"cnt":gu_company}).reset_index()
gu_company = gu_company.sort_values(by=["시군구","cnt"], ascending=False)
sns.factorplot(y='cnt',x='시군구',kind='bar',hue='제휴사',data=gu_company,size=12)
gu_company.groupby(['시군구']).first()

one_house = pd.read_csv("One_house.csv",encoding="cp949")
del one_house['기간']
del one_house['동']
one_house.head()
one_col = list(one_house.columns.difference(['자치구','계']))

e/e.sum(axis=1, keepdims=True)

one_house[one_col]/one_house[one_col].sum(axis=1,keepdims=True)

one_house[one_col] = one_house[one_col].div(one_house['계'],axis=0).applymap(lambda x:round(x,3)) 
one_house = one_house[["자치구","계","1인가구","2인가구","3인가구","4인가구"]]
gu_company_first = gu_company.groupby(['시군구']).first()
gu_company_first = gu_company_first.reset_index()

one_house = pd.merge(one_house,gu_company_first,left_on="자치구",right_on="시군구")
del one_house["시군구"]
one_house

one_house.melt()


gwan = tr_customer[(tr_customer['제휴사']=='A') & (tr_customer['시군구']=="관악구")]
gwan = pd.DataFrame({'cnt':gwan.groupby(['구매시간','중분류명']).size()}).reset_index()
gwan.sort_values(by=['구매시간','cnt'],ascending=False).groupby(['구매시간']).first()

song = tr_customer[(tr_customer['제휴사']=='A') & (tr_customer['시군구']=="송파구")]
song = pd.DataFrame({'cnt':song.groupby(['구매시간','중분류명']).size()}).reset_index()
song.sort_values(by=['구매시간','cnt'],ascending=False).groupby(['구매시간']).first()

jong = tr_customer[(tr_customer['제휴사']=='A') & (tr_customer['시군구']=="종로구")]
jong = pd.DataFrame({'cnt':jong.groupby(['구매시간','중분류명']).size()}).reset_index()
jong.sort_values(by=['구매시간','cnt'],ascending=False).groupby(['구매시간']).first()
