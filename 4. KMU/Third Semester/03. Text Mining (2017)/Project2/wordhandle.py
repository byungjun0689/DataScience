# -*- coding: utf-8 -*-
"""
Created on Wed May 31 21:10:30 2017

@author: byung
"""
from konlpy.tag import Komoran
from sklearn.feature_extraction.text import CountVectorizer
import numpy as np
import matplotlib.pyplot as plt
from wordcloud import WordCloud

def get_noun(text):
    tagger = Komoran() # 형태소 분석기
    nouns = tagger.nouns(text)
    return [n for n in nouns if len(n) > 1] # 2글자 이상만

def makeTDM(text, max_feature):
   cv = CountVectorizer(tokenizer=get_noun, max_features=max_feature) # 1000개의 단어를 2자 이상 단어 명사만 추출.
   tdm = cv.fit_transform(text)
   return tdm,cv

def makeWordFrequency(tdm,words):
    # 단어 빈도
    #words = cv.get_feature_names()
    count_mat = tdm.sum(axis=0)
    count = np.squeeze(np.asarray(count_mat))
    word_count = list(zip(words,count))
    word_count = sorted(word_count,key=lambda x:x[1],reverse=True)
    print(word_count[:10])
    return word_count

def makeWordCloud(tdm,words):
    word_count = makeWordFrequency(tdm,words)

    wc = WordCloud(font_path='C:\\Windows\\Fonts\\malgun.ttf', background_color='white', width=800, height=500)
    cloud = wc.generate_from_frequencies(dict(word_count[:100]))
    plt.figure(figsize=(15,12))
    plt.imshow(cloud)
    return word_count



