# -*- coding: utf-8 -*-
"""
Created on Wed May 31 20:45:05 2017

@author: byungjun
"""

import pandas as pd
import re
from sklearn.feature_extraction.text import CountVectorizer
import numpy as np
import naver
from selenium import webdriver
import wordhandle
import json

#driver = webdriver.Chrome(executable_path=r'D:\DataScience\chromedriver.exe')
#driver = webdriver.PhantomJS(executable_path=r'D:\DataScience\Phantomjs.exe') 실제적으로 할때는 팬텀 사용.

# searchNaverNews(search,frdate,todate)

data = naver.searchNaverNews("갤럭시s8","2017-05-01","2017-06-01")
data = naver.drop_duplidata(data)
data.head()

#data2 = data.copy()

#data.to_csv("news_samsung.csv",index=False, encoding='utf8')
data = pd.read_csv("news_samsung.csv")


#under_comment = naver.getAllUnderComment(data)
under_comment = naver.getComment_json(data,"갤럭시s8")
#under_comment.to_csv("under_comment_samsung.csv",index=False, encoding='utf8')
under_comment = pd.read_csv("tmp.csv")
under_comment = under_comment.sort_values(by='like', ascending = False)

tdm, cv = wordhandle.makeTDM(data['contents'])

np.savez('news_tdm.npz',tdm)

with open('news_tdm.json',"w", encoding='utf8') as f:
    json.dump(cv.get_feature_names(),f)

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


