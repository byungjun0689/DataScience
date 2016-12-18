install.packages("recommenderlab")
library(recommenderlab)
library(ggplot2)
data(MovieLense)
ml.df <- as(MovieLense, "data.frame")
head(ml.df)

ratings_v <- as.vector(MovieLense@data)
unique(ratings_v)
ratings_tbl <- table(ratings_v)
ratings_tbl

ratings_v <- ratings_v[ratings_v != 0]
qplot(ratings_v, bins=5) + ggtitle("평점 분포")

views_per_movie <- colCounts(MovieLense)

views_tbl <- data.frame(
  movie = names(views_per_movie),
  views = views_per_movie
)

views_tbl <- views_tbl[order(views_tbl$views, decreasing = TRUE), ]

head(views_tbl)

ggplot(views_tbl[1:5, ], aes(x = movie, y = views)) +
  geom_bar(stat="identity") + theme(axis.text.x = element_text(angle = 45, hjust = 1)) + ggtitle("가장 많이 본 영화 5 개")


ratings_avg <- colMeans(MovieLense)

ratings_avg_relevant <- ratings_avg[views_per_movie > 100]

qplot(ratings_avg_relevant) + stat_bin(binwidth = 0.1) +
  ggtitle(paste("연관성이 있는 영화만 뽑아본 평점 분포"))


ratings_movies <- MovieLense[rowCounts(MovieLense) > 50,
                             colCounts(MovieLense) > 100]
ratings_movies

percentage_training <- 0.8
items_to_keep <- 15
rating_threshold <- 3
n_eval <- 1

eval_scheme <- evaluationScheme(data = ratings_movies, method = "split",
                                train = percentage_training, 
                                given = items_to_keep, 
                                goodRating = rating_threshold, 
                                k = n_eval) 


algorithms_to_evaluate <- list(
  IBCF_cos = list(name = "IBCF", param = list(method ="cosine")),
  IBCF_cor = list(name = "IBCF", param = list(method ="pearson")),
  UBCF_cos = list(name = "UBCF", param = list(method ="cosine")),
  UBCF_cor = list(name = "UBCF", param = list(method ="pearson")),
  random = list(name = "RANDOM", param = NULL)
)

n_recommendations <- c(1, 5, seq(10, 100, 10))

results <- evaluate(eval_scheme, algorithms_to_evaluate, type = "ratings")
plot(results)

sapply(results, class) == "evaluationResults"
lapply(results, avg)

sapply(results, avg)

# http://parallel.xwmooc.org/recommendation-implementation.html
