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
    pos = pd.read_csv("./data/population_of_seoul_2021.csv", header=2)
    dos = pd.read_excel("./data/disabled_of_seoul_2021.xlsx", sheet_name=13, header=[4, 5])
    del pos["동별(1)"]
    del pos["항목"]

    cols = pos.columns

    print(dos.columns)
    print(dos.head())

if __name__ != '__main__':

    dos = dos.droplevel(level=0, axis=1)
    dos.columns = ["시도", "시군구", "나이", "심한장애_남", "심한장애_여", "심한장애_합계", "심하지않은_남", "심하지않은_여", "심하지않은_합계", "남", "여", "총합계"]
    dos = dos.loc[dos['시도'] == "서울특별시", :]
    del dos["시도"]
    dos = dos.loc[(dos['나이'] != "소계") & (dos['나이'] != "합계"), :]

    dos['나이'] = dos['나이'].astype(float).astype(int)

    dos.loc[:, "나이2"] = dos["나이"].apply(lambda x: f'{x // 5 * 5}~{(x // 5 + 1) * 5 - 1}세' if x < 100 else "100세 이상")

    dos = dos.groupby(["시군구", "나이2"]).sum()

    del pos["소계"]

    pos = pos.T
    pos.columns = pos.iloc[0]
    pos = pos[1:]

    del pos["소계"]

    pos = pos.stack()
    pos = pos.swaplevel().sort_index()

    result = pd.concat([dos, pos], axis=1)
    result.rename(columns={0: "인구수"}, inplace=True)

    result["비율"] = result["총합계"] / result["인구수"]
    result["비율정규화"] = (result["비율"] - result["비율"].min()) / (result["비율"].max() - result["비율"].min())

    result.reset_index(inplace=True)

    result.rename(columns={"level_0": "구별", "level_1": "나이대"}, inplace=True)

    result["인구수"] = result["인구수"].astype(int)
    result["비율"] = result["비율"].astype(float)
    result["비율정규화"] = result["비율정규화"].astype(float)
    result.info()
    del result["나이"]

    # result.to_csv("./data/Number_of_people_with_disabilities_compared_to_population.csv", encoding="UTF-8")
    # result.to_csv("./data/인구수_대비_장애인_수.csv", encoding="EUC-KR")

    result = result.pivot_table(index="구별", values=["총합계", "인구수"], aggfunc="sum")

    result["비율"] = result["총합계"] / result["인구수"]
    result["비율정규화"] = (result["비율"] - result["비율"].min()) / (result["비율"].max() - result["비율"].min())
    # result["비율"].sort_values().plot.barh()

    print(result)
    fig = plt.figure(figsize=(12, 8))
    ax = fig.add_subplot(1, 1, 1)
    ax = result["비율"].sort_values().plot.barh()
    ax.set_title("지역구에 따른 인구수 비교")
    ax.set_xlabel("장애인 인구수")
    ax.set_ylabel("지역구")
    plt.show()

    state_geo = "data/skorea_municipalities_geo_simple_seoul.json"

    map = folium.Map(location=[37.560000, 127.0000000], zoom_start=11)
    # map
    map = folium.Map(location=[37.560000, 127.0000000], zoom_start=11)
    map.choropleth(geo_data=state_geo, data=result, key_on="feature.id",
                   columns=[result.index, "총합계"], fill_color="PuRd")

    df = pd.read_csv('./data/Caring_Facility_Status3.csv')
    print(df)
    # {'lightgray', 'darkblue', 'darkpurple', 'white', 'cadetblue', 'blue', 'pink', 'green', 'orange', 'lightred',
    # 'purple', 'beige', 'lightgreen', 'lightblue', 'red', 'black', 'darkgreen', 'gray', 'darkred'}
    # for idx in df.index:
    # folium.Marker(location=[df["lat"][idx], df["lng"][idx]], popup=df["station_name"][idx],
    #               icon=folium.Icon(color="beige", icon='star')).add_to(map)
    # folium.CircleMarker(location=[df["lat"][idx],df["lng"][idx]],popup=df["total"][idx], radius=df["total"][idx]/5, color="#26BB98", fill_color="#26BB98").add_to(map)

    map.save('./data/총합계.html')

# See PyCharm help at https://www.jetbrains.com/help/pycharm/
