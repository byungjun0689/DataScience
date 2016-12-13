
# apply() 함수
# merge()
# summary()
# aggregate()
# which()
#=========================================================#

str(iris)  # 데이터 요약이 아니라 형태를 보여주는것이다. 150 데이터 5개 컬럼.
head(iris)
tail(iris)
table(iris$Species)   #컬럼 별 몇개의 오브젝트가 존재하는지 알 수 있다. 질문할 것 factor/table은 factor를 구하는것인지.
table(iris[,5]) 
?table

iris$Sepal.Length
length(iris$Sepal.Length)
length(iris[,1])

iris_setosa = iris[iris$Species == 'setosa',]
iris_versicolor = iris[iris$Species == 'versicolor',]
iris_virginica = iris[iris$Species == 'virginica',]

##### apply() ################### #####
# 벡터에 일괄적으로 FUN을 적용
MyMatrix=matrix(1:12,nrow=3,ncol=4,byrow=FALSE)
MyMatrix
str(MyMatrix)
sum(MyMatrix[1,])
sum(MyMatrix[2,])
sum(MyMatrix[3,])
apply(X = MyMatrix,MARGIN = 1,FUN = sum)     #apply(데이터, Margin 1:로우 2:컬럼 3 FUN =  함수)
apply(X = MyMatrix,MARGIN = 2,FUN = sum)
#대표적인 FUN: sum,min,max,mean,median,length,sd,quantile
?quantile
iris_setosa
apply(iris_setosa[,-5],2,mean)   # factor 를 제외한 부분. 

##### lapply() ##### 벡터에 일괄적으로 FUN을 적용 후 list 반환


Mylist = list(a=1:5,b=6:10)
Mylist
result = lapply(X = Mylist,FUN = mean)
result
result$a
result[[1]]  
unlist(result)

head(iris_setosa,10)
result_1 = lapply(iris_setosa[,-5],mean)
result_1
str(result_1)
result_1 = unlist(result_1)   #produce a vector which contains all the atomic components which occur in x.
str(result_1)
result_1 = as.matrix(result_1)
result_1
result_1 = data.frame(result_1)
result_1
colnames(result_1) = c("Mean")
str(result_1)

result_2 = as.data.frame(matrix(unlist(lapply(iris[,1:4],mean)),ncol=4,byrow=TRUE))
result_2
colnames(result_2) = colnames(iris_setosa[,-5])
result_2

data.frame(do.call(what = cbind,args = lapply(iris_setosa[,1:4],mean)))
data.frame(do.call(what = rbind,args = lapply(iris_setosa[,1:4],mean)))
data.frame(Mean = do.call(what = rbind,args = lapply(iris_setosa[,1:4],mean)))

##### sapply #####
#벡터에 일괄적으로 FUN을 적용 후 벡터로 반환(lapply와 유사)

result_3 = sapply(X = iris_setosa[,1:4],FUN = mean)            #한번에 vector화 시킨것.
result_3
as.data.frame(result_3)
as.data.frame(t(result_3))          #전치행렬. t()  

iris_setosa[1:10,1:4]
sapply(iris_setosa[1:10,1:4],function(x){x>3})
sapply(iris_setosa[1:10,1:4],function(x){x%%0.2==0})

##### tapply() #####
#그룹별 함수를 적용하기 위한 apply함수
?tapply
tapply(iris$Sepal.Length,iris$Species,mean)   # (1,2,3)   1번을 가지고 2번 별로 3번을 한다. 
tapply(iris$Sepal.Length,iris$Species == 'setosa',mean)
tapply(iris$Sepal.Length,iris$Species != 'setosa',mean)
#tapply, sapply 를 알아야한다. 
##### mapply() #####

mapply(FUN = mean,iris_setosa[,1:4])

##### summary #####

summary(iris_setosa)
summary(iris_versicolor)
summary(iris_virginica)

summary(iris)

colMeans(iris_setosa[,-5])
mean(iris_setosa$Sepal.Length)
median(iris_setosa$Sepal.Length)
quantile(iris_setosa$Sepal.Length)
seq(0,1,by=0.05)
quantile(iris_setosa$Sepal.Length,probs = seq(0,1,by=0.05))
sd(x = iris_setosa$Sepal.Length)


