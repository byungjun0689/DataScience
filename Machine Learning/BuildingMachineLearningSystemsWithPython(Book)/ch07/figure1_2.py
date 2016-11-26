#-*- coding: utf-8 -*-

# This code is supporting material for the book
# Building Machine Learning Systems with Python
# by Willi Richert and Luis Pedro Coelho
# published by PACKT Publishing
#
# It is made available under the MIT License

import numpy as np
from sklearn.datasets import load_boston
from sklearn.linear_model import LinearRegression
from sklearn.metrics import mean_squared_error, r2_score
from matplotlib import pyplot as plt

boston = load_boston()

# 방 개수는 5번째다
fig,ax = plt.subplots()
ax.scatter(boston.data[:, 5], boston.target)
ax.set_xlabel("Average number of rooms (RM)")
ax.set_ylabel("House Price")

x = boston.data[:, 5]
# 다음은 입력으로 2차원을 사용하기 때문에 2차원을 만들기 위해 np.atleast_2d을 사용한다.
# 입력 형태를 맞추기 위해 전치한다:
x = np.transpose(np.atleast_2d(x))

y = boston.target

lr = LinearRegression(fit_intercept=False)
lr.fit(x, y)

ax.plot([0, boston.data[:, 5].max() + 1],
         [0, lr.predict(boston.data[:, 5].max() + 1)], '-', lw=4)
fig.savefig('Figure1.png')

mse = mean_squared_error(y, lr.predict(x))
rmse = np.sqrt(mse)
print('RMSE (no intercept): {}'.format(rmse))

# 이번에는 절편을 적합화한다
lr = LinearRegression(fit_intercept=True)

lr.fit(x, y)

fig,ax = plt.subplots()
ax.set_xlabel("Average number of rooms (RM)")
ax.set_ylabel("House Price")
ax.scatter(boston.data[:, 5], boston.target)
xmin = x.min()
xmax = x.max()
ax.plot([xmin, xmax], lr.predict([[xmin], [xmax]]) , '-', lw=4)
fig.savefig('Figure2.png')

mse = mean_squared_error(y, lr.predict(x))
print("Mean squared error (of training data): {:.3}".format(mse))

rmse = np.sqrt(mse)
print("Root mean squared error (of training data): {:.3}".format(rmse))

cod = r2_score(y, lr.predict(x))
print('COD (on training data): {:.2}'.format(cod))

