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

promise  = pd.read_csv("./data/csv/promise_kr.csv", encoding="euc-kr")

print(promise["sgId"].unique())

promise1 = promise[(promise["sgId"] == 20200415) & (promise["sgTypecode"] != 2)]
promise1 = promise[promise["sgTypecode"] != 2]
print(promise1)
promise1 = promise1[promise.columns[11:]]
promise1["sgTypecode"] = promise["sgTypecode"]
promise1

promise1["inTopic"] = promise[1:].apply(lambda row: "출산" in ''.join(str(row[col]) for col in promise.columns[12:]), axis=1)

promise_g_t = promise1.groupby("inTopic").count()
promise_g_m = promise1.groupby("inTopic").mean()
# print(promise1.groupby("inTopic").mean())

# sns.barplot(x = promise_g_t.index, y = promise_g_t["dugyul"] )
# plt.show()
# sns.barplot(x = promise_g_m.index, y = promise_g_m["dugyul"] )
# plt.show()

promise_g_t = promise1.groupby(["inTopic", "sgTypecode"])[["dugyul"]].count()
promise_g_m = promise1.groupby(["inTopic", "sgTypecode"])[["dugyul"]].mean()
print(promise_g_m)
print(promise_g_t.index)
sns.barplot(x = promise_g_t.index, y = promise_g_t["dugyul"] )
plt.show()
sns.barplot(x = promise_g_m.index, y = promise_g_m["dugyul"] )
plt.show()