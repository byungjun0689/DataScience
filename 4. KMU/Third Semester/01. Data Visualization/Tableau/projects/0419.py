# -*- coding: utf-8 -*-
"""
Created on Wed Apr 19 21:11:42 2017

@author: byung
"""

import pandas as pd
import pandas as pd
import numpy as np 
import matplotlib.pyplot as plt 
import seaborn as sns 
from matplotlib import font_manager, rc

font_name = font_manager.FontProperties(fname="c:/Windows/Fonts/malgun.ttf").get_name()
rc('font', family=font_name)


#order = pd.read_csv("2. TR.csv", encoding="cp949")
customer = pd.read_csv("customer.csv")
product = pd.read_csv("product.csv")
tr_customer = pd.read_csv("order_seoul.csv",encoding='cp949')
zip_code = pd.read_csv("data/zipcode.csv",encoding="cp949")
customer.head()
len(tr_customer)
#tr_customer = pd.merge(order,customer,on="고객번호")

#order['구매일자'] = order['구매일자'].astype(int)
#order = order[order['구매일자'] > 20150000]

#tr_customer = tr_customer[tr_customer['시도']=='서울특별시']


#tr_customer = pd.merge(tr_customer, product, on=['제휴사','대분류코드','중분류코드','소분류코드'])
#tr_customer.head()

#tr_customer.to_csv("order_seoul.csv",index=False)

#점포 코드는 없던걸로 해야된다.
'''
store_zip = pd.DataFrame({'count':tr_customer.groupby(['점포코드','ZIP']).size()}).reset_index()
store_zip = store_zip.sort_values(by=['점포코드','count'],ascending=False)
tmp = store_zip.groupby(['점포코드']).first() 
tmp = tmp.reset_index()

tmp2 = pd.merge(tmp,zip_code,on="ZIP",how='left')
tmp2[tmp2['시군구']=='관악구']

# check how many store in each gu in seoul
tmp2[['점포코드','시군구']].groupby(['시군구']).size()
tmp2 = tmp2.rename(columns={'시군구': '점포위치','시도': '점포시위치'})
tmp2.to_csv("store_code.csv",index=False, encoding="utf-8")
tr_customer = pd.merge(tr_customer,tmp2[['점포코드','점포위치']],on='점포코드')
tr_customer.groupby(['점포위치','제휴사']).size()
tr_customer[tr_customer['점포코드'].isin(list(tmp2[tmp2['점포위치']=='관악구']['점포코드']))]
'''

# 고객주소별 제휴사 구매 빈도

gu_per = tr_customer.drop_duplicates(['영수증번호']).groupby(['시군구','제휴사']).size()
gu_per = gu_per.groupby(level=0).apply(lambda x:100 * x / float(x.sum()))
gu_per = gu_per.apply(lambda x:round(x,1))
gu_per_df = pd.DataFrame({'percent':gu_per}).reset_index()
gu_per_df = gu_per_df.sort_values(by=["시군구","percent"], ascending=False)
heat_gu_per = pd.pivot_table(gu_per_df,index=['시군구'],values=['percent'],columns=['제휴사']).fillna(0)
heat_gu_per = heat_gu_per.sort_index()
plt.figure(figsize = (15,12))
sns.heatmap(heat_gu_per, annot=True, fmt='f', linewidths=.5)
plt.title('구 / 제휴사 별 구매 분포')
plt.xlabel("제휴사별")
plt.show()


# 가족 구성원의 따른 구매 패턴
one_house = pd.read_csv("One_house.csv",encoding="cp949")
del one_house['기간']
del one_house['동']

one_col = list(one_house.columns.difference(['자치구','계']))
one_house[one_col] = one_house[one_col].div(one_house['계'],axis=0).applymap(lambda x:round(x,3)) 
one_house = one_house[["자치구","계","1인가구","2인가구","3인가구","4인가구"]]

one_house.index = list(one_house['자치구'])
one_house = one_house.sort_index()
plt.figure(figsize = (15,12))
sns.heatmap(one_house[["1인가구","2인가구","3인가구","4인가구"]], annot=True, fmt='f', linewidths=.5)
plt.title('가족 구성')
plt.show()

