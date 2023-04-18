# 크롤링을 위한 모듈
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns

from tqdm import tqdm


import urllib.request

from bs4 import BeautifulSoup
import requests
import time
import random
from tqdm import tqdm_notebook
import folium
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.common.keys import Keys
import os
import traceback
import glob
from webdriver_manager.chrome import ChromeDriverManager
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.common.action_chains import ActionChains

from xml.etree import ElementTree

# 워드 클라우드를 위한 모듈
from fake_useragent import UserAgent
ua = UserAgent()
from konlpy.tag import Okt
from collections import Counter
import wordcloud
from wordcloud import WordCloud
from PIL import Image
import networkx as nx


# 아래는 한글 문제 해결하는 코드
import matplotlib.font_manager as fm
import matplotlib as mlp
# font_name = fm.FontProperties(fname=r"C:\Windows\Fonts\malgun.ttf").get_name()
font_path = r"C:\PythonWork\PycharmWork\ProjectTeam1\data\crawling\font\BlackHanSans-Regular.ttf"
g_font_path = r"C:\Windows\Fonts\malgun.ttf"
font_name = fm.FontProperties(fname=font_path).get_name()
plt.rc("font", family=font_name)
mlp.rcParams["axes.unicode_minus"] = False


ServiceKey = "hDMqY7Vq9Ql%2F%2FDBdvOJnrnr0WpoXLZeV%2Fta7mwwz8eX8qLB2c35BbGco%2FRbt23Lvdvhq2ww4dEFST8WXvGt%2FUw%3D%3D"
pageNo = 1
numOfRows = 10000
#선거날짜
# "20120411","2012219","20140604",
sgIds = ["20150429","20151028","20160413","20170412","20170509","20180613","20190403","20220309","20200415","20210407","20220309","20220601"]
#선거타입
#1. 대통령 선거
#2. 국회의원 선거 & 전국동시지방선거
#3. 전국동시지방선거
#4. 국회의원 선거 & 전국동시지방선거
#11. 전국동시지방선거
sgTypecodes = ["1","2","3","4","11"]
#시도 이름
sdName = None
#구군 이름
sggName	= None

url_base = "https://apis.data.go.kr/9760000/WinnerInfoInqireService2/getWinnerInfoInqire?"

if __name__ != "__main__" :
    for sgId in sgIds:
        for sgTypecode in sgTypecodes:
            #당선인 정보 조회
            url = f"{url_base}serviceKey={ServiceKey}&pageNo={pageNo}&numOfRows={numOfRows}&sgId={sgId}&sgTypecode={sgTypecode}"

            xml = requests.get(url)

            print(xml.text)

            with open(f'./data/Candidate_Information/list_{sgId}_{sgTypecode}.txt', 'w', encoding="utf-8") as f:
                f.write(xml.text)

    path = "./data/Candidate_Information/"
    files = os.listdir(path)
    print(files)

    cols = ["sgId", "sgTypecode", "huboid", "sggName", "sdName", "jdName", "name", "gender", "dugsu", "dugyul"]
    init = pd.DataFrame(columns=cols)

    for file in files:
        with open(path+file, 'r', encoding="utf-8") as f:
            text = f.read()
            root = ElementTree.fromstring(str(text))
            items = root.findall("./body/items/item")

            for item in items:
                data = dict()
                for col in cols:
                    try:
                        data[col] = item.find(f"./{col}").text
                    except:
                        pass
                init = pd.concat([init, pd.DataFrame(data, index=[0])], ignore_index=True)


    print(init)
    null_count = init.isnull().sum()
    print(null_count)

    print(init["jdName"].unique())

    init.to_csv('./data/csv/Candidate_Information_kr.csv', na_rep='무소속', encoding="euc-kr")

if __name__ != "__main__" :
    ci = pd.read_csv("./data/csv/Candidate_Information_kr.csv", header=0, encoding="euc-kr")
    ci = ci[ci["sgTypecode"]!=2]
    # print(ci)
    url_base = "https://apis.data.go.kr/9760000/ElecPrmsInfoInqireService/getCnddtElecPrmsInfoInqire?"
    serviceKey = "hDMqY7Vq9Ql%2F%2FDBdvOJnrnr0WpoXLZeV%2Fta7mwwz8eX8qLB2c35BbGco%2FRbt23Lvdvhq2ww4dEFST8WXvGt%2FUw%3D%3D"
    pageNo = 1
    numOfRows = 10000
    sgId = None
    sgTypecode = None
    cnddtId = None

    for idx in ci.index:
        sgId = ci.loc[idx, "sgId"]
        sgTypecode = ci.loc[idx, "sgTypecode"]
        cnddtId = ci.loc[idx, "huboid"]
        url = f"{url_base}serviceKey={serviceKey}&pageNo={pageNo}&numOfRows={numOfRows}&sgId={sgId}&sgTypecode={sgTypecode}&cnddtId={cnddtId}"
        xml = requests.get(url)
        root = ElementTree.fromstring(str(xml.text))
        print(ci.loc[idx, "name"])
        for i in range(1, 11):
            try:
                ci.loc[idx, f"prmsRealmName{i}"] = root.find(f"./body/items/item/prmsRealmName{i}").text
                ci.loc[idx, f"prmsTitle{i}"] = root.find(f"./body/items/item/prmsTitle{i}").text
                ci.loc[idx, f"prmmCont{i}"] = root.find(f"./body/items/item/prmmCont{i}").text
            except:
                pass


    ci.to_csv('./data/csv/promise.csv', encoding="utf-8")
    ci.to_csv('./data/csv/promise_kr.csv', encoding="euc-kr")

