# 다음 영화 네티즌 평점 분석. 
# Internet 
# Client -> http -> Server
# GET / POST 
# 200 OK -> 서버가 내가 원하는 코드를 주는 것이다. 
# 그외의 것은 서버가 고장났거나, 내가 이상하게 보냈거나. 

install.packages(c('rvest', 'httr', 'stringr', 'readxl', 'dplyr', 'tm', 'qgraph', 'KoNLP'), repos='http://cran.nexr.com')

library(httr) # http 통신.

#url = 'http://movie.daum.net/moviedetail/moviedetailNetizenPoint.do?movieId=73750&t__nil_NetizenPoint=tabName'

# 동강 부분
url = "http://movie.daum.net/moviedb/grade?movieId=54081&type=netizen&page=5"
r <- GET(url)


# 인터넷을 크롤링하는 이유 
# 내용을 분석하기 위해서 크롤링한다. 내가 필요한 부분만 빼낸다. 
# <p>안녕하세요</p>  P태그로 감싸져있다. Element 라고도 하고 Node라고도한다. (엄격하게는 다르다.)
# <h3 class='title'> 텍스트에 감정읽기 </h3>  // class 는 여러개를 가질 수 있다. 
# <h3 id='title'> 텍스트에 감정읽기 </h3>    // id는 하나밖에 없다. 페이지하나에.

library(rvest)
library(dplyr)

h = read_html(r) # Read HTML or XML.
comment_area = html_nodes(h, '.list_review') # list_review안에 다 있다.    // .은 class
# html_nodes 노드를 찾는것.
comments = html_nodes(comment_area, '.desc_review') # 그 안에서 desc_review안에 코멘트가 존재한다. id는 #
comments = repair_encoding(html_text(comments)) # html_text 노드사이에있는 텍스트를 가지고 온다. 
comments


# 여러페이지 크롤링하기.

base_url <-  "http://movie.daum.net/moviedb/grade?movieId=54081&type=netizen&page="

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


# Save and Read data

all.reviews[1:5]

write.csv(all.reviews[20:25],"reviews.csv")
tmp <- read.csv("reviews.csv", stringsAsFactors = F)




# 키워드 추출 (KoNLP, stringr)
# 아직 문제 전체를 이해하는 부분은 없다. 해당 단어만 뽑아서 분석하는 것이 최대한인데. 의외로 많은 부분을 해석할 수 있다. 
# 전반적으로 하고 싶은 얘기를 알고싶기때문에 단어로도 할 수 있다. 

library(KoNLP) # java로 만들어진 형태소 분석기를 사용한다. 한나눔이라는 형태소 분석기다. 
library(stringr)
extractNoun('이 영화 정말 재미있다')

# 형태소 분석
# 이(관형사) 영화(명사) 정말(부사) 재미있(형용사)다(어미)  -> 관형사, 어미는 보통 버린다. / 명,형,동사 정도만 분석을 하는데 사용한다.

pos <- paste(SimplePos09('이 영화 정말 재미있다'))
# str_match 찾기

str_match(pos,"N")
str_match(pos,'[가-힣]+') #[가-힣]한글만 찾아라. 가~힣 // + 1글자 이상 다 찾아라. 

str_match(pos,'[가-힣]+/N') #한글로가다가 N으로 끝나는.

str_match(pos,'([가-힣]+)/N') #한글로가다가 N으로 끝나는 것중에 한글로 된부분을 2번째 필드로 추


str_match(pos,'([가-힣]+)/[NP]') #한글로가다가 N/P으로 끝나는 것중에 한글로 된부분을 2번째 필드로 추
extracted <- str_match(pos,'([가-힣]+)/[NP]') 
extracted <- extracted[,2]
extracted[!is.na(extracted)]


# 15분 정도부터 다시 듣기 ( 메모리떄문에 R에서 실행이 안댐. 4기가....(회사컴))
# 
# Corpus (말뭉치) : 기존의 데이터를 합쳐놓은 것
# 텍스트 분석의 첫번째 단계.
# 언어학 연구학자들이 말뭉치를 많이 만든다.
# 사전도 말뭉치를 기반으로 한다.
# 
# 말뭉치만 가지고는 분석을 할 수 없다.
# 통계적으로 사용하기 위해선 Term Document Matrix 로 만들어야 한다.
# 
# TM : 어떠한 단어가 나타나는지 표로 만들어주는 것
# 
# TM 을 바탕으로 한다.
# 
# https://brunch.co.kr/@mapthecity/9

# 이상한 단어는 제거하도록하고 내가 원하는 단어는 사전에 입력.

install.packages(c('rvest', 'httr', 'stringr', 'readxl', 'dplyr', 'tm', 'qgraph', 'KoNLP'), repos='http://cran.nexr.com')


library(tm)

texts <- c('hello world','hello text')
texts

Corpus(VectorSource(texts))

cps <- Corpus(VectorSource(texts))
TermDocumentMatrix(cps)

tdm <- TermDocumentMatrix(cps)
as.matrix(tdm)


# 한국어는 처리를 좀더 해줘야한다.
# KoNLP + TM을 잘 해야한다.


texts <- c('오늘은 영화를','영화에는 팝콘')
library(KoNLP)

cps <- Corpus(VectorSource(texts))
tdm <- TermDocumentMatrix(cps)
as.matrix(tdm)

# 우리가 원하는 것은 영화 / 오늘 / 팝콘 이렇게 나오기를 원했는데 안된다.
# 함수

add.one <- function(x){
  return(x+1)
}
add.one(2)


# 명사만 꺼내는 함수가 있다. extractNoun()
extractNoun('오늘은 영화를')

as.character()

