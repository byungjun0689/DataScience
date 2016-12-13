x <- 1:16
y <- x + 1
y

myVector <- c("hello,", "me","?", "it", "looking", "is", "you", "for")
myVector[-1]  # hello 를 제외한 부부만 호출
myVector[3]

myVector[nchar(myVector)>=3]

ifelse(myVector[nchar(myVector)>3],myVector,NULL)


myVector<-ifelse(nchar(myVector)>3,1,NULL)

myVector
nchar(myVector)>=3


help(ifelse)
