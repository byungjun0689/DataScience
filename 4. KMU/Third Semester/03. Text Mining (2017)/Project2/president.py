# -*- coding: utf-8 -*-
"""
Created on Sat Jun 10 13:48:50 2017

@author: BYUNGJUN
"""
import pandas as pd
from bs4 import BeautifulSoup
from selenium import webdriver
import requests
import re
from urllib.parse import parse_qs, urlparse
import wordhandle


driver = webdriver.Chrome(executable_path=r'D:\DataScience\chromedriver.exe')

url = "http://www.pa.go.kr/research/contents/speech/index.jsp"

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
    for page in range(1,1000):
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
            
    return pd.DataFrame({'number':number_list, 'president':president_list, 'categroy':category_list, 'sub_category':sub_category_list,'title':title_list,'href':href_list,'date':date_list})
            
data = get_president_speech("김대중")

data.to_csv("김대중.csv",index=False)
data = pd.read_csv("김대중.csv", encoding='cp949')

get_speech_view(data.ix[0,'href'], '김대중')

def get_speech_view(view_url,president):
    #print(view_url)
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

#data['contents'] = data.apply(lambda x:get_speech_view(data['href'],data['president']), axis=1)

contents_list = []
for i in range(len(data)):
    print(data.ix[i,'href'])
    contents = get_speech_view(data.ix[i,'href'],data.ix[i,'president'])
    contents_list.append(contents)

data['contents'] = contents_list

data.to_csv("김대중_contents.csv",index=False, encoding='utf8')

tdm, cv = wordhandle.makeTDM(data['contents'],500)