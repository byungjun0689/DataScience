# HTML 이 Javascript 에 있을때.
# 지도와 같이 동적으로 HTML 제공할때가 있다. 
# 1. 개발자도구의 네트워크로 볼때 추가적으로가져오는 부분이 있다. 
# 2. Selenium 을 사용해 웹 브라우저를 통해 크롤링.


# 사례 분석
library(httr)
library(rvest)

h <- read_html('http://www.inven.co.kr/board/powerbbs.php?come_idx=2152&l=19094')

comment.url = 'http://www.inven.co.kr/common/board/comment.xml.php?dummy=1433931866095'
comment = POST(comment.url,
               body=list(
                 comeidx=2152,
                 articlecode=19094,
                 sortorder='date',
                 act='list',
                 out='xml',
                 replynick='',
                 replyidx=0))
