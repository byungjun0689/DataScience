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


# 다음 전체 건수 나누기 하는 걸찾아서 해야된다. 
def searchDaumNews(search,frdate,todate):
    frdate = frdate.replace("-","")+"000000"
    todate = todate.replace("-","")+"235959"
    headers = {'User-Agent': 'Mozilla/5.0 (Windows; U; MSIE 9.0; Windows NT 9.0; en-US)'}
    search_url = "http://search.daum.net/search?w=news&sort=recency&q={query}&cluster=n&DA=STC&s=NS&a=STCF&dc=STC&pg=1&r=1&p=1&rc=1&at=more&sd={start}&ed={end}&period=u"
    query = quote_plus(search.encode('utf-8'))    
    url = url = search_url.format(query=query,page=1,start=frdate,end=todate)
    req = urllib.request.Request(url, headers=headers)
    status = urllib.request.urlopen(req).status
    if status==200:
        html = urllib.request.urlopen(req).read().decode('utf-8')
        soup = BeautifulSoup(html,'html.parser')
        article_list = soup.select('ul#newsResultUL li div.cont_inner')
        for article in article_list:
            daum_news_list = article.select('a.f_nb')
            if len(daum_news_list) > 0:
                article_title = article.select('a.f_link_b')[0].text
                daum_href=daum_news_list[0]['href']
                print(article_title)
                print(daum_href)
                

searchDaumNews("갤럭시","2017-05-22","2017-05-24")

headers = {'User-Agent': 'Mozilla/5.0 (Windows; U; MSIE 9.0; Windows NT 9.0; en-US)'}
url ="http://search.daum.net/search?w=news&sort=recency&q=%EA%B0%A4%EB%9F%AD%EC%8B%9C&cluster=n&DA=STC&s=NS&a=STCF&dc=STC&pg=1&r=1&p=1&rc=1&at=more&sd=20170522000000&ed=20170524235959&period=u"
req = urllib.request.Request(url, headers=headers)
status = urllib.request.urlopen(req).status
if status==200:
    html = urllib.request.urlopen(req).read().decode('utf-8')
    soup = BeautifulSoup(html,'html.parser')

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

def drop_duplidata(data):
    data['contents'] = data['url'].apply(lambda x:getContents(x))
    data = data[data['contents']!='']
    data = data.drop_duplicates(['titles'])
    data = data.reset_index()
    del data['index']    
    data['contents'] = data['contents'].apply(lambda x:re.sub(r'^\[[\s\w가-힣\=]*\]','',x).strip())    
    return data

data = drop_duplidata(data)


def get_noun(text):
    tagger = Komoran() # 형태소 분석기
    nouns = tagger.nouns(text)
    return [n for n in nouns if len(n) > 1] # 2글자 이상만

def makeTDM(text):
   cv = CountVectorizer(tokenizer=get_noun, max_features=1000) # 1000개의 단어를 2자 이상 단어 명사만 추출.
   tdm = cv.fit_transform(text)
   return tdm,cv


tdm,cv = makeTDM(data['contents'])


def makeWordFrequency(tdm,cv):
    # 단어 빈도
    words = cv.get_feature_names()
    count_mat = tdm.sum(axis=0)
    count = np.squeeze(np.asarray(count_mat))
    word_count = list(zip(words,count))
    word_count = sorted(word_count,key=lambda x:x[1],reverse=True)
    print(word_count[:10])
    return word_count

word_count = makeWordFrequency(tdm,cv)

import matplotlib.pyplot as plt
from wordcloud import WordCloud

wc = WordCloud(font_path='C:\\Windows\\Fonts\\malgun.ttf', background_color='white', width=800, height=500)
cloud = wc.generate_from_frequencies(dict(word_count[:100]))
plt.figure(figsize=(15,12))
plt.imshow(cloud)


# LDA를 이용 해서 주제 파악을 해봐야겠다.






url = "http://news.naver.com/main/read.nhn?mode=LSD&mid=shm&sid1=105&oid=293&aid=0000019884"
req = urllib.request.Request(url)
html = urllib.request.urlopen(req).read()
soup = BeautifulSoup(html,'html.parser')

soup.select('div#cbox_module')