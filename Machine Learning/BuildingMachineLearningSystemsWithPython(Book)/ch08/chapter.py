#-*- coding: utf-8 -*-

import numpy as np # NOT IN BOOK
from matplotlib import pyplot as plt # NOT IN BOOK

def load():
    import numpy as np
    from scipy import sparse

    data = np.loadtxt('data/ml-100k/u.data')
    ij = data[:, :2]
    ij -= 1  # 원본 데이터는 1-기반 시스템이다
    values = data[:, 2]
    reviews = sparse.csc_matrix((values, ij.T)).astype(float)
    return reviews.toarray()
reviews = load()
U,M = np.where(reviews)
import random
test_idxs = np.array(random.sample(range(len(U)), len(U)//10))

train = reviews.copy()
train[U[test_idxs], M[test_idxs]] = 0

test = np.zeros_like(reviews)
test[U[test_idxs], M[test_idxs]] = reviews[U[test_idxs], M[test_idxs]]

class NormalizePositive(object):
    def __init__(self, axis=0):
        self.axis = axis

    def fit(self, features, y=None):
        if self.axis == 1:
            features = features.T
        #  축 0에서 0보다 큰 속성을 센다
        binary = (features > 0)

        count0 = binary.sum(axis=0)

        # 0으로 나눌 것을 피하기 위해, 0을 1로 설정
        count0[count0 == 0] = 1.

        # 평균을 구한다
        self.mean = features.sum(axis=0)/count0

        # only consider differences where binary is True:
        # binary가 True의 차를 구한다:
        diff = (features - self.mean) * binary
        diff **= 2
        # 0.1을 더하여 std의 추정을 정규화한다
        self.std = np.sqrt(0.1 + diff.sum(axis=0)/count0)
        return self


    def transform(self, features):
        if self.axis == 1:
          features = features.T
        binary = (features > 0)
        features = features - self.mean
        features /= self.std
        features *= binary
        if self.axis == 1:
          features = features.T
        return features

    def inverse_transform(self, features, copy=True):
        if copy:
            features = features.copy()
        if self.axis == 1:
          features = features.T
        features *= self.std
        features += self.mean
        if self.axis == 1:
          features = features.T
        return features

    def fit_transform(self, features):
        return self.fit(features).transform(features)


norm = NormalizePositive(axis=1)
binary = (train > 0)
train = norm.fit_transform(train)
# 200x200 크기로 그린다
plt.imshow(binary[:200, :200], interpolation='nearest')

from scipy.spatial import distance
# 모든 짝 단위로 거리를 계산한다
dists = distance.pdist(binary, 'correlation')

# dists[i,j]는 binary[i]와 binary[j]의 거리ry[j]:
dists = distance.squareform(dists)
neighbors = dists.argsort(axis=1)

# 이 매트릭스에 결과를 넣는다
filled = train.copy()
for u in range(filled.shape[0]):
    # n_u는 사용자의 이웃이다
    n_u = neighbors[u, 1:]
    for m in range(filled.shape[1]):
        # 관련 리뷰를 구한다
        revs = [train[neigh, m]
                   for neigh in n_u
                        if binary    [neigh, m]]
        if len(revs):
            # n은 이 영화에 대한 리뷰의 개수이다
            n = len(revs)
            # 리뷰를 반으로 나누고 1를 더한다
            n //= 2
            n += 1
            revs = revs[:n]
            filled[u,m] = np.mean(revs)

predicted = norm.inverse_transform(filled)
from sklearn import metrics
r2 = metrics.r2_score(test[test > 0], predicted[test > 0])
print('R2 score (binary neighbors): {:.1%}'.format(r2))

reviews = reviews.T
# 이전 코드를 사용한다
r2 = metrics.r2_score(test[test > 0], predicted[test > 0])
print('R2 score (binary movie neighbors): {:.1%}'.format(r2))


from sklearn.linear_model import ElasticNetCV # NOT IN BOOK

reg = ElasticNetCV(alphas=[
                       0.0125, 0.025, 0.05, .125, .25, .5, 1., 2., 4.])
filled = train.copy()
# 모든 사용자에 대한 반복
for u in range(train.shape[0]):
    curtrain = np.delete(train, u, axis=0)
    bu = binary[u]
    reg.fit(curtrain[:,bu].T, train[u, bu])
    filled[u, ~bu] = reg.predict(curtrain[:,~bu].T)
predicted = norm.inverse_transform(filled)
r2 = metrics.r2_score(test[test > 0], predicted[test > 0])
print('R2 score (user regression): {:.1%}'.format(r2))


# 장바구니 분석
# 이는 느린 코드다. 시간이 걸리다

from collections import defaultdict
from itertools import chain

# 파일은 압축된 채다
import gzip
# 한 줄에 '12 34 342 5...' 형태로 트랜젝션이 있다.
dataset = [[int(tok) for tok in line.strip().split()]
       for line in gzip.open('data/retail.dat.gz')]
dataset = [set(d) for d in dataset]
# 각 제품을 구매한지 센다
counts = defaultdict(int)
for elem in chain(*dataset):
    counts[elem] += 1

minsupport = 80
valid = set(k for k,v in counts.items() if (v >= minsupport))
itemsets = [frozenset([v]) for v in valid]
freqsets = []
for i in range(16):
    nextsets = []
    tested = set()
    for it in itemsets:
        for v in valid:
           if v not in it:
               # v에 it를 추가하여 새로운 후보 집합 생성
               c = (it | frozenset([v]))
               # 이전에 테스트 했는지 확인:
               if c in tested:
                    continue
               tested.add(c)

               # 데이터셋에 대해 반복하여 support 세기
               # 이 단계는 느리다
               # 좀 더 나은 구현물은 `apriori.py`을 확인한다
               support_c = sum(1 for d in dataset if d.issuperset(c))
               if support_c > minsupport:
                    nextsets.append(c)
    freqsets.extend(nextsets)
    itemsets = nextsets
    if not len(itemsets):
        break
print("Finished!")


minlift = 5.0
nr_transactions = float(len(dataset))
for itemset in freqsets:
    for item in itemset:
        consequent = frozenset([item])
        antecedent = itemset-consequent
        base = 0.0
        # acount: 선례의 카운트
        acount = 0.0

        # ccount : 결과의 카운트
        ccount = 0.0
        for d in dataset:
          if item in d: base += 1
          if d.issuperset(itemset): ccount += 1
          if d.issuperset(antecedent): acount += 1
        base /= nr_transactions
        p_y_given_x = ccount/acount
        lift = p_y_given_x / base
        if lift > minlift:
            print('Rule {0} ->  {1} has lift {2}'
                  .format(antecedent, consequent,lift))
