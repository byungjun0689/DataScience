#-*- coding: utf-8 -*-

# This code is supporting material for the book
# Building Machine Learning Systems with Python
# by Willi Richert and Luis Pedro Coelho
# published by PACKT Publishing
#
# It is made available under the MIT License

# 이 스크립트는 단순한 (일반) 선형 회귀의 예제를 보인다

import numpy as np
from sklearn.datasets import load_boston
from sklearn.linear_model import LinearRegression
from matplotlib import pyplot as plt

boston = load_boston()
x = boston.data
y = boston.target

# 모델 적합화는 반드시 필요하다: LinearRegression의 ``fit``를 호출한다:
lr = LinearRegression()
lr.fit(x, y)

# 인스턴스의 `residues_`에는 제곱된 잔차 합이 있다
rmse = np.sqrt(lr.residues_/len(x))
print('RMSE: {}'.format(rmse))

fig, ax = plt.subplots()
# 대각선을 그린다(참조)
ax.plot([0, 50], [0, 50], '-', color=(.9,.3,.3), lw=4)

# 실제 값과 예측 값을 그린다:
ax.scatter(lr.predict(x), boston.target)

ax.set_xlabel('predicted')
ax.set_ylabel('real')
fig.savefig('Figure_07_08.png')
