'''
	Project Name : WAI (Where Am i?)
	Description : 기업 또는 어떠한 항목이던 자신의 위치 즉, Brand 평가?(현재) 인식 등 알아보는 프로젝트
	Version : v1.0
	Date : 2017-05-20
	WorkFlow : 
	  	1. User Typing Brand Or Product
	  	2. Crawling NewsData, SNS Data, Community Board Data(Clien.net)
	  	3. Making WordCloud, Rating from NewsData(Like, Dislike)
'''

import Requests
from bs4 import BeautifulSoup
import pandas as pd
import numpy as np