##### doBy ################### #####
install.packages("twittR")
install.packages("doBy")
library("doBy")

## summaryBy
head(iris)
mean(iris$Sepal.Width); mean(iris$Sepal.Length)
summaryBy(Sepal.Width + Sepal.Length ~ Species,data=iris,FUN = mean)
?summaryBy
# width 와 length 데이터를 가지고 ~ specics를 기준으로 mean을 한다. 

iris$Type = NA
iris[1:75,6] = 1
iris[76:nrow(iris),6] = 2
head(iris);tail(iris)
summaryBy(Sepal.Width + Sepal.Length ~ Species | Type,data=iris,FUN = mean)
# ~ 를 기준으로 하되 | or 둘다. specics와 type


## orderBy
iris_setosa[order(iris_setosa$Sepal.Length),]  # setosa의 sepal.length를 기준으로 순서대로 표시 order return index
order(iris_setosa$Sepal.Length) # index를 출력한다.
iris_setosa[order(iris_setosa$Sepal.Length,decreasing = T),]  #decreasing
orderBy(~Sepal.Length,data=iris_setosa)

iris_setosa[order(iris_setosa$Sepal.Length,iris_setosa$Sepal.Width),]
orderBy(~ Sepal.Length + Sepal.Width, data=iris_setosa)

## sampleBy
sample(1:10,replace = T)
iris_setosa[sample(nrow(iris_setosa),nrow(iris_setosa)),]

sampleBy(~ Species, frac = 0.1, data=iris_setosa)

##### 데이터 분리 및 병합 #####
iris = iris[,-6]

## split()
# 주어진 조건에 따라 데이터를 분리
result_3 = split(x = iris$Sepal.Length,f = iris$Species)
result_3
str(result_3)
mean(result_3$setosa)
mean(result_3[[1]])

lapply(result_3,mean)

## subset()
# 주어진 조건을 만족하는 데이터를 선택
subset(x = iris, subset = Species == "setosa" & Sepal.Length > 5.0)
subset(x = iris, Species == "setosa" & Sepal.Length > 5.0,
       select = c(Sepal.Length,Sepal.Width))
subset() # Tab활용

## merge()
# 두 데이터 프레임을 공통괸 값을 기준으로 묶는 함수
x = data.frame(name=c("a","b","c"),math=c(1,2,3))
y = data.frame(name=c("c","b","a"),english =c(4,5,6))
z = data.frame(name=c("b","d","a"),statistic =c(7,8,9))
x;y;z

merge(x = x,y = y,by = c("name"))
merge(x = x,y = z,by = c("name"))
merge(x = x,y = z,by = c("name"),all = T)

##### 조건에 맞는 데이터의 색인 찾기 #####
## which

which(iris$Species == "setosa")
which.max(iris$Sepal.Length)
iris[132,]
max(iris$Sepal.Length)
which.min(iris$Sepal.Length)

which(iris$Species == "setosa" & iris$Sepal.Length > 5.0)
iris[which(iris$Species == "setosa" & iris$Sepal.Length > 5.0),]
iris[which.max(iris$Sepal.Length),]

##### 그룹별 연산 #####

aggregate(Sepal.Length ~ Species,data=iris,FUN=mean)           # 알고싶은 값 ~ 기준. 
aggregate(Sepal.Length ~ Species,data=iris,FUN=max)
aggregate(Sepal.Length ~ Species,data=iris,FUN=summary)

iris$Type = NA
iris[1:75,6] = 1
iris[76:nrow(iris),6] = 2

aggregate(Sepal.Length ~ Species + Type,data=iris,FUN=summary)  # length를 종류와 타입별로 

# [Question]
#1. iris 데이터에서 Species가 Septal.Length가 가장 큰 값을 포함한 row를 출력하시오.(which / max )
#2. iris 데이터에서 Species별 Petal.Length의 Median값을 구하시오(tapply, median)
#3. Septal.Length가 6보다 큰 row만 출력하시오 (which)
#4. authors의 surname과 books의 names을 공통된 이름으로 묶으시오.-books의 R Core도 포함(심화학습)(merge)
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
authors
books
