# -*- coding: utf-8 -*-
"""
Created on Fri Sep 22 16:30:13 2017

@author: MCR007
"""

import pandas as pd
import seaborn as sns 
import matplotlib.pyplot as plt

df = pd.read_csv("./HANDICAP_DEID_20170418.csv", encoding='cp949')
df.head()

df.columns

df = df.rename(columns = {'나이':'AGE', '가입자성별':'SEX', '복지할인유형':'TYPE'})

df['WK0609'] = df.iloc[:,3:6].apply(lambda x: " ".join(x), axis=1)
df['WK0912'] = df.iloc[:,6:9].apply(lambda x: " ".join(x), axis=1)
df['WK1215'] = df.iloc[:,9:12].apply(lambda x: " ".join(x), axis=1)
df['WK1518'] = df.iloc[:,12:15].apply(lambda x: " ".join(x), axis=1)
df['WK1821'] = df.iloc[:,15:18].apply(lambda x: " ".join(x), axis=1)
df['WK2124'] = df.iloc[:,18:21].apply(lambda x: " ".join(x), axis=1)

df.head()

df['WE0609'] = df.iloc[:,21:24].apply(lambda x: " ".join(x), axis=1)
df['WE0912'] = df.iloc[:,24:27].apply(lambda x: " ".join(x), axis=1)
df['WE1215'] = df.iloc[:,27:30].apply(lambda x: " ".join(x), axis=1)
df['WE1518'] = df.iloc[:,30:33].apply(lambda x: " ".join(x), axis=1)
df['WE1821'] = df.iloc[:,33:36].apply(lambda x: " ".join(x), axis=1)
df['WE2124'] = df.iloc[:,36:39].apply(lambda x: " ".join(x), axis=1)


df2 = df[['AGE','SEX','TYPE','WK0609','WK0912','WK1215','WK1518','WK1821','WK2124','WE0609','WE0912','WE1215','WE1518','WE1821','WE2124']]

df2.to_csv("re_saved_data.csv", encoding='utf-8')

df2.head()

# 성비별 비교
# 여성이 
df2['SEX'] = df2['SEX'].map({1:'male',2:'female'})

sns.factorplot(data=df2, x='SEX', kind='count')
sns.countplot(data=df2, x='AGE')
plt.xticks(rotation=45)

