#-*- coding: utf-8 -*-

import numpy as np
import mahotas as mh
image = mh.imread('scene00.jpg')
from matplotlib import pyplot as plt
plt.imshow(image)
plt.show()
image = mh.colors.rgb2grey(image, dtype=np.uint8)
plt.imshow(image) # Display the image
plt.gray()
thresh = mh.thresholding.otsu(image)
print('Otsu threshold is {}.'.format(thresh))
# Otsu 경계 값은 138이다
plt.imshow(image > thresh)

im16 = mh.gaussian_filter(image,16)
im = mh.demos.load('lenna')

r,g,b = im.transpose(2,0,1) 
r12 = mh.gaussian_filter(r, 12.)
g12 = mh.gaussian_filter(g, 12.)
b12 = mh.gaussian_filter(b, 12.)
im12 = mh.as_rgb(r12,g12,b12)
h, w = r.shape # 높이와 폭
Y, X = np.mgrid[:h,:w]
Y = Y-h/2. # h/2에 중앙화
Y = Y / Y.max() # -1 .. +1로 정규화

X = X-w/2.
X = X / X.max()

C = np.exp(-2.*(X**2+ Y**2))

# 다시  0..1로 정규화 
C = C - C.min()
C = C / C.ptp()
C = C[:,:,None] # C에 3번째 차원 추가

ringed = mh.stretch(im*C + (1-C)*im12)

haralick_features = mh.features.haralick(image)
haralick_features_mean = np.mean(haralick_features, axis=0)
haralick_features_all = np.ravel(haralick_features)

from glob import glob
images = glob('../SimpleImageDataset/*.jpg')
features = []
labels = []
for im in images:
  labels.append(im[:-len('00.jpg')])
  im = mh.imread(im)
  im = mh.colors.rgb2gray(im, dtype=np.uint8)
  features.append(mh.features.haralick(im).ravel())

features = np.array(features)
labels = np.array(labels)

from sklearn.pipeline import Pipeline
from sklearn.preprocessing import StandardScaler
from sklearn.linear_model import LogisticRegression
clf = Pipeline([('preproc', StandardScaler()),
                ('classifier', LogisticRegression())])


from sklearn import cross_validation
cv = cross_validation.LeaveOneOut(len(images))
scores = cross_validation.cross_val_score(
    clf, features, labels, cv=cv)
print('Accuracy: {:.1%}'.format(scores.mean()))
# Accuracy: 81.1%

def chist(im):
    im = im // 64
    r,g,b = im.transpose((2,0,1))
    pixels = 1 * r + 4 * b + 16 * g
    hist = np.bincount(pixels.ravel(), minlength=64)
    hist = hist.astype(float)
    hist = np.log1p(hist)
    return hist

features = []
for im in images:
  im = mh.imread(im)
  features.append(chist(im))



features = []
for im in images:
  imcolor = mh.imread(im)
  im = mh.colors.rgb2gray(imcolor, dtype=np.uint8)
  features.append(np.concatenate([
          mh.features.haralick(im).ravel(),
          chist(imcolor),
      ]))


scores = cross_validation.cross_val_score(
    clf, features, labels, cv=cv)
print('Accuracy: {:.1%}'.format(scores.mean()))
# Accuracy: 95.6%


features = []
for im in images:
  imcolor = mh.imread(im)
  # 외곽에 가까운 200 픽셀에 모든 것을 무히한다
  imcolor = imcolor[200:-200, 200:-200]
  im = mh.colors.rgb2gray(imcolor, dtype=np.uint8)
  features.append(np.concatenate([
          mh.features.haralick(im).ravel(),
          chist(imcolor),
      ]))

sc = StandardScaler()
features = sc.fit_transform(features)
from scipy.spatial import distance
dists = distance.squareform(distance.pdist(features))


fig, axes = plt.subplots(2, 9)
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



from sklearn.grid_search import GridSearchCV
C_range = 10.0 ** np.arange(-4, 3)
grid = GridSearchCV(LogisticRegression(), param_grid={'C' : C_range})
clf = Pipeline([('preproc', StandardScaler()),
               ('classifier', grid)])

cv = cross_validation.KFold(len(features), 5,
                     shuffle=True, random_state=123)
scores = cross_validation.cross_val_score(
   clf, features, labels, cv=cv)
print('Accuracy: {:.1%}'.format(scores.mean()))




from mahotas.features import surf
image = mh.demos.load('lena')
image = mh.colors.rgb2gray(image, dtype=np.uint8)
descriptors = surf.surf(image, descriptor_only=True)

from mahotas.features import surf
descriptors = surf.dense(image, spacing=16)
alldescriptors = []
for im in images:
  im = mh.imread(im, as_grey=True)
  im = im.astype(np.uint8)
  alldescriptors.append(surf.dense(image, spacing=16))
# 하나의 배열에서 모든 디스크립터를 구한다
concatenated = np.concatenate(alldescriptors)
print('Number of descriptors: {}'.format(
       len(concatenated)))
# 64번째 벡터를 사용
concatenated = concatenated[::64] 
from sklearn.cluster import KMeans # FIXME CAPITALIZATION
k = 256
km = KMeans(k)
km.fit(concatenated)

features = []
for d in alldescriptors:
  c = km.predict(d)
  features.append(
      np.array([np.sum(c == ci) for ci in range(k)])
  )
# build single array and convert to float
features = np.array(features, dtype=float)
scores = cross_validation.cross_val_score(
   clf, features, labels, cv=cv)
print('Accuracy: {:.1%}'.format(scores.mean()))
# Accuracy: 62.6%


