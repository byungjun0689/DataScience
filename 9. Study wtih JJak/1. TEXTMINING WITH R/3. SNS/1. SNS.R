# API
# Application Programming Interface

# https://developers.facebook.com/tools/explorer

# User 정보. 

install.packages("Rfacebook")
library(Rfacebook)
library(KoNLP)
library(tm)
library(wordcloud)
library(stringr)

fb_oauth <- ''
fb_oauth

getUsers('me', token=fb_oauth, private_info = F)


# POST정보 가지고 오기.

all.reviews <- getPage("me",token = fb_oauth,n=100)
all.reviews$created_time # UTC 시간대. +9:00 해야 한국시간이 된다. 
all.reviews$message # TEXTepdlxj 

# 날짜지정.
all.reviews2 <- getPage("me", token=fb_oauth, n = 100, 
                       since = '2015/10/01', until='2015/10/31')
all.reviews2$created_time

all.reviews <- getPage("me",token = fb_oauth,n=1000)

# NA가 많다. 
all.text <- all.reviews$message
all.text <- all.text[!is.na(all.text)]
all.text

write.csv(all.text, 'reviews.csv')

all.text <- read.csv('reviews.csv', stringsAsFactors = F)
head(all.text)
all.reviews <- all.text$x


# wordCloud
options(mc.cores=1)

ko.words = function(doc){
  d <- as.character(doc)
  extractNoun(d)
}

cps <- Corpus(VectorSource(all.reviews))
tdm <- TermDocumentMatrix(cps,
                          control=list(tokenize=ko.words,
                                       removePunctuation=T,
                                       removeNumbers=T,
                                       wordLengths=c(2, 5)))
tdm

v <- sort(slam::row_sums(tdm), decreasing = T)
d <- data.frame(word = names(v), freq = v)
View(d)

wordcloud(d$word, d$freq,random.order = F)

display.brewer.all()
pal <- brewer.pal(9, 'Set1')
pal
plot(1:9, col = pal, pch = 20)

wordcloud(d$word, d$freq,
          random.order = F,
          rot.per = 0,
          colors = pal) # 글자 조절을 하려면 scale = c(8,1)추가.


# PNG로 저장하려면
png('me.png', width=800, height=800)
# - 그림그리는 명령.
dev.off()



# 대한민국 정부포털 데이터를 가지고 와서 정보 뿌리기.
# https://www.facebook.com/govkorea/   ID기억하기.

getUsers('govkorea', token=fb_oauth, private_info = F) #정부포털 정보.
getUsers('happylotteworld', token=fb_oauth, private_info = F)

all.reviews <- getPage("happylotteworld",token=fb_oauth,n=500)
all.reviews <- all.reviews$message

write.csv(all.reviews,'lotte.csv')


all.reviews <- all.reviews[!is.na(all.reviews)]


ko.words = function(doc){
  d <- as.character(doc)
  pos <- paste(SimplePos09(d))
  extracted <- str_match(pos, '([가-힣]+)/[NP]') # 명사와 동사만가지고오기.
  keyword <- extracted[,2]
  keyword[!is.na(keyword)]
}


options(mc.cores=1)
cps <- Corpus(VectorSource(all.reviews))

tdm <- TermDocumentMatrix(cps,
                          control=list(tokenize=ko.words,
                                       removePunctuation=T,
                                       removeNumbers=T,
                                       wordLengths=c(2, 5),
                                       weighting = weightTfIdf))

tdm

v <- sort(slam::row_sums(tdm),decreasing=TRUE)
d <- data.frame(word = names(v),freq=v)
View(d)


pal <- brewer.pal(9,"Set1")

#png('govkorea.png', width=800,height=800)
#par(family = 'AppleGothic')
wordcloud(d$word, d$freq,
          random.order=F,
          rot.per=0,
          colors = pal)
#dev.off()

