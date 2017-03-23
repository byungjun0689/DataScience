# https://cran.r-project.org/web/packages/Rfacebook/Rfacebook.pdf
library(Rfacebook)
library(ggplot2)
library(scales)
# get auth token

fb_oauth <- 'EAACEdEose0cBAKkSzpIOVu5GqP6UGutNSH5WXhN2fHaesMZCi6XOWS0jRXMtR3ZAD0QkGpJktXGNx9iBWQYNZBEYWQvxYFVA69evlykH03zKY7ZBnZCTGXfWkBrZA9EfWuxxKAjn9ysonJiPTh6rBa4rMEgou0mCJQIbX0VvpizyGvQW4eEmiBTCx8Ned7B8MZD'
fb_oauth


# 해당 페이지의 시작날짜와 종료날짜 사이의 모든 포스트 가져옴
getPosts <- function(page_name, start_date, end_date) {
  # 날짜 sequence
  scrape_days <- seq(from=as.Date(start_date), to=as.Date(end_date), by='days')
  posts = c()
  for(scrape_day in scrape_days){
    daypost = c()
    tryCatch({
      daypost = getPage(page=page_name, token=fb_oauth,
                        since=as.Date(scrape_day, origin='1970-01-01'),
                        until=as.Date(scrape_day, origin='1970-01-01')+1)},
      error = function(e){})
    posts = rbind(posts, daypost)
  }
  return(posts)
}

drawLikeGraph <- function(data){
  ggplot(data, aes(x=created_time, y=likes_count)) + geom_line() + 
    theme_bw() + scale_x_date(labels = date_format("%m-%Y")) +
    labs(x = "날짜(MM-yyyy)", y = "좋아요수(n)") + 
    ggtitle(paste(start_date, end_date, sep="~"))
}

drawPostNumGraph <- function(data){
  ggplot(data=data, aes(x=name, y=num, fill=name)) +
    geom_bar(stat="identity", width=0.8) +
    labs(x='대선주자', y='포스트수') +
    geom_text(aes(label=num), vjust=1.6, color="white", size=3.5) +
    theme_minimal() +
    ggtitle(paste(start_date, end_date, sep="~"))
}

drawAverageLikeGraph <- function(data){
  ggplot(data=data, aes(x=name, y=average_like, fill=name)) +
    geom_bar(stat="identity", width=0.8) +
    labs(x='대선주자', y='평균 좋아요수') +
    geom_text(aes(label=round(average_like, 0)), vjust=1.6, color="white", size=3.5) +
    theme_minimal() +
    ggtitle(paste(start_date, end_date, sep="~"))
}

getSummaryDataFrame <- function(posts, name){
  average_like = sum(posts$likes_count)/nrow(posts)
  summary <- data.frame(name=name, num=nrow(posts),
                        average_like=average_like)
  return(summary)
}

moon_page = "moonbyun1" # 문재인 페이지 
lee_page = "jaemyunglee1" # 이재명 페이지
hwang_page = "PM0415HwangKyoahn" # 황교안 페이지
yoo_page = "yooseongmin21" # 유승민 페이지
ahn_hwee_page = "steelroot" # 안희정 페이지
ahn_chul_page = "ahncs111" # 안철수 페이

start_date <- '2017/01/01' # 시작 날짜
end_date <- '2017/03/20' # 종료 날짜

moon_posts <- getPosts(moon_page, start_date, end_date)
lee_posts <- getPosts(lee_page, start_date, end_date)
hwang_posts <- getPosts(hwang_page, start_date, end_date)
yoo_posts <- getPosts(yoo_page, start_date, end_date)
ahn_hwee_posts <- getPosts(ahn_hwee_page, start_date, end_date)
ahn_chul_posts <- getPosts(ahn_chul_page, start_date, end_date)

print(nrow(moon_posts))
print(nrow(lee_posts))
print(nrow(hwang_posts))
print(nrow(yoo_posts))
print(nrow(ahn_hwee_posts))
print(nrow(ahn_chul_posts))


# preprocess
moon_posts$created_time <- as.Date(moon_posts$created_time) # string to date
lee_posts$created_time <- as.Date(lee_posts$created_time)
hwang_posts$created_time <- as.Date(hwang_posts$created_time)
yoo_posts$created_time <- as.Date(yoo_posts$created_time)
ahn_hwee_posts$created_time <- as.Date(ahn_hwee_posts$created_time)
ahn_chul_posts$created_time <- as.Date(ahn_chul_posts$created_time)

# summary 데이터 프레임 만듦
moon_summary <- getSummaryDataFrame(moon_posts, '문재인')
lee_summary <- getSummaryDataFrame(lee_posts, '이재명')
hwang_summary <- getSummaryDataFrame(hwang_posts, '황교안')
yoo_summary <- getSummaryDataFrame(yoo_posts, '유승민')
ahn_hwee_summary <- getSummaryDataFrame(ahn_hwee_posts, '안희정')
ahn_chul_summary <- getSummaryDataFrame(ahn_chul_posts, '안철수')

summary <- data.frame() # 빈 데이터 프레임을 만듦
summary <- rbind(summary, moon_summary) # 행추가
summary <- rbind(summary, lee_summary)
summary <- rbind(summary, hwang_summary)
summary <- rbind(summary, yoo_summary)
summary <- rbind(summary, ahn_hwee_summary)
summary <- rbind(summary, ahn_chul_summary)

drawPostNumGraph(summary)
drawAverageLikeGraph(summary)

# reactions <- getReactions(post=posts$id, fb_oauth, verbose=TRUE)
drawLikeGraph(moon_posts)
drawLikeGraph(lee_posts)
drawLikeGraph(hwang_posts)
drawLikeGraph(yoo_posts)
drawLikeGraph(ahn_hwee_posts)
drawLikeGraph(ahn_chul_posts)

all_posts <- data.frame()
all_posts <- rbind(all_posts, moon_posts)
all_posts <- rbind(all_posts, lee_posts)
all_posts <- rbind(all_posts, hwang_posts)
all_posts <- rbind(all_posts, yoo_posts)
all_posts <- rbind(all_posts, ahn_hwee_posts)
all_posts <- rbind(all_posts, ahn_chul_posts)

ggplot(all_posts, aes(x=created_time, y=likes_count, group=from_name, colour=from_name)) + 
  geom_line(size=0.5) + 
  geom_smooth() +
  theme_minimal() + scale_x_date(labels = date_format("%m-%Y")) +
  labs(x = "날짜(MM-yyyy)", y = "좋아요수(n)") + 
  ggtitle(paste(start_date, end_date, sep="~"))


