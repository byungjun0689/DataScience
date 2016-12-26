test <- read.csv("rule.csv" , header = T)
test

#class별 비율을 구한다. (규칙에 상관없이 똑같다.) 
r1 <- NROW(subset(test , 효과 == "YES")) / NROW(test) 
r2 <- NROW(subset(test , 효과 == "NO")) / NROW(test)
r1
r2

#RULE1의 조건집합
cond1 <- subset(test , 과목 == "수학"  & 수업일 == "주말")

#RULE1의 관측도수를 구한다. 
f1 <- NROW(subset(cond1 , 효과 == "YES"))
f2 <- NROW(subset(cond1 , 효과 == "NO"))

#RULE1의 기대도수를 구한다. 
e1 <- NROW(cond1) * r1
e2 <- NROW(cond1) * r2
e1
e2

#RULE1의 가능도비율을 구한다. 
like1 <- 2 * (f1 * log(f1/e1) + f2 * log(f2/e2)) 
like1

#적용도 / 정확도 
cove <- NROW(cond1) / NROW(test) 
cove
acc <- NROW(subset(cond1 , 효과 == "NO")) / NROW(cond1) 
acc

#적용도/정확도/가능도비율 구하기
like_cov_acc <- function(cond , res) {
  f1 <- NROW(subset(cond , 효과 == "YES"))
  f2 <- NROW(subset(cond , 효과 == "NO"))
  
  e1 <- NROW(cond) * r1
  e2 <- NROW(cond) * r2
  
  like <- 2 * (f1 * log(f1/e1) + f2 * log(f2/e2)) 
  cove <- NROW(cond) / NROW(test) 
  acc <- NROW(subset(cond , 효과 == res)) / NROW(cond) 
  
  cat("적용도는" , cove , "입니다.\n")
  cat("정확도는" , acc , "입니다.\n")
  cat("가능도비율은" , like , "입니다.\n")
}

#RULE2
cond2 <- subset(test , 과목 == "과학")
res2 <- "NO" 
like_cov_acc(cond2 , res2) 

#RULE3
cond3 <- subset(test , (과목 == "과학" | 과목 == "수학") & 수업시간대 == "저녁" & (class == "A" | class == "B"))
res3 <- "NO" 
like_cov_acc(cond3 , res3) 

#RULE4
cond4 <- subset(test , (과목 == "영어" | 과목 == "국어") & (class == "A" | class == "B"))
res4 <- "YES" 
like_cov_acc(cond4 , res4) 

