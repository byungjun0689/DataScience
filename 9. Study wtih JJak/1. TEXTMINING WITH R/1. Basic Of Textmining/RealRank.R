# Naver 실시간 검색어 / 패키지 사용하여.

library(httr) # http 통신.
library(rvest)
library(dplyr)

url = "www.naver.com"
r = GET(url)
h = read_html(r)
rank_root <- html_nodes(h,"#realtimeKeywords")
rank_list = html_nodes(rank_root, 'li')
list_cnt <- length(rank_list)

rank_text <- c()
rank_length <- c()
rank_status <- c()
for(i in 1:list_cnt){
  rank_inside <- html_nodes(rank_list[i],"span")
  rank_text <- c(rank_text,html_text(rank_inside[1]))
  rank_status <- c(rank_status,html_text(rank_inside[2]))
  rank_length <- c(rank_length,html_text(rank_inside[4]))
}

rank.df <- data.frame(rank=rank_text, status=rank_status, gap=rank_length)


# Daum 실시간 검색어. 

url = "www.daum.net"
r = GET(url)
h = read_html(r)
rank_root <- html_nodes(h,"#realTimeSearchWord")
rank_list = html_nodes(rank_root, '.rank_cont.rank_dummy')
list_cnt <- length(rank_list)


rank_text <- c()
rank_length <- c()
rank_status <- c()
for(i in 1:list_cnt){
  rank_inside <- html_nodes(rank_list[i],"span") ## 순위, 검색어, Status(상승, 하강)
  rank_inside2 <- html_nodes(rank_list[i],"em") ## 몇칸 상승인지.
  rank_text <- c(rank_text,gsub("\n","",html_text(rank_inside[3])))
  rank_status <- c(rank_status,html_text(rank_inside[4]))
  rank_length <- c(rank_length,gsub("[^0-9]","",html_text(rank_inside2[1])))
}

rank.df2 <- data.frame(rank=rank_text, status=rank_status, gap=rank_length)

