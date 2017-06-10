# -*- coding: utf-8 -*-
"""
Created on Sat Jun 10 15:44:06 2017

@author: BYUNGJUN
"""

from gevent import monkey
import pandas as pd
from bs4 import BeautifulSoup
from selenium import webdriver
import requests
import re
from urllib.parse import parse_qs, urlparse
import sys
import gevent
import time

def get_speech_view(view_url,president):
    #print(view_url)
    time.sleep(2)
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

if __name__ == '__main__':
    if len(sys.argv) < 2:
        print("대통령을 입력")
        exit
    
    president = sys.argv[1]
    filename = president + ".csv"
    df = pd.read_csv(filename, encoding='cp949')
    href_list = list(df['href'])
    number = 1
    num_file = str(number) + ".csv"
    
    monkey.patch_all()
    threads = [gevent.spawn(get_speech_view, href,president) for href in href_list]
    a = gevent.joinall(threads)
    print(type(a))
    dd = pd.DataFrame([thread.value for thread in threads])
    
    dd.to_csv("tmp.csv",index=False)
    
    
    
    