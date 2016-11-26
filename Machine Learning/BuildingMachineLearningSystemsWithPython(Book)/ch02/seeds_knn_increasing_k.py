#-*- coding: utf-8 -*-

# This code is supporting material for the book
# Building Machine Learning Systems with Python
# by Willi Richert and Luis Pedro Coelho
# published by PACKT Publishing
#
# It is made available under the MIT License

from __future__ import print_function
import numpy as np
from matplotlib import pyplot as plt
from load import load_dataset


from sklearn.neighbors import KNeighborsClassifier

from sklearn.cross_validation import cross_val_score
from sklearn.pipeline import Pipeline
from sklearn.preprocessing import StandardScaler


features, labels = load_dataset('seeds')

# k를 고려함: 1 .. 160
ks = np.arange(1,161)

# 이웃 기본 개수로 분류기 객체 생성
classifier = KNeighborsClassifier()
classifier = Pipeline([('norm', StandardScaler()), ('knn', classifier)])

# accuracies에 결과를 저장
accuracies = []
for k in ks:
    # 분류기 parameter(매개변수) 설정
    classifier.set_params(knn__n_neighbors=k)
    crossed = cross_val_score(classifier, features, labels)

    # 평균 저장
    accuracies.append(crossed.mean())

accuracies = np.array(accuracies)

# 분수대신 %정확도 그리기
plt.plot(ks, accuracies*100)
plt.xlabel('Value for k (nr. of neighbors)')
plt.ylabel('Accuracy (%)')
plt.savefig('figure6.png')
