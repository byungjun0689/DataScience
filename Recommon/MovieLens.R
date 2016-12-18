install.packages("recommenderlab")
library("recommenderlab")
library("reshape2")

movie <- read.csv("train_recomon.csv",stringsAsFactors = F)
head(movie)

movie.matrix<- as(movie,"realRatingMatrix")

nb_ratings_per_user <-
  dcast(movie, user ~ ., fun.aggregate=length, value.var='rating')

nb_ratings_per_movie <-
  dcast(movie, movie ~ ., fun.aggregate=length, value.var='rating')


train_proportion <- .5
nb_of_given_ratings_per_test_user <- 10

evaluation_scheme <- evaluationScheme(
  movie.matrix, 
  method='split',
  train=train_proportion,
  k=1,
  given=nb_of_given_ratings_per_test_user)
