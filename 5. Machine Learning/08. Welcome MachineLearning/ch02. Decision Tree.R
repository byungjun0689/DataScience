# 할인 쿠폰을 좋아하는 고객의 패턴이나 규칙을 찾아라.
# 범주형 변수 
# 구분하는 기준이 되는 부분을 Node라고 한다. 

skin <- read.csv("data/skin.csv")
skin <- skin[-1]
head(skin)
str(skin)

#Entropy(x)
# 정보엔트로피 H : 정보의 기대값 = sum(p(x)log_2(p(x)))

x <- c("red","blue","blue","red","red")

#정보엔트로피를 구하는 함수 
info_entropy <- function(x) { 
  
  factor_x <- factor(x) 
  entropy <- 0 
  for(str in levels(factor_x)) {
    pro <- sum(x == str) / length(x) 
    entropy <- entropy - pro * log2(pro) 
  }
  return (entropy)
}

info_entropy(x)
# 엔트로피 값이 높을 수록 복잡한 구조라는 것.
# 하나의 종류만 있다면 엔트로피는 0 이 된다.

first_entropy <- info_entropy(skin$쿠폰반응여부)

for(str in colnames(skin)[1:5]) { 
  
  #str=조건변수 , factors=조건값집합
  factors <- levels(skin[[str]])
  
  #조건변수를 각각의 가능한 속성값으로 분류하였을때 '쿠폰반응여부'에 대한 엔트로피의 합계
  sum_entropy <- 0 
  for(str2 in factors) { 
    test_x <- skin[skin[[str]] == str2,][6]
    sum_entropy <- sum_entropy + info_entropy(test_x[,1])
  }
  cat(str , '---->' , sum_entropy,'\n')
  
}

table(skin$성별)

library(rpart)
# minsplit 가 클수록 트리가 간단해진다. 
# pruning (가지치기) : 의미없는 분할을 계속하지 않도록 하는 것.
# 해당 node의 예쌍최대오류의 개수보다 Child note의 오류개수의 합이 크다면 굳이 가지를 나눌 필요가 없다 

tree1 <- rpart(쿠폰반응여부 ~., data=skin, control=rpart.control(minsplit=2))
plot(tree1 , compress = T , uniform = T , margin=0.1) 
text(tree1 , use.n = T , col = "blue")


# 엔트로피 이외에도 다른 기준들이 존재한다.
# 1. 카이제곱스퀘어(X^2) 2. 지니계수

chisq.test(xtabs(~ 결혼여부 + 쿠폰반응여부, data=skin)) # p-value가 0.05보다 작다. 독립이다.
chisq.test(xtabs(~ 성별 + 쿠폰반응여부, data=skin)) # 0.08 , 0.05보다 크다. 연관성이 있다.


#지니계수를 구하는 함수 
info_gini <- function(x) { 
  
  factor_x <- factor(x) 
  gini_sum <- 0 
  for(str in levels(factor_x)) {
    pro <- sum(x == str) / length(x) 
    gini_sum <- gini_sum + pro^2
  }
  return (1 - gini_sum)
}

info_gini(skin$쿠폰쿠폰반응여부)

#새미의 데이터셋에 대하여 적용해 본 지니계수 계산
#맨처음의 '쿠폰반응여부'의 지니계수
first_gini <- info_gini(skin[,"쿠폰반응여부"])

for(str in colnames(skin)[1:5]) { 
  
  #str=조건변수 , factors=조건값집합
  factors <- levels(skin[[str]])
  
  #조건변수를 각각의 가능한 속성값으로 분류하였을때 '쿠폰반응여부'에 대한 엔트로피의 합계
  sum_gini <- 0 
  for(str2 in factors) { 
    test_x <- skin[skin[[str]] == str2,][6]
    sum_gini <- sum_gini + info_gini(test_x[,1])
  }
  cat(str , '---->' , sum_gini,'\n')
  
}

