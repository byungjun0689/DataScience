# SNS 데이터 가져오기
# 나의 페이스북 댓글 가져오기 -> 텍스트분석 -> 간단한 시각화

fb_oauth <- 'EAACEdEose0cBAKkSzpIOVu5GqP6UGutNSH5WXhN2fHaesMZCi6XOWS0jRXMtR3ZAD0QkGpJktXGNx9iBWQYNZBEYWQvxYFVA69evlykH03zKY7ZBnZCTGXfWkBrZA9EfWuxxKAjn9ysonJiPTh6rBa4rMEgou0mCJQIbX0VvpizyGvQW4eEmiBTCx8Ned7B8MZD'
fb_oauth

install.packages("Rfacebook")
library(Rfacebook)

#나의 정보 가져오기 ####
getUsers('me', token=fb_oauth, private_info = F) 

#나의 페이지내 글 가져오기 ####
getPage('OhmyStarKorea', token=fb_oauth, n=1) 
getPage('me', token=fb_oauth, n=2) 
getPage('me', token=fb_oauth, n=10) 

#최근 100개 가져오기 ####
all.reviews <- getPage('OhmyStarKorea', token=fb_oauth, n=200) 
all.reviews$created_time #올린 시간 확인하기(+9시간)
all.reviews$message  #글만 뽑기

colnames(all.reviews)

fbdata <- all.reviews$message
is.na(fbdata)  #NA값 확인1
fbdata <- fbdata[!is.na(fbdata)]
is.na(fbdata)  #NA값 확인2


#저장될 위치 확인 가능 ####
getwd() 
write.csv(fbdata, 'fbdata.csv') 
fbdata <- read.csv('fbdata.csv', stringsAsFactors = F)
fbdata[1:5,]

View(fbdata)
fbdata <- fbdata$x  #읽어온 csv파일을 기존 데이터처럼 사용하기 위해.
fbdata[1:5]

# KoNLP ####
install.packages("KoNLP", repos="http://cran.nexr.com")
Sys.setenv(JAVA_HOME = "C:/Program Files/Java/jre1.8.0_121")

install.packages("KoNLP")
library(KoNLP)

install.packages("tm")
library(tm)


# 명사만 추출해서 워드클라우드 그려보기 ####
ko.words <- function(doc){
  d <- as.character(doc)
  extractNoun(d)
}

options(mc.cores=1)
cps <- Corpus(VectorSource(fbdata))
tdm <- TermDocumentMatrix(cps,
                          control=list(tokenize=ko.words,
                                       removePunctuation=T,
                                       removeNumbers=T,
                                       wordLengths=c(3, 6)))  #2글자 이상, 5글자 이하

Terms(tdm)

install.packages('slam')
library('slam')

install.packages("wordcloud")
library(wordcloud)
slam ::row_sums(tdm) #모든 단어가 몇번 나왔는지 확인 가능
v <- sort(slam::row_sums(tdm), decreasing = T)
d <- data.frame(word=names(v), freq=v)
View(d)

wordcloud(d$word, d$freq)

#색상 보기
display.brewer.all()
color <- brewer.pal(9,'Set1')
color #순서대로 색상번호 확인 가능
plot(1:9, col=color, pch=20) #색상 확인해보기

wordcloud(d$word, d$freq,
          random.order = F,
          rot.per=0,                #세로로 90 / 0은 모두 가로
          colors=color[9:1])



#색상 보기
display.brewer.all()
color <- brewer.pal(9,'Set1')
color #순서대로 색상번호 확인 가능
plot(1:9, col=color, pch=20) #색상 확인해보기

---
fbdata <- gsub("ed","",fbdata)
fbdata <- gsub("bd","",fbdata)
fbdata <- gsub("bc","",fbdata)
fbdata <- gsub("be","",fbdata)
fbdata <- gsub("com","",fbdata)
fbdata <- gsub("www","",fbdata)


ko.words <- function(doc){
  d <- as.character(doc)
  extractNoun(d)
}

options(mc.cores=1)
cps <- Corpus(VectorSource(fbdata))
tdm <- TermDocumentMatrix(cps,
                          control=list(tokenize=ko.words,
                                       removePunctuation=T,
                                       removeNumbers=T,
                                       wordLengths=c(2, 5)))  #2글자 이상, 5글자 이하

tdm

slam ::row_sums(tdm) 
v <- sort(slam::row_sums(tdm), decreasing = T)
d <- data.frame(word=names(v), freq=v)
View(d)



wordcloud(d$word, d$freq)


wordcloud(d$word, d$freq,
          random.order = F,
          rot.per=0,
          colors=color[9:1],
          scale=c(8,1))


