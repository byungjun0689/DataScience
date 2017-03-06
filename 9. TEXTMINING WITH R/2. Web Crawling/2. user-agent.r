# user-agent 구별하기 (웹 브라우저)
# 모바일로 할때 좀 크롤링 하기 편할때가 있다. 
# 그렇다면 ~ 인척 하면된다. 
# 정부 사이트는 Ex아니면 안되는 경우도 있다. 
# http://www.useragentstring.com/pages/useragentstring.php

# Ex) cgv.co.kr 사이트의 경우 크롤링할때 잘 안된다.  지금은 되네??? 안될 경우 거의 크롤러라서 안된다. 

library(httr)
GET('www.cgv.co.kr')

# 그냥 user_agent list에서 정보를 찾아서 복붙. 끝
ua = user_agent('Mozilla/5.0 (Windows NT 6.3; rv:36.0) Gecko/20100101 Firefox/36.0')
GET('www.cgv.co.kr', ua)


#크롤러를 막는 방법은 
# 1. user_agent  하수
# 2. 일정시간내 자주 접속 하면 막는다. -> 잘 없다. 
# 3. Capturing -> 그림보고 문자를 맞춰라. 

