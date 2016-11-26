#-*- coding: utf-8 -*-

# This code is supporting material for the book
# Building Machine Learning Systems with Python
# by Willi Richert and Luis Pedro Coelho
# published by PACKT Publishing
#
# It is made available under the MIT License

# 이 스크립트는 (홀드-아웃) 테스트 정확도와 훈련 정확도의 차이를 설명한다  

import numpy as np
from sklearn.datasets import load_iris
from threshold import fit_model, accuracy

data = load_iris()
features = data['data']
labels = data['target_names'][data['target']]

# setosa 예제 제거
is_setosa = (labels == 'setosa')
features = features[~is_setosa]
labels = labels[~is_setosa]

# virginica vs non-virginica 분류한다
is_virginica = (labels == 'virginica')

# 테스트와 훈련 데이터로 나눈다
testing = np.tile([True, False], 50) # testing = [True,False,True,False,True,False...]

# 테스트 데이터르 훈련 데이터로 사용한다
training = ~testing

model = fit_model(features[training], is_virginica[training])
train_accuracy = accuracy(features[training], is_virginica[training], model)
test_accuracy = accuracy(features[testing], is_virginica[testing], model)

print('''\
Training accuracy was {0:.1%}.
Testing accuracy was {1:.1%} (N = {2}).
'''.format(train_accuracy, test_accuracy, testing.sum()))
