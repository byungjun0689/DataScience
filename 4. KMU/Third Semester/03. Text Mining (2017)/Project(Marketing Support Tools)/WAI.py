# -*- coding: utf-8 -*-
"""
Created on Wed May 31 20:45:05 2017

@author: byungjun
"""

import pandas as pd
import re
import numpy as np
import naver
import wordhandle
import json
import string

data = naver.searchNaverNews("맥도날드","2017-05-01","2017-06-07")
data = naver.drop_duplidata(data)
data.head()

def remove_string(text):
    regex = re.compile('[%s]' % re.escape(string.punctuation))
    text = re.sub(r'\([\w]+\)',"",text)
    text = re.sub(r'\([가-힣!]+\)',"",text)
    text = re.sub(r'\([가-힣\=]+\)',"",text)
    text = text.replace("캡처","")
    text = text.replace("뉴스","")
    text = text.replace("연합뉴스","")
    text = regex.sub('', text)   
    return text

def remove_titles(text):
    text = re.sub(r'\[[가-힣\s\w\'\-\_\?]+\]',"",text)
    text  = text.replace("(003490)","")
    return text

data['contents'] = data['contents'].apply(lambda x:remove_string(x))
data['titles'] = data['titles'].apply(lambda x:remove_titles(x))

#data.to_csv("news_mac.csv",index=False, encoding='utf8')
data = pd.read_csv("news_mac.csv")


#under_comment = naver.getAllUnderComment(data)
#under_comment = naver.getComment_json(data,"mac")
#under_comment.to_csv("under_comment_mac.csv",index=False, encoding='utf8')
under_comment = pd.read_csv("mac_comments.csv")
under_comment = under_comment.sort_values(by='like', ascending = False)

tdm, cv = wordhandle.makeTDM(data['titles'], 500)
np.savez('mac_title_tdm.npz',tdm)
with open('mac_tdm_title.json',"w", encoding='utf8') as f:
    json.dump(cv.get_feature_names(),f)
    
#wordcount = wordhandle.makeWordCloud(tdm,cv)

tdm2, cv2 = wordhandle.makeTDM(data['contents'], 300)
np.savez('mac_contents_tdm.npz',tdm2)
with open('mac_tdm_contents.json',"w", encoding='utf8') as f:
    json.dump(cv2.get_feature_names(),f)
    
#wordcount2 = wordhandle.makeWordCloud(tdm2,cv2)

tdm3, cv3 = wordhandle.makeTDM(under_comment['comment'], 250)
np.savez('mac_comments_tdm.npz',tdm3)
with open('mac_tdm_comments.json',"w", encoding='utf8') as f:
    json.dump(cv3.get_feature_names(),f)

wordcount3 = wordhandle.makeWordCloud(tdm3,cv3)



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


