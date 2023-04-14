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

from webdriver_manager.chrome import ChromeDriverManager
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.common.action_chains import ActionChains
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.common.keys import Keys
import os
import traceback


# Press the green button in the gutter to run the script.
if __name__ == '__main__':
    cols = ["url","sid1","news_title","news_desc","date"]
    n_news = []

    topic = "저출산"
    start_date = "20230101"
    end_date = "20230413"

    news_data = pd.read_csv(f'./data/crawling/news_{topic}_{start_date}_{end_date}.csv', header=0, encoding="utf-8")
    print(news_data.head())
    driver = webdriver.Chrome(service=Service(ChromeDriverManager().install()))
    init = pd.DataFrame(columns=["url","title","desc","body"])
    tf = False
    for idx, url in enumerate(news_data["url"]):
        try:
            driver.get(url)
            title = driver.find_element(By.CSS_SELECTOR,'meta[property=og\:title]').get_attribute("content")
            desc = driver.find_element(By.CSS_SELECTOR,'meta[property=og\:description]').get_attribute("content")
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
            data["body"] = driver.find_element(By.CSS_SELECTOR,'div#dic_area').text
            init = pd.concat([init, pd.DataFrame(data, index=[0])], ignore_index=True)
            time.sleep(1.5)
        except:
            pass

    init.to_csv(f'./data/crawling/meta_{topic}_{start_date}_{end_date}.csv', index=False)
    # init.to_csv(f'./data/crawling/n_news_meta_{topic}.csv', index=False, encoding="EUC-KR")

    #
    # print(init)
    # url = f"https://search.naver.com/search.naver?sm=tab_hty.top&where=news&query={topic}"
    # driver = webdriver.Chrome(service=Service(ChromeDriverManager().install()))
    # driver.get(url)

    # page_num=1;

    # while page_num<10000:
    #     # driver.get(driver.current_url)
    #     page_num += 1
    #     atags = driver.find_elements(By.CSS_SELECTOR,'div.info_group a')
    #     for atag in atags:
    #         data = dict()
    #         if atag.text == "네이버뉴스":
    #             try:
    #                 news_area = atag.find_element(By.XPATH, '..').find_element(By.XPATH, '..').find_element(By.XPATH, '..')
    #                 info_group = atag.find_element(By.XPATH, '..')
    #                 data[cols[0]] = atag.get_attribute("href")
    #                 data[cols[1]] = atag.get_attribute("href").split("?sid=")[1]
    #                 data[cols[2]] = news_area.find_element(By.CSS_SELECTOR,"a.news_tit").text
    #                 data[cols[3]] = news_area.find_element(By.CSS_SELECTOR,"div.news_dsc div.dsc_wrap a").text
    #                 data[cols[4]] = news_area.find_elements(By.CSS_SELECTOR,"span.info")[-1].text
    #                 init = pd.concat([init, pd.DataFrame(data, index=[0])], ignore_index=True)
    #             except:
    #                 pass
    #     driver.find_element(By.LINK_TEXT, str(page_num)).click()
    #     time.sleep(1.5)
    #     print(init.tail(5))



    #
    # for idx in range(1,10):
    #     radio = driver.find_element(By.ID, f"ck-line{idx}")
    #     radio.click()
    #     submit = driver.find_element(By.XPATH, f"// *[ @ id = \"contents\"] / div[1] / div[2]")
    #     submit.click()
    #
    #     trs = driver.find_elements(By.XPATH, f"//*[@id=\"line_{idx}\"]/table/tbody/tr")
    #
    #     for tr_idx, tr in enumerate(trs):
    #         data = dict()
    #
    #         for td_idx, td in enumerate(cols):
    #             if td_idx==0:
    #                 data[cols[td_idx]] = idx
    #             elif idx==9 and td_idx==10:
    #                 data[cols[td_idx]] = "0"
    #             else:
    #                 # print(tr)
    #                 td = tr.find_element(By.CSS_SELECTOR, f"td:nth-child({(td_idx)})")
    #                 # print(tr.text)
    #                 # print(td_idx, td.text)
    #                 # print("-------------------")
    #                 result = td.text if len(td.text) > 0 else "0"
    #                 # print(cols[td_idx], result)
    #                 data[cols[td_idx]] = result
    #         # print(data)
    #         init = pd.concat([init, pd.DataFrame(data, index=[0])], ignore_index=True)
    #         # print(station)
    #         # init.merge(station)
    #
    #     print(init.tail())

    # init.to_csv('./data/crawling/n_news_meta_저출산.csv', index=False)


# See PyCharm help at https://www.jetbrains.com/help/pycharm/
