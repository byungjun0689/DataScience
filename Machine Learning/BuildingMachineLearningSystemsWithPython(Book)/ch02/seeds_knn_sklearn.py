#-*- coding: utf-8 -*-

# This code is supporting material for the book
# Building Machine Learning Systems with Python
# by Willi Richert and Luis Pedro Coelho
# published by PACKT Publishing
#
# It is made available under the MIT License

from __future__ import print_function
import numpy as np
from load import load_dataset


# sklearn의 KNN 임프트
from sklearn.neighbors import KNeighborsClassifier

features, labels = load_dataset('seeds')
classifier = KNeighborsClassifier(n_neighbors=4)


n = len(features)
correct = 0.0
for ei in range(n):
    training = np.ones(n, bool)
    training[ei] = 0
    testing = ~training
    classifier.fit(features[training], labels[training])
    pred = classifier.predict(features[ei])
    correct += (pred == labels[ei])
print('Result of leave-one-out: {}'.format(correct/n))

# KFold 임포트
from sklearn.cross_validation import KFold

# means에 각 중첩에 대한 평균를 저장
means = []

# 각 반복을 개별화하기 위해 kf에 (training,testing)짝을 생성하는 생성자
kf = KFold(len(features), n_folds=3, shuffle=True)
for training,testing in kf:
    # 이 중접에 훈련 데이터에 대해  `fit`을 하고 테스트 데이터로 `predict`한다:
    classifier.fit(features[training], labels[training])
    prediction = classifier.predict(features[testing])

    # 이 중첩에 대해 정확도를 반환하여 불 배열에 대해 np.mean 사용
    curmean = np.mean(prediction == labels[testing])
    means.append(curmean)
print('Result of cross-validation using KFold: {}'.format(means))

# 함수 cross_val_score는 위에 함수와 같은 작업을 한다

from sklearn.cross_validation import cross_val_score
crossed = cross_val_score(classifier, features, labels)
print('Result of cross-validation using cross_val_score: {}'.format(crossed))

# 위 결과는 크기(scale) 조정 없이 속성을 그대로 사용한다. 책에서 설명대로 전처리 할 수 있다:
from sklearn.pipeline import Pipeline
from sklearn.preprocessing import StandardScaler
classifier = Pipeline([('norm', StandardScaler()), ('knn', classifier)])
crossed = cross_val_score(classifier, features, labels)
print('Result with prescaling: {}'.format(crossed))


# 같은 결과에 대해 교차 검증 혼돈 매트릭스를 생성, 출력
from sklearn.metrics import confusion_matrix
names = list(set(labels))
labels = np.array([names.index(ell) for ell in labels])
preds = labels.copy()
preds[:] = -1
for train, test in kf:
    classifier.fit(features[train], labels[train])
    preds[test] = classifier.predict(features[test])

cmat = confusion_matrix(labels, preds)
print()
print('Confusion matrix: [rows represent true outcome, columns predicted outcome]')
print(cmat)

# 파이썬 2에서 명시적으로 float() 변환한다(그렇지 않으면 0으로 반환된다)
acc = cmat.trace()/float(cmat.sum())
print('Accuracy: {0:.1%}'.format(acc))

