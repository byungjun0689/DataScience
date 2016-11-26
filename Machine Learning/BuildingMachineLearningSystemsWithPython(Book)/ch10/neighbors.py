#-*- coding: utf-8 -*-

# This code is supporting material for the book
# Building Machine Learning Systems with Python
# by Willi Richert and Luis Pedro Coelho
# published by PACKT Publishing

import numpy as np
import mahotas as mh
from glob import glob
from features import texture, color_histogram
from matplotlib import pyplot as plt
from sklearn.preprocessing import StandardScaler
from scipy.spatial import distance

basedir = '../SimpleImageDataset/'


haralicks = []
chists = []

print('Computing features...')

# 모든 이미지를 구하기 위해 glob 사용
images = glob('{}/*.jpg'.format(basedir))
# 같은 순서로 유지 하기 위해 정렬한다. 그렇지 않으면, 무작위 순서로 인해 일부 변화값을 생성한다
images.sort()

for fname in images:
    imc = mh.imread(fname)
    imc = imc[200:-200,200:-200]
    haralicks.append(texture(mh.colors.rgb2grey(imc)))
    chists.append(color_histogram(imc))

haralicks = np.array(haralicks)
chists = np.array(chists)
features = np.hstack([chists, haralicks])

print('Computing neighbors...')
sc = StandardScaler()
features = sc.fit_transform(features)
dists = distance.squareform(distance.pdist(features))

print('Plotting...')
fig, axes = plt.subplots(2, 9, figsize=(16,8))

# 모든 부분도표에서 ticks 제거
for ax in axes.flat:
    ax.set_xticks([])
    ax.set_yticks([])

for ci,i in enumerate(range(0,90,10)):
    left = images[i]
    dists_left = dists[i]
    right = dists_left.argsort()
    right = right[1]
    right = images[right]
    left = mh.imread(left)
    right = mh.imread(right)
    axes[0, ci].imshow(left)
    axes[1, ci].imshow(right)

fig.tight_layout()
fig.savefig('figure_neighbors.png', dpi=300)
