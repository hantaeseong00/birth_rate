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
from selenium.webdriver.support.ui import Select

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


# Press the green button in the gutter to run the script.
if __name__ == '__main__':
    cols = ["url","title","startdate","enddate","org","subtitle","subcontents"]
    year = "2023"

    init = pd.DataFrame(columns=cols)
    #
    # print(init)
    url = f"https://www.gosims.go.kr/hg/hg008/retrieveSearchAssiBiz.do?tabNm=bsns#none"
    driver = webdriver.Chrome(service=Service(ChromeDriverManager().install()))
    driver.get(url)

    q = driver.find_element(By.CSS_SELECTOR, 'input#query')
    q.send_keys("출산")
    q.send_keys(Keys.ENTER)

    years = driver.find_element(By.CSS_SELECTOR, 'select#selectYear')
    years_element = Select(years)
    years_element.select_by_value(year)

    driver.find_element(By.CSS_SELECTOR, 'button.btn-select').click()

    page_num=1;

    while page_num<10000:
        # driver.get(driver.current_url)
        page_num += 1
        lis = driver.find_elements(By.CSS_SELECTOR,'section.category.list li')
        for li in lis:
            atag = li.find_elements(By.CSS_SELECTOR,'a')[0]
            li_title = atag.text
            li_url = atag.get_attribute("href")
            li_date = li.find_element(By.CSS_SELECTOR,'span.date').text.strip().split("~")
            li_startdate = li_date[0]
            li_enddate = li_date[1]
            li_org = li.find_element(By.CSS_SELECTOR,'span.org').text.strip()
            dds = li.find_elements(By.CSS_SELECTOR,'dd')
            li_subtitle = dds[0].text.strip()
            li_subcontents = dds[1].text.strip()
            # print(li_title)
            # print(li_url)
            # print(li_date)
            # print(li_org)
            # print(li_subtitle)
            # print(li_subcontents)
            # print("===============================")
            data = dict()
            data[cols[0]] = li_title
            data[cols[1]] = li_url
            data[cols[2]] = li_startdate
            data[cols[3]] = li_enddate
            data[cols[4]] = li_org
            data[cols[5]] = li_subtitle
            data[cols[6]] = li_subcontents
            init = pd.concat([init, pd.DataFrame(data, index=[0])], ignore_index=True)

        print("==========",page_num,"===========")
        print(init.tail(5))
        # init.to_csv('./crawling/n_news_20230407_euc_kr.csv', index=False, encoding="EUC-KR")

        if(((page_num-1)%10) == 0):
            init.to_csv(f'./data/crawling/biz_출산_{year}.csv', index=False)
            driver.find_element(By.CSS_SELECTOR, 'button.next').click()
        else:
            paging = driver.find_elements(By.CSS_SELECTOR,'nav.paging li')
            paging[((page_num-1)%10)].click()

        time.sleep(1.5)