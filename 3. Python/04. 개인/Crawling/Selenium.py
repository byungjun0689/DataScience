# -*- coding: utf-8 -*-
"""
Created on Mon Apr  3 21:48:08 2017

@author: byung
"""

from selenium import webdriver
from selenium.webdriver.common.keys import Keys

url = 'https://play.google.com/store/apps/details?id=com.venticake.retrica&hl=ko#details-reviews'

driver = webdriver.Chrome(executable_path=r'D:\DataScience\chromedriver.exe')
driver.get(url)




elem = driver.find_element_by_name("q")
elem.clear()
elem.send_keys("pycon")
elem.send_keys(Keys.RETURN)

tmp = driver.page_source

assert "No results found." not in driver.page_source
driver.close()