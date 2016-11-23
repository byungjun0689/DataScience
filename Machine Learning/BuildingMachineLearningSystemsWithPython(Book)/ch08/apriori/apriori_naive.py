#-*- coding: utf-8 -*-

# This code is supporting material for the book
# Building Machine Learning Systems with Python
# by Willi Richert and Luis Pedro Coelho
# published by PACKT Publishing
#
# It is made available under the MIT License

from collections import defaultdict
from itertools import chain
from gzip import GzipFile
minsupport = 80

dataset = [[int(tok) for tok in line.strip().split()]
           for line in GzipFile('retail.dat.gz')]

counts = defaultdict(int)
for elem in chain(*dataset):
    counts[elem] += 1

# 최소한 minsupport 를 가진 원소를 고려
valid = set(el for el, c in counts.items() if (c >= minsupport))

# 유효한 원소를 포함하도록 데이터셋을 분별한다
dataset = [[el for el in ds if (el in valid)] for ds in dataset]

# 빠른 처리를 위해 frozenset을 변환
dataset = [frozenset(ds) for ds in dataset]

itemsets = [frozenset([v]) for v in valid]
freqsets = itemsets[:]
for i in range(16):
    print("At iteration {}, number of frequent baskets: {}".format(
        i, len(itemsets)))
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


def rules_from_itemset(itemset, dataset, minlift=1.):
    nr_transactions = float(len(dataset))
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

for itemset in freqsets:
    if len(itemset) > 1:
        rules_from_itemset(itemset, dataset, minlift=4.)
