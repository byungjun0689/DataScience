# -*- coding: utf-8 -*-
"""
Created on Wed May 31 20:45:05 2017

@author: byungjun
"""

import pandas as pd
import re
from konlpy.tag import Komoran
from sklearn.feature_extraction.text import CountVectorizer
import numpy as np
import naver
from selenium import webdriver
import wordhandle
 
#driver = webdriver.Chrome(executable_path=r'D:\DataScience\chromedriver.exe')
#driver = webdriver.PhantomJS(executable_path=r'D:\DataScience\Phantomjs.exe') 실제적으로 할때는 팬텀 사용.

# searchNaverNews(search,frdate,todate)

data = naver.searchNaverNews("롯데월드","2017-05-15","2017-05-20")
data = naver.drop_duplidata(data)
data.head()

data2 = data.copy()

data.to_csv("news.csv",index=False)
data = pd.read_csv("news.csv",encoding='cp949')

under_comment = naver.getAllUnderComment(data)
under_comment.to_csv("under_comment.csv",index=False)

under_comment = under_comment.sort_values(by='like', ascending = False)
tdm, cv = wordhandle.makeTDM(data['contents'])
wordcount = wordhandle.makeWordCloud(tdm,cv)

from sklearn.decomposition import TruncatedSVD
from sklearn.preprocessing import Normalizer
from sklearn.pipeline import make_pipeline

svd = TruncatedSVD(n_components=10) # 10개의 차원으로 변경.
snormalizer = Normalizer(copy=False)
lsa = make_pipeline(svd, normalizer)

pos = lsa.fit_transform(tdm)

from sklearn.cluster import KMeans
km = KMeans(n_clusters=5)

km.labels_

