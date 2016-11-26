#-*- coding: utf-8 -*-

# This code is supporting material for the book
# Building Machine Learning Systems with Python
# by Willi Richert and Luis Pedro Coelho
# published by PACKT Publishing
#
# It is made available under the MIT License


from matplotlib import pyplot as plt
import numpy as np

# sklearn의 load_iris로 데이터 로드한다
from sklearn.datasets import load_iris
data = load_iris()

# load_iris는 몇개의 필드를 가진 객체를 반환한다
features = data.data
feature_names = data.feature_names
target = data.target
target_names = data.target_names

for t in range(3):
 if t == 0:
     c = 'r'
     marker = '>'
 elif t == 1:
     c = 'g'
     marker = 'o'
 elif t == 2:
     c = 'b'
     marker = 'x'
 plt.scatter(features[target == t,0], 
            features[target == t,1],
            marker=marker,
            c=c)
# 문자열 배열를 얻기 위해 NumPy 인덱싱 사용한다
labels = target_names[target]

# 꽃잎 길이는 두 번째 속성이다 
plength = features[:, 2]

# 불 배열 생성
is_setosa = (labels == 'setosa')

# 이 단계가 중요하다:
max_setosa =plength[is_setosa].max()
min_non_setosa = plength[~is_setosa].min()
print('Maximum of setosa: {0}.'.format(max_setosa))

print('Minimum of others: {0}.'.format(min_non_setosa))

# ~ 는 불 부정 연산자
features = features[~is_setosa]
labels = labels[~is_setosa]
# 새로운 목적 변수 생성, is_virigina
is_virginica = (labels == 'virginica')

# 가장 작은 best_acc 초기화
best_acc = -1.0
for fi in range(features.shape[1]):
    # 모든 경계 값에 대해 테스트
    thresh = features[:,fi]
    for t in thresh:

        # 속성 `fi`에 대한 벡터를 구한다
        feature_i = features[:, fi]
        # 경계 값 `t`를 적용한다
        pred = (feature_i > t)
        acc = (pred == is_virginica).mean()
        rev_acc = (pred == ~is_virginica).mean()
        if rev_acc > acc:
            reverse = True
            acc = rev_acc
        else:
            reverse = False

        if acc > best_acc:
            best_acc = acc
            best_fi = fi
            best_t = t
            best_reverse = reverse

print(best_fi, best_t, best_reverse, best_acc)

def is_virginica_test(fi, t, reverse, example):
    '새로운 예제에 대한 경계 모델 적용'
    test = example[fi] > t
    if reverse:
        test = not test
    return test
from threshold import fit_model, predict

# 훈련 정확도는 96.0%였다.
# 테스트 정확도는 90.0%(N = 50)였다
correct = 0.0

for ei in range(len(features)):
    # `ei` 위치를 제외한 모두를 선택한다:
    training = np.ones(len(features), bool)
    training[ei] = False
    testing = ~training
    model = fit_model(features[training], is_virginica[training])
    predict(model, features[testing])
    predictions = predict(model, features[testing])
    correct += np.sum(predictions == is_virginica[testing])
acc = correct/float(len(features))
print('Accuracy: {0:.1%}'.format(acc))


###########################################
############## SEEDS DATASET ##############
###########################################

from load import load_dataset

feature_names = [
    'area',
    'perimeter',
    'compactness',
    'length of kernel',
    'width of kernel',
    'asymmetry coefficien',
    'length of kernel groove',
]
features, labels = load_dataset('seeds')



from sklearn.neighbors import KNeighborsClassifier
classifier = KNeighborsClassifier(n_neighbors=1)
from sklearn.cross_validation import KFold

kf = KFold(len(features), n_folds=5, shuffle=True)
means = []
for training,testing in kf:
   # 이 중첩에 대해 모델을 적합화하고 predict로 데이터를 테스트한다
   classifier.fit(features[training], labels[training])
   prediction = classifier.predict(features[testing])

   # 이 중첩에서 정확히 예측한 것에 대해 불 배열에 넣고 np.mean 한다:
   curmean = np.mean(prediction == labels[testing])
   means.append(curmean)
print('Mean accuracy: {:.1%}'.format(np.mean(means)))


from sklearn.pipeline import Pipeline
from sklearn.preprocessing import StandardScaler

classifier = KNeighborsClassifier(n_neighbors=1)
classifier = Pipeline([('norm', StandardScaler()), ('knn', classifier)])



means = []
for training,testing in kf:
   # 이 중첩에 대해 모델을 적합화하고 predict로 데이터를 테스트한다
   classifier.fit(features[training], labels[training])
   prediction = classifier.predict(features[testing])

   # 이 중첩에서 정확히 예측한 것에 대해 불 배열에 넣고 np.mean 한다:
   curmean = np.mean(prediction == labels[testing])
   means.append(curmean)
print('Mean accuracy: {:.1%}'.format(np.mean(means)))
