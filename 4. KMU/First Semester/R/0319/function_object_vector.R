
###########################
# Function
###########################


showMoney <- function(kor, eng, math, pm){  
  
  testAvg <- (kor + eng + math)/3
  
  if (testAvg >= 90) {
    pocketMoneyToBe <- pm * 1.1
  } else {
    pocketMoneyToBe <- pm
  }
  
  return(pocketMoneyToBe)
}

showMoney(90, 80, 70, 10000)

showMoney(eng=90, 80, 70, 10000)

showMoneyWithPrint <- function(kor, eng, math, pm){
  
  testAvg <- (kor + eng + math)/3
  
  if (testAvg >= 90) {
    pocketMoneyToBe <- pm * 1.1
  } else {
    pocketMoneyToBe <- "please, Try Hard"
  }
  
  print(kor)
  print(eng)
  print(math)
  print(pm)
  
  return(pocketMoneyToBe)
}

showMoneyWithPrint(eng = 80, 90, 70, 10000) #automatically arrange arguments and value.

showMoneyWithPrint(90, 80, 70) # one of argument is missing. error.


# When you are implementing a function,
# you can define default value of some arguments.


showMoneyDefault <- function(kor, eng, math, pm=10000){
  
  testAvg <- (kor + eng + math)/3
  
  if (testAvg >=90) {
    pocketMoneyToBe <- pm * 1.1
  } else {
    pocketMoneyToBe <- "please, Try Hard"
  }
  
  cat("kor :", kor, "\n")  # cat means "catalogue", "\n" means making a new line
  cat("eng :", eng, "\n")
  cat("math :", math, "\n")
  cat("pocket Money ;", pm, "\n")
  
  return(pocketMoneyToBe)
}

showMoneyDefault(90, 80, 70)


showMoneyWithWarning <- function(kor, eng, math, pm=10000, warn="please try hard!"){
  testAvg <- (kor + eng + math)/3
  if (testAvg >=90) {
    pocketMoneyToBe <- pm * 1.1
  } else {
    pocketMoneyToBe <- warn
  }
  return(pocketMoneyToBe)
}

showMoneyWithWarning(90, 80, 70, "this is your last chance.") # good

showMoneyWithWarning(90, 90, 90, "this is your last chance.") # error  # warn 이라고 지정해주지 X 그래서 PM으로 인식

showMoneyWithWarning(90, 90, 90, warn="this is your last chance.") # good


# R is lazy....

showMoneyWithHardWarning(90, 80, 70, "this is your last chance.",10000) # operate but semantic error


showMoneyWithHardWarning(90, 90, 90, "this is your last chance.",10000) # error


showMoneyWithHardWarning(90, 90, 90, warn="this is your last chance.",10000) # good


# weighted average : weight kor 20%, eng 30%, math 50% 

showAvg <- function(kor, eng, math){
  testAvg <- kor * 0.2 + eng * 0.3 + math * 0.5 # weighted average
  return(testAvg)
}

# compare the two different result.
# beware the order of arguments
# If you want to change the order of arguments when you call a function,
# you should have to tell it clearly with its argument names

showAvg(eng=90, kor=80, math=70)

showAvg(90, 80, 70) # R interprets this as, kor=90, eng=80, math=70



#########################
# Let's find out Where the objects are.
#########################

install.packages("pryr")    
library(pryr)

x <- 3
address(x)   #?????????? ?????? ????????. 
address(3) # error  ?????? ????. ???????? ??????.
address(pi)
address

mem_view <- function(x) capture.output(.Internal(inspect(x)))

inspect("a")  # STRSXP 0x156f8c18     CHARSXP 0xc159230 ???? ???????? ????. 
.Internal(inspect("a"))  

mem_view("a")
mem_view(3)

mem_view("<-")
mem_view("=")
mem_view("[[")

mem_view(showAvg)

memoryTour <- mem_view(showAvg)

head(memoryTour)

head(memoryTour, 30)

length(memoryTour) # count the length of vectors

NROW(memoryTour) # same as length()
nrow(memoryTour) # this function is not applicable with vectors.

#########################
# Vector
#########################

myVector <- c(1,2,3,4,5)

mem_view(myVector)

myInteger <- 1:5

mem_view(myInteger)

## various ways of making vectors

c(1,2,3,4,5,6,7,8,9,10)
mem_view(1,2,3,4,5,6,7,8,9,10)

x <- c(1,2,3,4,5,6,7,8,9,10)
mem_view(x)

y <- 1:10
mem_view(y)

z <- c(1:10)
mem_view(z)

identical(x, y)

identical(x, z)

identical(y, z)


seq(1, 10, 2) # from, to, by

rep(1:3, 3)

rep(1:3, times=3)

rep(1:3, times=3, each=2)

sample(1:10, 10, replace=TRUE)  # 1:10까지 숫자중 10개를 선택하여 replace = T 중복 허용

sample(1:10, 10, replace=FALSE)  # 위와 동일 하지만 중복 불가 

set.seed(1)
myVector <- sample(1:10, 5, replace=TRUE)

set.seed(2)
herVector <- sample(1:10, 5, replace=TRUE)

myVector
herVector

# ?????? ?????? ???? ???? 
#c(), 1:10 (:??), seq, rep, sample


setdiff(myVector, herVector) #  3,4 차집합. // 앞 데이터를 기준으로 앞에 꺼가 뒤에 없는 것만 보여주기
setdiff(herVector, myVector)   
intersect(myVector, herVector)  # 교집합
union(myVector, herVector)  #합집합

set.seed(123)
myVector <- sample(1:50, 20, replace=TRUE)

set.seed(345)
herVector <- sample(1:50, 10, replace=TRUE)

myVector
herVector

setdiff(myVector, 1:50) # beware the order of argument and compare the results.   1:50중에서 뽑았으니 없는게 없을리가 
setdiff(1:50, myVector)   # 1:50중 없는거 
?setdiff

sampled <- rep(1:5,1)
sampled
eachSampled <- rep(1:5,1,each=2)
eachSampled

identical(sampled, eachSampled) # not identical  같으냐?
setequal(sampled, eachSampled)  # but two sets has equal unique elements.  엘리멘트만 비교. 동일한 엘리멘트를 가지고 있다.

seqAlongVector <- seq(1,20,2)

length(seqAlongVector)

?seq_alongseq_along(seqAlongVector)  # smake seqence 즉, 전체 갯수를 1부터 나열하도록 만드는거.s
test <- 1:50
seq_along(test)
eqA_len(test)
seqlongVector[seq_along(seqAlongVector)]
myVector
seq_along(myVector) # making a sequence from 1 to length of input vector. very convenient!!


x<-seq(1,10,1)
y<-seq(2,11,1)

x + y
   # each elements add having same index