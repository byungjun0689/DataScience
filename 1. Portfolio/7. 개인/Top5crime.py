# -*- coding: utf-8 -*-
"""
Created on Fri Apr  7 11:18:38 2017

@author: MCR007
"""
# 서울 강남 3구 체감안전도 높아"라는 위 기사를 보고~~~ 실제 통계자료도 그렇게 나타나는지를 볼려고 했습니다.
# 출처: http://pinkwink.kr/1003 [PinkWink]


import pandas as pd 
import numpy as np 
import matplotlib.pyplot as plt
import seaborn as sns 
import platform
from matplotlib import font_manager, rc

font_name = font_manager.FontProperties(fname="c:/Windows/Fonts/malgun.ttf").get_name()
rc('font', family=font_name)


출처: http://pinkwink.kr/1003 [PinkWink]

df = pd.read_csv("data/관서별5대.csv", encoding='cp949')

object_list = []
for i in df.columns.difference(['관서명']):
    if df[i].dtype =='object':
        object_list.append(i)
    
df[object_list] = df[object_list].apply(lambda x:x.str.replace(',',''))    
df[object_list] = df[object_list].astype(int)

# 경찰서 to 구.
SeoulGu_name = {'서대문서': '서대문구', '수서서': '강남구', '강서서': '강서구', '서초서': '서초구',
                '서부서': '은평구', '중부서': '중구', '종로서': '종로구', '남대문서': '중구',
                '혜화서': '종로구', '용산서': '용산구', '성북서': '성북구', '동대문서': '동대문구',
                '마포서': '마포구', '영등포서': '영등포구', '성동서': '성동구', '동작서': '동작구',
                '광진서': '광진구', '강북서': '강북구', '금천서': '금천구', '중랑서': '중랑구',
                '강남서': '강남구', '관악서': '관악구', '강동서': '강동구', '종암서': '성북구', 
                '구로서': '구로구', '양천서': '양천구', '송파서': '송파구', '노원서': '노원구', 
                '방배서': '서초구', '은평서': '은평구', '도봉서': '도봉구'}


df['구별'] = df['관서명'].map(SeoulGu_name)

guDF = pd.pivot_table(df,index='구별',aggfunc=np.sum)
guDF['강간검거율'] = round(guDF['강간(검거)']/guDF['강간(발생)']*100,2)
guDF['강도검거율'] = round(guDF['강도(검거)']/guDF['강도(발생)']*100,2)
guDF['살인검거율'] = round(guDF['살인(검거)']/guDF['살인(발생)']*100,2)
guDF['절도검거율'] = round(guDF['절도(검거)']/guDF['절도(발생)']*100,2)
guDF['폭력검거율'] = round(guDF['폭력(검거)']/guDF['폭력(발생)']*100,2)

del guDF['강간(검거)']
del guDF['강도(검거)']
del guDF['살인(검거)']
del guDF['절도(검거)']
del guDF['폭력(검거)']


tmpCol = guDF.columns[guDF.columns.str.contains('율')]
guDF[guDF[tmpCol]>100] = 100

guDF['검거율'] = round(guDF['소계(검거)']/guDF['소계(발생)']*100,2)

guDF.rename(columns = {'강간(발생)':'강간', 
                       '강도(발생)':'강도', 
                       '살인(발생)':'살인', 
                       '절도(발생)':'절도', 
                       '폭력(발생)':'폭력'}, inplace=True)

del guDF['소계(발생)']
del guDF['소계(검거)']

guDF.head()

pop_df = pd.read_csv('data/pop_kor.csv', index_col='구별')
pop_df.head()

guDF = guDF.join(pop_df)
guDF.sort_values(by='검거율',ascending=False)

target_col = ['강간', '강도', '살인', '절도', '폭력']
weight_col = guDF[target_col].max()
weight_col

crime_count_norm = guDF[target_col]/weight_col
crime_count_norm.head()

sns.heatmap(crime_count_norm.sort_values(by='살인', ascending=False), annot=True, fmt='f', linewidths=.5)
plt.title('범죄 발생(살인발생으로 정렬) - 각 항목별 최대값으로 나눠 정규화')
plt.show()


crime_ratio = crime_count_norm.div(guDF['인구수'], axis=0)*100000

sns.heatmap(crime_ratio.sort_values(by='살인', ascending=False), annot=True, fmt='f', linewidths=.5)
plt.title('범죄 발생(살인발생으로 정렬) - 각 항목을 정규화한 후 인구로 나눔')
plt.show()


crime_ratio['전체발생비율'] = crime_ratio.mean(axis=1)

plt.figure(figsize = (10,10))
sns.heatmap(crime_ratio.sort_values(by='전체발생비율', ascending=False), annot=True, fmt='f', linewidths=.5)
plt.title('범죄 발생(전체발생비율로 정렬) - 각 항목을 정규화한 후 인구로 나눔')
plt.show()

