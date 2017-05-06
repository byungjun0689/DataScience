# -*- coding: utf-8 -*-
"""
Created on Sat Apr 15 10:02:01 2017

@author: BYUNGJUN
"""

import pandas as pd

customer = pd.read_csv(u"1.customer_info.txt",encoding="cp949")
tr = pd.read_csv(u"2.order_tr.txt",encoding="cp949")
product = pd.read_csv(u"3.product.txt",encoding="cp949")
competition = pd.read_csv(u"4.competition.txt",encoding="cp949")
membership = pd.read_csv(u"5.membership.txt",encoding="cp949")
channel = pd.read_csv(u"6.channel.txt",encoding="cp949")

channel['제휴사'] = channel['제휴사'].astype('category')
channel['제휴사'].cat.set_categories(['A_MOBILE/APP',
 'B_MOBILE/APP',
 'C_MOBILE/APP',
 'D_MOBILE/APP',
 'B_ONLINEMALL',
 'C_ONLINEMALL'], inplace=True)

ch = pd.pivot_table(channel, index=['고객번호'],columns=['제휴사'],values=['이용횟수']).fillna(0)
customer = pd.merge(customer,ch,left_on='고객번호',right_index=True, how='left').fillna(0)
customer.head()


customer.to_csv("customer.csv",index=False,encoding="utf-8")
tr[:5000000].to_csv("order.csv",index=False,encoding='utf-8')
product.to_csv("product.csv",index=False,encoding='utf-8')
competition.to_csv("competition.csv",index=False,encoding='utf-8')
membership.to_csv("membership.csv",index=False,encoding='utf-8')
channel.to_csv("channel.csv",index=False,encoding='utf-8')


product.head()
tr = pd.merge(tr,product,on=["대분류코드","중분류코드","소분류코드","제휴사"])
competition.head()

membership[membership['고객번호']==21]


tr = pd.merge(tr,membership,on="고객번호")
tr.to_csv("visualization.csv",index=False)


channel[channel[['고객번호']].duplicated()]
pd.melt(channel[channel['고객번호']==18795], id_vars=['고객번호'], value_vars=['제휴사','이용횟수'])
channel.unstack(0)


channel.stack().groupby(level=0).value_counts()

list(channel['제휴사'].unique())
ch = list(channel['제휴사'].unique())
channel['제휴사'] = channel['제휴사'].astype('category')
channel['제휴사'].cat.set_categories(['A_MOBILE/APP',
 'B_MOBILE/APP',
 'C_MOBILE/APP',
 'D_MOBILE/APP',
 'B_ONLINEMALL',
 'C_ONLINEMALL'], inplace=True)

ch = pd.pivot_table(channel, index=['고객번호'],columns=['제휴사'],values=['이용횟수']).fillna(0)
customer = pd.merge(customer,ch,left_on='고객번호',right_index=True, how='left').fillna(0)
customer.head()

zip_code = pd.read_csv("zipcode.csv",encoding='cp949')
customer['거주지역'] = customer['거주지역'].astype(int)
customer = pd.merge(customer,zip_code,left_on="거주지역", right_on="ZIP")
customer.to_csv("customer.csv",index=False,encoding="utf-8")

###################################################################

tr = pd.merge(tr,ch,on="고객번호")

import seaborn as sns
from matplotlib import font_manager, rc
import matplotlib.pyplot as plt
df = pd.read_csv("visualization.csv", encoding="cp949")

font_name = font_manager.FontProperties(fname="c:/Windows/Fonts/malgun.ttf").get_name()
rc('font', family=font_name)

item_df = pd.DataFrame({'cnt':df.groupby(['제휴사','소분류명']).size()}).reset_index()

sns.factorplot('소분류명',kind='count',data=df[df['제휴사']=="B"])
tt = item_df[item_df['제휴사']=="B"]
tt = tt.sort_values(by='cnt',ascending=False)

sns.factorplot(data=tt.head(20),x='소분류명',y='cnt',kind='bar')
plt.xticks(rotation=90)

tmp_df = df.dropna(subset=['거주지역'])
tmp_df['거주지역'] = tmp_df['거주지역'].astype(object)
len(str(tmp_df['거주지역'][0]))
def changePost(x):
    if len(str(x)) < 3:
        x = "0" + str(x)
        return(x)
    else:
        return(x)
    
