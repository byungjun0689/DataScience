install.packages("Rfacebook")
library("Rfacebook")

#Facebook api get Authentication from FB site.
fb_oauth = fbOAuth(app_id = "1055189901193516", app_secret = "68b24f0e8091b4d93c813a2711d282ca", extended_permissions = T)

#인증서 처럼 사용.
save(fb_oauth, file="fb_oauth")
load("fb_oauth")

me <- getUsers("me", token = fb_oauth)
me$name

#my_friends <- getFriends(token = fb_oauth, simplify = TRUE)
#length(my_friends$name)
# test <- getPage(page="Byungjun Lee", token = fb_oauth, n = 30)
# fb <- getUsers("me", token=fb_oauth)
# fb <- getNewsfeed(token=fb_oauth, n = 10)

start_date='2016/06/01'
end_date='2016/06/25'
scrape_days=seq(from=as.Date(start_date), to=as.Date(end_date), by='days')
posts=c()
posts=c()
for(scrape_day in scrape_days)
{
  daypost=c()
  tryCatch({daypost=getPage(page="koreanAir",
                            token=fb_oauth,
                            since=as.Date(scrape_day, origin="1970-01-01"),
                            until=as.Date(scrape_day, origin="1970-01-01")+1
  )
  },
  error=function(e){}
  )
  posts= rbind(posts, daypost)
}
View(posts)
names(posts)
