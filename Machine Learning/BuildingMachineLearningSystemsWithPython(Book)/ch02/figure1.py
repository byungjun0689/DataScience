#-*- coding: utf-8 -*-

# This code is supporting material for the book
# Building Machine Learning Systems with Python
# by Willi Richert and Luis Pedro Coelho
# published by PACKT Publishing
#
# It is made available under the MIT License

from matplotlib import pyplot as plt

# sklearn의 load_iris로 데이터 로드한다
from sklearn.datasets import load_iris

# load_iris는 몇가지 필드를 가진 객체를 반환한다
data = load_iris()
features = data.data
feature_names = data.feature_names
target = data.target
target_names = data.target_names

fig,axes = plt.subplots(2, 3)
pairs = [(0, 1), (0, 2), (0, 3), (1, 2), (1, 3), (2, 3)]

# 3 가지 짝을 설정한다
color_markers = [
        ('r', '>'),
        ('g', 'o'),
        ('b', 'x'),
        ]
for i, (p0, p1) in enumerate(pairs):
    ax = axes.flat[i]

    for t in range(3):
        # 각 범주 `t`에 대해 다른 color/marker 사용한다
        c,marker = color_markers[t]
        ax.scatter(features[target == t, p0], features[
                    target == t, p1], marker=marker, c=c)
    ax.set_xlabel(feature_names[p0])
    ax.set_ylabel(feature_names[p1])
    ax.set_xticks([])
    ax.set_yticks([])
fig.tight_layout()
fig.savefig('figure1.png')
