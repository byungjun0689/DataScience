#
# [단축키]
# CTRL + ENTER : 스크립트 실행
# CTRL + 1 / 2 : 스크립트와 콘솔창 이동
# ALT + - : <-



##### CH2. DATA TYPE ####

### 1) 변수이름규칙
# a / b / a1 / b2 / .a / .a1 <--- GOOD
# 2a / .2 / a-b              <--- BAD

### 2)할당연산자
# <- / =
mean(x = c(1,2,3));x 
mean(x <- c(1,2,3));x

### 3) 스칼라(실질적으로는 Vector)

a = 90
b = 85
c = 80
d = 85
e = 70
f = NA
g = NULL
f

tmp = c(a,b,c,d,e,f,g)
(tmp_1 = 1:10)  # 실행과 동시에 결과도 나오게 하는것 () 묶에서 할당을 하게 된다면.
seq(from = 1,to = 10,by = 2)
rep(x = 1:2,times=3)

# NA: 결측치 / NULL: 미정
# NA :값은 있으나 값이 없는것.   NULL : 값자체가 아에 없는거.
sum(tmp)
sum(tmp,na.rm=TRUE)
tmp
help("NULL")
is.na(tmp)
is.null(tmp)
is.null(g)

is_even = NULL
if(a %% 2 == 0){   # %%나머지값만 보는 것.
  is_even = TRUE
}else if(a %% 2 == 1){   # %/% 
  is_even = FALSE
}else{is_even = NA
}
is_even

# 진릿값

if(a %% 2 == 0 & a %% 4 == 0){   # & | and or 
  ANSWER = "AND"
}else if(a %% 3 == 1 | a %% 5 ==1){
  ANSWER = "OR"
}else if(a != 90){
  ANSWER = "NOT"
}else if(a == 90){
  #ANSWER = "90"
}else{ANSWER = NA
}
ANSWER

### 4)벡터
tmp_3 = c(1,3,5)
tmp_4 = c(2,4,6)
tmp_5 = c("2","4","6")
tmp_6 = c(tmp_3,tmp_4); tmp_7 = c(tmp_3,tmp_5)
str(tmp_6);str(tmp_7)
tmp_6[1]; tmp_6[1:3]
tmp_3[-2]; tmp_6[-2:-3]    # -2 : 2번만 빼고    -2:-3   2~3번째 값을 빼고 출력.
is.vector(tmp_3)

# 벡터의 길이
length(tmp_3); NROW(tmp_6)

# 벡터의 연산
identical(tmp_3,tmp_6) # 동일한지 판단(완전히 같아야-->TRUE)
union(tmp_3,tmp_6) # 합집합
intersect(tmp_3,tmp_6) # 교집합
setdiff(tmp_3,tmp_4) # 차집합
setequal(tmp_3,tmp_4) # 같은집합인지 확ㅇ

tmp_3 + 1; tmp_3 - 1

# 행렬
tmp_7 = matrix(c(1,2,3,4,5,6,7,8,9),nrow=3,ncol=3,byrow = TRUE)
tmp_8 = matrix(c(1,2,3,4,5,6,7,8,9),nrow=3,ncol=3,byrow = FALSE)
t(tmp_7)
rownames(tmp_7) = c("r1","r2","r3")
colnames(tmp_7) = c("c1","c2","c3")

dimnames(tmp_8) = list(c("r1","r2","r3"),c("c1","c2","c3"))

t(tmp_8)
nrow(tmp_8)
ncol(tmp_8)
dim(tmp_8)
is.matrix(tmp_7)

tmp_8[1,2]; tmp_8[1:2,]; tmp_8[,-3]

tmp_7 + tmp_8
tmp_7 - tmp_8
tmp_7 * tmp_8  # 일반 곱하기 각 행 각 열에 맞게 
tmp_7 %*% tmp_8  # 행렬의 곱을 하려면 %*%

# 데이터프레임

tmp_9 = data.frame(c(1,3,5,7,9),c(2,4,6,8,10))
colnames(tmp_9) = c("C1","C2")
tmp_9$C3 = c("A","B","C","D","E")
tmp_9$C4 = c("A","B","C","D","")
str(tmp_9)   # 세로별 데이터 형태는 동일해야하나 가로별로는 다른 형태가 들어가도 된다. 
is.data.frame(tmp_9)

tmp_9[,1]; tmp_9[1:2,]; tmp_9$C1; tmp_9[,-2]

# 유틸리티 함수
tmp_10 = data.frame(C1 = 1:100, C2 = rep(1:2,50))
head(tmp_10,10)
tail(tmp_10)
View(tmp_10)

is.matrix(tmp_7)
tmp_7 = as.data.frame(tmp_7)
is.data.frame(tmp_7)
is.numeric(tmp_9$C2)
as.character(tmp_9$C2)

##### CH3. R Programing ####

### 조건문과 반복문
if(a %% 2 == 0){
  print(even)
}else if(a %% 2 == 1){
  print(odd)
}else{print(NA)
}

ifelse(a %% 2 == 0,"even","odd")   # 참, 거짓 순/

for(i in 1:10){
  A = 1 + i
  print(A)
}

i=1
while(i<=10){
  print(i)
  i = i + 1
}


for(i in 1:10){
  A = 1 + i
  if(A %% 2== 0){
    cat("\n","even =",A)
  }
}

### 연산

# + - * / : 사칙연산
# %% : 나눗셈의 나머지
# %/% : 나눗셈의 몫
# ^ : 승수
# exp() : 지수
# log() : 로그
# sin(),cos(),tan(): 삼각함수

tmp_10 = c(1,3,5,7,9)
tmp_11 = c(2,4,6,8,10)

tmp_10 + tmp_11
sum(tmp_10,tmp_11)
mean(tmp_10)
median(tmp_11)
sd(tmp_11)
quantile(tmp_11)
quantile(tmp_11,probs = seq(from = 0,to = 1,by = 0.05))
IQR(tmp_11)

?IQR

### 함수
LENGTH = function(x){
  A =  sum(x)
  B =  mean(x)
  C =  median(x)
  D =  sd(x)
  E = summary(x)
  cat("\n", "합계:",A)
  cat("\n", "평균:",B)
  cat("\n", "중위수:",C)
  cat("\n", "표준편차:",D)
  cat("\n", "SUMMARY:",E)
}
LENGTH(tmp_10)

head(iris)
tail(iris)
table(iris$Species)
aggregate(Sepal.Length ~ Species,data=iris,FUN=summary)
aggregate(Sepal.Length ~ Species,data=iris,FUN=sum)   # 전 ~ 후      전의 내용을 후를 기준으로 function에 있는 함수 사용.

?lm
lmout = lm(Sepal.Length ~ Species,data=iris)
lmout
summary(lmout)

ls()
rm()