ko.words <- function(doc){
  d <- as.character(doc)
  extractNoun(d)
}

options(mc.cores=1) # 한나눔 형태소 분석기 Java, TM Packages는 병렬처리를 이용. 두개가 같이 돌면 충돌.

tdm <- TermDocumentMatrix(cps, control=list(tokenize=ko.words)) # list로 만들어서 한번에 넘겨주는데 토큰 만드는 것을 ko.words 로
as.matrix(tdm) # 결과가 이상하다. 영어의 경우 1자 놈들을 없앤다. 1,2글자 는 없앤다. 왜냐 없기 때문에 한글은 대부분이 1~2글자



### TMP : 팝콘나오게 ###

useSejongDic()
word <- data.frame(c("팝콘"),"ncn")
extractNoun(texts)
buildDictionary(ext_dic = c('sejong','woorimalsam'), user_dic = word,replace_usr_dic = T)
tdm <- TermDocumentMatrix(cps, control=list(tokenize=ko.words, wordLengths=c(1,Inf), stopwords = c('팝','콘','를')))  # 단어길이 제약 풀기.
as.matrix(tdm)   

#### 

# http://dbrang.tistory.com/1061

library(httr)
library(rvest)

base_url = 'http://movie.daum.net/moviedb/grade?movieId=84000&type=netizen&page='

all.reviews = c()
for(page in 1:10){
  print(page)
  url = paste(base_url, page, sep = '')
  r = GET(url)
  h = read_html(r)
  comment_area = html_nodes(h, '.list_review')
  comments = html_nodes(comment_area, '.desc_review')
  reviews = html_text(comments)
  
  if(length(reviews) == 0){ break }
  all.reviews = c(all.reviews, reviews)
}

review.corpus <- Corpus(VectorSource(all.reviews))
options(mc.cores=1)
tdm <- TermDocumentMatrix(review.corpus, control = list(tokenize=ko.words,wordLengths=c(1,Inf)))
tdm.matrix <- as.matrix(tdm)
dim(tdm.matrix)

# 숫자 지우기
tdm <- TermDocumentMatrix(review.corpus, control = list(tokenize=ko.words,wordLengths=c(1,Inf), removeNumbers=T))
tdm.matrix <- as.matrix(tdm)


ko.words2 <- function(doc){
  d <- as.character(doc)
  pos <- paste(SimplePos09(d))
  extracted <- str_match(pos, '([가-힣]+)/[NP]')
  keyword <- extracted[,2]
  keyword[!is.na(keyword)]
}



options(mc.cores=1)
tdm <- TermDocumentMatrix(review.corpus, control = list(tokenize=ko.words2,wordLengths=c(1,5), removeNumbers=T)) 
tdm.matrix <- as.matrix(tdm)
dim(tdm.matrix)

rownames(tdm.matrix)[1:20]

library(tm)


doc <- c('This is a banana.', 'That is an apple.')

corpus <- Corpus(VectorSource(doc))

TermDocumentMatrix(corpus)

tdm <- TermDocumentMatrix(corpus) # that, this가 대명사.
as.matrix(tdm)

tdm <- TermDocumentMatrix(corpus, control = list(removePunctuation = T)) # Punctuation (.과 같은 특수문자 제거.)
as.matrix(tdm)

tdm <- TermDocumentMatrix(corpus, control = list(removePunctuation = T, wordLengths = c(1,Inf)))  # a, an , is, that, this 제거를 하고싶다.
as.matrix(tdm)

tdm <- TermDocumentMatrix(corpus, control = list(removePunctuation = T, wordLengths = c(1,Inf), stopwords = T)) # 영어를 기준으로 제거
as.matrix(tdm)

stopwords() # 영어

stopwords('ge') # 독일어

stopwords('fr') # 프랑스어

tdm <- TermDocumentMatrix(corpus, control = list(removePunctuation = T, wordLengths = c(1,Inf), stopwords = stopwords('ge')))
# 독일어로 없앤다. 
as.matrix(tdm)

tdm <- TermDocumentMatrix(corpus, control = list(removePunctuation = T, wordLengths = c(1,Inf), stopwords = c('a','an','is'))) 
as.matrix(tdm)

texts

options(mc.cores=1)

cps <- Corpus(VectorSource(texts))

tdm <- TermDocumentMatrix(cps, control = list(tokenize=ko.words,wordLengths=c(1,Inf)))

tdm.matrix <- as.matrix(tdm)

tdm.matrix  %*% t(tdm.matrix ) # Co-occurrence Matrix 만들기. 

all.views <- read.csv('reviews.csv', stringsAsFactors=F)$x

review.corpus <- Corpus(VectorSource(all.views))

tdm <- TermDocumentMatrix(review.corpus, control = list(tokenize=ko.words,wordLengths=c(2,5),removeNumbers=T, weighting=weightBin,removePunctuation=T)) 

tdm.matrix <- as.matrix(tdm)

dim(tdm.matrix)

word.count <- rowSums(tdm.matrix)
word.order <- order(word.count,decreasing = T)

word.order[1:20]

rownames(tdm.matrix)[word.order[1:20]]

freq.words <- tdm.matrix[word.order[1:20],]

dim(freq.words)

cooccur <- freq.words %*% t(freq.words)

cooccur

library(qgraph)

par(family='NanumGothic')

qgraph(cooccur,
       labels=rownames(cooccur), # 가로세로 모두 단어다 그래서 colnames로 해도상관없다. 단어가 안짤리고 잘나온다. 
       diag=F, # 자기자신을 나타내는 대각선 부분을 없앤다. 
       layout='spring', # Node의 위치를 바꿀수있다. 
       edge.color='blue',
       vsize=log(diag(cooccur)*3))








