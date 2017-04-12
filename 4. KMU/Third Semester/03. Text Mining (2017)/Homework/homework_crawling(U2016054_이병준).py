''' 
학번 : U2016054
기수 : 5기
이름 : 이병준
크롤링 사이트 : 구글 플레이 리뷰 (Application Replica) 
사용법 : ID와 Token만 변경해주면 다른 어플리케이션 정보도 크롤링 가능. 

정리.
우선 전체 데이터는 첫페이지 URL을 통해서 크롤링. 
리뷰 : ajax통신을 통해 크롤링.
'''
import pandas as pd
import seaborn as sns 
import matplotlib.pyplot as plt
import requests
import urllib.request
import json
import requests
import re


url = 'https://play.google.com/store/apps/details?id=com.venticake.retrica&hl=ko#details-reviews'
headers = {'User-Agent': 'Mozilla/5.0 (Windows; U; MSIE 9.0; Windows NT 9.0; en-US)'}
req = urllib.request.Request(url, headers=headers)
data = urllib.request.urlopen(req).read().decode('utf-8')
#req = requests.get(url, headers = headers)
#data = req.text

bs = BeautifulSoup(data, 'html.parser')
div_list = bs.find_all('div',class_="details-section-body expandable")

div_root_list = bs.find_all('div',class_="details-wrapper apps")

# 각 리뷰 스코오별 투표 인원 가지고 오기 
# 1~5점 각 인원, 평균, 전체 인원 
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
        
total_series = pd.Series(total_number)
total_series.to_csv("total_series.csv")

url = "https://play.google.com/store/getreviews?authuser=0"
id = 'com.venticake.retrica'
token = 'ZLqR3TmB64y6koyq8uj1tqqiQ4k:14191636750027'

# Review가지고오기.
def GetReviews(url,id,token,pages):  
    param = {'reviewType': '0', 'pageNum': '10000', 'id':'','reviewSortOrder':'4','xhr':'1','token':'','hl':'ko'}
    param['id'] = id
    param['token'] = token
    
    review_date_all = []
    review_star_all = []
    review_user_all = []
    review_title_all = []
    review_body_all = []
    for i in range(1,pages):
        param['pageNum'] = i
        res = requests.post(url, data=param)
        print(" line : {line}, code : {code}".format(line=i,code=res.status_code))
        if res.status_code == 400 or i == pages-1:
            review_df = pd.DataFrame({'DATE':review_date_all,'STAR':review_star_all,'TITLE':review_title_all, 'USER':review_user_all,'BODY':review_body_all})
            columns_list = ['DATE','USER','STAR','TITLE','BODY']
            return(review_df[columns_list])
        else:
            body = res.text[6:]
            res_json = json.loads(body)
            bs = BeautifulSoup(res_json[0][2], 'html.parser')
            review_lists = bs.find_all('div',class_="single-review")
            for j in range(1,len(review_lists)):
                review_date = review_lists[j].find('span',class_="review-date").text # review_date
                review_star = int(re.findall(r'\d+', review_lists[0].find('div',class_="tiny-star star-rating-non-editable-container")['aria-label'])[1]) # Get Digits from Rates
                review_title = review_lists[j].find('span',class_="review-title").text # title
                review_body = review_lists[j].find('div',class_="review-body with-review-wrapper").text # review body
                review_body = str.replace(review_body,review_title,"")
                review_body = str.replace(review_body,"전체 리뷰","")
                review_body = review_body.strip()
                review_user = review_lists[j].find('span',class_="author-name").text.strip()  # get Reviewer
                review_date_all.append(review_date)
                review_star_all.append(review_star)
                review_user_all.append(review_user)
                review_title_all.append(review_title)
                review_body_all.append(review_body)
                
                
DF = GetReviews(url,id,token,10000)
DF['DATE'] = pd.to_datetime(DF['DATE'],format='%Y년 %m월 %d일')
DF = DF.sort_values(by='DATE', ascending=True).reindex()   
DF.head()

DF.to_csv("Replica_review.csv")

sns.factorplot('STAR',kind='count',data=DF) # 실질적으로 1을 준 사용자도 많다. 완전히 실망하거나 만족하거나 하는 성향을 보였다.


DF[DF['STAR']==3]

# WordCloud 적용.

Under_three = DF[DF['STAR']<=3]
Over_three = DF[DF['STAR']>3]
len(Under_three) + len(Over_three)
len(DF)

under_text = Under_three['BODY']
re.sub('[^가-힣\s]',"",under_text[80])
under_text = under_text.apply(lambda x:re.sub('[^가-힣\s]',"",x))

# 형태소 분석
from konlpy.tag import Twitter
from sklearn.feature_extraction.text import CountVectorizer

# 1글자 짜리 빼기

def get_word(doc):
    nouns = tagger.nouns(doc)
    return [noun for noun in nouns if len(noun) > 1]                

cv = CountVectorizer(tokenizer=get_word, max_features=200)
tdf = cv.fit_transform(under_text)
words = cv.get_feature_names()
words

# 단어별 출현 빈도
import numpy as np 
count_mat = tdf.sum(axis=0)
count_mat
count = np.squeeze(np.asarray(count_mat))
word_count = list(zip(words, count))

# 빈도 정렬 
word_count = sorted(word_count, key=lambda t:t[1], reverse=True)

word_count2 = []
for item in word_count:
    if item[1] > 20:
        word_count2.append(item)
    

import matplotlib.pyplot as plt
from wordcloud import WordCloud

wc = WordCloud(font_path='C:\\Windows\\Fonts\\malgun.ttf', background_color='white', width=400, height=300)
cloud = wc.generate_from_frequencies(dict(word_count2))
plt.figure(figsize=(12,9))
plt.imshow(cloud)
plt.axis('off')
plt.show()