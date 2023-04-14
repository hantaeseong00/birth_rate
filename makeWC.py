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

from bs4 import BeautifulSoup as bs
import bs4

import networkx as nx

# Press the green button in the gutter to run the script.
if __name__ == '__main__':
    rm_words = ['하라','노력','확산','임명','이번','준비','가래','이하','백신','오픈','헬로비전','자신감','나경원','윤석열','사위','올해','징수','직원','적십자사','지적자','모든','활성화','파마','바이오', '시니어', '본부', '부재', '기부', '실전', '김성', '갈수록', '원장', '이후', '변수', '모두', '위해', '고민정', '부탁', '얼마', '화두', '지시', '회의', '과감', '대통령', '직접', '이제', '생각', '반도체', '직원', '대해', '부위', '핵심', '사내', '그간', '주재', '기자', '오전', '직속', '맞춤', '달라', '하나', '엑스포', '라며', '차금법', '대부', '인터뷰', '교총', '교회', '목사', '업무', '음료', '기독교', '기후', '뽀로로', '개신교', '프랑스', '후미', '반전', '갈등', '집중', '언론', '도쿄', '추진', '재원', '방송', '보도', '담당', '이탈리아', '조명', '대한', '사설', '우리', '정도', '파격', '위원회', '하나', '지금', '주문', '때문', '보고서', '기교', '사의', '대사', '출마', '용산', '도전', '민주당', '당권', '통해', '이상', '앞서', '뉴시스', '대통령실', '과감', '영빈', '전당대회', '뉴스', '청와대', '원장', '표명', '대표', '총리', '기본', '장관', '제대로', '김현숙', '함영주', '김영미', '오리진', '밀크', '이영훈', '브리핑', '해임', '지난', '영빈', '칼럼', '우리', '관계자', '회위', '발표', '거론', '언론', '제출', '상임', '사실', '속보', '투입', '논란', '비판', '게임', '대답', '모바일', '지구온난화', '헬로', '이노베이션', '혈액', '실전', '가능', '존재', '갈수록', '도쿄도', '사진', '마련', '대가', '사안', '여야', '이제', '기금', '다자', '가운데', '지난해', '부처', '협약', '센터', '토론회', '부분', '필요', '회장', '금융', '분유']

    topic="출산율"
    news_list = pd.read_csv(f"./data/crawling/n_news_meta_{topic}.csv", header=0, encoding="euc-kr")
    news_list.head()
    text = ""
    desc = ""
    for idx in news_list.index:
        if ("나경원" in news_list.loc[idx, "title"]) or ("나경원" in news_list.loc[idx, "desc"]):
            continue
        text = text+" "+news_list.loc[idx, "title"]
        desc = desc+" "+news_list.loc[idx, "desc"]
    okt = Okt()
    noun = okt.nouns(text)

    stop_words = [v for v in noun if len(v) < 2]
    noun = [word for word in noun if word not in stop_words]
    noun = [word for word in noun if word not in rm_words]

    print(noun)
    cnts = Counter(noun)

    dict_data = dict(cnts)

    font = r"C:\Windows\Fonts\malgun.ttf"
    result = f'wordcloud_{topic}'

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