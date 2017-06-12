# -*- coding: utf-8 -*-
"""
Created on Mon Jun 12 07:59:37 2017

@author: BYUNGJUN
"""

import president
import pandas as pd
import re
import wordhandle
import numpy as np
from sklearn.feature_extraction.text import TfidfTransformer
import matplotlib.pyplot as plt # for basic plots
import seaborn as sns # for nicer plots
import json

from matplotlib import font_manager, rc
font_name = font_manager.FontProperties(fname="c:/Windows/Fonts/malgun.ttf").get_name()
rc('font', family=font_name)


# 노무현
#no_pre = president.get_president_speech("노무현")
#no_pre = president.get_speech_view_list(no_pre,"노무현")

# 이명박
#lee_pre = president.get_president_speech("이명박")
#lee_pre = president.get_speech_view_list(lee_pre, "이명박")


no_pre  = pd.read_csv('노무현_contents.csv')
lee_pre = pd.read_csv('이명박_contents.csv')

cate_list = president.get_speech_category(no_pre)
cate_list


sub_cate_list = president.get_speech_subcategory(no_pre)
sub_cate_list


# 교육

#tdm, cv = president.get_president_tdm(no_pre,"교육",500)
#tdm2, cv2 = president.get_president_tdm(lee_pre,"교육",500)

tdm = np.load("tdm_교육_노무현.npz")
tdm = tdm['arr_0'].item()

with open('tdm_교육_노무현.json', encoding='utf8') as f:
    words = json.load(f)    

tdm2 = np.load("tdm_교육_이명박.npz")
tdm2 = tdm2['arr_0'].item()

with open('tdm_교육_이명박.json', encoding='utf8') as f:
    words2 = json.load(f)


dae_pre = pd.read_csv("김대중_contents.csv")
tdm3, cv3 = president.get_president_tdm(dae_pre,"교육",500)

wordcount = wordhandle.makeWordCloud(tdm,words)
wordcount2 = wordhandle.makeWordCloud(tdm2,words2)
wordcount3 = wordhandle.makeWordCloud(tdm3,cv3.get_feature_names())

df = president.two_wordcount_df(wordcount, wordcount2)
df2 = president.two_wordcount_df(wordcount, wordcount3)

president.get_compare_words_view(df,"노무현","이명박","교육")
president.get_compare_words_view(df2,"노무현","김대중","교육")


lda, topics = president.get_lda_topic(tdm,words,20)
topics
lda.show_topic(3)
lda.show_topic(9)

lda2, topics2 = president.get_lda_topic(tdm2,words2,20)
topics2
lda2.show_topic(6)


## 외교

tdm = np.load("tdm_외교_노무현.npz")
tdm = tdm['arr_0'].item()

with open('tdm_외교_노무현_.json', encoding='utf8') as f:
    words = json.load(f)
    
tdm2 = np.load("tdm_외교_이명박.npz")
tdm2 = tdm2['arr_0'].item()

with open('tdm_외교_이명박_.json', encoding='utf8') as f:
    words2 = json.load(f)
    
    
wordcount = wordhandle.makeWordCloud(tdm,words)
wordcount2 = wordhandle.makeWordCloud(tdm2,words2)

df = president.two_wordcount_df(wordcount,wordcount2)

president.get_compare_words_view(df,"노무현","이명박","외교")


#### 취임사

tdm = np.load("tdm_취임사_노무현.npz")
tdm = tdm['arr_0'].item()

with open('tdm_취임사_노무현_.json', encoding='utf8') as f:
    words = json.load(f)
    
tdm2 = np.load("tdm_취임사_이명박.npz")
tdm2 = tdm2['arr_0'].item()

with open('tdm_취임사_이명박_.json', encoding='utf8') as f:
    words2 = json.load(f)
    
wordcount = wordhandle.makeWordCloud(tdm,words)
wordcount2 = wordhandle.makeWordCloud(tdm2,words2)

