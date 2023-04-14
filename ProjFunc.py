# -*- coding: utf-8 -*-
import re
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns

# 크롤링을 위한 모듈
from bs4 import BeautifulSoup
import requests
import time
import random
from tqdm import tqdm_notebook
import folium
from IPython.display import display
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.common.keys import Keys
import os
import traceback
import glob
from webdriver_manager.chrome import ChromeDriverManager
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.common.action_chains import ActionChains

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

class ProJCrawl:
    # 클래스 변수
    # class_variable = "Hello"
    cols = ["url","sid1","news_title","news_desc","date"]
    n_news = []
    delay = 1.5

    # 생성자
    def __init__(self, topic, start_date, end_date):
        # 인스턴스 변수
        self.topic = topic
        self.start_date = start_date
        self.end_date = end_date

    # 메서드
    def getNewsList(self):
        url = f"https://search.naver.com/search.naver?sm=tab_hty.top&where=news&query={self.topic}&pd=3&ds={self.start_date}&de={self.end_date}"
        driver = webdriver.Chrome(service=Service(ChromeDriverManager().install()))
        driver.get(url)
        self.page_num = 1;
        init = pd.DataFrame(columns=self.cols)
        while self.page_num < 10000:
            self.page_num += 1
            atags = driver.find_elements(By.CSS_SELECTOR, 'div.info_group a')
            for atag in atags:
                data = dict()
                if atag.text == "네이버뉴스":
                    try:
                        news_area = atag.find_element(By.XPATH, '..').find_element(By.XPATH, '..').find_element(
                            By.XPATH, '..')
                        info_group = atag.find_element(By.XPATH, '..')
                        data[self.cols[0]] = atag.get_attribute("href")
                        data[self.cols[1]] = atag.get_attribute("href").split("?sid=")[1]
                        data[self.cols[2]] = news_area.find_element(By.CSS_SELECTOR, "a.news_tit").text
                        data[self.cols[3]] = news_area.find_element(By.CSS_SELECTOR, "div.news_dsc div.dsc_wrap a").text
                        data[self.cols[4]] = news_area.find_elements(By.CSS_SELECTOR, "span.info")[-1].text
                        init = pd.concat([init, pd.DataFrame(data, index=[0])], ignore_index=True)
                    except:
                        pass

            print("==========", self.page_num, "===========")
            print(init.tail(5))

            self.makeCSV(init, f'./data/crawling/news_{self.topic}_{self.start_date}_{self.end_date}.csv')

            driver.find_element(By.LINK_TEXT, str(self.page_num)).click()
            time.sleep(self.delay)

    def makeCSV(self, init, csv_path):
        init.to_csv(csv_path, index=False)
        # init.to_csv('./crawling/n_news_20230407_euc_kr.csv', index=False, encoding="EUC-KR")

    def getArticles(self):
        news_data = pd.read_csv(f'./data/crawling/news_{self.topic}_{self.start_date}_{self.end_date}.csv', header=0, encoding="utf-8")
        print(news_data.head())
        driver = webdriver.Chrome(service=Service(ChromeDriverManager().install()))
        init = pd.DataFrame(columns=["url", "title", "desc", "body"])
        tf = False
        for idx, url in enumerate(news_data["url"]):
            try:
                driver.get(url)
                title = driver.find_element(By.CSS_SELECTOR, 'meta[property=og\:title]').get_attribute("content")
                desc = driver.find_element(By.CSS_SELECTOR, 'meta[property=og\:description]').get_attribute("content")
                desc = desc.split(" ")
                desc = " ".join(desc[:-1])

                print("==============", idx, "================")
                print(title)
                print(desc)
                print()

                data = dict()
                data["url"] = url
                data["title"] = title
                data["desc"] = desc
                data["body"] = driver.find_element(By.CSS_SELECTOR, 'div#dic_area').text
                init = pd.concat([init, pd.DataFrame(data, index=[0])], ignore_index=True)
                time.sleep(1.5)
            except:
                pass

        self.makeCSV(init, f'./data/crawling/meta_{self.topic}_{self.start_date}_{self.end_date}.csv')


class ProjNx:
    def __init__(self, topic, start_date, end_date, word_count):
        # 인스턴스 변수
        self.topic = topic
        self.start_date = start_date
        self.end_date = end_date
        self.word_count = word_count

