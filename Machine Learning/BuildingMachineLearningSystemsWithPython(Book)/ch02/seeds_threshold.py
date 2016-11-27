#-*- coding: utf-8 -*-

# This code is supporting material for the book
# Building Machine Learning Systems with Python
# by Willi Richert and Luis Pedro Coelho
# published by PACKT Publishing
#
# It is made available under the MIT License

from load import load_dataset
import numpy as np
from threshold import fit_model, accuracy

features, labels = load_dataset('seeds')

# 불 배열로 라벨로 저장
labels = (labels == 'Canadian')

error = 0.0
for fold in range(10):
    training = np.ones(len(features), bool)

    training[fold::10] = 0

    # 훈련 데이터에서 테스트 데이터로 구별
    testing = ~training

    model = fit_model(features[training], labels[training])
    test_error = accuracy(features[testing], labels[testing], model)
    error += test_error

error /= 10.0

print('Ten fold cross-validated error was {0:.1%}.'.format(error))
