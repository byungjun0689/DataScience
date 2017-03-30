# Background
How can we tell the greatness of a movie before it is released in cinema? 

This question puzzled me for a long time since there is no universal way to claim the goodness of movies. Many people rely on critics to gauge the quality of a film, while others use their instincts. But it takes the time to obtain a reasonable amount of critics review after a movie is released. And human instinct sometimes is unreliable.

# Question
1. Given that thousands of movies were produced each year, is there a better way for us to tell the greatness of movie without relying on critics or our own instincts?
2. Will the number of human faces in movie poster correlate with the movie rating?

# Method
To answer this question, I scraped 5000+ movies from IMDB website using a Python library called "scrapy".

The scraping process took 2 hours to finish. In the end, I was able to obtain all needed 28 variables for 5043 movies and 4906 posters (998MB), spanning across 100 years in 66 countries. There are 2399 unique director names, and thousands of actors/actresses. Below are the 28 variables:

"movie_title"
"color"
"num_critic_for_reviews"
"movie_facebook_likes" 
"duration"
"director_name"
"director_facebook_likes"
"actor_3_name" 
"actor_3_facebook_likes"
"actor_2_name"
"actor_2_facebook_likes"
"actor_1_name" 
"actor_1_facebook_likes"
"gross"
"genres"
"num_voted_users"
"cast_total_facebook_likes" 
"facenumber_in_poster"
"plot_keywords"
"movie_imdb_link"
"num_user_for_reviews"
"language"
"country"
"content_rating"
"budget"
"title_year"
"imdb_score"
"aspect_ratio"

To answer question 2, I applied the human face detection algorithm on all the posters using python library called dlib, and extracted the number of faces in posters.

# Blog and Github codes

See here for more details about the scraping steps, the EDA, and the predictions : https://blog.nycdatascience.com/student-works/machine-learning/movie-rating-prediction/

Github page: https://github.com/sundeepblue/movie_rating_prediction


# Important notes

1. This dataset is by no means to be a comprehensive scraping of all attributes relating to movies. It stemmed from one of my project built from scratch and finished in around one week. So please do not be surprised if you find something is off.

2. This dataset is a proof of concept. It can be used for experimental and learning purpose to get hands dirty on web scraping, basic EDA, and learning algorithms in R or Python. For comprehensive movie analysis and accurate movie ratings prediction, 28 attributes from 5000 movies might not be enough. A decent dataset could contain hundreds of attributes from 50K or more movies, and requires tons of feature engineering.

3. There are around 800 "0"s in the "gross" attribute. This was either caused by (a) no gross number was found in certain movie page, or (b) the response returned by scrapy http request returned nothing in short period of time. So please make your own judgement when analyzing on this attribute. 

4. There are around 908 directors whose "director_facebook_likes" attribute are 0. If somebody did analysis on "directory_facebook_like" attribute, there could be some off, and say, the top10, or top50 directors could be inaccurate. Thanks for pointing this out by user Kryslor. This is interesting, since the code I used to scrape everybody's facebook like were identical. See function [parse_facebook_likes_number()](https://github.com/sundeepblue/movie_rating_prediction/blob/master/parse_scraped_data.py). It was hard to directly scrape this data from IMDB website (due to dynamic embedded div frame), so I had to use a hacky way by directly sending request to facebook website (see [line 38 of this file](https://github.com/sundeepblue/movie_rating_prediction/blob/master/movie/spiders/imdb_spider.py)). Perhaps for some directors, facebook did not respond with reasonable result within short timespan (< 0.25 second) and returned "None" in Python (translated to 0 in my code). 

5. For those 0s, you might want to treat them as "missing value" when using certain machine learning algorithms. 

6. Thanks to user "Quinton", who found a bug in the dataset on 11/23/2016:
*(November 23, 2016 at 12:08 am) We actually used your IMDB dataset for an Advanced Data Mining class at Rockhurst University in Kansas City, MO. We love the data set and we really appreciate the time it took to create the it. However, we believe we found a small flaw in the data. Not all of the IMDB movie budget numbers are in US dollars, for example, the South Korean movie "The Host" has its budget numbers in S. Korean Won (Korean currency). But there is no data in the dataset that tells you the currency. The existance of foreign currencies skews the budget data for foreign films particularly for currencies with extreme exchange rates when compared to USD. For instance, many could assume the data set shows "The Host" cost $12 billion to make when it truthfully cost only 12 billion Won, but the dataset doesn't make the distinction. It is not just an issue with Korean movies we found Turkish and Japanese movies with the same issue.*
Quinton was right. When I parsed the currency, I didn't take the Korean currency into consideration. Therefore please be cautious if you analyze the currency related attributes for non US dollar currencies. The fix is actually quite simple in the corresponding python code.

7. Please be mindful that, analyzing currency related attributes, such as "gross" or "budget", is actually more complicated than it seems. For a really thorough and accurate analysis (EDA or prediction), we may want to do some feature engineering on those attributes in a systematic way. For example, one US dollar in 1920 is different from that of 2010. So we need to take ***inflation*** factors across years into consideration, and normalize all US dollars into one basis (a certain year). So do all other currencies (British pound, Chinese RMB Yuan, etc). If you also consider ***exchange rate*** between two different currencies and wanted to convert everything into dollars, things become tricker, because even those rates also varies over time. $1 equals RMB8.4 in 2000 but RMB6.8 in 2015.