class ProjWC():
    rm_words = ['가파르', '낳을']
    rm_keywords = ['나경원']

    # 생성자
    def __init__(self, topic, start_date, end_date, word_count):
        # 인스턴스 변수
        self.topic = topic
        self.start_date = start_date
        self.end_date = end_date
        self.word_count = word_count

        self.G = nx.Graph()

    def checkNaN(self, news_list, idx):
        if (news_list.loc[idx, "title"] is None or news_list.loc[idx, "title"] is np.nan): return True
        if (news_list.loc[idx, "desc"] is None or news_list.loc[idx, "desc"] is np.nan): return True
        if (news_list.loc[idx, "body"] is None or news_list.loc[idx, "body"] is np.nan): return True
        return False

    def checkKeyword(self, news_list, idx):
        if self.checkNaN(news_list, idx) : return True
        try:
            for rm_keyword in self.rm_keywords:
                if (rm_keyword in news_list.loc[idx, "title"]) or (rm_keyword in news_list.loc[idx, "desc"]) or (
                        rm_keyword in news_list.loc[idx, "body"]):
                    return True
        except:
            print(news_list.loc[idx, "title"])
            print(news_list.loc[idx, "desc"])
            print(news_list.loc[idx, "body"])
            return False
        return False

    def makeCSV(self, init, csv_path):
        init.to_csv(csv_path, index=False)

    def makeGF(self,dict_data, target, area, topic, max_idx = 10):
        font_name = fm.FontProperties(fname=g_font_path).get_name()
        plt.rc("font", family=font_name)
        mlp.rcParams["axes.unicode_minus"] = False

        word_df = pd.DataFrame.from_dict(dict_data, orient='index', columns=['count'])
        word_df.sort_values("count", ascending=False, inplace=True)
        print(word_df[1:11])
        sfig = None
        splot = None
        splot = sns.barplot(x=word_df["count"][1:(max_idx+1)], y=word_df[1:(max_idx+1)].index)
        splot.set_title(topic, fontsize=18)
        splot.tick_params(axis='both', labelsize=14)
        sfig = splot.get_figure()
        sfig.set_size_inches(12, 12)

        sfig.savefig(f'C:\PythonWork\PycharmWork\ProjectTeam1\data\crawling\graph\wc\gf_{topic}_{target}_{area}_{self.start_date}_{self.end_date}_{self.word_count}.png', orientation="landscape")

    def makeWC(self, target = "body", area = "all"):
        keyword = self.topic
        news_list = pd.read_csv(f'./data/crawling/meta_{self.topic}_{self.start_date}_{self.end_date}.csv', header=0, encoding="utf-8")
        print(news_list.tail())
        text = ""
        desc = ""
        okt = Okt()
        topic_sen_list = []
        word_list = []
        for idx in news_list.index:
            if self.checkKeyword(news_list, idx) : continue
            text = news_list.loc[idx, target]
            text = text.split("@")[0]
            # print(text)
            # break
            sen_list = text.split(".")
            topic_sen_list.extend([sen.replace("\n"," ").strip() for sen in sen_list if self.topic in sen])

            sen_list = sen_list if area == "all" else [sen.replace("\n"," ").strip() for sen in sen_list if self.topic in sen]

            for sen in sen_list:
                # if topic not in sen: continue

                noun = okt.nouns(sen)

                stop_words = [v for v in noun if len(v) < 2]
                noun = [word for word in noun if word not in stop_words]
                noun = [word for word in noun if word not in self.rm_words]
                tokens = noun

                # print(noun)

                # 단어를 노드로 추가
                for token in tokens:
                    self.G.add_node(token)

                if area != "word":
                    for i in range(len(tokens)):
                        if tokens[i] == self.topic: continue
                        if self.G.has_edge(self.topic, tokens[i]):
                            self.G.edges[tokens[i], self.topic]['weight'] += 1
                        else:
                            self.G.add_edge(tokens[i], self.topic, weight=1)

                        word_list.append(self.topic)
                        word_list.append(tokens[i])
                else:
                    # 저출산과 관련 된 관계 추가
                    for i in range(1,len(tokens)-1):
                        if tokens[i] == self.topic and tokens[i] != tokens[i-1] and tokens[i] != tokens[i+1]:
                            # print(tokens[i-1],tokens[i],tokens[i+1])
                            if self.G.has_edge(tokens[i-1], tokens[i]):
                                self.G.edges[tokens[i-1], tokens[i]]['weight'] += 1
                            else:
                                self.G.add_edge(tokens[i-1], tokens[i], weight=1)
                            if self.G.has_edge(tokens[i], tokens[i+1]):
                                self.G.edges[tokens[i], tokens[i+1]]['weight'] += 1
                            else:
                                self.G.add_edge(tokens[i], tokens[i+1], weight=1)
                            word_list.append(tokens[i-1])
                            word_list.append(tokens[i])
                            word_list.append(tokens[i+1])


        with open(f'./data/crawling/sen_{self.topic}_{target}_{area}_{self.start_date}_{self.end_date}.txt', 'w', encoding="utf-8") as f:
            f.write("\n".join(topic_sen_list))

        cnts = Counter(word_list)
        # cnts = Counter({key: value for key, value in cnts.items() if value > 9})
        dict_data = dict(cnts)
        print(dict_data)

        self.makeGF(dict_data, target=target, area=area, topic=self.topic)

        sorted_dict = {k: v for k, v in sorted(dict_data.items(), key=lambda item: item[1])}

        print(sorted_dict)

        font = font_path
        result = f'wordcloud_{self.topic}'

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
                       max_words=self.word_count)  # 마스크설정

        wc.generate_from_frequencies(dict_data)
        image_colors = wordcloud.ImageColorGenerator(mask)

        plt.figure(figsize=(12, 12))
        plt.imshow(wc.recolor(color_func=image_colors), interpolation="bilinear")  # 이것도 결국 matplotlib쓰는거네
        plt.axis("off")
        #
        # with open('C:/PythonWork/PycharmWork/newCrawler/data/' + str(sid1) + '_' + date + '.json', "w") as outfile:
        #     json.dump(dict_data, outfile)

        wc.to_file(
            f'C:\PythonWork\PycharmWork\ProjectTeam1\data\crawling\graph\wc\{result}_{target}_{area}_{self.start_date}_{self.end_date}_{self.word_count}.png')
