library(httr)
library(rvest)

url <- "https://cran.r-project.org/web/packages/httr/httr.pdf"
res <- GET(url)
res

writeBin(content(res, 'raw'), 'httr.pdf')


# 그림 gae9.com

url <- "http://gae9.com/trend/1pjc3ndLRfrX#!hot"
h = html(url)

imgs = html_nodes(h, 'div.trend-post-content img')
img.src = html_attr(imgs, 'src')
img.src

# ssproxy.ucloudbiz.olleh.com 를 포함한 녀석만 뽑아내야된다.

grep('ssproxy', img.src)

img.src = img.src[grep('ssproxy', img.src)]

for(i in 1:length(img.src)){
  res = GET(img.src[i])
  writeBin(content(res, 'raw'), sprintf('%03d.jpg', i))
}
