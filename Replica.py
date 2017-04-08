# -*- coding: utf-8 -*-
"""
Created on Mon Apr  3 16:53:55 2017

@author: byung
"""

import pandas as pd 
import numpy as np 
import matplotlib.pyplot as plt 
import seaborn as sns 
import datetime as dt
import urllib.request 
from bs4 import BeautifulSoup
from selenium import webdriver
from selenium.webdriver.common.keys import Keys

elem = driver.find_element_by_name("q")
elem.clear()
elem.send_keys("pycon")
elem.send_keys(Keys.RETURN)

tmp = driver.page_source

assert "No results found." not in driver.page_source
driver.close()



url = 'https://play.google.com/store/apps/details?id=com.venticake.retrica&hl=ko#details-reviews'

driver = webdriver.Chrome(executable_path=r'D:\DataScience\chromedriver.exe')
driver.get(url)
#req = urllib.request.Request(url)
#data = urllib.request.urlopen(req).read().decode('utf-8')

data = driver.page_source
bs = BeautifulSoup(data, 'html.parser')

#div_list = bs.find_all('div',class_="details-section-body expandable")
#for div in div_list:
#    print(div.find_all('div', class_='multicol-column'))
    
#div_list[1].find_all('div',class_="")

#bs.find_all('div',class_="details-wrapper apps")[0].find_all('div', class_="rating-box")


# Rating Total 
div_root_list = bs.find_all('div',class_="details-wrapper apps")

for div_list in div_root_list:
    rating = div_list.find_all('div',class_="rating-box")
    if len(rating)>0:
        total_num = rating[0].find_all('span', class_="reviews-num")[0].text
        avg = rating[0].find_all("div",class_="score")[0].text
        score_detail = rating[0].find_all("div",class_="rating-histogram")[0].find_all('div',class_="rating-bar-container")
        total_number = {}
        for score in score_detail:
            label = score.find('span',class_="bar-label").text.strip()
            label_number = score.find('span',class_="bar-number").text
            total_number[label] = label_number
        total_number['avg'] = avg
        total_number['total'] = total_num
            
#content_list = div_root_list[0].find_all('div',class_="details-section-body expandable")
#len(content_list[0].find_all('div',class_="single-review"))
#div_root_list[0].find_all('div',class_="expand-pages-container")

content_list = bs.find_all('div',class_="details-wrapper apps")
if len(content_list) > 0:
    content_list[0].find_all('div', class_="expand-page")    


tmp = content_list[0].find_all('div', class_="expand-page")    
tmp2 = tmp[9].find_all('div',class_="single-review")
len(tmp2)
tmp2[0].find('span',class_="review-date").text  #Review Date
tmp2[0].find('div',class_="tiny-star star-rating-non-editable-container")['aria-label'] # Review Rating (total / now) Extract
str.replace(tmp2[0].find('div',class_="review-body").text,"전체 리뷰","")

content_list[0].find_all('button',class_="expand-button expand-next")
driver.find_element_by_class_name('expand-button expand-next')

driver.findElement(By.cssSelector(".alert.alert-success");
driver.findElement(By.className("expand-button expand-next"));







#### lxml
import lxml.html
import requests

url = 'https://play.google.com/store/apps/details?id=com.venticake.retrica&hl=ko#details-reviews'

 res = requests.get(url)
 root = lxml.html.fromstring(res.text)
 root[:100]
 tmp = root.cssselect('div.main-content')
 tmp
 tmp[0].text
 
 
 
    titles = root.cssselect('a.go_naver')
    for title in titles:
        article_url = title.attrib['href']
        art_res = requests.get(article_url)
        art_root = lxml.html.fromstring(art_res.text)
        body = art_root.cssselect('#articleBodyContents')[0]
        articles.append(body.text_content())




# ajax
import json
url = "https://play.google.com/store/getreviews?authuser=0"
param = {'reviewType': '0', 
         'pageNum': '2', 
         'id':'com.venticake.retrica',
         'reviewSortOrder':'4',
         'xhr':'1',
         'token':'ZLqR3TmB64y6koyq8uj1tqqiQ4k:14191636750027',
         'hl':'ko'}

r = requests.post(url, data=param)
r.text[len(r.text)-1000:len(r.text)]

for i in range(1,10):
    param['pageNum'] = i
    r = requests.post(url, data=param)
    print(i)
    print(r.text[len(r.text)-1000:len(r.text)])

param

json.loads(r.text)


