# Twitter Authentification ##

pac <- c('twitteR','base64enc','ROAuth')
install.packages(pac, dependencies = T)

library(twitteR)
library(base64enc)

options(httr_oauth_cache = T)
setup_twitter_oauth(consumer_key = '', 
                    consumer_secret = '',
                    access_token = '',
                    access_secret = '')


getCurRateLimitInfo() # 접속확인.

# 내용 찾기 
searchTwitter() # n = 가지고오는 수, lang=언어,since =시작날짜, until = 종료날짜, locale = 지역 ,retryOnRateLimit = 접속 제한걸렸을때 얼마나 더 시도해 볼거냐.
string <- '박근혜'
string <- iconv(string, 'CP949', 'UTF8')
tweets <- searchTwitter(searchString = string, n = 1000, lang="ko", retryOnRateLimit = 10000)
tweets

length(tweets)
tweets[[1]]

str(tweets[[1]]) # 많은 정보들을 포함하고 있다. 

tweets[[1]]$created #작성된 날짜 
tweets[[1]]$favoriteCount
tweets[[1]]$retweetCount

# 텍스트 가지고 오기. 
# 1번.
text_extracted <- sapply(tweets, function(t) t$getText()) # getText() 
unique(text_extracted) # 리트윗으로 인한 내용 제거
uniq.text <- unique(text_extracted)

# 2번.
tweets_df <- twListToDF(tweets)
tweets_df$text
str(tweets_df)
View(head(tweets_df))


## 여러개의 키워드가 들어간 것을 찾고싶다면??

tweets <- searchTwitter(searchString = 'bigdata+statistics', n = 100)

string <- '박근혜+우병우'
string <- iconv(string, 'CP949', 'UTF8')
tweets <- searchTwitter(searchString = string, n = 100, lang="ko", retryOnRateLimit = 10000)
tweets


getCurRateLimitInfo() # /search/tweets   180       129   129 로 떨어졌다. 다시 다 쓰게 되면 180개 된다면 15분정도 걸린다. 

text_extracted <- gsub("(RT|via)((?:\\b\\W*@\\w+)+)", "", text_extracted)
text_extracted <- gsub("@\\w+", "", text_extracted)
text_extracted <- gsub("[[:punct:]]", '', text_extracted)
text_extracted <- gsub("(http|https)[[:alnum:]]+", '', text_extracted)
text_extracted <- gsub("http\\+", "", text_extracted)
text_extracted <- gsub("\n", ' ', text_extracted)
text_extracted <- gsub("[ \t]{2,}", "", text_extracted)

text_extracted <- unique(text_extracted)



# 3. Snowball Sampling 
# 일종의 다단계 모집과 같다. 한명이 두사람을 물고오고 쭉쭉쭉 엄청난 사람들을 물고온다. 
# 랜덤하게 피험자를 모집하는게 아니라 이미 연구에 참가한 사람들의 추천에 의해 새로운 사람 모집
# 특히 SNA(사회연결망 분석, Social Network Analysis) 를 할 때에 많이 사용한다.
# 절차 
# 1. 초기 seed 멤버를 설정한다. 예) 서울대 졸업생을 연구하고싶다.
# 2. seed 멤버에게 연구를 진행.
# 3. 이멤버들에게 연구에 참여할 사람을 추천받는다.
# 4. 추천 받은 사람에게 연락하여 연구를 진행한다.
# 5. 반복 => 눈덩이가 굴러가듯이 내 표본이 늘어난다. 

# 장점 : 1. 연구자가 모르는 사람에게도 접근 가능.
#       2. 비슷한 속성을 공유하고 있는 사람을 모을 수 있다.
#       3. 비용이 적게 든다.
#       4. 네트워크 구조를 좀 더 보존하는 표본을 모을 수 있다. 

# 단점 :
# 1. 랜덤한 표본을 모으지 못한다(편향생김)
# 2. 표본을 통제하기 어렵다.
# 3. 초기 멤버에 영향을 많이 받는다. 

