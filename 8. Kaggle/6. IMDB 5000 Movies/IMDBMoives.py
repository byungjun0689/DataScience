# -*- coding: utf-8 -*-
"""
Created on Thu Mar 30 16:54:16 2017

@author: BYUNGJUN
"""

import pandas as pd 
import numpy as np 
import matplotlib.pyplot as plt 
import seaborn as sns 
import datetime as dt

# How people can know rating(like greatness of moives) before watching a moive 
# without critics or our own instincts? It's the point of this Analysis 

movies = pd.read_csv("data/movie_metadata.csv")
movies.columns

movies['content_rating'].value_counts() # content rating -> 상영등급.
movies['imdb_score'].value_counts()

# 몇점 만점인가?
movies['imdb_score'].max() # 10 is highest, maximun of rating is 9.5 in this db
movies['imdb_score'].min() # 0 is lowest, minimun of rating is 1.6 in this db

# 우선 영향도를 보기 위해서 평점을 반올림을 통해서 구분이 잘되도록 변환 

df = movies.copy()
df['imdb_score'] = df['imdb_score'].apply(lambda x:int(round(x)))
df['imdb_score'].value_counts()

sns.factorplot('imdb_score',kind='count',data=df, size=8)

df.columns

# Q2 : Will the number of human faces in movie poster correlate with the movie rating?
# A2 : Nop, There's nothing about realtion with two data number of face in poster and imdbsocre 
#      it's Almost 0 Correation with two factors
realtionOfFN = df[['facenumber_in_poster','imdb_score']].dropna().corr()
realtionOfFN
# Delete columns i don't need
del df['movie_imdb_link']
del df['color']

# number of directors 2399.
len(df['director_name'].unique())

tmp_df = df[['director_name','imdb_score']]
tmp_X = pd.get_dummies(df['director_name'])
tmp_X['imdb_score'] = tmp_df['imdb_score']
df_corr = tmp_X.corr()

corr = df_corr['imdb_score']
corr[corr>0.05]

# 감독 출현수 
df_director = pd.DataFrame({'cnt' : df.groupby(['director_name']).size()}).reset_index()
df_director = df_director.sort_values(by='cnt',ascending = False)
df[df['director_name']=='Steven Spielberg']['imdb_score'].mean()

# 감독과 영화 평점은 연관성이 크게 없어 보인다. 
# 연관이 있을 것 같은데 크게 없다고 나오네..

df[['director_name','imdb_score']].groupby(['director_name']).mean()


genre_list = df['genres'].str.split('|')
genre_list
# set 으로 활용하면 되려나 
genre = set()
for i in range(len(genre_list)):
    genre |= set(genre_list[i])
    
pd.DataFrame(genre_list[1]).T

genre_df = pd.DataFrame()
for i in range(len(genre_list)):
    genre_df = genre_df.append(pd.DataFrame(genre_list[i]).T)


# way 1 .
df1 = pd.DataFrame(genre_list.values.tolist(), index=genre_list.index)
df1 = pd.DataFrame(genre_list.values.tolist(), index=genre_list.index).replace({None:np.nan})

# way 2 
df1 = genre_list.apply(pd.Series)



genre_df = genre_df.reset_index()
genre_df['index'] = range(len(genre_df))
#genre_df['imdb_score'] = df['imdb_score']
#del genre_df['index']
genre_df.stack()

genre_df.stack().groupby(level=0).value_counts().unstack().fillna(0)

# way 1
df = pd.get_dummies(genre_df.drop('index', axis=1).stack()).groupby(level=0).max()

# way 2
genre_df = genre_df.drop('index', 1)
genre_df.stack().groupby(level=0).value_counts().unstack(fill_value=0) # int
genre_df.stack().groupby(level=0).value_counts().unstack().fillna(0) # float
#way 3
genre_df.apply(pd.value_counts, 1).fillna(0).astype(int)


df_genre = genre_df.stack().groupby(level=0).value_counts().unstack(fill_value=0) 
df_genre['imdb_score'] = df['imdb_score']

genre_corr = df_genre.corr()
genre_corr = genre_corr['imdb_score']
genre_corr[abs(genre_corr)>0.1]

# horror & comedy have a bad effection to rating of moives
# Biography, Documentary, Drama, History, War have good factors for rating of movies

actor_df = df[['actor_1_name','actor_2_name','actor_3_name']]
actor_df = actor_df.stack().groupby(level=0).value_counts().unstack(fill_value=0)
actor_df['imdb_score'] = df['imdb_score']

actor_corr = actor_df.corr()

tmp = pd.get_dummies(df['actor_1_name']).astype(int)
tmp['imdb_score'] = df['imdb_score']
tmp = tmp.corr()
tmp = tmp['imdb_score']
tmp[abs(tmp)>0.1]



# actor like
tmp = df[['actor_1_facebook_likes','imdb_score']]
tmp = tmp.corr()
tmp = tmp['imdb_score']
tmp[abs(tmp)>0.1]