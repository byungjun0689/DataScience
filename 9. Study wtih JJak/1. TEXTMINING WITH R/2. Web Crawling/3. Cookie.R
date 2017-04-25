# 쿠키 
# 사용자가 로그인이 필요할 경우가 있다. 
# Server -> (Cookie) -> Client 
# Client -> (Cookie) -> Server 형태로 로그인 확인. 
# 
# Facebook ID -> 다른 사이트 로그인 OAuth
# 

library(httr)
library(rvest)
# login -> header -> request url
# https 는 문제가 있다. SSL 이라.. s 제거

url = "http://onoffmix.com/account/login"
res <- POST(url, body=list(proc='login',returnUrl='http://onoffmix.com',email="byungjun0689@gmail.com",pw="wjddks"))

cookies(res) # 유지 하려면 set_cookies

session <- set_cookies(.cookies = unlist(cookies(res)))

r <- GET('http://onoffmix.com',session)

read_html(r) %>% html_nodes("ul.serviceMenu") %>% html_text() # 로그아웃이 보이는 걸로 봐서 로그인이 된걸로 확인된다. 


