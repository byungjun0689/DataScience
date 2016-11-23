#-*- coding: utf-8 -*-

# This code is supporting material for the book
# Building Machine Learning Systems with Python
# by Willi Richert and Luis Pedro Coelho
# published by PACKT Publishing
#
# It is made available under the MIT License

import numpy as np
import mahotas as mh

# 이 스크립트는 두 예제로 이미지를 생성한다

text = mh.imread("../SimpleImageDataset/text21.jpg")
building = mh.imread("../SimpleImageDataset/building00.jpg")
h, w, _ = text.shape
canvas = np.zeros((h, 2 * w + 128, 3), np.uint8)
canvas[:, -w:] = building
canvas[:, :w] = text
canvas = canvas[::4, ::4]
mh.imsave('figure10.jpg', canvas)
