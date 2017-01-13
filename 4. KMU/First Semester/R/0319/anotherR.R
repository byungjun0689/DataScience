
simpleAvg <- function (kor,eng,math){
  dummy <- (kor + eng + math)/3 

  return(dummy)
} 

simpleAvg(10,20,30)

help("inspect")

mem_view(simpleAvg)

mean(70,80,90)
mean(c(70,80,90))

install.packages("Matrix")
library(Matrix)

m <- Matrix(1:20, 4,5)

c(70,80,90)

show_money<- function (kor,eng,math,pm,warn="다음에는 시험 잘봐"){
  
  dummy <- (kor + eng + math)/3 
  #print(kor)
  #print(eng)
  #print(math)
  
  cat("국어 : ", kor, "\n")
  cat("영어 : ", eng, "\n")
  cat("수학 : ", math, "\n")
  
  if(dummy >= 90){
    pockeyMoneyTobe <- pm * 1.1
  }else{
    pockeyMoneyTobe <- warn
  }
  
  return(pockeyMoneyTobe)
}

show_money(10,100,100,10000)
show_money(10,100,100,warn ="너죽을래?")
show_money(eng = 10,100,120 ,warn ="너죽을래?")  # 키워드를 지정해준다면 그 다음부터 순서대로 넣는다. 지정 변수에 값은 넣지 않고 ( 이미 넣었기 때문에 )



memoryTour <- mem_view(simpleAvg)
head(memoryTour)



myVector <- c(1,2,3,4,5)
mem_view(myVector)

myInterger<- 1:5
mem_view(myInterger)


x <- c(1,2,3,4,5,6,7,8,9,10)
mem_view(x)

y <- 1:10
mem_view(y)

z <- c(1:10)
mem_view(z)


str(1)
str(x)
str(y)
identical(x,y)   #두개의 변수가 값이 같은지 확인하는 것.
identical(y,z)


s <- seq(1,10, 2)
s

s1<- seq(1,10000,2)
s1


rep(1:3,3)


rep(1:3,3,each =3)      #각각을 3번씩 반복하면서 111 222 333 이런식으로 나오게 하라.
