# -*- coding: utf-8 -*-
"""
Created on Tue Jan 24 17:20:07 2017

@author: MCR007
"""
import math 

def nextSqure(n):
    result = math.sqrt(n)
    if result.is_integer():
        return (int(result)+1)**2
    else:
        return 'no'

# 아래는 테스트로 출력해 보기 위한 코드입니다.
print("결과 : {}".format(nextSqure(121)));


def nextSqure2(n):
    sqrt = n ** (1/2)

    if sqrt % 1 == 0:
        return (sqrt + 1) ** 2
    return 'no'
    