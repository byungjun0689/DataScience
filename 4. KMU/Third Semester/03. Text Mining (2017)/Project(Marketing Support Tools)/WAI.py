# -*- coding: utf-8 -*-
"""
Created on Wed May 31 20:45:05 2017

@author: byung
"""


import pandas as pd
import re
from konlpy.tag import Komoran
from sklearn.feature_extraction.text import CountVectorizer
import numpy as np
import Naver
from selenium import webdriver
 
driver = webdriver.Chrome(executable_path=r'F:\DataScience\chromedriver.exe')
#driver = webdriver.PhantomJS(executable_path=r'D:\DataScience\Phantomjs.exe') 실제적으로 할때는 팬텀 사용.

# searchNaverNews(search,frdate,todate)

data = Naver.searchNaverNews("딥러닝","2017-05-24","2017-05-27")
data = Naver.drop_duplidata(data)
data.head()

under_comment = pd.DataFrame()
for i in range(5):
    under_comment = under_comment.append(Naver.getNaverUnderComments(data.ix[i,"url"],driver))


type(under_comment)

under_comment['url']