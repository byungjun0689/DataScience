# -*- coding: utf-8 -*-
"""
Created on Thu Apr  6 12:16:13 2017

@author: MCR007
"""


# Ch2. Perceptron
# 다수의 신호를 받아 하나의 신호로 출력하는 것.
# 신호를 받아 정보를 전달하는데 그것이 활성화 됐다 안됐다 표현해주는 것.(1/0)
# Ex) x1, x2 : 입력 w1,w2 가중치 @(THeta) : 임계값.

# w1x1 + w2x2 > @ : 1
# w1x1 + w2x2 <= @ : 0
# AND Gate 

param_list = [[0,0],[1,0],[0,1],[1,1]]

def AND(x1,x2):
    w1, w2, theta = 0.5,0.5,0.7
    tmp = w1 * x1 + w2 * x2 
    if tmp <= theta:
        return 0
    else:
        return 1


for param in param_list:
    print(param)    
    print(AND(param[0],param[1]))

# 가중치 편향 도입
# w1x1 + w2x2 > @ : 1
# w1x1 + w2x2 <= @ : 0
# 식에서 Theta를 -b로 치환 하게 된다면
# w1x1 + w2x2 + b > 0 : 1
# w1x1 + w2x2 + b <= 0 : 0
# 기표 표시 저환으로 b : bias를 형성

import numpy as np 
x = np.array([0,1])
w = np.array([.5,.5])
b = -0.7
print(w*x)
np.sum(w * x) + b

def AND(x1,x2):
    x = np.array([x1,x2])
    w = np.array([.5,.5])
    b = -0.7
    tmp = np.sum(w * x) + b
    if tmp <= 0:
        return 0
    else:
        return 1
        
for param in param_list:
    print(param)    
    print(AND(param[0],param[1]))

def NAND(x1,x2):
    x = np.array([x1,x2])
    w = np.array([-.5,-.5])
    b = 0.7
    tmp = np.sum(w * x) + b
    if tmp <= 0:
        return 0
    else:
        return 1
        
for param in param_list:
    print(param)    
    print(NAND(param[0],param[1]))

def OR(x1,x2):
    x = np.array([x1,x2])
    w = np.array([.5,.5])
    b = -0.2
    tmp = np.sum(w * x) + b
    if tmp <= 0:
        return 0
    else:
        return 1
        
for param in param_list:
    print(param)    
    print(OR(param[0],param[1]))
    
    
def XOR(x1,x2):
    s1 = NAND(x1,x2)
    s2 = OR(x1,x2)
    y= AND(s1,s2)
    return y


for param in param_list:
    print(param)    
    print(XOR(param[0],param[1]))
    