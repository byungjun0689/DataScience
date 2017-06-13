
# -*- coding: utf-8 -*-
"""
Created on Sat Jun 10 13:48:50 2017

@author: BYUNGJUN
"""
import pandas as pd
from bs4 import BeautifulSoup
import requests
import re
from urllib.parse import parse_qs, urlparse
import wordhandle
import numpy as np
import json
from sklearn.feature_extraction.text import TfidfTransformer
import matplotlib.pyplot as plt # for basic plots
import seaborn as sns # for nicer plots
from gensim.matutils import Sparse2Corpus
from gensim.models.ldamodel import LdaModel
from collections import Counter
    

from matplotlib import font_manager, rc
font_name = font_manager.FontProperties(fname="c:/Windows/Fonts/malgun.ttf").get_name()
rc('font', family=font_name)



# http://geference.blogspot.kr/2011/12/blog-post.html
# http://statkclee.github.io/politics/text-mb-gh.html
# http://slownews.kr/60919

def get_president_speech(president):
    getstatus = re.compile(r"([\d]+)")
    url = "http://www.pa.go.kr/research/contents/speech/index.jsp"  
    number_list = []
    president_list = []
    category_list = []
    sub_category_list = []
    title_list = []
    href_list = []
    date_list = []
    f_header = {'User-Agent':':Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.36','Origin':'http://www.pa.go.kr'}
    f_data = {'pageIndex': '1', 'damPst': '김대중', 'pageUnit':20}
    f_data['damPst'] = president  
    res = requests.post(url, data=f_data, headers=f_header)
    soup = BeautifulSoup(res.text,'html.parser')
    max_count = int(re.findall(r'([\d]+)',soup.find("p",class_="boardCount").text)[0])
    pages = int(max_count / 20) + 1
    for page in range(1,pages):
        print(page)
        header = {'User-Agent':':Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.36','Origin':'http://www.pa.go.kr'}
        data = {'pageIndex': '1', 'damPst': '김대중', 'pageUnit':20}
        data['pageIndex'] = page
        data['damPst'] = president
        res = requests.post(url, data=data, headers=header)
        print(res)
        if int(getstatus.findall(str(res))[0]) == 200:
            soup = BeautifulSoup(res.text,'html.parser')
            table_body = soup.find("tbody")
            rows_table = table_body.find_all("tr")
            for row in rows_table:
                td_list = row.find_all('td')
                try:
                    number = td_list[0].text
                    president = td_list[1].text
                    category = td_list[2].text
                    sub_categroy = td_list[3].text
                    title = td_list[4].text
                    href = td_list[4].find("a")['href']
                    date = td_list[5].text
                    number_list.append(number)
                    president_list.append(president)
                    category_list.append(category)
                    sub_category_list.append(sub_categroy)
                    title_list.append(title)
                    href_list.append(href)
                    date_list.append(date)
                except:
                    pass
        else:
            print("빠잉")
    
    tmp_df = pd.DataFrame({'number':number_list, 'president':president_list, 'category':category_list, 'sub_category':sub_category_list,'title':title_list,'href':href_list,'date':date_list})       
    file_name = president + "_speech.csv"
    tmp_df.to_csv(file_name, index=False, encoding='utf8')
    return tmp_df


def get_speech_view(view_url,president):
    #print(view_url)
    try:
        getstatus = re.compile(r"([\d]+)")
        header = {'User-Agent':':Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.36','Origin':'http://www.pa.go.kr'}
        view_url = 'http://www.pa.go.kr/research/contents/speech/index.jsp' + view_url
        url = 'http://www.pa.go.kr/research/contents/speech/index.jsp'
        result = urlparse(view_url)
        qs = parse_qs(result.query)
        view_data = {'spMode': qs['spMode'][0], 'artid': qs['artid'][0], 'catid':qs['catid'][0], 'pageIndex':1, 'damPst':president,'damPst0':president,'pageUnit':20}
        view_res = requests.post(url, data=view_data, headers=header)
        if int(getstatus.findall(str(view_res))[0]) == 200: 
            soup = BeautifulSoup(view_res.text,'html.parser')
            speech_body = soup.find("div",class_='boardView')
            speech_content = speech_body.find('div',class_='conTxt').text
        
        return speech_content
    except:
        return []


