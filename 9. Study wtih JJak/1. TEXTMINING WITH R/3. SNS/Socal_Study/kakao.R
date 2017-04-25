
# 카카오톡 ####

library(stringr)
#install.packages("KoNLP", repos="http://cran.nexr.com")
#Sys.setenv(JAVA_HOME = "C:/Program Files/Java/jre1.8.0_121")
library(KoNLP)

useSejongDic()
install.packages("wordcloud2")
library(wordcloud2)

t <- file("1.txt",encoding = "UTF-8")
text <- readLines(t)
close(t)

# --------------- 2017년 1월 12일 목요일 ---------------
text <- gsub("\\--------------- (.*?)\\ ---------------", " ", text)

#[병준오빠] [오후 5:47] 하...안가면 길티...
text <- gsub("\\[(.*?)\\]", " ", text)

#[변보람 언니] [오후 5:35] (이모티콘)
text <- gsub("(이모티콘)"," ", text)

#사진 삭제
text <- gsub("사진"," ",text)

#동영상 삭제
text <- gsub("동영상"," ",text)

#ㅋㅋㅋㅋㅋ ㅎㅎㅎㅎㅎ 삭제
text <- gsub("[^가-힇]"," ",text)

#제거할 단어들


#문자 앞뒤의 빈공간 없애기 
text <- str_trim(text)
text <- Filter(function(x){nchar(x)<=10}, text)

head(text)

#명사 추출하기
nouns <- sapply(text, extractNoun, USE.NAMES=F)
head(nouns)
#단어 길이 제한하기
unlist_nouns <- unlist(nouns)
filter2_nouns <- Filter(function(x){nchar(x) >=2&nchar(x)<=5}, unlist_nouns)

#테이블 형태로 변환
wordcount <- table(filter2_nouns)

#파일로 저장
write.csv(wordcount,"C:\\Users\\hehe2\\Documents\\KMU\\study_mindscale\\kakao_1.csv")

wordcloud2(data=wordcount, minSize=20)

text <- gsub("삼증"," ",text)   #ㅋ...........
text <- gsub("삼증이"," ",text)
text <- gsub("키키"," ",text)
text <- gsub("근데"," ",text)
text <- gsub("이거"," ",text)
text <- gsub("저거"," ",text)
text <- gsub("거기"," ",text)
text <- gsub("니가"," ",text)
text <- gsub("이상"," ",text)
text <- gsub("하나"," ",text)
text <- gsub("그거"," ",text)
text <- gsub("사람"," ",text)
text <- gsub("시간"," ",text)
text <- gsub("그것"," ",text)
text <- gsub("이름"," ",text)
text <- gsub("교시"," ",text)

