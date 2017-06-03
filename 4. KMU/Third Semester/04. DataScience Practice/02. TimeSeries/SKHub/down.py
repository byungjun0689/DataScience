# -*- coding: utf-8 -*-
"""
Created on Sat Jun  3 14:20:51 2017

@author: BYUNGJUN
"""

from selenium import webdriver
import urllib.request
from urllib.parse import quote_plus
from bs4 import BeautifulSoup
import pandas as pd
import time

login_url = "https://www.bigdatahub.co.kr/index.do"
driver = webdriver.Chrome(executable_path=r'D:\DataScience\chromedriver.exe')

driver.get(login_url)
try:
    driver.find_element_by_xpath("//img[@class='close_layer']").click()
except:
    print("없당")
    
driver.find_element_by_xpath("//img[@alt='Login']").click()
time.sleep(5)

driver.find_element_by_xpath("//input[@class='id_input text']").clear()
driver.find_element_by_xpath("//input[@class='id_input text']").send_keys('bjlee0689')
driver.find_element_by_xpath("//input[@name='password']").clear()
driver.find_element_by_xpath("//input[@name='password']").send_keys('dpsehfvls1!')
driver.find_element_by_xpath("//img[@src='/images/btn/btn_login.gif']").click()

time.sleep(3)
try:
    driver.find_element_by_xpath("//img[@class='close_layer']").click()
except:
    print("없당")
    
driver.find_element_by_xpath("//img[@src='/images/tit/tit_main_popularity.gif']").click()
driver.find_element_by_xpath("//img[@src='/images/icon/icon_cal01.gif']").click()