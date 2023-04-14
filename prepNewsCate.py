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
import glob
from wordcloud import WordCloud, STOPWORDS
from konlpy.tag import Okt
from collections import Counter

from wordcloud import WordCloud
import wordcloud
import numpy as np
import matplotlib.pyplot as plt
import pandas as pd


# Press the green button in the gutter to run the script.
if __name__ == '__main__':

    topic="출산율+반려동물"
    news_cate = pd.read_csv(f"./data/\crawling/n_news_20230407_{topic}.csv", header=0)

    print(news_cate.describe())

    print(news_cate.head(5))

    print(news_cate.columns)

    sid = {
        4:"",
        100: "정치",
        101: "경제",
        102: "사회",
        103: "생활/문화",
        104: "세계",
        105: "IT/과학",
        106: "",
        110: "오피니언",
        115: "TV",
        123: "",
        154: "",
        161: "",
        162: ""
    }
    print(news_cate.groupby("sid1").count())

    for idx in news_cate.index:
        news_cate.loc[idx,"sid_name"] = sid[news_cate.loc[idx,"sid1"]]

    cate_vc = news_cate.groupby("sid_name").count()
    print(cate_vc)
    sns.barplot(cate_vc.T)

    plt.savefig(f"카테고리_{topic}.png")

    cate_name = "정치"

    for cate_name in news_cate.groupby("sid_name").count().index:
        news_cata_100 = news_cate[news_cate["sid_name"]==cate_name]
        text = ""
        for idx in news_cata_100.index:
            print(news_cata_100.loc[idx,"news_title"])
            text += str(news_cata_100.loc[idx,"news_title"])
            text += str(news_cata_100.loc[idx,"news_desc"])

        okt = Okt()
        noun = okt.nouns(text)

        stop_words = [v for v in noun if len(v) < 2]
        noun = [word for word in noun if word not in stop_words]

        print(noun)
        cnts = Counter(noun)

        dict_data = dict(cnts)

        font = r"C:\Windows\Fonts\malgun.ttf"
        result = f'wordcloud_{cate_name.replace("/","_")}_{topic}'

        wc = WordCloud(font_path=font,
                       background_color='#aaaacc')
        wc.generate_from_frequencies(dict_data)

        plt.figure(figsize=(12, 12))
        plt.imshow(wc, interpolation="bilinear")  # 이것도 결국 matplotlib쓰는거네
        plt.axis("off")
        #
        # with open('C:/PythonWork/PycharmWork/newCrawler/data/' + str(sid1) + '_' + date + '.json', "w") as outfile:
        #     json.dump(dict_data, outfile)

        wc.to_file(f'C:\PythonWork\PycharmWork\ProjectTeam1/{result}.png')
        # plt.show()