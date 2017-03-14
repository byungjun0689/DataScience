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
