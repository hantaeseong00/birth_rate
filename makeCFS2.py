import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns


# 아래는 한글 문제 해결하는 코드
import matplotlib.font_manager as fm

font_name = fm.FontProperties(fname=r"C:\Windows\Fonts\malgun.ttf").get_name()
plt.rc("font", family=font_name)

import matplotlib as mlp
mlp.rcParams["axes.unicode_minus"] = False

from bs4 import BeautifulSoup
import requests
import time
import random
from tqdm import tqdm_notebook
from fake_useragent import UserAgent

ua = UserAgent()

import folium
from IPython.display import display

from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.common.keys import Keys
import os
import traceback


# Press the green button in the gutter to run the script.
if __name__ == '__main__':
    df = pd.read_csv('./data/Caring_Facility_Status.csv')
    # print(df)
    df["station_name"] = df["station_name"].str.replace("\n","")
    df['station_name'] = df['station_name'].apply(lambda x: x if x.endswith('역') else x+"역")

    # print(df["station_name"].unique())
    df["주소"] = None
    df["구별"] = None
    df["lat"] = None
    df["lng"] = None

    for idx in df.index:
        url = "https://dapi.kakao.com/v2/local/search/keyword.json?query=" + df.loc[idx, "station_name"]
        head = {
            "Authorization": "KakaoAK " + "242c14237d1ba566f2c89a90adff7f65"
        }

        result = requests.get(url, headers=head).json()
        print(result["documents"][0])
        print(result["documents"][0]['address_name'])
        df["주소"][idx] = result["documents"][0]['address_name']
        print(result["documents"][0]['address_name'].split(" ")[1])
        df["구별"][idx] = result["documents"][0]['address_name'].split(" ")[1]
        print(result["documents"][0]['y'])
        df["lat"][idx] = result["documents"][0]['y']
        print(result["documents"][0]['x'])
        df["lng"][idx] = result["documents"][0]['x']
    # ka_station_address = []
    # ka_station_lat = []
    # ka_station_lng = []
    print(df)

    df.to_csv('./data/Caring_Facility_Status2.csv', index=False)

    # for name in station_names:
    #     url = f"https://dapi.kakao.com/v2/local/search/keyword.json?query={name}"
    #     place = requests.get(url, headers=header).json()['documents'][0]
    #     ka_station_address.append(place['address_name'])
    #     ka_station_lat.append(place['y'])
    #     ka_station_lng.append(place['x'])
# See PyCharm help at https://www.jetbrains.com/help/pycharm/
