# 뉴스, 게시판 등 글 목록에서 글의 URL 만 뽑아내기.
library(httr)
library(rvest)

url <- "http://news.naver.com/main/list.nhn?mode=LSD&mid=sec&sid1=106"
res <- GET(url)
res

htxt <- read_html(res)
html_nodes(htxt,'a') # 전체 다 가져온다. 
 
html_nodes(htxt,'.type06_headline a') # 띄워주고 a하면 그 안에 있는 a만 가지고 온다. 
html_nodes(htxt,'.type06_headline a') %>% html_attr('href') # 2개씩 가지고 있다. 제목 사진 
# 중복된 부분 삭제.

a_href <- html_nodes(htxt,'.type06_headline a') %>% html_attr('href')
article.href <- unique(a_href) # 중복된 건 없애준다. 

# 또는 제목형으로 조회해서 하면 된다. 

# 하나하나 내용 보기 
for(i in 1:length(article.href)) # 이렇게 하거나 
{}

for(href in article.href){
  print(href)
}
