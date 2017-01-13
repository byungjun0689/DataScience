# xwMOOC 기계학습
 


### 1. 동적 네트워크 데이터 시각화

최근에 R 시각화 산출물을 HTML/자바스크립트 출력물로 내보는 것이 훨씬 쉬워졌다.
[`rChart`](https://github.com/ramnathv/rCharts), [`htmlwidgets`](http://www.htmlwidgets.org/)을 통해
R 시각화 산출물을 인터랙티브 웹도표로 생성하는 것이 가능하다.

[`networkD3`](https://christophergandrud.github.io/networkD3/)는 동적 네트워크 시각화에
D3 자바스크립트 라이브러리를 사용한다.

**중요:** `networkD3`로 생성된 산출물은 후속 작업에 필요한 토대를 마련해주고, 
네트워크 데이터 분석 및 시각화 작업을 시작점으로 의미가 크다. 따라서, 
인터랙티브 네트워크 시각화 산출물을 바탕으로 향후 후속작업과 연계하여 최종산출물을
생성시킨다.

`install.packages("networkD3")` 명령어로 이름에서 나타나지만 자바스크립트 D3 라이브러리를
R과 연결시킨 팩키지를 설치한다.


~~~{.r}
##============================================================================================
## 1. 환경 설정
##============================================================================================
# install.packages("networkD3")

library(networkD3)
~~~

networkD3 팩키지로 시각화 산출물을 생성시키는데 기존 `from`, `to` 형식 edgelist 자료구조에 
일부 작업이 필요하다. 노드 ID는 숫자형이 되어야 하고 R이 1에서 시작하지만,
자바스크립트는 0부터 숫자가 시작하는 특성을 반영한다.
이를 위한 가장 쉬운 방법은 먼저 문자 ID를 요인(factor) 자료 구조로 바꾸고 
이를 숫자형으로 변환시키고 1을 빼준다.

노드는 링크에 있는 "source" 칼럼과 동일한 순서를 맞춰준다. 


~~~{.r}
##============================================================================================
## 2. 네트워크 데이터 준비
##============================================================================================
# source("02.code/static-rmarkdown-code.R")

el <- data.frame(from=as.numeric(factor(links$from))-1, 
                 to=as.numeric(factor(links$to))-1 )
nl <- cbind(idn=factor(nodes$media, levels=nodes$media), nodes) 
~~~

이제 모든 준비가 마무리되었다. `Group` 인자를 통해 노드 색상을 맞춰준다.
`Nodesize` 인자는 노드 크기가 아니라는 것을 주의한다. 크기로 사용될 노드데이터의 
칼럼 숫자를 나타낸다. `charge` 인자는 노드를 잡아당길지 노드를 밀어낼지 제어한다.
만약 음수면 밀어내고, 양수면 잡아당긴다.


~~~{.r}
##============================================================================================
## 3. 네트워크 시각화
##============================================================================================

forceNetwork(Links = el, Nodes = nl, Source="from", Target="to",
             NodeID = "idn", Group = "type.label",linkWidth = 1,
             linkColour = "#afafaf", fontSize=12, zoom=T, legend=T,
             Nodesize=6, opacity = 0.8, charge=-300, 
             width = 600, height = 400)
~~~

<!--html_preserve--><div id="htmlwidget-2390" style="width:600px;height:400px;" class="forceNetwork html-widget"></div>
<script type="application/json" data-for="htmlwidget-2390">{"x":{"links":{"source":[0,0,0,0,1,1,1,1,2,2,2,2,2,2,2,3,3,3,3,3,4,4,4,4,5,5,5,6,6,6,6,7,7,7,8,9,10,10,10,11,11,12,12,13,13,13,14,14,15],"target":[1,2,3,14,0,2,8,9,0,3,4,7,9,10,11,2,5,10,11,16,0,1,8,14,5,15,16,2,7,9,13,2,6,8,9,2,5,12,13,11,16,10,12,0,3,5,5,16,3],"colour":["#afafaf","#afafaf","#afafaf","#afafaf","#afafaf","#afafaf","#afafaf","#afafaf","#afafaf","#afafaf","#afafaf","#afafaf","#afafaf","#afafaf","#afafaf","#afafaf","#afafaf","#afafaf","#afafaf","#afafaf","#afafaf","#afafaf","#afafaf","#afafaf","#afafaf","#afafaf","#afafaf","#afafaf","#afafaf","#afafaf","#afafaf","#afafaf","#afafaf","#afafaf","#afafaf","#afafaf","#afafaf","#afafaf","#afafaf","#afafaf","#afafaf","#afafaf","#afafaf","#afafaf","#afafaf","#afafaf","#afafaf","#afafaf","#afafaf"]},"nodes":{"name":["NY Times","Washington Post","Wall Street Journal","USA Today","LA Times","New York Post","CNN","MSNBC","FOX News","ABC","BBC","Yahoo News","Google News","Reuters.com","NYTimes.com","WashingtonPost.com","AOL.com"],"group":["Newspaper","Newspaper","Newspaper","Newspaper","Newspaper","Newspaper","TV","TV","TV","TV","TV","Online","Online","Online","Online","Online","Online"],"nodesize":[20,25,30,32,20,50,56,34,60,23,34,33,23,12,24,28,33]},"options":{"NodeID":"idn","Group":"type.label","colourScale":"d3.scale.category20()","fontSize":12,"fontFamily":"serif","clickTextSize":30,"linkDistance":50,"linkWidth":"1","charge":-300,"opacity":0.8,"zoom":true,"legend":true,"nodesize":true,"radiusCalculation":" Math.sqrt(d.nodesize)+6","bounded":false,"opacityNoHover":0,"clickAction":null}},"evals":[],"jsHooks":[]}</script><!--/html_preserve-->




### 2. GIF 애니메이션 [^r-gif-animation-with-imagemagick]

`ndtv` 팩키지를 설치했다면, 이미 `animation` 팩키지가 설치되어 있을 것이다.
[ImageMagick](http://imagemagick.org)을 작업흐름에 포함시켜 작업한다.


[^r-gif-animation-with-imagemagick]: [R GIF animation with ImageMagick](http://stackoverflow.com/questions/28142300/r-gif-animation-with-imagemagick)


`ani.options` ImageMagick 변환(convert) 선택옵션을 설정하고, 그래프를 4개 차례로 생성시키고,
`saveGIF` 함수로 이를 묶어 `network_animation.gif` 파일로 저장시킨다.


~~~{.r}
library(animation) 
library(igraph)

# install_github("yihui/animation")

#ani.options(convert = "C:/Program Files/ImageMagick-7.0.3-Q16/convert.exe") 
#ani.options("convert")[1]

l <- layout.fruchterman.reingold(net)

saveGIF( {  col <- rep("grey40", vcount(net))
            plot(net, vertex.color=col, layout=l)

            step.1 <- V(net)[media=="Wall Street Journal"]
            col[step.1] <- "#ff5100"
            plot(net, vertex.color=col, layout=l)

            step.2 <- unlist(igraph::neighborhood(net, 1, step.1, mode="out"))
            col[setdiff(step.2, step.1)] <- "#ff9d00"
            plot(net, vertex.color=col, layout=l) 
            
            step.3 <- unlist(igraph::neighborhood(net, 2, step.1, mode="out"))
            col[setdiff(step.3, step.2)] <- "#FFDD1F"
            plot(net, vertex.color=col, layout=l)  
        },
            interval = .8, movie.name="network_animation.gif" )
~~~



~~~{.output}
Executing: 
convert -loop 0 -delay 80 Rplot1.png Rplot2.png Rplot3.png
    Rplot4.png 'network_animation.gif'

~~~



~~~{.output}
Output at: /Users/statkclee/swc/ml/network_animation.gif

~~~



~~~{.output}
NULL

~~~

MAC OSX 에서 작업을 할 경우 `$ brew install ghostscript imagemagick` **brew** 명령어로 설치하는 것이 좋다.
그리고, 윈도우에서 작업을 할 경우 여러가지 사항을 맞춰주어야 하고, 특히 `animation` 팩키지 자체에 일부
오류가 있어 `devtools::install_github("yihui/animation")` 명령어로 GIF 관련된 버그를 수정한 팩키지를 설치한다.

<img src="fig/network_animation.gif" alt="GIF 산출 결과물" width="77%" />


