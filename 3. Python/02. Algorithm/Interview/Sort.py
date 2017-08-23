# -*- coding: utf-8 -*-
"""
Created on Wed May 24 12:44:46 2017

@author: MCR007
"""


# http://ejklike.github.io/2017/03/04/sorting-algorithms-with-python.html
import numpy as np
import datetime

np.random.seed(10)
lists = np.random.choice(10000,5000,replace=False)

tt = np.random.choice(10000,10,replace=False)
# Bubble Sort
# 이웃한 두값을 비교 왼쪽에서 오른쪽으로 정렬하는 방법.

def swap(x,i,j):
    x[i],x[j] = x[j],x[i]

def bubble(x):
    for size in reversed(range(len(x))):
        for i in range(size):
            if x[i] > x[i+1]:
                swap(x, i, i+1)

before = datetime.datetime.now()
bubble(lists)
after = datetime.datetime.now()
gap_bubble = str(after - before)
print(gap_bubble)

def selectionSort(x):
    for size in reversed(range(len(x))):
        max_i = 0
        for i in range(1, 1+size):
            if x[i] > x[max_i]:
                max_i = i
        
        swap(x,max_i,size)
        
before = datetime.datetime.now()
selectionSort(lists)
after = datetime.datetime.now()
selection_bubble = str(after - before)        
print(selection_bubble)