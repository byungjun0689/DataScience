# 유사부류 

academy <- read.csv("data/academy.csv",stringsAsFactors = F, header = T)
head(academy)
dist_academy <- dist(academy,method="euclidean")
dist_academy

# 3차원 이상 데이터를 2차원으로 변경
two_coord <- cmdscale(dist_academy)
plot(two_coord,type="n")
text(two_coord,as.character(1:52))


# 순대국 사장님
food <- read.csv("data/food.csv",stringsAsFactors = F, header = T)
food <- food[-1]
head(food)

# 같은 1일때라도 1,1 의 거리를 구하게 되면 0 이된다. 
food.mult <- t(as.matrix(food)) %*% as.matrix(food) # 빈도 카운트 
dist.food <- dist(food.mult)
dist.food

two_coord2 <- cmdscale(dist.food)
plot(two_coord2,type="n")
text(two_coord2,rownames(food.mult))


