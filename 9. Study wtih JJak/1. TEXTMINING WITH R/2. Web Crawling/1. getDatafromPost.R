# http://www.gevolution.co.kr/ Post형식으로 데이터를 보낸다. 그래서조회한다.

library(httr)
library(rvest)

url = "http://www.gevolution.co.kr/score/gamescore.asp?t=3&m=0&d=week"

r = POST(url, encode = 'form',
         body = list(txtPeriodW="2016-01-02")) # body에는 Form데이터가 들어가야된다. schStartDate = 2017-01-29 schEndDate = 2017-02-24
r
game = read_html(r)
title = html_nodes(game,'a.tracktitle') ## a의 Class가 Tracktitle인 것.
titles = html_text(title)



