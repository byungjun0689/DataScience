# -*- coding: utf-8 -*-
#writer : Tomas 

import time
import random
import math
import scipy.stats
import numpy as np

times = ['A','B','C','D','E','F']                     
domain=[(0,(len(times)*3)-i-1) for i in range(0,len(times)*3)]

prefs={
       1 : ['B', 'C' , 'A'],
       7 : ['E', 'F'],
       11 : ['A', 'B'],
       15 : ['E', 'D']
       }
       
hates = {
        13 : [1, 7], 
        10 : [11, 15],
        3 : [8, 12, 10]
        }

man = [range(0,12)]
woman = [range(12,18)]        

#vec = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]


def dormcost(vec):
    
    #선호하는 시간대에 따라 점수부여 
    
    #싫어하는 사람에 따라 점수부여 
    
    #각 시간대에 적어도 1명은 남자
    
    #C시간대에 여자가 있으면 안됨 
    
  cost=0
  
  # Create list a of slots
  slots=[]
  for i in range(len(times)): slots+=[i,i,i]
  
  #선호하는 시간대에 따라 점수부여 
  for i in prefs.keys():
      x = int(vec[i])
      time=times[slots[x]]
      pref=prefs[i]
      
      satisfy = False
      for j in range(len(pref)):           
          if pref[j]==time: 
              cost+=(j*2)
              satisfy = True
      if satisfy == False:
          cost+=(j*2+3)
          
  #싫어하는 사람에 따라 점수부여 
  for i in hates.keys():
      x = int(vec[i])
      time=times[slots[x]]
      ha=hates[i]
      
      for j in range(len(ha)):
          y = int(vec[ha[j]])
          time_y=times[slots[y]]           
          if time_y==time: 
              cost+=(7-j)
              

  #각 방에 적어도 1명은 남자
  times_band = printsolution(vec)
  
  idx = 0 
  time_dic = {'A':0 , 'B':0 , 'C':0 , 'D':0 , 'E':0 , 'F':0} 
  
  for t in times_band:
      idx += 1
      if idx >=0 and idx <= 11:
          if t == 'A': time_dic['A'] += 1
          elif t == 'B': time_dic['B'] += 1
          elif t == 'C': time_dic['C'] += 1
          elif t == 'D': time_dic['D'] += 1
          elif t == 'E': time_dic['E'] += 1
          elif t == 'F': time_dic['F'] += 1
          
  cost += sum(matrix(time_dic.values()) == 0) * 2
       
  #C시간대에 여자가 있으면 안됨 
  idx = 0 
  time_dic = {'A':0 , 'B':0 , 'C':0 , 'D':0 , 'E':0 , 'F':0} 
  
  for t in times_band:
      idx += 1
      if idx >=12:
          if t == 'C': time_dic['C'] += 1
          
  if time_dic['C']>0 : cost+=10 
  
  return cost
  

def printsolution(vec):
  slots = []
  times_band = []
  # Create 3 slots for each time
  for i in range(len(times)): slots+=[i,i,i]

  # Loop over each students assignment
  for i in range(len(vec)):
    x=int(vec[i])

    # Choose the slot from the remaining ones
    time=times[slots[x]]
    
    # Show the student and assigned dorm
    #print i,time
    times_band.append(time)
    
    # Remove this slot
    del slots[x]
    
  return times_band


def geneticoptimize(domain,costf=dormcost,popsize=200,step=1,
                    mutprob=0.5,elite=0.4,maxiter=20):
  # Mutation Operation
  def mutate(vec):
    i=random.randint(0,len(domain)-1)
    if random.random()<0.5 and vec[i]-step>domain[i][0]:
      return vec[0:i]+[vec[i]-step]+vec[i+1:] 
    elif vec[i]+step<domain[i][1]:
      return vec[0:i]+[vec[i]+step]+vec[i+1:]
    else:
      return vec
  
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
    print i,scores[0][0],'--->',scores[0][1] , '==>' , printsolution(scores[0][1])
    
  return scores[0][1]
