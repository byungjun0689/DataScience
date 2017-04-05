set1 <- read.csv("data/set1.csv" , header = T , stringsAsFactors = F)
head(set1)
set1

plot(set1) 

library(MASS)
density <- kde2d(set1$food , set1$book , n=400)
image(density , xlab = "food" , ylab = "book") 

library(e1071) 
m1 <- svm(status ~ food + book + cul + cloth + travel , type = "C-classification" , data = set1) 
m1

predict(m1 , set1)
sum(set1$status != predict(m1 , set1))

library(caret)
confusionMatrix(set1$status,predict(m1 , set1))

library(kernlab)
m2 <- ksvm(status ~ . , kernel = "rbfdot" , data = set1) 
m2

predict(m2 , set1)
sum(as.numeric(predict(m2 , set1) > 0.5) != set1$status)

tmp = predict(m2 , set1)
tmp[tmp>=0.5] =1 
tmp[tmp<0.5] =0
tmp

confusionMatrix(set1$status,tmp)

