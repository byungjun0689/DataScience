# -*- coding: utf-8 -*-
"""
Created on Thu Apr 20 22:32:03 2017

@author: BYUNGJUN
"""

import pandas as pd
import seaborn as sns 
import matplotlib.pyplot as plt
import requests
import urllib.request
import json
import requests
import re
from bs4 import BeautifulSoup

url = "http://www.lohbs.co.kr/lohbs_store.jsp"

url = 'https://play.google.com/store/apps/details?id=com.venticake.retrica&hl=ko#details-reviews'
req = urllib.request.Request(url)
data = urllib.request.urlopen(req).read().decode('utf-8')

bs = BeautifulSoup(data, 'html.parser')
div_list = bs.find_all('table',class_="store_info")
div_root_list = div_list[0].find_all('tr')
gu = []
for i in range(1,len(div_root_list)):
    td_list = div_root_list[i].find_all('td')
    city = td_list[1].text
    if city == "서울특별시":
        print(td_list[2].text.split(" ")[1])    
        gu.append(td_list[2].text.split(" ")[1])
        
gu_df = pd.DataFrame({"gu":gu})

pd.DataFrame(gu_df['gu'].value_counts()).to_csv("gu.csv")


