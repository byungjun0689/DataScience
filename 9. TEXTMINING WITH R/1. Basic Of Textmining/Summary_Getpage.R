install.packages(c('rvest', 'httr', 'stringr', 'readxl', 'dplyr', 'tm', 'qgraph', 'KoNLP'), repos='http://cran.nexr.com')
install.packages("magrittr")
install.packages("qgraph")
install.packages("scales")
install.packages("data.table")
install.packages("wordcloud")
library(httr) # http 통신.
library(rvest)
library(dplyr)
library(qgraph)
library(wordcloud)

#pagerTagAnchor1

base_url = "http://movie.daum.net/moviedb/grade?movieId=105570&type=netizen&page="

all.reviews <- c()

for(page in 1:10000){
  print(page)
  url = paste0(base_url,page)
  r = GET(url)
  h = read_html(r)
  comment_area = html_nodes(h, '.list_review')
  comments = html_nodes(comment_area, '.desc_review')
  reviews = html_text(comments)
  
  if(length(reviews) == 0){ break }
  all.reviews = c(all.reviews, reviews)
}

library(KoNLP) 
library(stringr)
library(tm)

ko.words <- function(doc){
  d <- as.character(doc)
  extractNoun(d)
}

options(mc.cores=1)

all.reviews <- gsub("\\n","",all.reviews)
all.reviews <- gsub("\\t","",all.reviews)
all.reviews <- str_trim(all.reviews)
all.reviews <- gsub("tistory","",all.reviews)
all.reviews <- gsub("com","",all.reviews)
all.reviews <- gsub("http","",all.reviews)

review.corpus <- Corpus(VectorSource(all.reviews))
tdm <- TermDocumentMatrix(review.corpus, control=list(tokenize=ko.words,wordLengths=c(2,Inf), removeNumbers=T, removePunctuation=T))
tdm.matrix <- as.matrix(tdm)

rownames(tdm.matrix)[1:20]
word.count <- rowSums(tdm.matrix)
word.order <- order(word.count,decreasing = T)
freq.words <- tdm.matrix[word.order[1:20],]
cooccur <- freq.words %*% t(freq.words)

qgraph(cooccur,
       labels=rownames(cooccur), # 가로세로 모두 단어다 그래서 colnames로 해도상관없다. 단어가 안짤리고 잘나온다. 
       diag=F, # 자기자신을 나타내는 대각선 부분을 없앤다. 
       layout='spring', # Node의 위치를 바꿀수있다. 
       edge.color='blue',
       vsize=log(diag(cooccur)*5))


# WordCloud about arrive(Contact)


tot.cooccur <- tdm.matrix %*% t(tdm.matrix)

word.count <- diag(tot.cooccur)
word.count <- as.data.frame(word.count)

wordcloud(words = rownames(word.count), freq = word.count$word.count, min.freq = 3,
          max.words=200, random.order=FALSE, rot.per=0.35,colors=brewer.pal(8, "Dark2"))

word.count2 <- data.frame(txt=rownames(word.count), freq = as.integer(sqrt(word.count$word.count * 3)))
head(word.count2[order(word.count2$freq,decreasing = T),])

wordcloud2(word.count2,minSize = 20)

