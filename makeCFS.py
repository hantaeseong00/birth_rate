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

from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.common.keys import Keys
import os
import traceback


# Press the green button in the gutter to run the script.
if __name__ == '__main__':
    cols = [
    "subway_name",
    "station_name",
    "elevator",
    "escalator",
    "horizontal_walker",
    "wheelchair_lift",
    "Movable_safety_footrest",
    "electric_wheelchair_rapid_charger",
    "Disabled_toilets",
    "voice_guides",
    "sign_language_video_cellphone"
    ]
    subways = []

    init = pd.DataFrame(columns=cols)

    print(init)



    url = "http://www.seoulmetro.co.kr/kr/page.do?menuIdx=366"

    driver = webdriver.Chrome("data/chromedriver_win32/chromedriver")
    driver.get(url)

    for idx in range(1,10):
        radio = driver.find_element(By.ID, f"ck-line{idx}")
        radio.click()
        submit = driver.find_element(By.XPATH, f"// *[ @ id = \"contents\"] / div[1] / div[2]")
        submit.click()

        trs = driver.find_elements(By.XPATH, f"//*[@id=\"line_{idx}\"]/table/tbody/tr")

        for tr_idx, tr in enumerate(trs):
            data = dict()

            for td_idx, td in enumerate(cols):
                if td_idx==0:
                    data[cols[td_idx]] = idx
                elif idx==9 and td_idx==10:
                    data[cols[td_idx]] = "0"
                else:
                    # print(tr)
                    td = tr.find_element(By.CSS_SELECTOR, f"td:nth-child({(td_idx)})")
                    # print(tr.text)
                    # print(td_idx, td.text)
                    # print("-------------------")
                    result = td.text if len(td.text) > 0 else "0"
                    # print(cols[td_idx], result)
                    data[cols[td_idx]] = result
            # print(data)
            init = pd.concat([init, pd.DataFrame(data, index=[0])], ignore_index=True)
            # print(station)
            # init.merge(station)

        print(init.tail())

    init.to_csv('./data/Caring_Facility_Status.csv', index=False)


# See PyCharm help at https://www.jetbrains.com/help/pycharm/
