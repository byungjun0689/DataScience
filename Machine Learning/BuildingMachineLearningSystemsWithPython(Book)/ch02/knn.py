#-*- coding: utf-8 -*-

# This code is supporting material for the book
# Building Machine Learning Systems with Python
# by Willi Richert and Luis Pedro Coelho
# published by PACKT Publishing
#
# It is made available under the MIT License

import numpy as np

# 이 함수를 초판에서 ``learn_model``이라 함
def fit_model(k, features, labels):
    '''Learn a k-nn model'''
    # k-nn 모델은 없고 입력을 복사한다
    return k, features.copy(), labels.copy()


def plurality(xs):
    '''collection에서 가장 많은 공통으로 가진 요소을 찾는다'''
    from collections import defaultdict
    counts = defaultdict(int)
    for x in xs:
        counts[x] += 1
    maxv = max(counts.values())
    for k, v in counts.items():
        if v == maxv:
            return k

# 이 함수를 초판에서 ``apply_model``이라 함
def predict(model, features):
    '''k-nn 모델 적용'''
    k, train_feats, labels = model
    results = []
    for f in features:
        label_dist = []
        # 모든 거리 계산:
        for t, ell in zip(train_feats, labels):
            label_dist.append((np.linalg.norm(f - t), ell))
        label_dist.sort(key=lambda d_ell: d_ell[0])
        label_dist = label_dist[:k]
        results.append(plurality([ell for _, ell in label_dist]))
    return np.array(results)


def accuracy(features, labels, model):
    preds = predict(model, features)
    return np.mean(preds == labels)