tmp_df['거주지역'] = tmp_df['거주지역'].apply(changePost)

sns.factorplot('거주지역',data=tmp_df,kind='count',size=10)
plt.xticks(rotation=90)

def cutZipcode(x):
    x = str(x)
    if len(str(x)) < 5:
        x = "0" + str(x)
    return x[:3]
        

import os,glob

zip_code = pd.read_table("강원도.txt",delimiter="|",encoding="cp949")
zip_code = zip_code[['새우편번호','시도','시군구','도로명']]
zip_code['ZIP'] = zip_code['새우편번호'].apply(cutZipcode)
zip_code.columns
zip_code = zip_code.drop_duplicates(['시도', '시군구','ZIP'],keep='first')
zip_code = zip_code[['ZIP','시도','시군구']]

zip_code2 = pd.read_table("서울특별시.txt",delimiter="|",encoding="cp949")
zip_code2 = zip_code2[['새우편번호','시도','시군구','도로명']]
zip_code2.head()
zip_code2['ZIP'] = zip_code2['새우편번호'].apply(cutZipcode)


zip_code_total = pd.DataFrame()
dirlist = glob.glob("*.txt")
for files in dirlist:
    print(files)
    zip_code = pd.read_table(files,delimiter="|",encoding="cp949")
    zip_code = zip_code[['새우편번호','시도','시군구','도로명']]
    zip_code['ZIP'] = zip_code['새우편번호'].apply(cutZipcode)
    zip_code = zip_code.drop_duplicates(['시도', '시군구','ZIP'],keep='first')
    zip_code = zip_code[['ZIP','시도','시군구']]
    zip_code_total = zip_code_total.append(zip_code)


zip_code_total = zip_code_total.reset_index()
del zip_code_total['index']
zip_code_total.head()

zip_code_total.to_csv('zipcode.csv',index=False)


tmp_df = pd.merge(tmp_df,zip_code_total,left_on="거주지역",right_on="ZIP")

sns.factorplot('시군구',hue='제휴사',kind='count',data=tmp_df,size=10)
plt.xticks(rotation=90)


gu_df = pd.DataFrame({'cnt':tmp_df.groupby(['시군구','제휴사']).size()}).reset_index()

import json 
import folium
import warnings

warnings.simplefilter(action='ignore', category=FutureWarning)

geo_path = 'skorea_municipalities_geo_simple.json'
geo_str = json.load(open(geo_path,encoding='utf-8'))

map = folium.Map(location=[37.5502, 126.982], zoom_start=11, tiles='Stamen Toner')

map.choropleth(geo_str = geo_str,
               data = gu_df[gu_df['제휴사']=="D"][['시군구','cnt']],
               columns = ['시군구', 'cnt'],
               fill_color = 'PuRd', #PuRd, YlGnBu
               key_on = 'feature.id')
map

map.choropleth(threshold_scale=True)
gu_df2 = pd.DataFrame({'cnt':tmp_df.groupby(['시군구']).size()}).reset_index()

max_df = pd.DataFrame({'cnt':df.groupby(['제휴사',"소분류명"]).size()}).reset_index()

idx = max_df.groupby(['제휴사'])['cnt'].transform(max) == max_df['cnt']
max_df[idx]

tt_df = df[(df['제휴사']=="B") & (df['소분류명']=="일반흰우유")]
milk_group = pd.DataFrame({'cnt':tt_df.groupby(['구매일자']).size()}).reset_index()
milk_group['구매일자'] = pd.to_datetime(milk_group['구매일자'],format="%Y%m%d")
sns.tsplot(milk_group, time='구매일자', value='cnt')
milk_group.plot()
milk_group.index = milk_group['구매일자']

one_house = pd.read_table("Octagon.txt",delimiter="\t")
one_house = one_house[one_house["동"]=="소계"]
tt = list(one_house.columns.difference(["기간","자치구","동"]))
one_house[tt] = one_house[tt].applymap(lambda x: x.replace(',', ''))
one_house[tt] = one_house[tt].astype(int)
one_house.to_csv("One_house.csv",index=False)