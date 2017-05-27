# -*- coding: utf-8 -*-
"""
Created on Sat May 27 02:07:23 2017

@author: BYUNGJUN
"""

import urllib.request
from urllib.parse import quote_plus
from bs4 import BeautifulSoup
import pandas as pd
import re
from konlpy.tag import Komoran
from sklearn.feature_extraction.text import CountVectorizer
import numpy as np
from selenium import webdriver
import time

driver = webdriver.Chrome(executable_path=r'D:\DataScience\chromedriver.exe')
#driver = webdriver.PhantomJS(executable_path=r'D:\DataScience\Phantomjs.exe') 실제적으로 할때는 팬텀 사용.

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
    
data = searchNaverNews('딥러닝','2017-05-24','2017-05-27')

def getUnderComments(contents_url):
    driver.get(contents_url)
    time.sleep(2)
    comments_count = int(driver.find_element_by_xpath("//span[@class='u_cbox_count']").text)
    T_comment = []
    T_recomment_cnt = []
    T_unlike = []
    T_like = []
    if comments_count > 0:
        driver.find_element_by_xpath("//a[@data-param='favorite']").click() # 호감순 클릭.
        comments = driver.find_elements_by_xpath("//div[@class='u_cbox_content_wrap']/ul[@class='u_cbox_list']/li[@*]")
        for comment in comments:
            comment_text = comment.find_element_by_class_name("u_cbox_contents").text
            under_comment_box = comment.find_element_by_class_name("u_cbox_tool")
            comment_like = int(under_comment_box.find_element_by_class_name('u_cbox_cnt_recomm').text)
            comment_unlike = int(under_comment_box.find_element_by_class_name('u_cbox_cnt_unrecomm').text)
            comment_re_cnt = int(under_comment_box.find_element_by_class_name('u_cbox_reply_cnt').text)
            T_comment.append(comment_text)
            T_recomment_cnt.append(comment_re_cnt)
            T_unlike.append(comment_unlike)
            T_like.append(comment_like)
    return pd.DataFrame({'url':contents_url,'comment':T_comment,'recom_cnt':T_recomment_cnt,'unlike':T_unlike,'like':T_like})
            
com_df = getUnderComments(data.iloc[0,1])