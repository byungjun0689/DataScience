# Twitter Authentification ##

pac <- c('twitteR','base64enc','ROAuth')
install.packages(pac, dependencies = T)

library(twitteR)
library(base64enc)

options(httr_oauth_cache = T)
setup_twitter_oauth(consumer_key = 'J6Y4NEAl5mubjrHQ28kFbWAsw', 
                    consumer_secret = 'qbnzZOVPcQjAU0MbKbFybEw5jtcrZTlhs1djEi0Xaix9Ev1gxH',
                    access_token = '896621426-KC4s40IVAlYWhrL61N6RGkxlUMfkirUjGFdvZaju',
                    access_secret = 'JQ9ZT8j2VY2wKZiehy2IKU5toSkcnfhHevpx0x0Hq6Jn0')


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

