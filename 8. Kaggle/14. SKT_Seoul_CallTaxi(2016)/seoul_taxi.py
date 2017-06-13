from glob import glob
import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt
import datetime as dt
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
        
    if len(df) > 1:
        df_unqiue = df.drop_duplicates(['발신지_시도','발신지_시군구','발신지_읍면동'],keep ='first').reset_index()
        df_unqiue = df_unqiue.ix[:,['발신지_시도','발신지_시군구','발신지_읍면동']]
        df_unqiue['geo'] = df_unqiue.apply(lambda x:get_long_lati(x), axis=1)
        df_unqiue.to_csv("data/location_geo.csv",encoding='utf8',index=False)
        
        df = pd.merge(df,df_unqiue,how='left',on=['발신지_시도','발신지_시군구','발신지_읍면동'])
        df['기준년월일'] = pd.to_datetime(df['기준년월일'],format='%Y%m%d')
        df['일'] = df['기준년월일'].dt.day
        df['월'] = df['기준년월일'].dt.month
        df['장소'] = df['발신지_시도'] + " " + df['발신지_시군구'] + " " + df['발신지_읍면동']

        df.to_csv("data/total_taxi.csv",encoding='utf8',index=False)
        
def data_handling(data):
	pass


def get_long_lati(data):
    url = 'http://maps.googleapis.com/maps/api/geocode/json?sensor=false&language=ko&address={location}'
    location = " ".join(data)
    print(location)

    url = url.format(location=location)

    response = requests.get(url)
    js_geo = json.loads(response.text)

    latitude = js_geo["results"][0]["geometry"]["location"]["lat"]
    longitude = js_geo["results"][0]["geometry"]["location"]["lng"]

    results = (latitude,longitude)
    return results

if __name__ == '__main__':
	get_data()
	#data = pd.read_csv("data/total_taxi.csv")
	#data_handling(data)
	#getLongLati(data.ix[0])


