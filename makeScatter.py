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
from sklearn.linear_model import LinearRegression


# Press the green button in the gutter to run the script.
if __name__ == '__main__':
    cfs = pd.read_csv('./data/Caring_Facility_Status3.csv')
    dcp = pd.read_csv('./data/Number_of_people_with_disabilities_compared_to_population.csv')

    # print(df)
    # print(df.info())
    gu_cfs = cfs.groupby("구별").sum()
    gu_dcp = dcp.groupby("구별").sum()
    cols = [
    "elevator",
    "escalator",
    "horizontal_walker",
    "wheelchair_lift",
    "Movable_safety_footrest",
    "electric_wheelchair_rapid_charger",
    "Disabled_toilets",
    "voice_guides",
    "sign_language_video_cellphone",
    "total"]
    cols2 = [
        "horizontal_walker",
        "wheelchair_lift",
        "Movable_safety_footrest",
        "electric_wheelchair_rapid_charger",
        "voice_guides",
        "sign_language_video_cellphone"]
    print(gu_cfs.info())
    print(gu_cfs[cols])
    print(gu_dcp.info())
    result = pd.concat([gu_cfs, gu_dcp], axis=1).dropna()
    result["total2"] = result[cols2].sum(axis=1)
    print(result.info())
    print(result[["total","total2"]].head())
    result["비율"] = result["총합계"]/result["인구수"]
    result["심한장애비율"] = result["심한장애_합계"]/result["총합계"]
    result["심하지않은장애비율"] = result["심하지않은_합계"]/result["총합계"]
    result["남성장애인비율"] = result["남"]/result["총합계"]
    result["여성장애인비율"] = result["여"]/result["총합계"]

    col3 = ["심한장애비율","심하지않은장애비율","남성장애인비율","여성장애인비율"]

    # for y in cols[:-1]:
    for y in cols2:
    # for x in col3:
        x = "남성장애인비율"
        # y="total2"

        result[x+"정규화"] = (result[x]-result[x].min())/(result[x].max()-result[x].min())
        result[y+"정규화"] = (result[y]-result[y].min())/(result[y].max()-result[y].min())

        z = np.polyfit(result[x+'정규화'], result[y+'정규화'], 1) # 기울기와 절편 확인
        f = np.poly1d(z) # f(x): f함수에 x값을 넣으면 y값을 계산해 줌

        print(x, y, z[0], z[1])

        fig = plt.figure()
        ax = sns.lmplot(x=x + "정규화", y=y + "정규화", data=result, order=1)
        ax.fig.set_size_inches(12, 8)
        ax.set(title=f"{x}와 지하철 {y} 개수의 연관성", xlabel=x, ylabel=f"{y} 개수")

        plt.savefig(f"{x}와 지하철 {y} 개수의 연관성.png")

    # for col in cols:
    #     state_geo = "data/skorea_municipalities_geo_simple_seoul.json"
    #     map = folium.Map(location=[37.560000, 127.0000000], zoom_start=11)
    #     map.choropleth(geo_data=state_geo, data=df1, key_on="feature.id",
    #                    columns=[df1.index, col], fill_color="PuRd")
    #
    #     map.save(f'./data/{col}.html')
# See PyCharm help at https://www.jetbrains.com/help/pycharm/
