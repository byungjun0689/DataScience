from glob import glob
import pandas as pd
#import seaborn as sns
#import matplotlib.pyplot as plt
#import datetime as dt
import requests
import json

#from matplotlib import font_manager, rc
#font_name = font_manager.FontProperties(fname="c:/Windows/Fonts/malgun.ttf").get_name()
#rc('font', family=font_name)

def get_data():
	lists = glob('data/*.csv')

	df = pd.DataFrame()
	for data in lists:
		tmp = pd.read_csv(data)
		df = df.append(tmp)

	if len(df) > 0:
		print("get_data")
		try:
			df['geo'] = df.apply(lambda x:get_long_lati(x),axis=1)
		except:
			df['geo'] = null
		#data.to_csv("data/total_taxi.csv",encoding='utf8',index=False)
		df.to_csv("data/total_taxi.csv",encoding='utf8',index=False)

def data_handling(data):
	pass


def get_long_lati(data):
	url = 'http://maps.googleapis.com/maps/api/geocode/json?sensor=false&language=ko&address={location}'
	location = " ".join(data[3:6])

	url = url.format(location=location)

	response = requests.get(url)
	js_geo = json.loads(response.text)

	latitude = js_geo["results"][0]["geometry"]["location"]["lat"]
	longitude = js_geo["results"][0]["geometry"]["location"]["lng"]

	results = (latitude,longitude)
	print(results)
	return results

if __name__ == '__main__':
	get_data()
	#data = pd.read_csv("data/total_taxi.csv")
	#data_handling(data)
	#getLongLati(data.ix[0])


