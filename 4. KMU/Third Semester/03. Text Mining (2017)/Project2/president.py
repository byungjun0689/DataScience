
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
            
    return pd.DataFrame({'number':number_list, 'president':president_list, 'category':category_list, 'sub_category':sub_category_list,'title':title_list,'href':href_list,'date':date_list})


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


data = get_president_speech("노무현")
data.to_csv("노무현.csv",index=False, encoding='utf8')
data = pd.read_csv("노무현.csv")

contents_list = []
for i in range(len(data)):
    print(data.ix[i,'href'])
    contents = get_speech_view(data.ix[i,'href'],data.ix[i,'president'])
    contents_list.append(contents)

data['contents'] = contents_list
data.to_csv("노무현_contents.csv",index=False, encoding='utf8')
data['categroy'].unique()

# 이명박

data = get_president_speech("이명박")
data.to_csv("이명박.csv",index=False, encoding='utf8')
data = pd.read_csv("이명박.csv")

contents_list = []
for i in range(len(data)):
    print(data.ix[i,'href'])
    contents = get_speech_view(data.ix[i,'href'],data.ix[i,'president'])
    contents_list.append(contents)

data['contents'] = contents_list
data.to_csv("이명박_contents.csv",index=False, encoding='utf8')



no_pre  = pd.read_csv('노무현_contents.csv')
lee_pre = pd.read_csv('이명박_contents.csv')

cate_list = no_pre['category'].unique()
cate_list

no_pre[no_pre['category']=='외교/통상']['contents']
lee_pre[lee_pre['category']=='외교/통상']['contents']

tdm, cv = wordhandle.makeTDM(no_pre[no_pre['category']=='외교/통상']['contents'],500)
np.savez('tdm_외교_노무현.npz',tdm)
with open('tdm_외교_노무현_.json',"w", encoding='utf8') as f:
    json.dump(cv.get_feature_names(),f)

tdm2, cv2 = wordhandle.makeTDM(lee_pre[lee_pre['category']=='외교/통상']['contents'],500)
np.savez('tdm_외교_이명박.npz',tdm2)
with open('tdm_외교_이명박_.json',"w", encoding='utf8') as f:
    json.dump(cv2.get_feature_names(),f)


    
    
wordcount = wordhandle.makeWordCloud(tdm,cv)
wordcount2 = wordhandle.makeWordCloud(tdm2,cv2)


## 외교

tdm = np.load("tdm_외교_노무현.npz")
tdm = tdm['arr_0'].item()
tdm

with open('tdm_외교_노무현_.json', encoding='utf8') as f:
    words = json.load(f)
    

tdm2 = np.load("tdm_외교_이명박.npz")
tdm2 = tdm2['arr_0'].item()
tdm2

with open('tdm_외교_이명박_.json', encoding='utf8') as f:
    words2 = json.load(f)
    
    
wordcount = wordhandle.makeWordCloud(tdm,words)
wordcount2 = wordhandle.makeWordCloud(tdm2,words2)

word = [ word for word,cnt in wordcount]
cnt = [ cnt for word,cnt in wordcount]
wordcount_df = pd.DataFrame({'word':word, 'cnt':cnt})

word2 = [ word for word,cnt in wordcount2]
cnt2 = [ cnt for word,cnt in wordcount2]
wordcount2_df = pd.DataFrame({'word':word2, 'cnt':cnt2})


df = pd.merge(wordcount_df,wordcount2_df,how='inner',on='word')    
df['total'] = df['cnt_x'] + df['cnt_y']
df = df.sort_values(by='total', ascending=False)

len(df[df['total']>300])


plt.figure(figsize=(10,7))
sns.barplot(y='cnt_x',x='word',data=df[(df['cnt_x']>130) & (df['cnt_y']>180)], color='blue',alpha=.5, label='노무현')
sns.barplot(y='cnt_y',x='word',data=df[(df['cnt_x']>130) & (df['cnt_y']>180)], color='red',alpha=.5, label='이명박')
plt.xticks(rotation=90)
plt.legend()
plt.xlabel("단어",fontsize=25)
plt.ylabel("합계",fontsize=25)
plt.xticks(fontsize=15)
plt.yticks(fontsize=15)


plt.figure(figsize=(10,7))
sns.barplot(y='cnt_x',x='word',data=df[df['total']>300], color='blue',alpha=.5)
sns.barplot(y='cnt_y',x='word',data=df[df['total']>300], color='red',alpha=.5)
plt.xticks(rotation=90)


sub_cate_list = no_pre['sub_category'].unique()
sub_cate_list

no_pre[no_pre['sub_category']=='취임사']
lee_pre[lee_pre['sub_category']=='취임사']

tdm, cv = wordhandle.makeTDM(no_pre[no_pre['sub_category']=='취임사']['contents'],500)

np.savez('tdm_취임사_노무현.npz',tdm)
with open('tdm_취임사_노무현_.json',"w", encoding='utf8') as f:
    json.dump(cv.get_feature_names(),f)
    
tdm2, cv2 = wordhandle.makeTDM(lee_pre[lee_pre['sub_category']=='취임사']['contents'],500)

np.savez('tdm_취임사_이명박.npz',tdm2)
with open('tdm_취임사_이명박_.json',"w", encoding='utf8') as f:
    json.dump(cv2.get_feature_names(),f)
    
    
wordcount = wordhandle.makeWordCloud(tdm,cv.get_feature_names())
wordcount2 = wordhandle.makeWordCloud(tdm2,cv2.get_feature_names())

word = [ word for word,cnt in wordcount]
cnt = [ cnt for word,cnt in wordcount]
wordcount_df = pd.DataFrame({'word':word, 'cnt':cnt})

word2 = [ word for word,cnt in wordcount2]
cnt2 = [ cnt for word,cnt in wordcount2]
wordcount2_df = pd.DataFrame({'word':word2, 'cnt':cnt2})


df = pd.merge(wordcount_df,wordcount2_df,how='inner',on='word')    
df['total'] = df['cnt_x'] + df['cnt_y']
df = df.sort_values(by='total', ascending=False)



## 취임사
## 확실히 이명박의 경우 나라의 역할 나라, 정부의 주도의 행동을 강조하는 듯하는 모습을 보인다.
## 이와 반대적으로 노무현 대통령의 경우 대한민국, 정부 단어 언급보다는 시대적,평화 등 한번도 평화에 대한 언급이 많았다. 대화, 지리 등 한반도 정세에 대한 언급이 많다.

plt.figure(figsize=(10,7))
sns.barplot(y='cnt_x',x='word',data=df[df['total']>7], color='blue',alpha=.5)
sns.barplot(y='cnt_y',x='word',data=df[df['total']>7], color='red',alpha=.5)
plt.xticks(rotation=90)



### TF-IDF


no_pre  = pd.read_csv('노무현_contents.csv')
lee_pre = pd.read_csv('이명박_contents.csv')

no_pre[no_pre['category']=='외교/통상']['contents']
lee_pre[lee_pre['category']=='외교/통상']['contents']

tdm = np.load("tdm_외교_노무현.npz")
tdm = tdm['arr_0'].item()
tdm

with open('tdm_외교_노무현_.json', encoding='utf8') as f:
    words = json.load(f)
    
tf = TfidfTransformer(smooth_idf=False)
tf
tfidf = tf.fit_transform(tdm.toarray())

tfidf.toarray()[0]

