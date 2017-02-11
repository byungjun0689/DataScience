# 짝태 마이닝 

library(stringr)
library(KoNLP)
useSejongDic()
install.packages("wordcloud2")
library(wordcloud2)


text <- readLines("짝태.txt",encoding="UTF-8")
text <- gsub("\\--------------- (.*?)\\ ---------------", "", text) 
text <- gsub("\\[(.*?)\\]", "", text)
text <- gsub("(이모티콘)", "", text)
text <- gsub("사진", "", text)
text <- gsub("동영상", "", text)
text <- gsub("오늘", "", text)
text <- gsub("오빠","",text)
text <- gsub("내일","",text)
text <- gsub("이거","",text)
text <- gsub("거기","",text)
text <- gsub("삼증","",text) ## 헤어짐 처리 
text <- gsub("삼증이","",text) ## 헤어짐 처리2 
text <- gsub("어제","",text) ## 빼고싶은 단어들 넣느방법.
text <- gsub("이형","",text)

word<-data.frame(c("키킼"), "ncn") # 넣고 싶은 단어 넣는 곳. c(), c()이렇게 나열하면됨.
buildDictionary(ext_dic = c('sejong', 'woorimalsam'), user_dic=word,replace_usr_dic = T)
#한글 외에 모든 문자는 제거한다!
#ㅋ,ㅎ,ㅇ 이런것들도 모두 제거!
text <- gsub("[^가-힣]", " ", text)
head(text, 20)
text <- str_trim(text) #빈공간 제거 
text <- Filter(function(x){nchar(x) <= 10}, text)

nouns = sapply(text, extractNoun, USE.NAMES=F)

#단어 길이를 제한하기 위해
unlist_nouns <- unlist(nouns)
filter2_nouns <- Filter(function(x){nchar(x) >= 2 & nchar(x) <= 5}, unlist_nouns)
#테이블 형태로 변환
wordcount <- table(filter2_nouns)


library(RColorBrewer)
palete <- brewer.pal(9,"Set1")

wordcloud2(data = wordcount, minSize = 20)
