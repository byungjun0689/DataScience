#-*- coding: utf-8 -*-

# This code is supporting material for the book
# Building Machine Learning Systems with Python
# by Willi Richert and Luis Pedro Coelho
# published by PACKT Publishing
#
# It is made available under the MIT License

from __future__ import print_function
import numpy as np
import gensim
from os import path
from wordcloud import create_cloud

if not path.exists('wiki_lda.pkl'):
    import sys
    sys.stderr.write('''\
This script must be run after wikitopics_create.py!

That script creates and saves the LDA model (this must onlly be done once).
This script is responsible for the analysis.''')
    sys.exit(1)

# 전처리된 위키피디아 말뭉치(id2word and mm) 모드
id2word = gensim.corpora.Dictionary.load_from_text(
    'data/wiki_en_output_wordids.txt.bz2')
mm = gensim.corpora.MmCorpus('data/wiki_en_output_tfidf.mm')

# 전처리된 모델 로드
model = gensim.models.ldamodel.LdaModel.load('wiki_lda.pkl')

topics = np.load('topics.npy', mmap_mode='r')

# 각 문서에서 언급된 주제 개수 계산
lens = (topics > 0).sum(axis=1)
print('Mean number of topics mentioned: {0:.3}'.format(np.mean(lens)))
print('Percentage of articles mentioning less than 10 topics: {0:.1%}'.format(np.mean(lens <= 10)))

# Weights는 각 주제의 총 가중치
weights = topics.sum(0)

# 단어 클아우드로 최대로 사용한 주제 찾기와 그리기
words = model.show_topic(weights.argmax(), 64)

# 매개변수 ``maxsize``로 보기좋게 만든다.
create_cloud('Wikipedia_most.png', words, maxsize=250, fontname='Cardo')

fraction_mention = np.mean(topics[:,weights.argmax()] > 0)
print("The most mentioned topics is mentioned in {:.1%} of documents.".format(fraction_mention))
total_weight = np.mean(topics[:,weights.argmax()])
print("It represents {:.1%} of the total number of words.".format(total_weight))
print()
print()
print()

#  단어 클아우드로 최소로 사용한 주제 찾기와 그리기
words = model.show_topic(weights.argmin(), 64)
create_cloud('Wikipedia_least.png', words, maxsize=150, fontname='Cardo')
fraction_mention = np.mean(topics[:,weights.argmin()] > 0)
print("The least mentioned topics is mentioned in {:.1%} of documents.".format(fraction_mention))
total_weight = np.mean(topics[:,weights.argmin()])
print("It represents {:.1%} of the total number of words.".format(total_weight))
print()
print()
print()
