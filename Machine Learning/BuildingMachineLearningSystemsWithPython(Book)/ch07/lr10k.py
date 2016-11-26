#-*- coding: utf-8 -*-

# This code is supporting material for the book
# Building Machine Learning Systems with Python
# by Willi Richert and Luis Pedro Coelho
# published by PACKT Publishing
#
# It is made available under the MIT License

import numpy as np
from sklearn.metrics import mean_squared_error, r2_score
from sklearn.datasets import load_svmlight_file
from sklearn.linear_model import LinearRegression
from sklearn.cross_validation import KFold

# 데이터 로드:
data, target = load_svmlight_file('data/E2006.train')

lr = LinearRegression()

# 완벽한 score를 구하기 위해 설명할 수 있는 훈련 데이터에 대해 오차 계산

lr.fit(data, target)
pred = lr.predict(data)

print('RMSE on training, {:.2}'.format(np.sqrt(mean_squared_error(target, pred))))
print('R2 on training, {:.2}'.format(r2_score(target, pred)))
print('')

pred = np.zeros_like(target)
kf = KFold(len(target), n_folds=5)
for train, test in kf:
    lr.fit(data[train], target[train])
    pred[test] = lr.predict(data[test])

print('RMSE on testing (5 fold), {:.2}'.format(np.sqrt(mean_squared_error(target, pred))))
print('R2 on testing (5 fold), {:.2}'.format(r2_score(target, pred)))
