#-*- coding: utf-8 -*-

# This code is supporting material for the book
# Building Machine Learning Systems with Python
# by Willi Richert and Luis Pedro Coelho
# published by PACKT Publishing
#
# It is made available under the MIT License

from __future__ import print_function
import logging
import gensim
import numpy as np

NR_OF_TOPICS = 100

# 진행 정보를 얻기 위해 로그를 설정
logging.basicConfig(
    format='%(asctime)s : %(levelname)s : %(message)s',
    level=logging.INFO)

# 전처리된 말뭉치(corpus) (id2word & mm) 로드
id2word = gensim.corpora.Dictionary.load_from_text(
    'data/wiki_en_output_wordids.txt.bz2')
mm = gensim.corpora.MmCorpus('data/wiki_en_output_tfidf.mm')

# 모델을 생성하기 위해 생성자 호출, 이 함수는 시간이 많이 걸린다
model = gensim.models.ldamodel.LdaModel(
    corpus=mm,
    id2word=id2word,
    num_topics=NR_OF_TOPICS,
    update_every=1,
    chunksize=10000,
    passes=1)

# 다시 모델을 사용하기 위해 저장
model.save('wiki_lda.pkl')

# 문서/주제 매트릭스 계산
topics = np.zeros((len(mm), model.num_topics))
for di,doc in enumerate(mm):
    doc_top = model[doc]
    for ti,tv in doc_top:
        topics[di,ti] += tv
np.save('topics.npy', topics)

# 대안으로, 희소 매트릭스(sparse matrix) 생성하고 저장한다
# 디스크 공간을 절약하지만 코드가 복잡해진다

## from scipy import sparse, io
## sp = sparse.csr_matrix(topics)
## io.savemat('topics.mat', {'topics': sp})