# 실습

getCurRateLimitInfo()

## 문재인
moon  <- getUser('moonriver365')
str(moon)

## 킹무성
king <- getUser('kimmoosung')
str(king)

##get followers/friends
N = 1000
friends.moon <- lookupUsers(moon$getFriendIDs(n=N, retryOnRateLimit=10000)) ## 자기가 Follow하는 사람
followers.moon <- lookupUsers(moon$getFollowerIDs(n=N, retryOnRateLimit=10000)) ## 자기가 Follow하는 사람

friends.king <- lookupUsers(king$getFriendIDs(n = N, retryOnRateLimit = 10000))
followers.king <- lookupUsers(king$getFriendIDs(n = N, retryOnRateLimit = 10000))

## delete protected users
friends.moon <- friends.moon[sapply(friends.moon, function(t) t$protected) == F]
followers.moon <- followers.moon[sapply(followers.moon, function(t) t$protected) == F]

friends.king <- friends.king[sapply(friends.king, function(t) t$protected) == F]
followers.king <- followers.king[sapply(followers.king, function(t) t$protected) == F]


## snowball sampling
s <- 40 # 약간의 편향을 줄일 수 있다.(bias)
friends.ID.moon <- sample(sapply(friends.moon, function(t) t$screenName), s)
followers.ID.moon <- sample(sapply(followers.moon, function(t) t$screenName), s) 
friends.ID.king <- sample(sapply(friends.king, function(t) t$screenName), s)
followers.ID.king <- sample(sapply(followers.king, function(t) t$screenName), s) 



## collect text from friends

temp <- lapply(friends.ID.moon, function(x) do.call("rbind", lapply(userTimeline(x,retryOnRateLimit = 10000), as.data.frame))) ##limit handling
df_moon_friend <- do.call(rbind, temp)
df_moon_friend$text


gsub("(|)*(\\s*[\\|]*\\w+뉴스)*\\s+http(|s)://\\w+.?\\w+[/|]+\\w+","",df_moon_friend$text)



# 한국어 Term Doucment Matrix 만들기(weighting이해하기)
# KoNLP이용
library(tm)
library(KoNLP)
library(stringr)

A <- '나는 배고파서 슬프다. 매우 슬프다.'
B <- '나는 잠이 와서 졸립다. 졸립다. 졸립다.'
C <- '나는 잠이 안와서 슬프다'
ex <- c(A, B, C )
ex


ko.words <- function(doc){
  d <- as.character(doc)
  pos <- paste(SimplePos09(d))
  extracted <- str_match(pos, '([가-힣]+)/[NP]')
  keyword <- extracted[,2]
  keyword[!is.na(keyword)]
}
ko.words(A)
ko.words(B)
ko.words(C)

# TermDocument Matrix
options(mc.cores=1)
cps <- Corpus(VectorSource(ex))
tdm <- TermDocumentMatrix(cps,
                          control=list(
                            tokenize = ko.words,
                            removePunctuation=T,
                            removeNumbers=T,
                            wordLengths=c(1,5)
                          ))

tdm
as.matrix(tdm)
tdm # term frequency (tf) 단어 출현 빈도.

# weightBin : 1번이상 출현하면 1로 바꾸고 아니면 0 
# 액션영화인지 아닌지. 
tdm.bin <- TermDocumentMatrix(cps,
                              control=list(
                                tokenize = ko.words,
                                removePunctuation=T,
                                removeNumbers=T,
                                wordLengths=c(1,5),
                                weighting=weightBin
                              ))
as.matrix(tdm.bin)

# weightTfIdf = Tf * IDF
# TF 개별단어숫자 : Normalize 
# 많은 말을 한 부분이 웨이트가 높게 나온다. 이러한 걸 조절 할 수 있다.
# 모든 사람들의 단어 사용을 0 ~ 1 사이 값으로 바꾼다.

