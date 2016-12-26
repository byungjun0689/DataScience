movie <- read.csv("movie.csv" , header = T)
library(e1071)
nm <- naiveBayes(movie[1:5] , movie$장르 , laplace = 0 )
head(movie)

result <- predict(nm , movie[1:5])
sum(movie$장르 != result)
result

mail <- read.csv("spam.csv" , header = T)
mail[is.na(mail)] <- 0  
nm2 <- naiveBayes(mail[2:13] , mail$메일종류 , laplace = 0)
head(mail) 

result2 <- predict(nm2 , mail[2:13])
sum(mail$메일종류 != result2)
result2

nm
nm2

library(KoNLP)
txt <- readLines('spam.txt')
place <- sapply(txt , extractNoun , USE.NAMES = F)
useSejongDic()
c <- unlist(place) 
place <- Filter(function(x) {nchar(x) >=2} , c)
res <- str_replace_all(place , "[^[:alpha:]]" , "")
res <- res[res != ""]
res

wordcount <- table(res)
wordcount2 <- sort(table(res) , decreasing=T)
wordcount2

library(wordcloud);
library(RColorBrewer)
palete <- brewer.pal(8 , "Set2") 
wordcloud(names(wordcount) , freq = wordcount , scale=c(5,1) , rot.per = 0.25 , min.freq = 1 , random.order = F , random.color = T , colors = palete) 



