#-*- coding: utf-8 -*-

# This code is supporting material for the book
# Building Machine Learning Systems with Python
# by Willi Richert and Luis Pedro Coelho
# published by PACKT Publishing
#
# It is made available under the MIT License

from sklearn.datasets import load_iris
data = load_iris()
features = data.data
labels = data.target_names[data.target]


is_setosa = (labels == 'setosa')
features = features[~is_setosa]
labels = labels[~is_setosa]
is_virginica = (labels == 'virginica')


# 가장 작은 best_acc 초기화
best_acc = -1.0

# 모든 속성에 대한 반복
for fi in range(features.shape[1]):
    # 속성 fi에 대한 모든 경계 값 테스트
    thresh = features[:, fi].copy()

    thresh.sort()
    for t in thresh:

        # t을 경계 값으로 예측 생성
        pred = (features[:, fi] > t)

        # 정확도는 정확히 맞은 예측 비율
        acc = (pred == is_virginica).mean()

        acc_neg = ((~pred) == is_virginica).mean()
        if acc_neg > acc:
            acc = acc_neg
            negated = True
        else:
            negated = False

        # 이전 최상 값보다 좋다면, 갱신한다

        if acc > best_acc:
            best_acc = acc
            best_fi = fi
            best_t = t
            best_is_negated = negated

print('Best threshold is {0} on feature {1} (index {2}), which achieves accuracy of {3:.1%}.'.format(
    best_t, data.feature_names[best_fi], best_fi, best_acc))
