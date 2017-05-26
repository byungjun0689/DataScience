
### 바로 Stream 해서 즉각즉각 대응할 때 사용하면 좋을듯.
import tweepy
# consumer_key, consumer_secret from twitter api site
consumer_key = ''
consumer_secret = ''
access_token = ''
access_token_secret = ''
auth = tweepy.OAuthHandler(consumer_key,consumer_secret)
auth.set_access_token(access_token, access_token_secret)

api = tweepy.API(auth)
public_tweets = api.home_timeline()

len(public_tweets)
type(public_tweets)

for tweet in enumerate(public_tweets):
    print(tweet[0], tweet[1].text)

user = api.get_user('twitter')
user


class MyStreamListener(tweepy.StreamListener):

    def on_status(self, status):
        print(status.text)

myStreamListener = MyStreamListener()
myStream = tweepy.Stream(auth = api.auth, listener=myStreamListener)
t = myStream.filter(track=['python'])


from TwitterAPI import TwitterAPI
api = TwitterAPI(consumer_key, consumer_secret, access_token, access_token_secret)
r = api.request('search/tweets', {'q':'pizza'})
r.status_code

screen_name = []
for item in r.get_iterator():
    screen_name.append(item['user']['screen_name'])
    print(item['user']['screen_name'])


len(screen_name)


import requests
