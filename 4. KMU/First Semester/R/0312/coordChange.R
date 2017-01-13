install.packages("XML")
install.packages("maptools")
install.packages("PBSmapping")
install.packages("gridExtra")
install.packages("gpclib")

require("XML")
require("plyr")
require("ggplot2")
require("gridExtra")
require("stringr")
library(maptools)
library(PBSmapping)

#setwd("D:/빅데이터MBA/R프로그래밍/R")

load("subwayStn_CP949.RData") #맥등??? 경우??? load("subwayStn_UTF8.RData")
head(subwayStn)


### coordChange ?????? --------

substnGPS <- subwayStn
substnGPS$latitude <- NA
substnGPS$longitude <- NA
head(substnGPS)

transCoord <- function (addrDb, from=1, to=dim(addrDb)[1]) {
  
  for (j in from:to) {
    STN_ID <- paste0(addrDb[j,"STN_ID"])
    tgtNm <- paste0(addrDb[j,"STN_NM"])
    tgtln <- paste0(addrDb[j,"LINE_NM"])
    tgtLat <- paste0(addrDb[j,"lat"])
    tgtLong <- paste0(addrDb[j,"long"])
    #'
    #' 
    #'
    url <- "http://apis.daum.net/local/geo/transcoord?apikey="
    #url <- "https://apis.daum.net/local/geo/transcoord?apikey="
    #'
    #' ?????? developer??????????????? 발급받??? API key??? ???????????? ???.
    #' 
    url <- paste(url,"b8337f038a6d27c0de69fadf704e1669","&x=", sep="")

    url <- paste(url,tgtLong,"&y=",tgtLat,"&fromCoord=WGS84&toCoord=TM",sep="")
    #' 
    #' iconv????????? ???글 ???코딩??? 바꾸??? 주는 ?????????.
    #' ?????? ????????? 검?????? ?????? 것이??? ???글??? UTF-8?????? ???코딩??? ????????? ????????? ???.
    #' 
    
    url2 <- iconv(url, localeToCharset()[1],"UTF-8")
    res <- xmlTreeParse(URLencode(url2), getDTD=F)

    
    output <- xmlRoot(res)

    outdf <- data.frame(c())

    
    cat(STN_ID,"_",tgtNm, "\n")
    cat(tgtLat, "to TM Coordinate latitude ",xmlAttrs(output)[2],"\n")
    cat(tgtLong, "to TM Coordinate longitude",xmlAttrs(output)[1],"\n")

    addrDb[j,"longitude"] <- xmlAttrs(output)[1]
    addrDb[j,"latitude"] <- xmlAttrs(output)[2]

  }
  return(addrDb)
}

substnTM <- transCoord(substnGPS)
head(substnTM)

# save(substnTM, file="substnTM.RData")


load("Shape.RData")
head(Shape)
tail(Shape)

# Data EDA
#install.packages("dplyr")
library(dplyr)

Shape %>%
  group_by(PID) %>%
  summarize(N=n())

Shape %>%
  group_by(PID) %>%
  summarize(N=n()) %>%
  sum(.$N)

start.time <- Sys.time()
plotPolys(Shape)
Sys.time() - start.time
# 
# for (i in 1:17) {
#   seoulShape <- Shape[Shape$PID == i,]
#   plotPolys(seoulShape, main=i)
# }

stnPointData <- data.frame(EID=as.numeric(substnTM$STN_ID),X=as.numeric(substnTM$longitude),
                           Y=as.numeric(substnTM$latitude), stringsAsFactors=F)

str(stnPointData)
stnEventData <- as.EventData(stnPointData, projection=NA)

plotPolys(Shape)
addPoints(stnEventData, col="red", cex=0.5, pch=16)


# 그래???가 ??? ???????????? ????????? ????????? ??????링이 부족하??? ???문임.

seoulShape <- Shape[Shape$PID %in% c(14,9,17),]
plotPolys(seoulShape)

seoulShape <- Shape[Shape$PID %in% c(14,9,17) & Shape$X > 100000,]
plotPolys(seoulShape)


plotPolys(seoulShape)
addPoints(stnEventData, col="blue", cex=0.5, pch=16)




