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
import re
import os
import urllib.request

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
            date = date.replace(".","")
            directory = "d:\webtoon\\"+date
            if os.path.isdir(directory) == False:
                os.makedirs(directory) 
                in_url = tr_list[i].find_all("td")[0].find('a').attrs['href']
                full_url = naver_url + in_url
                folder_name = date + "_" + title
                sub_req = requests.get(full_url)
                headers = {'Referer': full_url}
                if sub_req.status_code == 200:
                    sub_bs = BeautifulSoup(sub_req.text, 'html.parser')
                    container_list = sub_bs.find_all("div",class_="wt_viewer")
                    img_list = re.findall(r"src=\"http\:\/\/imgcomic\.naver\.net\/webtoon\/([\d]+)\/([\d]+)\/([\d_\w]+.jpg)",str(container_list[0]))                    
                    for j in range(len(img_list)):
                        first = img_list[j][0]
                        second = img_list[j][1]
                        file_name = img_list[j][2]
                        file_name_url_base = "http://imgcomic.naver.net/webtoon/{first_digit}/{second_digit}/{file}"
                        file_name_url = file_name_url_base.format(first_digit=first,second_digit=second,file=file_name)
                        img_res = requests.get(file_name_url)
                        tmp_file = img_list[j][2].split("_")
                        save_file_name = tmp_file[2] + "_" + tmp_file[3]
                        directory_full = directory + "\\"+ save_file_name
                        image_file_data = requests.get(file_name_url, headers=headers).content
                        with open(directory_full, 'wb') as f:
                            f.write(image_file_data)
                            
                            



## 기기괴괴

naver_url = "http://comic.naver.com"
url = "http://comic.naver.com/webtoon/list.nhn?titleId=557672&weekday=thu&page={page}"

for i in range(1,2):
    real_url = url.format(page=i)    
    req = requests.get(real_url)
    if req.status_code == 200:
        bs = BeautifulSoup(req.text, 'html.parser')
        table_list = bs.find_all("table",class_="viewList")
        tr_list = table_list[0].find_all("tr")
        for i in range(2,len(tr_list)):
            title = tr_list[i].find_all("td")[0].find("img").attrs["alt"]
            date = tr_list[i].find_all("td")[3].text 
            date = date.replace(".","")
            directory = "d:\webtoon\기기괴괴\\"+date
            if os.path.isdir(directory) == False:
                os.makedirs(directory) 
                in_url = tr_list[i].find_all("td")[0].find('a').attrs['href']
                full_url = naver_url + in_url
                folder_name = date + "_" + title
                sub_req = requests.get(full_url)
                headers = {'Referer': full_url}
                if sub_req.status_code == 200:
                    sub_bs = BeautifulSoup(sub_req.text, 'html.parser')
                    for img_list in sub_bs.select('.wt_viewer img'):
                        file_name_url = img_list['src']
                        save_file_name = file_name_url.split("/")[6].split("_")[2] + "_" + file_name_url.split("/")[6].split("_")[3]
                        directory_full = directory + "\\"+ save_file_name
                        image_file_data = requests.get(file_name_url, headers=headers).content
                        with open(directory_full, 'wb') as f:
                            f.write(image_file_data)


    