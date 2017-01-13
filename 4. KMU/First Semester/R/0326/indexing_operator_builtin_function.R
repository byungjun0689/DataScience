####################
# vector indexing
####################

# making vectors

smpl_vector <- seq(1,20,2)
smpl_vector
mode(smpl_vector)

mem_view <- function(x) capture.output(.Internal(inspect(x)))
mem_view(smpl_vector)
length(smpl_vector)
smpl_vector[1]
smpl_vector[3]
smpl_vector[length(smpl_vector)]
smpl_vector[3:length(smpl_vector)]  # 5부터 19 까지가 나옴. 
smpl_vector[3:length(smpl_vector)-1]  # 결과 3부터 17까지가 나옴. 이유는? 3 4 5 6 7 ~~ 19까지 만들어서 -1 즉, 2 3 4 5 ~ 18까지 
                                      # 그래서 3부터 17까지 나온다. 연산자의 우선순위 
smpl_vector[3:(length(smpl_vector)-1)] # 5부터 17까지 나옴.  (length(smpl_vector)-1)

?isTRUE
char_vector <- LETTERS
char_vector
mode(char_vector)

-1:5
1:5%%5   # 나머지 연산자  연산 순위가 : 가 %보다 높다. 
1:5^2    # 제곱 ^가 :보다 연산 순위가 높다. 즉, 1:25 까지 숫자가 나온다. ( 우선순위 )


for (i in char_vector) {
  print(i)
}

for (i in char_vector) {
  cat(i)
}

for (i in char_vector) {
  cat(i, "\n")
}

bool_vector <- c(TRUE, FALSE, TRUE, FALSE, FALSE, TRUE, TRUE, FALSE)
bool_vector
mode(bool_vector)
sum(bool_vector) # count the number of TRUEs


str_vector <- c("hello,", "me","?", "it", "looking", "is", "you", "for")
length(str_vector)
str <- "a"




s<- 0
for(i in str_vector){
    s <- s + 1        
    print(i)
}
s

help("for")
1:5
for(i in 1:5){
 print(i)
}

str_vector
factorial(8)  #8!

#시간이 얼마나 걸렸는지 확인할때 쓰는 부분 
(start.time <- Sys.time())
cumulativeRandom <- 0
for(j in 1:10){
  for (i in 1:100000) {
    #set.seed(i)
    dummy_str <- str_vector[sample(1:8,8,replace=F)]
    if(sum( dummy_str == str_vector[c(1,6,4,2,7,5,8,3)]) == 8) {  #8개가 전체가 맞으면 프린트 한다. 
      #print(i)
      #print(dummy_str)
      cumulativeRandom = sum(cumulativeRandom + i)
      print(i)
      break
    }
  }   #중첩 포문을 이용해서 반복가능하다.
}
cumulativeRandom / 10


Sys.time() - start.time

sum(dummy_str == str_vector[c(1,6,4,2,7,5,8,3)])


str_vector[c(1,6,4,2,7,5,8,3)]
mode(str_vector)


?rep
na_vector <- rep(NA, 7)
na_vector
mode(na_vector)

null_vector <- NULL
null_vector
mode(null_vector)

null_vector2 <- c()
null_vector2

# how to count vector's number of elements?
length(smpl_vector)
length(char_vector)
length(str_vector)
length(bool_vector)

# Boolean retrieval

str_vector <- c("hello,", "me","?", "it", "looking", "is", "you", "for")
bool_vector <- c(TRUE, FALSE, TRUE, FALSE, FALSE, TRUE, TRUE, FALSE)
bool_vector
str_vector[bool_vector]

mode(bool_vector)
sum(bool_vector) # count the number of TRUEs

str_vector[bool_vector]

set.seed(123)
a<-sample(1:8,replace = F)
a
factorial(8)
# application of boolean retrieval : comparing conditions

set.seed(25)
myVector <- sample(1:20, 10, replace=T)
myVector
myVector[myVector >= 10]
conditionCompare <- myVector >= 10
conditionCompare
myVector[conditionCompare]


# application of positive integer retrieval : which()

which(myVector >= 10)
myVector[which(myVector >= 10)]

x
# sigmoid function
x <- seq(-20,20,0.1)
length(x)
sigmoid <- exp(x)/(1+exp(x))
plot(x, sigmoid)


