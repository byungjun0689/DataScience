library(httr) # http 통신.
library(rvest)
library(dplyr)
library(XML)
library(RCurl)
library(stringr)
library(KoNLP)
useSejongDic()
install.packages("wordcloud2")
library(wordcloud2)
install.packages("qgraph")
library(qgraph)

url = "http://movie.naver.com/movie/bi/mi/point.nhn?code=121051"

r = GET(url)
h = read_html(r)

movie_ratio_root <- html_nodes(h,".ifr_module2")
iframe.url = paste0("http://movie.naver.com",html_attr(html_node(movie_ratio_root[1],"iframe"),"src"),"&page=")

tot_score <- c()
tot_reply <- c()
tot_good <- c()
tot_bad <- c()

for(i in 1:50000){
  if(i %% 100 == 0){
    print(i)
  }
  tmp_url = paste0(iframe.url,i)
  r2 <- GET(tmp_url)
  html <- read_html(r2)

  ratio_root <- html_nodes(html,".score_result")
  each_ratio <- html_nodes(ratio_root,"li")
  ratio_length <- length(each_ratio) 
  
  for(i in 1:ratio_length){
    score <- html_text(html_nodes(html_nodes(each_ratio[i],".star_score"),"em"))
    reply <- gsub("관람객","",gsub("BEST","",str_trim(html_text(html_node(html_nodes(each_ratio[i],".score_reple"),"p")))))
    good <- html_text(html_nodes(html_nodes(each_ratio[i],".btn_area"),"strong"))[1]
    bad <- html_text(html_nodes(html_nodes(each_ratio[i],".btn_area"),"strong"))[2]
    tot_score <- c(tot_score,score)
    tot_reply <- c(tot_reply,reply)
    tot_good <- c(tot_good,good)
    tot_bad <- c(tot_bad,bad)
  }
  
  if(ratio_length == 0){ break }
}

naver.ratio.df <- data.frame(score = as.integer(tot_score), reply = as.character(tot_reply), good = as.integer(tot_good), bad = as.integer(tot_bad))
naver.ratio.df$reply <-  as.character(naver.ratio.df$reply)
mean(naver.ratio.df$score)
boxplot(naver.ratio.df$score)

write.csv(naver.ratio.df,"곡성.csv")

library(tm)

all.reviews <- naver.ratio.df$reply

ko.words <- function(doc){
  d <- as.character(doc)
  extractNoun(d)
}

options(mc.cores=1)

# all.reviews <- str_trim(all.reviews)
# all.reviews <- gsub("\\n","",all.reviews)
# all.reviews <- gsub("\\t","",all.reviews)
# all.reviews <- gsub("ㅇㄱㅁㅈ￦","",all.reviews)
# all.reviews <- gsub("라라라라","",all.reviews)

review.corpus <- Corpus(VectorSource(all.reviews))
tdm <- TermDocumentMatrix(review.corpus, control=list(tokenize=ko.words,wordLengths=c(2,5), removeNumbers=T, removePunctuation=T))
tdm.matrix <- as.matrix(tdm)

# rownames(tdm.matrix)[1:20]
# word.count <- rowSums(tdm.matrix)
# word.order <- order(word.count,decreasing = T)
# freq.words <- tdm.matrix[word.order[1:20],]
# 
# cooccur <- freq.words %*% t(freq.words)
# 
# qgraph(cooccur,
#        labels=rownames(cooccur), # 가로세로 모두 단어다 그래서 colnames로 해도상관없다. 단어가 안짤리고 잘나온다. 
#        diag=F, # 자기자신을 나타내는 대각선 부분을 없앤다. 
#        layout='spring', # Node의 위치를 바꿀수있다. 
#        edge.color='blue',
#        vsize=log(diag(cooccur)*5))

tmp.reviews <- naver.ratio.df$reply


tmp.reviews <- Filter(function(x){nchar(x) <= 20}, tmp.reviews)
nouns = sapply(tmp.reviews, extractNoun, USE.NAMES=F)
extractNoun(nouns[1])
unlist_nouns <- unlist(nouns)
#filter2_nouns <- Filter(function(x){nchar(x) >= 2 & nchar(x) <= 5}, unlist_nouns)
#테이블 형태로 변환
wordcount <- table(unlist_nouns)

