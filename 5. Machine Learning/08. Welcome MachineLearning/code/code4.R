like <- read.csv("like.csv" , stringsAsFactors = F , header = T)
colnames(like) <- c("talk" , "book" , "travel" , "school" , "tall" , "skin" , "muscle" , "label")
like
test <- data.frame(talk=70 , book=50 , travel=30 , school=70 , tall=70 , skin=40 , muscle=50)
test

library(class) 
train <- like[,-8]
group <- like[,8]
knnpred1 <- knn(train , test , group , k=3 , prob=TRUE) 
knnpred2 <- knn(train , test , group , k=4 , prob=TRUE) 

buy <- read.csv("buy.csv" , stringsAsFactors = F , header = T)
buy$age <- scale(buy$나이)
buy$pay <- scale(buy$월수입)
buy

test <- data.frame(age=44 , pay=400)

train <- buy[,c(4,5)]
labels <- buy[,3]

#표준화 
test$age <- (test$age - mean(buy$나이)) / sd(buy$나이)
test$pay <- (test$pay - mean(buy$월수입)) / sd(buy$월수입)
knnpred1 <- knn(train , test , labels , k=5 , prob=TRUE) 
knnpred2 <- knn(train , test , labels , k=6 , prob=TRUE) 
knnpred1;knnpred2

