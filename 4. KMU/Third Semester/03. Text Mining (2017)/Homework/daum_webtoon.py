# -*- coding: utf-8 -*-
"""
Created on Fri Apr 21 00:28:01 2017

@author: byung
"""
import pandas as pd
import seaborn as sns 
import matplotlib.pyplot as plt
import requests
from bs4 import BeautifulSoup


naver_url = "http://comic.naver.com"
url = "http://comic.naver.com/webtoon/list.nhn?titleId=670152&weekday=sun&page={page}"
for i in range(1,10):
    real_url = url.format(page=i)    
    req = requests.get(real_url)
    if req.status_code == 200:
        bs = BeautifulSoup(req.text, 'html.parser')
        table_list = bs.find_all("table",class_="viewList")
        tr_list = table_list[0].find_all("tr")
        for i in range(2,len(tr_list)):
            title = tr_list[i].find_all("td")[0].find("img").attrs["alt"]
            date = tr_list[i].find_all("td")[3].text
            in_url = tr_list[i].find_all("td")[0].find('a').attrs['href']
            full_url = naver_url + in_url
            folder_name = date.replace(".","") + "_" + title
            print(folder_name)
            print(full_url)
            sub_req = requests.get(full_url)
            if sub_req.status_code == 200:
                sub_bs = BeautifulSoup(sub_req.text, 'html.parser')
                container_list = sub_bs.find_all("div",class_="wt_viewer")
                img_list = container_list[0].find_all("img")
                for j in range(len(img_list)):
                    
                    
                