#필요한 패키지 설치.
install.packages("base64enc")
install.packages(c("RCurl","twitteR","ROAuth"))
install.packages("KoNLP")
install.packages("wordcloud")
install.packages("plyr")
install.packages("tm")
install.packages("Unicode")
# Library 로드
library("base64enc")
library("RCurl")
library("twitteR")
library("ROAuth")
library(KoNLP)
library(wordcloud)
library(plyr)
library(tm)
library(Unicode)

reqURL <- "https://api.twitter.com/oauth/request_token"
accessURL <- "https://api.twitter.com/oauth/access_token"
authURL <- "https://api.twitter.com/oauth/authorize"

# 트위터에서 받은 네개의 키 값을 변수에 할당.
consumerKey <- "J6Y4NEAl5mubjrHQ28kFbWAsw"
consumerSecret <- "qbnzZOVPcQjAU0MbKbFybEw5jtcrZTlhs1djEi0Xaix9Ev1gxH"
accesstoken <- "896621426-KC4s40IVAlYWhrL61N6RGkxlUMfkirUjGFdvZaju"
accesstokensecret <- "JQ9ZT8j2VY2wKZiehy2IKU5toSkcnfhHevpx0x0Hq6Jn0"

cred <- OAuthFactory$new(consumerKey=consumerKey,
                         consumerSecret=consumerSecret,
                         requestURL="https://api.twitter.com/oauth/request_token",
                         accessURL="https://api.twitter.com/oauth/access_token",
                         authURL="https://api.twitter.com/oauth/authorize")
cred$handshake(cainfo = system.file("CurlSSL", "cacert.pem", package = "RCurl")) 



#인증처리.
#1번.
options(RCurlOptions = list(cainfo = system.file("CurlSSL", "cacert.pem", package = "RCurl")))
registerTwitterOAuth(cred)

#2번.
setup_twitter_oauth(consumerKey,consumerSecret,accesstoken,accesstokensecret)

#해당 단어를 언급한 글을 가지고 오고 싶을 때 사용.
keyword <- enc2utf8("박유천")
lotteworld <-  searchTwitter(keyword,n=10)
tmp <- unlist(lotteworld,use.names = TRUE)
head(lotteworld)

# 계정이 남긴 글을 가져오고 싶을때 사용
JTBC.tweets <- searchTwitter("@jtbclove", n = 100)

# 분석할 키워드 설정
keyword <- "#쯔위"

# 트위터에서 키워드로 검색, 시작날짜, 지역코드(우리나라만 적용), 가져올 개수를 옵션에 대입
#h3_twitter <- searchTwitter(keyword,since='2015-10-29',geocode='35.874,128.246,400km',n=100)
twitter <- searchTwitter(keyword,since='2015-10-29',until='2016-06-21', lang="ko",n=100)

# 트위터 데이터를 형태별로 분류하고 멘션 부분만 추출
twitter.df <- twListToDF(twitter)  #data.frame 형태로 해당 트위터의 정보를 추출한다. 
View(twitter.df)
twitter.df <- twitter.df[twitter.df$retweetCount!=0,]
twitter.text <- twitter.df$text

# 불필요한 문자를 필터링
# result.text <- gsub(keyword, "", result.text) gsub (지울글자,어떤글자로,데이터)
twitter.text <- gsub("\n", "", twitter.text)
twitter.text <- gsub("\r", "", twitter.text)
twitter.text <- gsub("RT", "", twitter.text)
twitter.text <- gsub("http", "", twitter.text)
twitter.text <- gsub("ㅠ", "", twitter.text)
twitter.text <- gsub("ㅋ", "", twitter.text)

# 문자 분리  extractNoun : KoNLP 패키지의 함수로 명사로 추출한다.
result_nouns <- Map(extractNoun, twitter.text)          

# 쓸모없는 문자들을 제거한다. 특히 영문자의 경우 tm의 stopwords를 활용한다.
result_wordsvec  <- unlist(result_nouns, use.name=F)
result_wordsvec  <- result_wordsvec [-which(result_wordsvec  %in% stopwords("english"))]
result_wordsvec  <- gsub("[[:punct:]]","", result_wordsvec )
result_wordsvec  <- Filter(function(x){nchar(x)>=2}, result_wordsvec )

# 단어별 카운팅
twitter_count <- table(result_wordsvec)
str(twitter_count)
tmp <- head(sort(twitter_count,decreasing=T),30)

# 컬러 세팅
pal <- brewer.pal(12,"Paired")

# 폰트 세팅
windowsFonts(malgun=windowsFont("Arial"))

# 그리기
wordcloud(names(tmp),freq=tmp,scale=c(4,0.5),min.freq=1,
          random.order=F,rot.per=.1,colors=pal,family="malgun")



apple <- searchTwitter("@BREXIT",n=10000)
length(apple)
class(apple)
head(apple)
tweet.apple <- apple[[1]]
tweet.apple$getId()
tweet.apple$favoriteCount
tweet.apple$getScreenName()  # ID확인
tweet.apple$text #내용.

apple.text <- laply(apple, function(t) t$getText())
head(apple.text)

pos.word <- scan("positive-words.txt",what="character",comment.char = ";")
neg.word <- scan("negative-words.txt",what="character",comment.char = ";")
pos.word <- c(pos.word,"upgrade")
pos.word <- c(pos.word,"freedom","Independence")
neg.word <- c(neg.word,"wait","waiting","leave","withdraw","out","quit","broke","cancel","get out","swallow")

score.sentiment = function(sentences, pos.words, neg.words, .progress='none')
{
  require(plyr)
  require(stringr)
  # we got a vector of sentences. plyr will handle a list or a vector as an "l" for us
  # we want a simple array ("a") of scores back, so we use
  # "l" + "a" + "ply" = "laply":
  scores = laply(sentences, function(sentence, pos.words, neg.words) {
    
    # clean up sentences with R's regex-driven global substitute, gsub():
    sentence = gsub('[[:punct:]]', '', sentence)
    sentence = gsub('[[:cntrl:]]', '', sentence)
    sentence = gsub('\\d+', '', sentence)
    
    # and convert to lower case:
    sentence = tolower(sentence)
    # split into words. str_split is in the stringr package
    word.list = str_split(sentence, '\\s+')
    # sometimes a list() is one level of hierarchy too much
    words = unlist(word.list)
    
    # compare our words to the dictionaries of positive & negative terms
    pos.matches = match(words, pos.words)
    neg.matches = match(words, neg.words)
    
    # match() returns the position of the matched term or NA
    # we just want a TRUE/FALSE:
    pos.matches = !is.na(pos.matches)
    neg.matches = !is.na(neg.matches)
    # and conveniently enough, TRUE/FALSE will be treated as 1/0 by sum():
    score = sum(pos.matches) - sum(neg.matches)
    return(score)
  }, pos.words, neg.words, .progress=.progress )
  scores.df = data.frame(score=scores, text=sentences)
  return(scores.df)
}

apple.text <- apple.text[!Encoding(apple.text)=="UTF-8"]
apple.score <- score.sentiment(apple.text,pos.word,neg.word,.progress = 'text')
hist(apple.score$score)

head(apple.score)
View(apple.score)

 