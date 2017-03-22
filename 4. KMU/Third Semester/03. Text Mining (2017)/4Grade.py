# -*- coding: utf-8 -*-
"""
Created on Tue Mar 21 12:41:18 2017

@author: MCR007
"""

# TermDocument Matrix 

import requests
import lxml.html
import csv
import matplotlib.pyplot as plt


url = 'http://news.naver.com/main/search/search.nhn?query=%BA%F2%B5%A5%C0%CC%C5%CD&ie=MS949&x=0&y=0&page={}'
url = "http://news.naver.com/main/search/search.nhn?refresh=&so=rel.dsc&stPhoto=&stPaper=&stRelease=&ie=MS949&detail=0&rcsection=&query=%B9%DA%B1%D9%C7%FD&sm=all.basic&pd=1&startDate=&endDate="
# 박근혜 
with open('news.csv', 'w', encoding='utf8') as f:
    writer = csv.writer(f)
    for i in range(1, 21):
        res = requests.get(url.format(i))  # 기사 목록
        element = lxml.html.fromstring(res.text)
        for news_link in element.xpath('.//a[@class="go_naver"]'):
            try:
                res = requests.get(news_link.attrib['href'])   # 네이버 뉴스 링크
                news = lxml.html.fromstring(res.text)
                body = news.xpath('.//div[@id="articleBodyContents"]')[0]
                writer.writerow([body.text_content()])
            except:
                continue
            
            
news = []
with open('news.csv', encoding='utf8', newline='\r\n') as f:
    reader = csv.reader(f)
    for row in reader:
        news.append(row[0])
        
news


from konlpy.tag import Twitter
from sklearn.feature_extraction.text import CountVectorizer
tagger = Twitter()

cv = CountVectorizer(tokenizer=tagger.nouns, max_features=50)
cv

tdf = cv.fit_transform(news)
tdf

words = cv.get_feature_names()
words

# 한 글자 짜리 없애기 
def get_word(doc):
    nouns = tagger.nouns(doc)
    return [noun for noun in nouns if len(noun) > 1]
    
cv = CountVectorizer(tokenizer=get_word, max_features=50)    
tdf = cv.fit_transform(news)
words = cv.get_feature_names()
words


# 단어 출현 빈도. 
import numpy as np
count_mat = tdf.sum(axis=0) # matrix 
count_mat

# matrix -> array
count = np.squeeze(np.asarray(count_mat))
count

word_count = dict(zip(words, count))


# 빈도 순 정렬
import operator

#word_count = sorted(word_count, key=operator.itemgetter(1), reverse=True)

%matplotlib inline
from wordcloud import WordCloud
from matplotlib import pyplot
word_count.items()
wc = WordCloud(font_path='C:\\Windows\\Fonts\\malgun.ttf', background_color='white', width=400, height=300)
cloud = wc.generate_from_frequencies(word_count)

pyplot.figure(figsize=(12, 9))
pyplot.imshow(cloud)
pyplot.axis("off")


# 단어간 상관계수
word_corr = np.corrcoef(tdf.todense(), rowvar=0)


# 상관관계 높은 것 100개만 추리기

edges = []
for i in range(len(words)):
    for j in range(i + 1, len(words)):
        edges.append((words[i], words[j], word_corr[i, j]))

edges

edges = sorted(edges, key=operator.itemgetter(2), reverse=True)
edges = edges[:20]

edge_list = [(word1, word2) for word1, word2, weight in edges]
weight_list = [weight for word1, word2, weight in edges]

# 상관관계 시각화
import networkx
G = networkx.Graph()

edge_set = set()

for word1, word2, weight in edges:
    G.add_edge(word1,word2,weight=weight)
    edge_set.add((word1,word2))

position = networkx.spring_layout(G, iterations=30)
pyplot.figure(figsize=(12, 9))
networkx.draw_networkx_nodes(G, position, node_size=0)
networkx.draw_networkx_edges(G, position, edgelist=edge_list, width=weight_list, edge_color='lightgray')
networkx.draw_networkx_labels(G, position, font_size=10, font_family='Malgun Gothic')
plt.axis('off')


# 영화 평점 분석 

# 리뷰 모음
reviews = []

# 네이버 영화평 주소
url = 'http://movie.naver.com/movie/bi/mi/pointWriteFormList.nhn?code=121051&type=after&onlyActualPointYn=Y&page={}'

for page in range(100, 500):
    res = requests.get(url.format(page))
    element = lxml.html.fromstring(res.text)
    for e in element.xpath('.//div[@class="score_result"]//li'):
        star = e.find('.//div[@class="star_score"]//em').text_content()
        comment = e.find('.//div[@class="score_reple"]//p').text_content()
        reviews.append([star, comment[3:]])
        
len(reviews)

with open('naver_review.csv', 'w') as f:
    w = csv.writer(f)
    w.writerow(['star', 'comment'])
    w.writerows(reviews)


tagger = Twitter()
cv = CountVectorizer(tokenizer=get_word, max_features=1000)
tdm = cv.fit_transform([r[1] for r in reviews])
noun_list = cv.get_feature_names()

np.save('tdm.npy', tdm)
with open('nouns.txt', 'w', encoding='utf8') as f:
    f.write('\n'.join(noun_list))
    

with open('naver_review.csv', encoding='utf8') as f:
    w = csv.reader(f)
    next(w)
    reviews = list(w)
    
reviews
    
# Training Set / Test Set

from sklearn.cross_validation import train_test_split

stars = [int(r[0]) for r in reviews]
X_train, X_test, y_train, y_test = train_test_split(tdm, stars, test_size=0.2, random_state=42)

# Linear Model 
from sklearn import linear_model

lm = linear_model.LinearRegression()
lm.fit(X_train, y_train)

# 결과보기 
import operator
def get_important_words(model, positive=True, n=8):
    return sorted(list(zip(noun_list, model.coef_)), key=operator.itemgetter(1), reverse=positive)[:n]

get_important_words(lm)
get_important_words(lm, False)

lm.score(X_train, y_train)
lm.score(X_test, y_test)    


# Lasso 
lasso = linear_model.Lasso(alpha=0.01)
lasso.fit (X_train, y_train)

get_important_words(lasso)
get_important_words(lasso, False)
lasso.score(X_train, y_train)
lasso.score(X_test, y_test)


# ridge 
ridge = linear_model.Ridge(alpha=10)
ridge.fit (X_train, y_train)
get_important_words(ridge)
get_important_words(ridge, False)
ridge.score(X_train, y_train)
ridge.score(X_test, y_test)


# Elastic Net
elastic = linear_model.ElasticNetCV(l1_ratio=np.arange(.1, 1.0, .1))
elastic.fit(X_train, y_train)
elastic.alpha_

get_important_words(elastic)
get_important_words(elastic, False)


ridge_predict = ridge.predict(X_test)
ridge_predict = ridge_predict.round().astype(np.int)
from sklearn import metrics


def getResult(y_test,y_pred):
    print(metrics.confusion_matrix(y_test, y_pred))
    print('accurracy:', metrics.accuracy_score(y_test, y_pred))

getResult(y_test,ridge_predict)

    