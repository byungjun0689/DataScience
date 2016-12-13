

x <-1:10
which(x > 5)
x > 5  #return is logical variable
which(x[x>5])   # which 함수안에 logical 형 데이터가 와야하는데 일반적인 정수가 들어와 에러남. 

x1 <- c(1,NA,2,NA,3)
which(is.na(x1))
which(!is.na(x1))[3]  # is.na false data choose index 3 

?which

set.seed(10)
x2<- sample(1:50,7,replace = F)  #중복방지
x2
y <- which(x2>20)
x2[y]
y1 <- which.max(x2>20) # 조건문이 아니더라도 상관없다 which.max(x) 도 가능. 
x2[y1]


#myMatrix <- matrix(1:20,4,5,byrow = T)
myMatrix <- matrix(1:20,4,5)
myMatrix[1,]
myMatrix[,5]
myMatrix[2,3]
myMatrix[2:3,3:4]
myMatrix2 <- matrix(1:19,4,5)  #warning 1개가 부족하므로 다시 시작해서 1을 추가 하고 1:20으로 만들어준다.
myMatrix2

age <- 10:20
class(age)
payment <-  300:310

a <- cbind(age,payment)
class(a)
b <- rbind(age,payment)
help("rowsum")
a


rowsum()
rowSums(a)
colSums(a)
