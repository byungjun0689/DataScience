#-*- coding: utf-8 -*-

# This code is supporting material for the book
# Building Machine Learning Systems with Python
# by Willi Richert and Luis Pedro Coelho
# published by PACKT Publishing
#
# It is made available under the MIT License

from __future__ import print_function
from wordcloud import create_cloud
try:
    from gensim import corpora, models, matutils
except:
    print("import gensim failed.")
    print()
    print("Please install it")
    raise

import matplotlib.pyplot as plt
import numpy as np
from os import path

NUM_TOPICS = 100

# 데이터가 있는지 확인
if not path.exists('./data/ap/ap.dat'):
    print('Error: Expected data to be present at data/ap/')
    print('Please cd into ./data & run ./download_ap.sh')

# 데이터 로드
corpus = corpora.BleiCorpus('./data/ap/ap.dat', './data/ap/vocab.txt')

# 주제 모델 생성
model = models.ldamodel.LdaModel(
    corpus, num_topics=NUM_TOPICS, id2word=corpus.id2word, alpha=None)

# 모델에서 모든 주제에 대해 반복
for ti in range(model.num_topics):
    words = model.show_topic(ti, 64)
    tf = sum(f for f, w in words)
    with open('topics.txt', 'w') as output:
        output.write('\n'.join('{}:{}'.format(w, int(1000. * f / tf)) for f, w in words))
        output.write("\n\n\n")

# 가장 높은 가중치 주제로, 주제 명시
topics = matutils.corpus2dense(model[corpus], num_terms=model.num_topics)
weight = topics.sum(1)
max_topic = weight.argmax()


# 이 주제에 대한 상위 64 단어 구하기
# 아규먼트가 없으면, show_topic는 10 단어를 반환한다
words = model.show_topic(max_topic, 64)

# 이 함수는 pytagcloud가 설치 되었는지 확인
create_cloud('cloud_blei_lda.png', words)

num_topics_used = [len(model[doc]) for doc in corpus]
fig,ax = plt.subplots()
ax.hist(num_topics_used, np.arange(42))
ax.set_ylabel('Nr of documents')
ax.set_xlabel('Nr of topics')
fig.tight_layout()
fig.savefig('Figure_04_01.png')


# alpha=1.0을 사용하여 반복한다
# 이 매개변수로 다음 코드를 변경할 수 있다
ALPHA = 1.0

model1 = models.ldamodel.LdaModel(
    corpus, num_topics=NUM_TOPICS, id2word=corpus.id2word, alpha=ALPHA)
num_topics_used1 = [len(model1[doc]) for doc in corpus]

fig,ax = plt.subplots()
ax.hist([num_topics_used, num_topics_used1], np.arange(42))
ax.set_ylabel('Nr of documents')
ax.set_xlabel('Nr of topics')

# The coordinates below were fit by trial and error to look good
ax.text(9, 223, r'default alpha')
ax.text(26, 156, 'alpha=1.0')
fig.tight_layout()
fig.savefig('Figure_04_02.png')

