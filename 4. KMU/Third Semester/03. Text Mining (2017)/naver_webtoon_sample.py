# -*- coding: utf-8 -*-
"""
Created on Fri Apr 21 12:23:43 2017

@author: BYUNGJUN
"""

import os
import requests
from bs4 import BeautifulSoup

def crawl_naver_webtoon(episode_url):
    
    
    
    html = requests.get(episode_url).text
    soup = BeautifulSoup(html, 'html.parser')

    comic_title = ' '.join(soup.select('.comicinfo h2')[0].text.split())
    ep_title = ' '.join(soup.select('.tit_area h3')[0].text.split())

    for img_tag in soup.select('.wt_viewer img'):
        image_file_url = img_tag['src']
        #image_dir_path = os.path.join(os.path.dirname(__file__), comic_title, ep_title)
        #image_file_path = os.path.join(image_dir_path, os.path.basename(image_file_url))

        #if not os.path.exists(image_dir_path):
        #    os.makedirs(image_dir_path)
        print(image_file_url)
        print(image_file_path)

        headers = {'Referer': episode_url}
        image_file_data = requests.get("http://imgcomic.naver.net/webtoon/20853/1048/20160627141252_8d671ceddf202931b716afe33b72c69d_IMAG01_24.jpg", headers=headers).content
        open("2.jpg", 'wb').write(image_file_data)

    print('Completed !')

if __name__ == '__main__':
    episode_url = 'http://comic.naver.com/webtoon/detail.nhn?titleId=20853&no=1048&weekday=tue'
    crawl_naver_webtoon(episode_url)
    