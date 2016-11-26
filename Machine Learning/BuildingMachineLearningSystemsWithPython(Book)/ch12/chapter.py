#-*- coding: utf-8 -*-

from jug import TaskGenerator
from glob import glob
import mahotas as mh
@TaskGenerator
def compute_texture(im):   
    from features import texture
    imc = mh.imread(im)
    return texture(mh.colors.rgb2gray(imc))

@TaskGenerator
def chist_file(fname):
    from features import chist
    im = mh.imread(fname)
    return chist(im)

import numpy as np
to_array = TaskGenerator(np.array)
hstack = TaskGenerator(np.hstack)

haralicks = []
chists = []
labels = []

# 데이터셋이 있는 위치로 변경한다
basedir = '../SimpleImageDataset/'
# 모든 이미지를 구하기 위해 glob 사용한다
images = glob('{}/*.jpg'.format(basedir))

for fname in sorted(images):
    haralicks.append(compute_texture(fname))
    chists.append(chist_file(fname))
    labels.append(fname[:-len('00.jpg')])

haralicks = to_array(haralicks)
chists = to_array(chists)
labels = to_array(labels)

@TaskGenerator
def accuracy(features, labels):
    from sklearn.linear_model import LogisticRegression
    from sklearn.pipeline import Pipeline
    from sklearn.preprocessing import StandardScaler
    from sklearn import cross_validation
    
    clf = Pipeline([('preproc', StandardScaler()),
                ('classifier', LogisticRegression())])
    cv = cross_validation.LeaveOneOut(len(features))
    scores = cross_validation.cross_val_score(
        clf, features, labels, cv=cv)
    return scores.mean()
scores_base = accuracy(haralicks, labels)
scores_chist = accuracy(chists, labels)

combined = hstack([chists, haralicks])
scores_combined  = accuracy(combined, labels)

@TaskGenerator
def print_results(scores):
    with open('results.image.txt', 'w') as output:
        for k,v in scores:
            output.write('Accuracy [{}]: {:.1%}\n'.format(
                k, v.mean()))

print_results([
        ('base', scores_base),
        ('chists', scores_chist),
        ('combined' , scores_combined),
        ])

@TaskGenerator
def compute_lbp(fname):
    from mahotas.features import lbp
    imc = mh.imread(fname)
    im = mh.colors.rgb2grey(imc)
    return lbp(im, radius=8, points=6)

lbps = []
for fname in sorted(images):
    #  이전처럼 반복을 처리한다
    lbps.append(compute_lbp(fname))
lbps = to_array(lbps)

scores_lbps = accuracy(lbps, labels)
combined_all = hstack([chists, haralicks, lbps])
scores_combined_all = accuracy(combined_all, labels)

print_results([
        ('base', scores_base),
        ('chists', scores_chist),
        ('lbps', scores_lbps),
        ('combined' , scores_combined),
        ('combined_all' , scores_combined_all),
        ])