def get_speech_view_list(data,president):
    
    contents_list = []
    for i in range(len(data)):
        print(data.ix[i,'href'])
        contents = get_speech_view(data.ix[i,'href'],data.ix[i,'president'])
        contents_list.append(contents)
    
    data['contents'] = contents_list
    file_name = president+"_contents.csv"
    data.to_csv(file_name,index=False, encoding='utf8')
    return data


def get_speech_category(data):
    return data['category'].unique()

def get_speech_subcategory(data):
    return data['sub_category'].unique()


def get_president_tdm(data,category,maximum):
    if len(data[data['category']==category]) < 1:
        print("Category 또는 데이터 이상.")
        exit 
    else:
        tdm, cv = wordhandle.makeTDM(data[data['category']==category]['contents'],maximum)
        president_name = data['president'].unique()[0]
        
        file_name = npz_file_name = "tdm_" + category + "_" + president_name
        npz_file_name = file_name + ".npz"
        np.savez(npz_file_name,tdm)
        json_file_name = file_name + ".json"
        with open(json_file_name,"w", encoding='utf8') as f:
            json.dump(cv.get_feature_names(),f)
        
    return tdm, cv

def get_president_sub_tdm(data,sub_category,maximum):
    if len(data[data['sub_category']==sub_category]) < 1:
        print("sub_category 또는 데이터 이상.")
        exit 
    else:
        tdm, cv = wordhandle.makeTDM(data[data['sub_category']==sub_category]['contents'],maximum)
        president_name = data['president'].unique()[0]
        
        file_name = npz_file_name = "tdm_sub_" + sub_category + "_" + president_name
        npz_file_name = file_name + ".npz"
        np.savez(npz_file_name,tdm)
        json_file_name = file_name + ".json"
        with open(json_file_name,"w", encoding='utf8') as f:
            json.dump(cv.get_feature_names(),f)
        
    return tdm, cv

def two_wordcount_df(wordcount1, wordcount2):
    word = [ word for word,cnt in wordcount1]
    cnt = [ cnt for word,cnt in wordcount1]
    wordcount_df = pd.DataFrame({'word':word, 'cnt':cnt})
    
    word2 = [ word for word,cnt in wordcount2]
    cnt2 = [ cnt for word,cnt in wordcount2]
    wordcount2_df = pd.DataFrame({'word':word2, 'cnt':cnt2})
    
    
    df = pd.merge(wordcount_df,wordcount2_df,how='inner',on='word')    
    df['total'] = df['cnt_x'] + df['cnt_y']
    df = df.sort_values(by='total', ascending=False)
    
    return df


def get_compare_words_view(df,label_x,label_y,category):
    if category=="취임사":
        df_x_quantail = df['cnt_x'].describe()[5]
        df_y_quantail = df['cnt_y'].describe()[5]
    else:
        df_x_quantail = df['cnt_x'].describe()[6]
        df_y_quantail = df['cnt_y'].describe()[6]
    
    plt.figure(figsize=(15,9))
    sns.barplot(y='cnt_x',x='word',data=df[(df['cnt_x']>df_x_quantail) | (df['cnt_y']>df_y_quantail)], color='blue',alpha=.5, label=label_x)
    sns.barplot(y='cnt_y',x='word',data=df[(df['cnt_x']>df_x_quantail) | (df['cnt_y']>df_y_quantail)], color='red',alpha=.5, label=label_y)
    plt.xticks(rotation=90)
    plt.legend()
    plt.xlabel("단어",fontsize=20)
    plt.ylabel("합계",fontsize=20)
    plt.xticks(fontsize=12)
    plt.yticks(fontsize=12)    
    plt.title("연설문 : " + category, fontsize=30)
 
def get_lda_topic(tdm, words,num_topics):
    corpus = Sparse2Corpus(tdm.T)
    lda = LdaModel(corpus=corpus, num_topics=num_topics,id2word=dict(enumerate(words)), random_state=1234)
    total = Counter()
    num = tdm.shape[0]
    words_num = tdm.shape[1]
    for n in range(num):
        doc = [(i, tdm[n,i]) for i in range(words_num)]
        topics = lda.get_document_topics(doc)
        for topic,ratio in topics:
            total[topic] += ratio
    
    total = sorted(total.items(), key=lambda x:x[1], reverse=True)
    
    return lda, total