# IDF (Inverse Document Frequency)
# A : 나 배고파 슬프 슬프 
# B : 나 잠  와 졸립다 졸립다 졸립다
# C : 나 잠  안와서 슬프

# A 입장에서 '나'도 1회, '배고파'도 1회 출현
# 그러나, 나는 A,B,C모두 출현, 배고파는 A만 출현
# 신문기사를 예를 들면 ~기자는 말했다 등과 같이 모든 문서에 나타나는 단어의 중요도를 감소 
# TF-ij = log(총 문서갯수 / 출현한 문서 갯수)


tdm.test <- TermDocumentMatrix(cps,
                          control=list(
                            tokenize = ko.words,
                            removePunctuation=T,
                            removeNumbers=T,
                            wordLengths=c(1,5),
                            weighting = weightTfIdf
                            ))

as.matrix(tdm.test)


tdm.m <- as.matrix(tdm)

tdm.m <- apply(tdm.m,2,function(x) x/sum(x)) # 열별로 
tdm.m * log2(3/apply(tdm.m, 1, function(x) sum(x>0)))
# 이 값이 
as.matrix(tdm.test)
# 동일.



# 12. Network그리기
getCurRateLimitInfo()

seed <- getUser('GH_PARK')
seed$description

seed.n <- seed$screenName
seed.n

## get seed's friends
following <- seed$getFriends(n = 100000, retryOnRateLimit = 10000) # 결과값이 list형태.
str(following)
following.n <- as.character(lapply(following, function(x) x$getScreenName()))
head(following.n)

# 네트워크에 들어갈 사람을 LIST 로 만들기
follow.list <- list()
follow.list[[seed.n]] <- following.n

descriptions <- as.character(lapply(following, function(x) x$getDescription()))
politician <- grep('국회의원',descriptions,ignore.case=T) # 국회의원 

politician <- c(seed.n,following.n[politician])

a <- Sys.time()
a
i = 1
deprecated.user <- c()

# loop over politician following same steps
while (length(follow.list) < 100){ # 100명을 모으겠다.
  
  # pick first user not done
  user <- sample(politician[politician %in% c(names(follow.list), deprecated.user)==FALSE], 1)
  user <- getUser(user, retryOnRateLimit = 10000)
  user.n <- user$screenName
  cat(user$name, "\n")
  
  if(user$protected == F){
    # download list of users he/she follows
    following <- user$getFriends(n = 1000, retryOnRateLimit = 10000)
    friends <- as.character(lapply(following, function(x) x$getScreenName()))
    follow.list[[user.n]] <- friends
    descriptions <- as.character(lapply(following, function(x) x$getDescription()))
    
    # subset and add users who are politician
    pol <- grep('(국회의원)', descriptions, ignore.case = T)
    if(length(pol) != 0){
      new.users <- lapply(following[pol], function(x) x$getScreenName())
      new.users <- as.character(new.users)
      politician <- unique(c(politician, new.users))
    }
    else{
      deprecated.user <- c(deprecated.user, user.n)
    }
  }
  else{
    deprecated.user <- c(deprecated.user, user.n)
  }
  # if rate limit is hit, wait for a minute
  limit <- sum(as.numeric(getCurRateLimitInfo()[,3]) < 2)
  while (limit > 0){
    cat("sleeping for one minute", "\n")
    Sys.sleep(60)
    limit <- sum(as.numeric(getCurRateLimitInfo()[,3]) < 2)
  }
  print(i)
  print(c(length(politician), length(follow.list)))
  i <- i+1
}


Sys.time()


# a little bit of network analysis
pol <- names(follow.list)
adjMatrix <- lapply(follow.list, function(x) (pol %in% x)*1)
adjMatrix <- matrix(unlist(adjMatrix), nrow=length(pol), byrow=TRUE, dimnames=list(pol, pol))

library(igraph)
network <- graph.adjacency(adjMatrix)
plot(network)
