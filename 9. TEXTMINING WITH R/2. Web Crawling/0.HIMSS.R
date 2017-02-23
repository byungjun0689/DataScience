# GET pdf file from HIMSS Conference Site
# http://www.himssconference.org/Search/SessionSearch


library(httr) # http 통신.
library(rvest)
library(dplyr)

library(qgraph)
library(wordcloud)
library(wordcloud2)
library(stringr)

base_url = "http://www.himssconference.org/Search/SessionSearch"

r <- GET(base_url)
doc <- read_html(r)
filter_node <- html_nodes(doc,"#block-facetapi-ya102dvkqufdy9rbhbipdlru3vfsjc1t")
li_nodes <- html_nodes(filter_node,"li.leaf")
len_li <- length(li_nodes)

# Get topics text
topics <- c()

for(i in 7:len_li){
  # Get Topics #
  sp_title <- html_text(li_nodes[i])
  sp_title <- str_split(sp_title,pattern = "Apply")[[1]][1]
  sp_title <- str_replace(sp_title,"\\(\\d+\\)","")
  topics <- c(topics,sp_title)
  folder_name <- paste0("folder_",i)
  if(dir.exists(folder_name)==F){
    dir.create(folder_name) 
  }
  # ==================================== #
  # Get PDF Files # 
  get_param <- html_node(li_nodes[i],"a") %>% html_attr("href")
  url <- paste0(base_url,get_param) # 첫페이지 값에서 안에 내용 가지고 오고 나머지들은 또 URl로

  r_each <- GET(url)
  each_html <- read_html(r_each)
  each_detail_nodes <- html_nodes(each_html,".ds-schedule-page-group-right")
  each_detail_row <- html_nodes(each_detail_nodes,".views-row")

  # 첫 페이지 데이터 넣기.
  session_urls <- html_nodes(each_detail_row,"h4 a") %>% html_attr("href")
  session_titles <- html_nodes(each_detail_row,"h4 a") %>% html_text()
  session_url_row <- session_urls[grepl(pattern = "/session/",session_urls)]
  session_title_row <- session_titles[grepl(pattern = "/session/",session_urls)]
  
  length_text <- length(session_url_row)
  for(k in 1:length_text){
    getFile(folder_name,session_title_row[k],paste0("http://www.himssconference.org",session_url_row[k]))
  }
  
  get_page_url <- html_nodes(each_html,".pagination") %>% html_nodes("li")
  len_pages <- length(get_page_url)
  for(j in 2:(len_pages-1)){
    tmp_url <- html_node(get_page_url[j],"a") %>% html_attr("href")
    tmp_url <- paste0(base_url,tmp_url)
    level2_r <- GET(tmp_url)
    level2_html <- read_html(level2_r)
    level2_detail_nodes <- html_nodes(level2_html,".ds-schedule-page-group-right")
    level2_detail_row <- html_nodes(level2_detail_nodes,".views-row")
    level2_session_urls <- html_nodes(level2_detail_row,"h4 a") %>% html_attr("href")
    level2_session_titles <- html_nodes(level2_detail_row,"h4 a") %>% html_text()
    level2_session_url_row <- level2_session_urls[grepl(pattern = "/session/",level2_session_urls)]
    level2_session_title_row <- level2_session_titles[grepl(pattern = "/session/",level2_session_urls)]
    level2_length <- length(level2_session_url_row)
    if(level2_length>0){
      for(z in 1:level2_length){
        print(z)
        getFile(folder_name,level2_session_title_row[z],paste0("http://www.himssconference.org",level2_session_url_row[z]))
      }
    }
  }
}

getFile <- function(numberOftopics,filename,url){
  tmp_r <- GET(url)
  tmp_h <- read_html(tmp_r)
  tt <- html_nodes(tmp_h,".field-item.even") %>% html_nodes("a") %>% html_attr("href") 
  file_url <- tt[grepl(".pdf",tt)]
  full_filename <- paste0(numberOftopics,"/",gsub("[[:punct:]]","",filename),".pdf")
  print(file_url)
  print(full_filename)
  if(length(file_url)>=1){
    download.file(file_url,full_filename) 
  }
}

for(i in 1:length(topics)){
  folder_name <- paste0("folder_",i)
  print(folder_name)
  if(dir.exists(folder_name)){
    file.rename(folder_name,str_trim(topics[i],side="right")) 
  }
}

# making directory and download files 
dir.create("tmp")
download.file("http://www.himssconference.org/sites/himssconference/files/pdf/49_0.pdf","tmp/level file.pdf")
# it's way to download file from the website using url. download.file(url,"file.name or directory with file's name")

