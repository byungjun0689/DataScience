# HTML 이 Javascript 에 있을때.
# 지도와 같이 동적으로 HTML 제공할때가 있다. 
# 1. 개발자도구의 네트워크로 볼때 추가적으로가져오는 부분이 있다. 
# 2. Selenium 을 사용해 웹 브라우저를 통해 크롤링.


# 사례 분석
library(httr)
library(rvest)

h <- read_html('http://www.inven.co.kr/board/powerbbs.php?come_idx=2152&l=19094')
h
html_nodes(h,'div.comment') # 결과가 없다. => Javascript로 해서 결과를 가지고 온다. 


comment.url = 'http://www.inven.co.kr/common/board/comment.xml.php?dummy=1433931866095'

# FormData에 보면 POST로 넘어간 데이터를 알 수 있다. 

comment = POST(comment.url,
               body=list(
                 comeidx=2152,
                 articlecode=19094,
                 sortorder='date',
                 act='list',
                 out='xml',
                 replynick='',
                 replyidx=0))

x <- xml(comment)
xml_text(xml_nodes(x, 'item o_comment'))
comment_x <- repair_encoding(xml_text(xml_nodes(x, 'item o_comment')))  ##  윈도의 경우
gsub("&nbsp;","",comment_x) # 이런식으로 데이터 처리만 하면 될 듯.

