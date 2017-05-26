# -*- coding: utf-8 -*-
"""
Created on Tue May 23 15:21:44 2017

@author: MCR007
"""

import os
import re
import pandas as pd

#dirname = "//mcr022/FRISM_SOURCE/"
#dirname = "//mcr022/FRISM_SOURCE/진료/병동간호"
dirname = "//mcr022/FRISM_SOURCE/"
checkReport = re.compile(r"([\w가-힣\d\_\-\?\!]+\.rpt)")
#dirlist = os.listdir(dirname)

def search(dirname,findstr):
    tmp_dirlist = os.listdir(dirname)
    for i in tmp_dirlist:  
        spath = os.path.join(dirname,i)
        if os.path.isdir(spath):
            search(spath,findstr)
        else:
            ext = os.path.splitext(spath)[-1]
            if ext == ".frm":
                try:
                    lines = open(spath,'r').read()
                    if findstr in lines:
                        path_list.append(spath)
                        rpt_list.append(list(set(checkReport.findall(lines))))
                        print(spath)#print(findstr+" 문자열이 "+path+" 에 존재.")
                        print(list(set(checkReport.findall(lines))))
                except:
                    print("에러 : "+ spath)
                    #f findstr in open(path,'r','utf-8').read():
path_list = []
rpt_list = []         
search(dirname,".rpt")

data.to_csv("tmp.csv",index=False,encoding='cp949')
data = pd.read_csv("tmp.csv",encoding='cp949')
data.head()
data = pd.DataFrame({'path':path_list,'rpt':rpt_list})
data['path'] = data['path'].str.replace('//mcr022/FRISM_SOURCE/',"")
data['path'] = data['path'].str.replace('\\','/')
data['임시'] = data['path'].apply(lambda x:'임시' in x)
data['테스트'] = data['path'].apply(lambda x:'테스트' in x)
data['영종'] = data['path'].apply(lambda x:'영종' in x)
data = data[data['임시']==False]
data = data[data['테스트']==False]
data = data[data['영종']==False]
data.head()
del data['임시']
del data['테스트']
del data['영종']

data['EXE'] = data['path'].apply(lambda x:x.split("/")[2])
data['frm'] = data['path'].apply(lambda x:x.split("/")[-1])
data['root'] = data['path'].apply(lambda x:x.split("/")[1])

del data['path']
data = data.reset_index()
del data['index']
data['rpt'].apply(lambda x:pd.Series(x))
data = data.join(data['rpt'].apply(lambda x:pd.Series(x)),how='left')
data['size'] = data['rpt'].apply(lambda x:len(x))
del data['rpt']
data = data.fillna("")
data.head()
data.to_excel("report_total.xls",sheet_name="Sheet1",index=False)
#data.to_csv("rpt_data.csv",index=False)
#data.to_csv("건진_data.csv",index=False)



## 영종도 따로.
data2 = pd.DataFrame({'path':path_list,'rpt':rpt_list})
data2['path'] = data2['path'].str.replace('//mcr022/FRISM_SOURCE/',"")
data2['path'] = data2['path'].str.replace('\\','/')
data2['임시'] = data2['path'].apply(lambda x:'임시' in x)
data2['테스트'] = data2['path'].apply(lambda x:'테스트' in x)
data2['영종'] = data2['path'].apply(lambda x:'영종' in x)

data2 = data2[data2['임시']==False]
data2 = data2[data2['테스트']==False]
data2 = data2[data2['영종']==True]

data2['EXE'] = data2['path'].apply(lambda x:x.split("/")[2])
data2['frm'] = data2['path'].apply(lambda x:x.split("/")[-1])
data2['root'] = data2['path'].apply(lambda x:x.split("/")[1])

del data2['path']
data2 = data2.reset_index()
del data2['index']
data2['rpt'].apply(lambda x:pd.Series(x))
data2 = data2.join(data2['rpt'].apply(lambda x:pd.Series(x)),how='left')
del data2['rpt']
data2 = data2.fillna("")
data2.head()

del data2['임시']
del data2['테스트']
del data2['영종']

data2.to_excel("report_total_영종.xls",sheet_name="Sheet1",index=False)

