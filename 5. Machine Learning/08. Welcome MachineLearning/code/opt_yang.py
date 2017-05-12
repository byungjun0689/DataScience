# -*- coding: utf-8 -*-
#writer : Tomas 

import time
import random
import math
import scipy.stats
import numpy as np

map_mat = [[0,1,1,0,0,0,0,0,0,0] , 
            [0,0,0,1,0,0,0,0,0,0] , 
            [0,0,0,0,1,0,0,0,0,0] , 
            [0,0,0,0,1,0,1,0,0,0] , 
            [0,0,0,1,0,0,0,0,1,0] , 
            [0,0,0,0,0,0,0,0,0,0] , 
            [0,0,0,1,0,1,0,0,0,0] , 
            [0,0,0,0,0,0,0,0,0,0] , 
            [0,0,0,0,1,0,0,0,0,1] , 
            [0,0,0,0,0,0,0,0,0,0]]
            
node_cnt = np.shape(map_mat)[0]
connected_list = []
for x in map_mat:
    connected = []
    cnt = 0 
    for i in x:
        cnt += 1
        if i>0 :
            connected.append(cnt) 
    connected_list.append(connected) 
    
mat_tf = np.matrix(map_mat) > 0 

domain = []
for i in mat_tf:
    if sum(i).any() > 0 :
        tu = 1,sum(i)
    else :
        tu = 0,0
         
    domain.append(tu) 
    #print(tu) 
    
start = 1 
end = 10 
#vec = [2, 1, 1, 1, 2, 0, 2, 0, 2, 0]


def ret_path(sol , start=start , end=end):
    
    vec = sol    
    vec2 = [0,0,0,0,0,0,0,0,0,0]
    path = [start]
    node = start 
    rotate = 0 
    
    while True:
        rotate += 1 
        
        #막다른 골목이면 멈춘다. 
        if len(connected_list[node-1]) == 0 :
            break
            
        next1 = connected_list[node-1][vec[node-1]-1]
        vec2[node-1] = vec[node-1]
        path.append(next1) 
        node = next1
        path_len = len(path) - 1
        
        if next1 == end :
            break
        if rotate > node_cnt :
            break
            
    return path , vec2


def costfunc(sol):
    val_sum = 0.0
    
    path , vec2 = ret_path(sol , start , end)
    
    if len(path) > node_cnt:
        return 999
    if path[len(path)-1] <> end :
        return 999
        
    #추가로 rule을 넣을 수도 있고 가중치를 수정할 수도 있음. 
    
    val_sum = len(path)-1
    
    return val_sum


def geneticoptimize(domain,costf=costfunc,popsize=100,step=1,
                    mutprob=0.5,elite=0.4,maxiter=20):
  # Mutation Operation
  def mutate(vec):
    i=random.randint(0,len(domain)-1)
    
    if domain[i][0] > 0 :
        return vec
    
    if random.random()<0.5 and vec[i]-step>domain[i][0]:
      ret_vec = vec[0:i]+[vec[i]-step]+vec[i+1:] 
    elif vec[i]+step<domain[i][1]:
      ret_vec = vec[0:i]+[vec[i]+step]+vec[i+1:]
    else:
      ret_vec = vec
      
    return ret_vec
  
  # Crossover Operation
  def crossover(r1,r2):
    i=random.randint(1,len(domain)-1)
    return r1[0:i]+r2[i:]

  # Build the initial population
  pop=[]
  for i in range(popsize):
    vec=[random.randint(domain[i][0],domain[i][1]) 
         for i in range(len(domain))]
    pop.append(vec)
  
  # How many winners from each generation?
  topelite=int(elite*popsize)
  
  
  # Main loop 
  for i in range(maxiter):
    scores=[(costf(v),v) for v in pop]
    scores.sort()
    ranked=[v for (s,v) in scores]
    
    # Start with the pure winners
    pop=ranked[0:topelite]
    
    # Add mutated and bred forms of the winners
    while len(pop)<popsize:
      if random.random()<mutprob:

        # Mutation
        c=random.randint(0,topelite)
        pop.append(mutate(ranked[c]))
      else:
      
        # Crossover
        c1=random.randint(0,topelite)
        c2=random.randint(0,topelite)
        pop.append(crossover(ranked[c1],ranked[c2]))
    
    # Print current best score
    print i,scores[0][0],'==> PATH:' , ret_path(scores[0][1])
    
  return ret_path(scores[0][1])