# 시간대별 구매 추이
time_tr = pd.DataFrame({'cnt':tr_customer.drop_duplicates(['영수증번호']).groupby(['제휴사','구매시간']).size()}).reset_index()
sns.factorplot(x='구매시간',y='cnt',kind='bar',hue='제휴사',data=time_tr, size=12)

# 그래프를 나눠서 그리기 
plt.figure(figsize = (15,12))
g = sns.FacetGrid(time_tr, col="제휴사",size=3)
g = (g.map(plt.bar, "구매시간", "cnt").add_legend())

tr_customer.columns
tr_customer.groupby(['점포코드','제휴사','시군구']).size()

robs = tr_customer[tr_customer['제휴사']=="D"]

robs['구매일자'] = pd.to_datetime(robs['구매일자'], format="%Y%m%d")
date_df = robs.groupby(['구매일자']).size()
plt.figure(figsize = (15,12))
date_df.plot()

cate_df = pd.DataFrame({'cnt':robs.groupby(['중분류명']).size()}).reset_index()
cate_df.sort_values(by=['cnt'],ascending=False)

cate_time_df = pd.DataFrame({'cnt':robs.groupby(['중분류명','구매시간']).size()}).reset_index()
cate_time_df = cate_time_df.sort_values(by=['중분류명','구매시간'],ascending=False)
sns.factorplot(x='구매시간',y='cnt',data=cate_time_df[cate_time_df['중분류명'].isin(['음료','과자'])], hue='중분류명', size=10)


plt.figure(figsize = (15,12))
g = sns.FacetGrid(gu_df, col="시군구",size=3)
g = (g.map(plt.bar, "구매일자", "cnt").add_legend())



gu_df = pd.DataFrame({'cnt':robs.groupby(['구매일자','시군구']).size()}).reset_index()
sns.factorplot(x='구매일자',y='cnt',data=gu_df, hue='시군구', size=10)


pd.DataFrame({'cnt':product[product['제휴사']=='D'].groupby(['중분류명']).size()}).reset_index().sort_values(by='cnt',ascending=False)




# 0421  제품별 Correlation 

tr_customer.head()

tr_customer.groupby(['영수증번호'])

tt = tr_customer[tr_customer['제휴사']=="D"]


tt = pd.DataFrame({'cnt':tt.groupby(['영수증번호','중분류명']).size()}).reset_index()
tt = pd.pivot_table(tt,index='영수증번호',columns='중분류명',values='cnt').fillna(0)
tt = tt.applymap(lambda x:int(x))

def changeNumber(x):
    if x<0:
        return 0 
    else:
        return x

cor_tt = tt.corr()
basic = pd.DataFrame(cor_tt['음료'])
#basic = basic.applymap(lambda x:changeNumber(x))
#basic = basic[basic['과자']!=0]
sns.heatmap(basic, annot=True, fmt='f', linewidths=.5)
plt.title('음료와 연관있는 제품들')
plt.xlabel("음료")
plt.show()


basic = pd.DataFrame(cor_tt)
#basic = basic.applymap(lambda x:changeNumber(x))
#basic = basic[basic['과자']!=0]
sns.heatmap(basic, annot=True, fmt='f', linewidths=.5)
plt.title('연관있는 제품들')
plt.show()


total_d_product = pd.DataFrame({'cnt':tr_customer[tr_customer['제휴사']=="D"].groupby(['중분류명']).size()}).reset_index()
total_d_product = total_d_product.sort_values(by='cnt',ascending=False)

d_list = list(total_d_product[total_d_product['cnt']>1000]['중분류명'])


plt.figure(figsize = (15,12))
basic = pd.DataFrame(cor_tt[d_list])
basic = basic.ix[d_list,:]
#basic = basic.applymap(lambda x:changeNumber(x))
#basic = basic[basic['과자']!=0]
sns.heatmap(basic, annot=False, fmt='f', linewidths=.5)
plt.title('연관있는 제품들')
plt.show()

cor_tt[d_list].columns
cor_tt[d_list].index


