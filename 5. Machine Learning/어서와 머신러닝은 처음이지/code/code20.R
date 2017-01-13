paper <- read.csv("paper1.csv" , header = T)
paper[is.na(paper)] <- 0 
rownames(paper) <- paper[,1] 
paper <- paper[-1]
paper2 <- as.matrix(paper) 
book <- read.csv("book_hour.csv" , header = T)
paper2
book

library(sna) 
x11()
gplot(paper2 , displaylabels = T, boxed.labels = F , vertex.cex = sqrt(book[,2]) , vertex.col = "blue" , vertex.sides = 20 ,
      edge.lwd = paper2*2 , edge.col = "green" , label.pos = 3)

G.w <- 1 / paper2
D.w <- geodist(G.w , ignore.eval = F)$gdist
#round(closeness(G.w , ignore.eval = F) ,3)
clo <- round(closeness(G.w , cmode = "suminvundir" , ignore.eval = F) ,3)
bet <- round(betweenness(G.w , ignore.eval = F),3)
evc <- round(evcent(t(paper2) , ignore.eval = F),2)
clo
bet
evc

#result 
ret <- cbind(book , clo , bet , evc) 
ret[order(ret$clo , decreasing = TRUE) , ]
ret[order(ret$bet , decreasing = TRUE) , ]
ret[order(ret$evc , decreasing = TRUE) , ]
ret 

#정규화 
ret$clo2 <- (ret$clo - min(ret$clo)) / diff(range(ret$clo))
ret$bet2 <- (ret$bet - min(ret$bet)) / diff(range(ret$bet))
ret$evc2 <- (ret$evc - min(ret$evc)) / diff(range(ret$evc))
ret$book2 <- (ret$book - min(ret$book)) / diff(range(ret$book))
ret

library(nnet) 
attach(ret)
train.nnet <- nnet(book2 ~ clo2 + bet2 + evc2 , data = ret , rang = 0.15 , size = 5, decay = 3e-4 , maxit = 140) 
pred <- predict(train.nnet , ret[6:8]) 
ret$pred <- pred
mean(abs(ret$pred - ret$book2))

#모델평가 
ret[order(ret$book , decreasing = TRUE) , ]$name
ret[order(ret$pred , decreasing = TRUE) , ]$name

#연락하는 동창생 수 
fri <- read.csv("friends_cnt.csv" , header = T) 
fri
ret$fri <- (fri$friends - min(fri$friends)) / diff(range(fri$friends))
ret

attach(ret)
train.nnet <- nnet(fri ~ clo2 + bet2 + evc2 , data = ret , rang = 0.15 , size = 5, decay = 3e-4 , maxit = 140) 
pred2 <- predict(train.nnet , ret[6:8]) 
ret$pred2 <- pred2
mean(abs(ret$pred2 - ret$fri))

#모델평가 
ret[order(ret$fri , decreasing = TRUE) , ]$name
ret[order(ret$pred2 , decreasing = TRUE) , ]$name

