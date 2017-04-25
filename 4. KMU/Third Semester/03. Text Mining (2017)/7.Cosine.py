
# coding: utf-8

# # 7. 코사인 유사도 & Clustering 

# In[1]:

from urllib.parse import quote_plus

import requests
import lxml.html


# In[2]:

search_url = ('http://section.blog.naver.com/sub/SearchBlog.nhn?type=post&option.keyword={query}'
              '&option.page.currentPage={page}&option.orderBy=sim')


# In[3]:

query = quote_plus('딥러닝')
query


# In[4]:

url = search_url.format(query=query, page=2)
url


# In[5]:

res = requests.get(url)


# In[6]:

root = lxml.html.fromstring(res.text)


# In[7]:

root.cssselect('h5 a')


#  - a Class가 존재하지 않는다. 그럴때는 위에 태그를 본다. 

# In[8]:

for link in root.cssselect('h5 a'):
    print(link.text_content(), link.attrib['href'])


# ## URL 분해
#  - 크롤링에서 필요했던 내용들을 분해해서 데이터를 format으로 하면 된다. 

# In[9]:

from urllib.parse import parse_qs, urlparse


# In[10]:

result = urlparse('http://blog.naver.com/civilize?Redirect=Log&logNo=220976431562&from=section')


# In[11]:

result


# In[12]:

result.netloc


# In[13]:

result.path


# In[14]:

result.query


# In[15]:

qs = parse_qs(result.query)
qs


# In[16]:

qs['logNo'][0]


# In[17]:

post_url = 'http://blog.naver.com/PostView.nhn?blogId={}&logNo={}'.format(result.path[1:], qs['logNo'][0])


# In[18]:

post_url


# ## 게시물 내용 가져오기 

# In[19]:

post_res = requests.get(post_url)
post_root = lxml.html.fromstring(post_res.text)


# In[20]:

post_root.cssselect('div#postViewArea')[0].text_content()


# ## 블로그 스크래핑 

# In[21]:

import tqdm
from urllib.parse import urljoin


# In[22]:

keyword = '딥러닝'
query = quote_plus(keyword)


# In[23]:

search_url = ('http://section.blog.naver.com/sub/SearchBlog.nhn?type=post&option.keyword={query}'
              '&option.page.currentPage={page}&option.orderBy=sim')


# In[24]:

posts = []
for page in tqdm.tqdm_notebook(range(1, 20)):
    url = search_url.format(query=query, page=page)
    res = requests.get(url)
    root = lxml.html.fromstring(res.text)
    
    for link in root.cssselect('h5 a'):
        link_url = link.attrib['href']

        # 다른 형식의 주소는 무시
        if not link_url.startswith('http://blog.naver.com'):
            continue

        # 진짜 주소
        result = urlparse(link_url)
        blog_id = result.path[1:]
        qs = parse_qs(result.query)
        post_id = qs['logNo'][0]
        post_url = 'http://blog.naver.com/PostView.nhn?blogId={}&logNo={}'.format(blog_id, post_id)
        
        # 본문 가져오기
        post_res = requests.get(post_url)
        post_root = lxml.html.fromstring(post_res.text)
        
        try:
            body = post_root.cssselect('div#postViewArea')[0]
            posts.append(body.text_content())
        except IndexError:
            continue


# In[25]:

len(posts)


# ## CSV로 저장 

# In[26]:

import csv
import re 


# In[27]:

with open('posts.csv', 'w', encoding='utf8', newline='') as f:
    w = csv.writer(f)
    for post in posts:
        post_short = re.sub(r'\s+', ' ', post)  # 모든 종류의 공백을 빈 칸 하나로 바꿈 (엑셀에서 보기 좋게)
        w.writerow([post_short])


# ## CSV에서 불러오기 

# In[28]:

import csv


# In[29]:

posts = []
with open("posts.csv", encoding="utf8") as f:
    reader = csv.reader(f)
    for row in reader:
        post = row[0]
        if len(post) > 100:
            posts.append(post)


# In[30]:

len(posts)


# In[31]:

posts[:2]


# ## TDM 만들기 

# In[32]:

from sklearn.feature_extraction.text import CountVectorizer
from konlpy.tag import Komoran


# In[33]:

tagger = Komoran()


# In[34]:

def get_noun(text):
    nouns = tagger.nouns(text)
    return [n for n in nouns if len(n) > 1]  # 2글자 이상인 명사만 추출


# In[35]:

cv = CountVectorizer(tokenizer=tagger.nouns, max_features=100)


# In[ ]:

tdm = cv.fit_transform(posts)


# In[36]:

# tdm = cv.fit_transform(posts)


# ## T
