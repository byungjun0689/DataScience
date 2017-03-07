library(httr)
library(rvest)
library(stringr)

list.url <- "http://m.cafe.naver.com/ArticleList.nhn?search.clubid=25555212&search.menuid=5&search.boardtype=L"
h.list <- read_html(list.url)

html_nodes(h.list,'.list_area li a') # url

html_nodes(h.list,'.list_area li a strong') # 제목만
# \r\n: Enter

str_trim('   ab ')


# 제목 추출.
titles <- html_text(html_nodes(h.list,'.list_area li a strong'))
titles <- str_trim(titles) # 제목만
titles <- str_replace_all(titles,'[[:space:]]','')

# 링크 추출.
titles.links <- html_nodes(h.list,'.list_area li a')
article.links <- html_attr(titles.links,'href') 

for(link in article.links){
  if(link != '#') {
    print(paste0('http://m.cafe.naver.com/',link))
  }
}

# 로그인 하지 않고는 못보게하는 까페들이 있다. 

html_text(read_html(paste0('http://m.cafe.naver.com/',article.links[1])))

# 18분 49초에 멈춤.

