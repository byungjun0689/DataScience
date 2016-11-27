#-*- coding: utf-8 -*-

# This code is supporting material for the book
# Building Machine Learning Systems with Python
# by Willi Richert and Luis Pedro Coelho
# published by PACKT Publishing
#
# It is made available under the MIT License

import numpy as np

def all_correlations(y, X):
    from scipy import spatial
    y = np.atleast_2d(y)
    sp = spatial.distance.cdist(X, y, 'correlation')
    # "correlation distance"는 1 - corr(x,y)
    return 1 - sp.ravel()

# 책에 있는 함수 (초판):
def all_correlations_book_version(bait, target):
    '''
    corrs = all_correlations(bait, target)

    corrs[i] is the correlation between bait and target[i]
    '''
    return np.array(
        [np.corrcoef(bait, c)[0, 1]
         for c in target])

# 이 함수는 빠르지만 이해하기 쉽지 않다:
def all_correlations_fast_no_scipy(y, X):
    '''
    Cs = all_correlations(y, X)

    Cs[i] = np.corrcoef(y, X[i])[0,1]
    '''
    X = np.asanyarray(X, float)
    y = np.asanyarray(y, float)
    xy = np.dot(X, y)
    y_ = y.mean()
    ys_ = y.std()
    x_ = X.mean(1)
    xs_ = X.std(1)
    n = float(len(y))
    ys_ += 1e-5  # Handle zeros in ys
    xs_ += 1e-5  # Handle zeros in x

    return (xy - x_ * y_ * n) / n / xs_ / ys_


