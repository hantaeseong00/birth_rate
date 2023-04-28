# -*- coding: utf-8 -*-

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
from PIL import Image

biz_list = pd.read_csv(f"./data/crawling/biz_birth_2021_2023.csv", header=0, encoding="utf-8")
biz_list = biz_list.drop_duplicates()
print(biz_list.info())

biz_names = list(biz_list["government"].value_counts().index)

word_count = 100

for biz_idx, _ in enumerate(biz_names):

    text = ""
    for subcontents in biz_list[biz_list["government"]==biz_names[biz_idx]]["subcontents"]:
        text = text+str(subcontents)

    okt = Okt()
    noun = okt.nouns(text)
    stop_words = [v for v in noun if len(v) < 2]
    noun = [word for word in noun if word not in stop_words]

    print(noun)
    cnts = Counter(noun)

    dict_data = dict(cnts)

    font = r"C:\Windows\Fonts\malgun.ttf"
    result = f'wordcloud_{biz_names[0]}'

    icon = Image.open('./pngwing_com.png')  # 마스크가 될 이미지 불러오기
    plt.imshow(icon)

    mask = Image.new("RGB", icon.size, (255, 255, 255))
    mask.paste(icon, icon)
    mask = np.array(mask)

    font = r"C:\PythonWork\PycharmWork\ProjectTeam1\data\crawling\font\BlackHanSans-Regular.ttf"

    wc = WordCloud(font_path=font,  # 폰트
                   background_color='white',  # 배경색
                   mask=mask,
                   max_words=word_count)  # 마스크설정

    wc.generate_from_frequencies(dict_data)
    image_colors = wordcloud.ImageColorGenerator(mask)

    plt.figure(figsize=(12, 12))
    plt.imshow(wc.recolor(color_func=image_colors), interpolation="bilinear")  # 이것도 결국 matplotlib쓰는거네
    plt.axis("off")

    wc.to_file(f'C:\PythonWork\PycharmWork\ProjectTeam1/wc_biz_{biz_names[biz_idx]}.png')