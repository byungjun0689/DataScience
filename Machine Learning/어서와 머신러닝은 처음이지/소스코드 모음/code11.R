library(igraph)

#전화
tele <- read.csv("tele.csv",header=F)
levels_all <- union(levels(tele$V1) , levels(tele$V2))
tele$from <- factor(tele$V1 , levels = levels_all) 
tele$to <- factor(tele$V2 , levels = levels_all) 
tele$from2 <- as.integer(tele$from) 
tele$to2 <- as.integer(tele$to) 
tele_mat <- cbind(from = tele$from2 , to = tele$to2 , cnt = tele$V3) 

tele.w <- graph.edgelist(tele_mat[,1:2])
E(tele.w)$weight <- tele_mat[,3]
str(tele.w)

tele.diag <- rep(0,16) + 5
tele.name <- levels_all

plot(tele.w,  
     vertex.size=10,vertex.shape="circle",vertex.size=tele.diag,
     vertex.label=tele.name,vertex.label.font=1,
     vertex.label.cex=1+sqrt(tele.diag)/15,
     edge.width=2+E(tele.w)$weight/2, edge.arrow.width= E(tele.w)$weight/50)

#메일
email <- read.csv("email.csv",header=F)
levels_all <- union(levels(email$V1) , levels(email$V2))
email$from <- factor(email$V1 , levels = levels_all) 
email$to <- factor(email$V2 , levels = levels_all) 
email$from2 <- as.integer(email$from) 
email$to2 <- as.integer(email$to) 
email_mat <- cbind(from = email$from2 , to = email$to2 , cnt = email$V3) 

email.w <- graph.edgelist(email_mat[,1:2])
E(email.w)$weight <- email_mat[,3]
str(email.w)

email.diag <- rep(0,16) + 5
email.name <- levels_all

plot(email.w,  
     vertex.size=10,vertex.shape="circle",vertex.size=email.diag,
     vertex.label=email.name,vertex.label.font=1,
     vertex.label.cex=1+sqrt(email.diag)/15,
     edge.width=2+E(email.w)$weight/2, edge.arrow.width= E(email.w)$weight/50)

#BOOK
book <- read.csv("book.csv",header=T , stringsAsFactors = F)
book[is.na(book)] = 0  
rownames(book) <- book[,1]
book <- book[-1]
book_mat <- as.matrix(book) 
book_mat

n <- nrow(book_mat)
m <- ncol(book_mat)
book_mat2 <- rbind(cbind(matrix(0,n,n),book_mat),cbind(t(book_mat),matrix(0,m,m)))
book_mat2

library(sna)
vertex.col <- c(rep("blue",n),rep("green",m))
vertex.cex <- c(rep(2,n),rep(2,m))
gplot(book_mat2, mode="circle", displaylabels=T, boxed.labels=F, 
      vertex.col=vertex.col, vertex.cex=vertex.cex, 
      label.col=vertex.col, label.cex=1.2, usearrows=F)

book_mat3 <- book_mat %*% t(book_mat) 
diag(book_mat3) <- rep(0 , dim(book_mat3)[1])
book_mat3[book_mat3 > 0] = 1
book_mat3

gplot(book_mat3, mode="circle", displaylabels=T, boxed.labels=F, 
      vertex.col="blue", vertex.cex=2, 
      label.col="green", label.cex=1.2, usearrows=F)

rownames(book_mat3)
degree(book_mat3)
degree(book_mat3 , cmode ="indegree") 
degree(book_mat3 , cmode ="outdegree") 

gden(book_mat3)
reachability(book_mat3) 

#무작위 그래프샘플
set.seed(123) 
yang <- rgraph(10 , tprob = 0.2) 
gplot(yang , displaylabels = T , boxed.labels = F , vertex.cex = 2) 

components(yang) 
component.dist(yang) 

sedist(yang , method = "hamming")
cluster <- equiv.clust(yang , method = "hamming" , cluster.method = "complete") 
plot(cluster) 

bplot <- blockmodel(yang , cluster , h = 3)
plot(bplot)
bplot

yang
geodist(yang)$gdist 

closeness(book_mat3)
rownames(book_mat3)[which.max(closeness(book_mat3))]

#변환
range(tele_mat[,2])
tele_mat2 <- matrix(0 , 12 , 12)

for(i in 1:16) {
  tele_mat2[as.integer(tele_mat[i,][1]) , as.integer(tele_mat[i,][2])] = as.integer(tele_mat[i,][3])  
}

rownames(tele_mat2) <- union(levels(tele$V1) , levels(tele$V2))
colnames(tele_mat2) <- union(levels(tele$V1) , levels(tele$V2))
tele_mat2

gplot(tele_mat2, mode="circle", displaylabels=T, boxed.labels=F, 
      vertex.col="blue", vertex.cex=2, edge.lwd = tele_mat2 , 
      label.col="green", label.cex=1.2, usearrows=F)

tele_mat2[tele_mat2 > 0] <- 1
tele_mat2

betweenness(tele_mat2)
rownames(tele_mat2)[which.max(betweenness(tele_mat2))]

round(evcent(tele_mat2) , 3)
round(evcent(t(tele_mat2)) , 3)

abs(eigen(tele_mat2)$vectors[,1])
rownames(tele_mat2)[which.max(abs(eigen(tele_mat2)$vectors[,1]))]

#변환 
email_mat2 <- matrix(0 , 12 , 12)
email_mat2[email_mat[,1:2]] <- 1
rownames(email_mat2) <- email.name
colnames(email_mat2) <- email.name
email_mat2

netlogit(tele_mat2 , email_mat2) 

