'''
	Project Name : WAI (Where Am i?)
	Description : 기업 또는 어떠한 항목이던 자신의 위치 즉, Brand 평가?(현재) 인식 등 알아보는 프로젝트
	Version : v1.0
	Date : 2017-05-20
	WorkFlow : 
	  	1. User Typing Brand Or Product
	  	2. Crawling NewsData, SNS Data, Community Board Data(Clien.net)
	  	3. Making WordCloud, Rating from NewsData(Like, Dislike)
'''

import urllib.request
from urllib.parse import quote_plus
from bs4 import BeautifulSoup
import pandas as pd
import re
from konlpy.tag import Komoran
from sklearn.feature_extraction.text import CountVectorizer
import numpy as np
    
def searchNaverNews(search,frdate,todate):
    search_url = 'http://news.naver.com/main/search/search.nhn?ie=MS949&query={query}&startDate={start}&endDate={end}&page={page}'
    query = quote_plus(search.encode('euc-kr'))
    pageNumChk = re.compile(r'\([\d\,]+ ~ [\d\,]+ \/ ([\d\,]+)건\)')
    url = search_url.format(query=query,page=1,start=frdate,end=todate)
    req = urllib.request.Request(url)
    status = urllib.request.urlopen(req).status
    
    if status == 200:
        html = urllib.request.urlopen(req).read()
        soup = BeautifulSoup(html,'html.parser')
        total_page = int(int(pageNumChk.findall(soup.select('span.result_num')[0].text)[0].replace(",","")) / 10)
        title_list = []
        naver_url_list = []
        for page_num in range(2,total_page):
            url = search_url.format(query=query,page=page_num,start=frdate,end=todate)
            req = urllib.request.Request(url)
            status = urllib.request.urlopen(req).status
            if status == 200:
                html = urllib.request.urlopen(req).read()
                soup = BeautifulSoup(html,'html.parser')
                article_list = soup.find_all('ul',class_="srch_lst")
                for article in article_list:
                    article_title = article.select('div.ct a.tit')[0].text
                    naver_list = article.select('div.ct div.info a.go_naver')
                    if len(naver_list) > 0:
                        naver_href = naver_list[0]['href']    
                        title_list.append(article_title)
                        naver_url_list.append(naver_href)
    return pd.DataFrame({'titles':title_list,'url':naver_url_list})



def getContents(contents_url):
    print("getContents")
    if contents_url.startswith('http://news.naver.com'):
        replace_list = ['#','오류를 우회하기 위한 함수 추가','[]','\n','마감직전','웹 서비스 확대출시','//','function','_','flash_removeCallback','()','\t','\\','▶','flash',"\'",'페이스북','스포츠조선','현장정보','끝판왕','토토','{}',r'[\w\d]+@[\w\d.]+']
        req = urllib.request.Request(contents_url)
        status = urllib.request.urlopen(req).status
        if status == 200:
            html = urllib.request.urlopen(req).read()
            soup = BeautifulSoup(html,'html.parser')
            contents_body = soup.select('div#articleBodyContents')
            if len(contents_body) > 0:
                contents = contents_body[0].text
                contents = re.sub(r'|'.join(map(re.escape, replace_list)), '', contents)
                contents = re.sub(r'[\w\d]+@[\w\d.]+','',contents)    
                contents = re.sub(r'[\w\d]+@[\w\d.]+','',contents)    
                contents = re.sub(r'\[[\s]+바로가기\]','',contents)
                contents = re.sub(r'\[[\s]+\]','',contents)
                contents = re.sub(r'\<[\w\s\©가-힣\-]+\>','',contents)
                contents = re.sub(r'\[\ⓒ[\s가-힣\w\d]+\]','',contents)
                contents = re.sub(r'[가-힣\w\d\s]+기자','',contents)
                contents = re.sub(r'^\[\]','',contents).strip()
            else:
                contents_body = soup.select('div#articeBody')
                if len(contents_body) > 0:
                    contents = contents_body[0].text
                    contents = re.sub(r'|'.join(map(re.escape, replace_list)), '', contents)
                    contents = re.sub(r'[\w\d]+@[\w\d.]+','',contents)    
                    contents = re.sub(r'[\w\d]+@[\w\d.]+','',contents)    
                    contents = re.sub(r'\[[\s]+바로가기\]','',contents)
                    contents = re.sub(r'\[[\s]+\]','',contents)
                    contents = re.sub(r'\<[\w\s\©가-힣\-]+\>','',contents)
                    contents = re.sub(r'\[\ⓒ[\s가-힣\w\d]+\]','',contents)
                    contents = re.sub(r'[가-힣\w\d\s]+기자','',contents)
                    contents = re.sub(r'^\[\]','',contents).strip()
        return contents
    else:
        return ''
    
    
data = searchNaverNews('갤럭시8','2017-05-22','2017-05-23')
data['contents'] = data['url'].apply(lambda x:getContents(x))
data = data[data['contents']!='']
data = data.drop_duplicates(['titles'])
data = data.reset_index()
del data['index']    
data['contents'] = data['contents'].apply(lambda x:re.sub(r'^\[[\s\w가-힣\=]*\]','',x).strip())


tagger = Komoran() # 형태소 분석기
def get_noun(text):
    nouns = tagger.nouns(text)
    return [n for n in nouns if len(n) > 1] # 2글자 이상만


def makeTDM(text):
   cv = CountVectorizer(tokenizer=get_noun, max_features=1000) # 1000개의 단어를 2자 이상 단어 명사만 추출.
   tdm = cv.fit_transform(text)
   return tdm,cv


tdm,cv = makeTDM(data['contents'])

# 단어 빈도
words = cv.get_feature_names()
count_mat = tdm.sum(axis=0)
count = np.squeeze(np.asarray(count_mat))
word_count = list(zip(words,count))
word_count = sorted(word_count,key=lambda x:x[1],reverse=True)
word_count[:10]

import matplotlib.pyplot as plt
from wordcloud import WordCloud

wc = WordCloud(font_path='C:\\Windows\\Fonts\\malgun.ttf', background_color='white', width=800, height=500)
cloud = wc.generate_from_frequencies(dict(word_count[:100]))
plt.figure(figsize=(15,12))
plt.imshow(cloud)


# LDA를 이용 해서 주제 파악을 해봐야겠다.