if __name__ == "__main__" :
    g_font_path = r"C:\Windows\Fonts\malgun.ttf"

    topics = ["저출산","출산","출산율"]
    topic = "저출산"
    text = ""
    types = ["all","word"]
    type = 0
    okt = Okt()

    word_count = 30

    word_list = []
    rm_words = []

    G = nx.Graph()

    # promise_list = pd.read_csv(f'./data/csv/promise.csv', header=0, encoding="utf-8").fillna("")
    promise_list = pd.read_csv(f'./data/csv/promise_kr.csv', header=0, encoding="euc-kr").fillna("")
    promise_list = promise_list[promise_list["sgTypecode"]!=2]
    for idx in tqdm(promise_list.index):

        for i in range(1, 11):
            if "출산" in promise_list.loc[idx, f"prmsRealmName{i}"] or "출산" in promise_list.loc[idx, f"prmsTitle{i}"] or "출산" in promise_list.loc[idx, f"prmmCont{i}"]:
                text += promise_list.loc[idx, f"prmsRealmName{i}"]
                text += promise_list.loc[idx, f"prmsTitle{i}"]
                text += promise_list.loc[idx, f"prmmCont{i}"]

        print(promise_list.loc[idx, "name"])
        # if "출산" not in text: continue

    for topic in topics:
        noun = okt.nouns(text)

        stop_words = [v for v in noun if len(v) < 2]
        noun = [word for word in noun if word not in stop_words]
        noun = [word for word in noun if word not in rm_words]


        for type in range(2):
            word_list = []
            #토픽이 포함 된 공약 전체
            if(type == 0):
                word_list = noun

            #토픽의 전후 한단어
            if(type == 1):
                for i in tqdm(range(len(noun))):
                    if noun[i] == topic:
                        word_list.append(topic)
                        if i!= 0:
                            word_list.append(noun[i-1])
                        if i!=len(noun)-1:
                            word_list.append(noun[i+1])

            cnts = Counter(word_list)
            # cnts = Counter({key: value for key, value in cnts.items() if value > 9})
            dict_data = dict(cnts)
            print(dict_data)

            sorted_dict = {k: v for k, v in sorted(dict_data.items(), key=lambda item: item[1])}

            print(sorted_dict)

            font = r"C:\PythonWork\PycharmWork\ProjectTeam1\data\crawling\font\BlackHanSans-Regular.ttf"
            result = f'wordcloud_{topic}'

            # wc = WordCloud(font_path=font,
            #                background_color='#aaaacc')
            # wc.generate_from_frequencies(dict_data)

            icon = Image.open('./pngwing_com.png')  # 마스크가 될 이미지 불러오기
            plt.imshow(icon)

            mask = Image.new("RGB", icon.size, (255, 255, 255))
            mask.paste(icon, icon)
            mask = np.array(mask)

            wc = WordCloud(font_path=font,  # 폰트
                           background_color='white',  # 배경색
                           mask=mask,
                           max_words=word_count)  # 마스크설정

            wc.generate_from_frequencies(dict_data)
            image_colors = wordcloud.ImageColorGenerator(mask)

            plt.figure(figsize=(12, 12))
            plt.imshow(wc.recolor(color_func=image_colors), interpolation="bilinear")  # 이것도 결국 matplotlib쓰는거네
            plt.axis("off")

            # with open('C:/PythonWork/PycharmWork/newCrawler/data/' + str(sid1) + '_' + date + '.json', "w") as outfile:
            #     json.dump(dict_data, outfile)

            wc.to_file(f'C:\PythonWork\PycharmWork\ProjectTeam1\data\csv\{topic}_est_{types[type]}.png')

            plt.clf()

            max_idx = 30

            plt.rc('font', family='NanumGothic')
            mlp.rcParams["axes.unicode_minus"] = False

            word_df = pd.DataFrame.from_dict(dict_data, orient='index', columns=['count'])
            word_df.sort_values("count", ascending=False, inplace=True)
            print(word_df[1:11])
            splot = sns.barplot(x=word_df["count"][1:(max_idx+1)], y=word_df[1:(max_idx+1)].index)
            splot.set_title(f"{topic}_{types[type]}", fontsize=18)
            splot.tick_params(axis='both', labelsize=14)
            sfig = splot.get_figure()

            sfig.savefig(f'C:\PythonWork\PycharmWork\ProjectTeam1\data\csv\gf_{topic}_{types[type]}_{max_idx}.png', dpi=300)

            plt.clf()
