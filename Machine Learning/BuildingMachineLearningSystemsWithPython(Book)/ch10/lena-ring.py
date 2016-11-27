#-*- coding: utf-8 -*-

# This code is supporting material for the book
# Building Machine Learning Systems with Python
# by Willi Richert and Luis Pedro Coelho
# published by PACKT Publishing
#
# It is made available under the MIT License

import mahotas as mh
import numpy as np

# 이미지를 읽는다
im = mh.demos.load('lena')

# 이미지를 RGB 채널로 나눈다
r, g, b = im.transpose(2, 0, 1)
h, w = r.shape

# 각 채널마다 이미지를 smooth
r12 = mh.gaussian_filter(r, 12.)
g12 = mh.gaussian_filter(g, 12.)
b12 = mh.gaussian_filter(b, 12.)

# RGB 이미지로 다시 생성
im12 = mh.as_rgb(r12, g12, b12)

X, Y = np.mgrid[:h, :w]
X = X - h / 2.
Y = Y - w / 2.
X /= X.max()
Y /= Y.max()

# 배열 C는 중심에 가잔 높은 값을 가진다.

C = np.exp(-2. * (X ** 2 + Y ** 2))
C -= C.min()
C /= C.ptp()
C = C[:, :, None]

# 최종 결과는 외곽에는 부드럽게, 중심에는 선명하다
ring = mh.stretch(im * C + (1 - C) * im12)
mh.imsave('lena-ring.jpg', ring)
