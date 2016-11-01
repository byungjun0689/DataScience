
# coding: utf-8

def sum_str(string):
    string = [float(i) for i in string.split(",")]
    return sum(string)

def sum_str2(string):
    from functools import reduce
    return reduce(lambda x,y : float(x)+float(y), string.split(","))

def until_new_year():
    import arrow
    Next_Newyear = arrow.get("2017-01-30 00:00:00", 'YYYY-MM-DD HH:mm:ss').replace(tzinfo='Asia/Seoul')
    Now = arrow.now('Asia/Seoul')
    return((Next_Newyear - Now).days)

def ua_string(browser):
    import re
    browser = browser.lower()
    explorer = re.compile("msie")
    explorer2 = re.compile("trident")
    chrome = re.compile("chrome")
    safari = re.compile("safari")
    firefox = re.compile("firefox")
    resultOfexplorer = re.search(explorer, browser)
    resultOfexplorer2 = re.search(explorer2, browser)
    resultOfchrome = re.search(chrome, browser)
    resultOfsafari = re.search(safari, browser)
    resultOffirefox = re.search(firefox, browser)

    if resultOfexplorer or resultOfexplorer2:
        return "I"
    if resultOffirefox:
        return "F"
    if resultOfchrome:
        return "C"
    if resultOfsafari:
        return "S"
    return "None of them"

def ua_string2(browser):
    from collections import OrderedDict
    browserContext = browser.lower()
    listOfbrowser = OrderedDict([('msie', 'I'), ('chrome', 'C'),('safari','S'),('firefox','F'),('trident','I')])
    for browser,Init in listOfbrowser.items():
        if browser in browserContext:
            return Init

def del_nan_row(DF):
    import pandas as pd
    import numpy as np
    if isinstance(DF, pd.DataFrame):
        return DF.dropna(how="all")
    else:
        return "It's not PanDas DataFrame"


print("Practice 1")
print("2 Answers : sum_str, sum_str2")
print("Practice 2")
print("Answer : until_new_year")
print("Practice 3")
print("2 Answers : ua_string, ua_string2")
print("Practice 4")
print("Answer : del_nan_row")
