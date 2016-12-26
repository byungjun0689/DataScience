academy <- read.csv("academy.csv" , stringsAsFactors = F , header = T)
academy <- academy[-1]
head(academy)

dist_academy <- dist(academy , method = "euclidean")
dist_academy

two_coord <- cmdscale(dist_academy)
plot(two_coord , type = "n")
text(two_coord , as.character(1:52))

food <- read.csv("food.csv" , stringsAsFactors = F , header = T)
food <- food[-1]
head(food) 

#肋给等 规过 
dist(t(food) , method = "euclidean")

#壳篮 规过 
food.mult <- t(as.matrix(food)) %*% as.matrix(food)
food.mult

dist.food <- dist(food.mult)
dist.food

two_coord2 <- cmdscale(dist.food)
plot(two_coord2 , type = "n")
text(two_coord2 , rownames(food.mult))

