for(i in 1:nrow(iris)){
  sum = apply(iris[i,-5], 1, FUN = sum)
  cat("합계",i,sum,"\n")
}

ncol(iris)

1:ncol(iris)
for(i in 1:ncol(iris)){
  print(i)
}


seq(1,10,2)
seq(1,10)
for(i in seq(1,10,2)){
  print(i)
}

iris[1:150,1:4]
# 전체 열을 기준으로 for문을 1차원적으로 돌리고 행을 기준으로 2차원 적으로 돌린다.
# sum 을 첫번째 for문에서 0 로 초기화 하는 이유는 각 행마다 sum을 재계산해야 되기 때문이다.
# 2중 포문에서 각 열마다 is.numeric을 통해 숫자일 경우에만 적용 할 수 있도록 한다.
# 물론 저 조건문 없이 4까지만 적용하면 되겠지만. 만약 안에 컬럼 내용과 수를 모를 경우에는 적용하기 힘들기 때문이다.
# 각 행의 요소별로 sum을 구하여 출력한다.

for(i in 1:nrow(iris)){         
  sum = 0                         
  for(j in 1:ncol(iris)){
    if(is.numeric(iris[i,j]) == T){
      sum = sum + iris[i,j]
    }
  }
  cat("합계",i,sum,"\n")
}

# 5 번째 항목이 sum 을 구할 때 필요 없는 부분임을 판단하여 2중 포문 없이 sum 함수로 각 행 별 합을 구했습니다.
# 5 번째 항목은 species 로 factor 요소이다. 
# -5 는 해당 열의 데이터를 제외한다 라는 표현.

for(i in 1:nrow(iris)){         
  sum = 0;
  sum = sum(iris[i,-5])
  cat("합계",i,sum,"\n")
}

# [Question]
#1. iris 데이터에서 Species가 Septal.Length가 가장 큰 값을 포함한 row를 출력하시오.(which / max )
#2. iris 데이터에서 Species별 Petal.Length의 Median값을 구하시오(tapply, median)
#3. Septal.Length가 6보다 큰 row만 출력하시오 (which)
#4. authors의 surname과 books의 names을 공통된 이름으로 묶으시오.-books의 R Core도 포함(심화학습)(merge)

which.max(iris$Sepal.Length)
tapply(iris$Sepal.Length,iris$Species,mean)
which(iris$Sepal.Length>6)

merge(x = authors,y = books,by.x = "surname",by.y="name")   # SQL의 JOIN과 같은 역할임.
merge(authors, books, by.x = "surname", by.y = "name", all = TRUE)
?merge



?merge
authors <- data.frame(
  surname = I(c("Tukey", "Venables", "Tierney", "Ripley", "McNeil")),
  nationality = c("US", "Australia", "US", "UK", "Australia"),
  deceased = c("yes", rep("no", 4)))
books <- data.frame(
  name = I(c("Tukey", "Venables", "Tierney",
             "Ripley", "Ripley", "McNeil", "R Core")),
  title = c("Exploratory Data Analysis",
            "Modern Applied Statistics ...",
            "LISP-STAT",
            "Spatial Statistics", "Stochastic Simulation",
            "Interactive Data Analysis",
            "An Introduction to R"),
  other.author = c(NA, "Ripley", NA, NA, NA, NA,
                   "Venables & Smith"))

books
authors


a <- c(1,2,3,4,5)
a[-1]

?for (variable in vector) {
  
}
sum = 0 
for(i in 1:3){
  sum = 0 
  for(j in 1:4){
    sum = sum + 
  }
  print(sum)
}


for(i in 1:9){
  for(j in 1:9){
    cat(i,"*",j,"=",i*j,"\n")
  }
}


for(i in 1:9){
  for(j in 1:9){
      
  }
}


