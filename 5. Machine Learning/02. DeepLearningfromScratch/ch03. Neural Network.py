# -*- coding: utf-8 -*-
"""
Created on Mon Apr 10 08:07:46 2017

@author: MCR007
"""

# Chapter 3. Neural Network 
# Chapter 2까지 작업은 가중치 작업을 수동으로 해야했다. 
# 하지만 Neural Network부터는 자동으로 학습하는 능력을 알아 볼 것이다. 
# 입력층 -> 은닉층 -> 출력층 구조로 되어있다. 
# y = 0 (b + w1x1 + w2x2 <=0)
# y = 1 (b + w1x1 + w2x2  > 0)
# Activation Function 
# a = b + w1x1 + w2x2
# y = h(a)

# 임계값을 경계로 출력이 바뀌는 것을 Step function 이라고 한다. 
# 1. Sigmoid function 
# h(x) = 1 / (1 + exp(-x)) 
# 출력 0~1

# Compare with Step function and Sigmoid function

import numpy as np 
import matplotlib.pyplot as plt

# 3.2.2 Step function
# numpy array 지원 X
def step_function(x):
    if x>0:
        return 1
    else:
        return 0 
        
# numpy array 지원
def step_function(x):
    y = x>0
    return y.astype(np.int)
# more simple
def step_function(x):
    return np.array(x>0, dtype=np.int)

x = np.array([-1.0,1.0,2.0])
y = x>0
y
y.astype(np.int)


x = np.arange(-5, 5, 0.1)
y = step_function(x)
plt.plot(x,y)
plt.ylim(-0.1, 1.1)
plt.show()


# 3.2.4 Sigmoid function
def sigmoid(x):
    return 1 / (1+np.exp(-x))
    
x = np.array([-1.0,1.0,2.0])
sigmoid(x)

x1 = np.arange(-5.0,5.0,0.1)
y1 = sigmoid(x)
plt.plot(x1,y1)
plt.ylim(-0.1, 1.1)
plt.show()

# 3.2.5 Compare Two function
plt.plot(x,y,'r',label='Step')
plt.plot(x1,y1,'b', label='Sigmoid')
plt.ylim(-0.1, 1.1)
plt.legend(bbox_to_anchor=(1.05, 1), loc='best', borderaxespad=0.)
plt.show()

# 두개 그래프 모두 비선형
# 선형함수를 사용해서는 안된다. 선형함수를 사용한다면 신경망의 층을 깊게하는 의미가 없어진다.
# 또한 활성화 됐다 안됐다 라는 의미가 강하다 신경망에서는 

# 3.2.7 ReLU function
# h(x) = x ( x > 0) 
# h(x) = 0 ( x <= 0 )

def relu(x):
    return np.maximum(0,x)
    
relu(x1)

# Multi Demention Calculation
import numpy as np
A = np.array([1,2,3,4])
A
np.ndim(A)
A.shape
A.shape[0]

B = np.array([[1,2],[3,4],[5,6]])
B
B.ndim
B.shape

# 행렬의 곱 