df = president.two_wordcount_df(wordcount,wordcount2)
#president.get_compare_words_view(df,"노무현","이명박","취임사")
## 취임사
## 확실히 이명박의 경우 나라의 역할 나라, 정부의 주도의 행동을 강조하는 듯하는 모습을 보인다.
## 이와 반대적으로 노무현 대통령의 경우 대한민국, 정부 단어 언급보다는 시대적,평화 등 한번도 평화에 대한 언급이 많았다. 대화, 지리 등 한반도 정세에 대한 언급이 많다.

plt.figure(figsize=(15,9))
sns.barplot(y='cnt_x',x='word',data=df[df['total']>7], color='blue',alpha=.5)
sns.barplot(y='cnt_y',x='word',data=df[df['total']>7], color='red',alpha=.5)
plt.xticks(rotation=90)


# 국회연설

len(no_pre[no_pre['sub_category']=='국회연설'])
len(lee_pre[lee_pre['sub_category']=='국회연설'])

tdm, cv = president.get_president_sub_tdm(no_pre,"국회연설",500)
tdm2, cv2 = president.get_president_sub_tdm(lee_pre,"국회연설",500)

wordcount = wordhandle.makeWordCloud(tdm,cv.get_feature_names())
wordcount2 = wordhandle.makeWordCloud(tdm2,cv2.get_feature_names())

df = president.two_wordcount_df(wordcount,wordcount2)
president.get_compare_words_view(df,"노무현","이명박","국정연설")

lda, topics = president.get_lda_topic(tdm,cv.get_feature_names(),10)
topics
lda.show_topic(5)
lda.show_topic(3)

lda2, topics2 = president.get_lda_topic(tdm2,cv2.get_feature_names(),10)
lda2.show_topic(5)


from PIL import Image
from wordcloud import ImageColorGenerator
from wordcloud import WordCloud

moon_coloring = np.array(Image.open('korea_mask.jpg'))
moon_image_colors = ImageColorGenerator(moon_coloring)

wc = WordCloud(font_path='C:\\Windows\\Fonts\\malgun.ttf', background_color='white',mask=moon_coloring, 
               min_font_size=1, max_font_size=40, random_state=42, relative_scaling=0.2)
cloud = wc.generate_from_frequencies(dict(wordcount))
plt.figure(figsize=(12,12))
plt.imshow(cloud.recolor(color_func=moon_image_colors),interpolation='bilinear')
plt.axis("off")
plt.show()

### TF-IDF

no_pre  = pd.read_csv('노무현_contents.csv')
lee_pre = pd.read_csv('이명박_contents.csv')

tdm = np.load("tdm_외교_노무현.npz")
tdm = tdm['arr_0'].item()
tdm

with open('tdm_외교_노무현_.json', encoding='utf8') as f:
    words = json.load(f)
    
tf = TfidfTransformer(smooth_idf=False)
tfidf = tf.fit_transform(tdm.toarray())






### LSA Clustering

no_pre  = pd.read_csv('노무현_contents.csv')
lee_pre = pd.read_csv('이명박_contents.csv')

two_pre = pd.concat([no_pre[no_pre['category']=='산업/경제'],lee_pre[lee_pre['category']=='산업/경제']])

tdm, csv = wordhandle.makeTDM(two_pre['contents'],500)

np.savez("no_lee_economy.npz",tdm)
with open("no_lee_economy.json","w", encoding='utf8') as f:
    json.dump(csv.get_feature_names(),f)

from sklearn.decomposition import TruncatedSVD
from sklearn.preprocessing import Normalizer
from sklearn.pipeline import make_pipeline

svd = TruncatedSVD(n_components=10)
normalizer = Normalizer(copy=False)
lsa = make_pipeline(svd, normalizer)

pos = lsa.fit_transform(tdm)

from sklearn.cluster import KMeans
km = KMeans(n_clusters=2)

km.fit_transform(pos)
len(km.labels_)

pd.Series(km.labels_.tolist()).value_counts()