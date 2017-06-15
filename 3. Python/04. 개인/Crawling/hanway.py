# -*- coding: utf-8 -*-
"""
Created on Fri May 19 20:21:01 2017

@author: byungjun

Title : Crawling Groupware web site to get notice & board infomation 
"""
import pandas as pd
import sqlite3
from bs4 import BeautifulSoup
from selenium import webdriver
import re
import time
import sys
# 62938
driver = webdriver.Chrome(executable_path=r'D:\DataScience\chromedriver.exe')
#driver = webdriver.PhantomJS(executable_path=r'D:\DataScience\Phantomjs.exe')
con = sqlite3.connect("hanway.db")

def login(id='',passwd=''):
    print("login hanway")
    login_url = 'https://hanway.hist.co.kr/CoviSPWeb/Login/Login.aspx'
    driver.get(login_url)
    driver.find_element_by_id('UserID').clear()
    driver.find_element_by_id('UserID').send_keys(id)
    driver.find_element_by_id('UserPWD').send_keys(passwd)
    driver.find_element_by_css_selector('.btn_login').click()
    #driver.get("https://hanway.hist.co.kr/default.aspx")

# Version 1 한웨이 메인 게시판만 긁기.
#url = "https://hanway.hist.co.kr/HanJin/Common/Template/Bulletin/SelectBulletin.aspx?MenuID=1073&TemplateID=207&BulletinID={number}"

def getMainList():
    if driver.title != '' and driver.title != 'Hanway Login':
        print("Main Page")
        req = driver.page_source
        soup = BeautifulSoup(req,'html.parser')
        root_element = soup.select('.CEPS_WP_MultiMainList div div')[0]
        titles = root_element.select('tr td')
        split_re = re.compile("\\n\[([\w가-힣]+)\]([가-힣\d\w\s\-\(\)\.]+)\\n([\d\-]+)")
        for title in titles:
            lists = split_re.findall(title.text)[0]
            print("분류 : ", lists[0])
            print("내용 : ", lists[1].lstrip())
            print("날짜 : ", lists[2])


# Version 2 세부 게시판 내용 긁기.
def detailGet():
    root_url = "https://hanway.hist.co.kr"
    #driver.find_element_by_id('tabedd01').click()
    driver.get("https://hanway.hist.co.kr/default.aspx")
    print("wait 2 seconds")
    time.sleep(2)
    allTabs = driver.find_elements_by_css_selector("ul[class='tabs']")[0]
    li_lists = allTabs.find_elements_by_css_selector("li")
    for li in li_lists:
        if "공지" in li.text:
            li.click()
    more_src = li_lists[3].find_elements_by_css_selector('a')
    more_url = more_src[0].get_attribute('href')
    driver.get(more_url)
    print("wait 2 seconds, Going to Board page")
    time.sleep(2)
    board_root_html = driver.page_source
    soup2 = BeautifulSoup(board_root_html,"html.parser")
    detail_url = soup2.find("iframe")['src']
    t_board_url = root_url + detail_url
    driver.get(t_board_url)
    print("wait 2 seconds, IFrame with board")
    time.sleep(2)
    frame = driver.find_elements_by_css_selector("iframe")
    driver.switch_to_frame(frame[1])    
    print("wait 2 seconds, Last iframe in Board Page")
    time.sleep(2)
    board_detail = driver.page_source
    soup3 = BeautifulSoup(board_detail,"html.parser")
    tr_list = soup3.select('tbody tr')
    for tr in tr_list[1:]:
        td_list = tr.find_all('td')
        print("제목 :", td_list[0].text)
        print("분류 :", td_list[2].text)
        print("일자 :", td_list[3].text)
        print("작성자 :", td_list[4].text)
        print("조회수 :", td_list[5].text)

if __name__ == '__main__':
    if len(sys.argv) != 3:
        print("Needs hanway id & passwd")
        exit()
    if sys.argv[1] == 'help':
        print("argv[0] : id ")
        print("argv[1] : passwd")
        exit()
    login(id=sys.argv[1],passwd=sys.argv[2])
    getMainList()
    detailGet()
