

hr <- read.table("HR.csv",sep=";",header = T)
head(hr)

hr <- hr[,c(1:6,8:9,7)]
head(hr)

hr$number_project <- as.factor(hr$number_project)
hr$Work_accident <- as.factor(hr$Work_accident)
hr$promotion_last_5years <- as.factor(hr$promotion_last_5years)
hr$sales <- as.factor(hr$sales)
hr$left <- as.factor(hr$left)

str(hr)


model = glm(left ~ ., data=hr,family = binomial)
summary(model)

