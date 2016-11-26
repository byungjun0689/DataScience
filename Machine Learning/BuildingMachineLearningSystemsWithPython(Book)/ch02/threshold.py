#-*- coding: utf-8 -*-

# This code is supporting material for the book
# Building Machine Learning Systems with Python
# by Willi Richert and Luis Pedro Coelho
# published by PACKT Publishing
#
# It is made available under the MIT License

import numpy as np


# 이 함수를 초판에서 ``learn_model``이라 함
def fit_model(features, labels):
    '''단순한 경계 값 모델'''
    best_acc = -1.0
    # 모든 속성에 대한 반목:
    for fi in range(features.shape[1]):
        thresh = features[:, fi].copy()
        # 모든 속성 값 테스트:
        thresh.sort()
        for t in thresh:
            pred = (features[:, fi] > t)

            # 정확도 측정 
            acc = (pred == labels).mean()

            rev_acc = (pred == ~labels).mean()
            if rev_acc > acc:
                acc = rev_acc
                reverse = True
            else:
                reverse = False
            if acc > best_acc:
                best_acc = acc
                best_fi = fi
                best_t = t
                best_reverse = reverse

    # 모델은 경계 값과 인덱스이다
    return best_t, best_fi, best_reverse


# 이 함수를 초판에서 ``apply_model``이라 함
def predict(model, features):
    '''학습한 모델을 적용'''
    # 모델은 fit_model로 반환한 짝(pair)이다.
    t, fi, reverse = model
    if reverse:
        return features[:, fi] <= t
    else:
        return features[:, fi] > t

def accuracy(features, labels, model):
    '''모델의 정확도 계산'''
    preds = predict(model, features)
    return np.mean(preds == labels)
