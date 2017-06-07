import pandas as pd
import re
from urllib.parse import quote_plus
import requests
import json

data_list = pd.read_csv("news_samsung.csv")
find_news = re.compile(r'oid=([\d]+)&aid=([\d]+)')

#for i in range(len(data_list)):
comments_df = pd.DataFrame()
for i in range(len(data_list)):
	origin_url = data_list.ix[i,'url']
	ticket = "news"
	news_id  = str(find_news.findall(origin_url)[0][0])
	aid = str(find_news.findall(origin_url)[0][1])

	input_news = "news" + news_id
	objectId =  input_news + "," + aid
	objectId = quote_plus(objectId)

	comment_url = ('https://apis.naver.com/commentBox/cbox/web_neo_list_jsonp.json?'
	               'ticket={ticket}&templateId=default_it&pool=cbox5&_callback=jQuery1709951719079191433_1496387548832&'
	               'lang=ko&country=KR&objectId={objectId}&categoryId=&pageSize=20&indexSize=10&groupId=&'
	               'listType=OBJECT&page={page}&initialize=true&userType=&useAltSort=true&replyPageSize=20&moveTo=&'
	               'sort=reply&_=1496387549604')

	tmp_url = comment_url.format(ticket=ticket, objectId = objectId, page = 1)

	res = requests.get(tmp_url, headers = {'referer':origin_url})

	if res.status_code == 200:
		try:
			start = len(res.text[:100].split("(")[0]) + 1
			end = len(');')

			comment = json.loads(res.text[start:-end])
			#print(comment['result']['commentList'][0])
			T_comment = []
			T_recomment_cnt = []
			T_unlike = []
			T_like = []
			for comment_data in comment['result']['commentList']:
				T_recomment_cnt.append(comment_data['replyCount'])
				T_like.append(comment_data['sympathyCount'])
				T_unlike.append(comment_data['antipathyCount'])
				T_comment.append(comment_data['contents'])
			tmp_df = pd.DataFrame({'url':origin_url,'comment':T_comment,'recom_cnt': T_recomment_cnt,'unlike':T_unlike,'like':T_like})

			if len(tmp_df) > 0:
				comments_df = comments_df.append(tmp_df)
				print(tmp_df)

		except:
			print("없다")

comments_df.to_csv("tmp22.csv",index=False, encoding='utf8')
