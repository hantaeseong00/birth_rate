# -*- coding: utf-8 -*-

import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns


# 아래는 한글 문제 해결하는 코드
import matplotlib.font_manager as fm

# font_name = fm.FontProperties(fname=r"C:\Windows\Fonts\malgun.ttf").get_name()
font_name = fm.FontProperties(fname=r"C:\PythonWork\PycharmWork\ProjectTeam1\data\crawling\font\BlackHanSans-Regular.ttf").get_name()
plt.rc("font", family=font_name)

import matplotlib as mlp
mlp.rcParams["axes.unicode_minus"] = False

from fake_useragent import UserAgent

ua = UserAgent()

from konlpy.tag import Okt
from collections import Counter
import matplotlib.pyplot as plt
import pandas as pd

import networkx as nx
import matplotlib.pyplot as plt


from wordcloud import WordCloud
from PIL import Image
import wordcloud
import numpy as np

if __name__ == '__main__':
    # rm_words = ['하라','노력','확산','임명','이번','준비','가래','이하','백신','오픈','헬로비전','자신감','나경원','윤석열','사위','올해','징수','직원','적십자사','지적자','모든','활성화','파마','바이오', '시니어', '본부', '부재', '기부', '실전', '김성', '갈수록', '원장', '이후', '변수', '모두', '위해', '고민정', '부탁', '얼마', '화두', '지시', '회의', '과감', '대통령', '직접', '이제', '생각', '반도체', '직원', '대해', '부위', '핵심', '사내', '그간', '주재', '기자', '오전', '직속', '맞춤', '달라', '하나', '엑스포', '라며', '차금법', '대부', '인터뷰', '교총', '교회', '목사', '업무', '음료', '기독교', '기후', '뽀로로', '개신교', '프랑스', '후미', '반전', '갈등', '집중', '언론', '도쿄', '추진', '재원', '방송', '보도', '담당', '이탈리아', '조명', '대한', '사설', '우리', '정도', '파격', '위원회', '하나', '지금', '주문', '때문', '보고서', '기교', '사의', '대사', '출마', '용산', '도전', '민주당', '당권', '통해', '이상', '앞서', '뉴시스', '대통령실', '과감', '영빈', '전당대회', '뉴스', '청와대', '원장', '표명', '대표', '총리', '기본', '장관', '제대로', '김현숙', '함영주', '김영미', '오리진', '밀크', '이영훈', '브리핑', '해임', '지난', '영빈', '칼럼', '우리', '관계자', '회위', '발표', '거론', '언론', '제출', '상임', '사실', '속보', '투입', '논란', '비판', '게임', '대답', '모바일', '지구온난화', '헬로', '이노베이션', '혈액', '실전', '가능', '존재', '갈수록', '도쿄도', '사진', '마련', '대가', '사안', '여야', '이제', '기금', '다자', '가운데', '지난해', '부처', '협약', '센터', '토론회', '부분', '필요', '회장', '금융', '분유']
    rm_words = ['가파르','낳을']
    # 빈 그래프 생성
    G = nx.Graph()


    topic = "저출산"
    start_date = "20230101"
    end_date = "20230413"

    keword = topic
    news_list = pd.read_csv(f'./data/crawling/meta_{topic}_{start_date}_{end_date}.csv', header=0, encoding="utf-8")
    print(f'./data/crawling/meta_{topic}_{start_date}_{end_date}.csv')
    print(news_list.tail())
    text = ""
    desc = ""
    okt = Okt()

    word_count = 30

    word_list = []
    for idx in news_list.index:
        try:
            if ("나경원" in news_list.loc[idx, "title"]) or ("나경원" in news_list.loc[idx, "desc"]) or ("나경원" in news_list.loc[idx, "body"]):
                continue
        except:
            print(news_list.loc[idx, "title"])
            print(news_list.loc[idx, "desc"])
            print(news_list.loc[idx, "body"])
            pass
        if (news_list.loc[idx, "body"] is None or news_list.loc[idx, "body"] is np.nan): continue
        text = news_list.loc[idx, "body"]
        text = text.split("@")[0]
        # print(text)
        # break
        sen_list = text.split(".")

        for sen in sen_list:
            # if topic not in sen: continue

            noun = okt.nouns(sen)

            stop_words = [v for v in noun if len(v) < 2]
            noun = [word for word in noun if word not in stop_words]
            noun = [word for word in noun if word not in rm_words]
            tokens = noun

            # print(noun)

            # 단어를 노드로 추가
            for token in tokens:
                G.add_node(token)

            for i in range(len(tokens)):
                if tokens[i] == topic: continue
                if G.has_edge(topic, tokens[i]):
                    G.edges[tokens[i],topic]['weight'] += 1
                else:
                    G.add_edge(tokens[i],topic, weight=1)

                word_list.append(topic)
                word_list.append(tokens[i])
            # 저출산과 관련 된 관계 추가
            # for i in range(1,len(tokens)-1):
            #     if tokens[i] == keword and tokens[i] != tokens[i-1] and tokens[i] != tokens[i+1]:
            #         print(tokens[i-1],tokens[i],tokens[i+1])
            #         if G.has_edge(tokens[i-1], tokens[i]):
            #             G.edges[tokens[i-1], tokens[i]]['weight'] += 1
            #         else:
            #             G.add_edge(tokens[i-1], tokens[i], weight=1)
            #         if G.has_edge(tokens[i], tokens[i+1]):
            #             G.edges[tokens[i], tokens[i+1]]['weight'] += 1
            #         else:
            #             G.add_edge(tokens[i], tokens[i+1], weight=1)


    cnts = Counter(word_list)
    cnts = Counter({key: value for key, value in cnts.items() if value > 9})
    dict_data = dict(cnts)
    print(dict_data)

    sorted_dict = {k: v for k, v in sorted(dict_data.items(), key=lambda item: item[1])}

    print(sorted_dict)

    font = r"C:\PythonWork\PycharmWork\ProjectTeam1\data\crawling\font\BlackHanSans-Regular.ttf"
    result = f'wordcloud_{topic}'

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
                   max_words=word_count)  # 마스크설정

    wc.generate_from_frequencies(dict_data)
    image_colors = wordcloud.ImageColorGenerator(mask)

    plt.figure(figsize=(12, 12))
    plt.imshow(wc.recolor(color_func=image_colors), interpolation="bilinear")  # 이것도 결국 matplotlib쓰는거네
    plt.axis("off")
    #
    # with open('C:/PythonWork/PycharmWork/newCrawler/data/' + str(sid1) + '_' + date + '.json', "w") as outfile:
    #     json.dump(dict_data, outfile)

    wc.to_file(f'C:\PythonWork\PycharmWork\ProjectTeam1\data\crawling\graph\wc\{result}_{start_date}_{end_date}_{word_count}.png')

    # 그래프 시각화
    degree_centrality = nx.degree_centrality(G)
    print(degree_centrality)
    pos = nx.spring_layout(G, k=0.3)

    print(degree_centrality)

    degree_centrality[keword] = 0
    degree_centrality[keword] = degree_centrality[max(degree_centrality,key=degree_centrality.get)]

    print(degree_centrality[keword])

    max_val = degree_centrality[max(degree_centrality,key=degree_centrality.get)]
    min_val = degree_centrality[min(degree_centrality,key=degree_centrality.get)]
    print(max_val, min_val)
    for key, val in degree_centrality.items():
        degree_centrality[key] = (val-min_val)/(max_val-min_val)

    # 노드 필터링
    threshold = 0.3  # 필터링 기준값 설정

    #노드의 관련도를 계산하여 필터링 기준값보다 작은 노드들을 제거
    filtered_nodes = [node for node, degree in degree_centrality.items() if degree > threshold]
    G.remove_nodes_from([node for node in G.nodes() if node not in filtered_nodes])
    # G.remove_edges_from([node for node in G.edges(data=True) if d['weight'] < 2])

    degree_centrality = nx.degree_centrality(G)

    degree_centrality[keword] = 0
    degree_centrality[keword] = degree_centrality[max(degree_centrality, key=degree_centrality.get)]*2

    max_val = degree_centrality[max(degree_centrality, key=degree_centrality.get)]
    min_val = degree_centrality[min(degree_centrality, key=degree_centrality.get)]
    for key, val in degree_centrality.items():
        degree_centrality[key] = val / max_val


    node_size = [v * 10000 for v in degree_centrality.values()]  # 노드 크기를 degree_centrality 값에 비례하도록 조정
    nx.draw_networkx_nodes(G, pos, node_color='r', node_size=[v * 1000 for v in degree_centrality.values()])
    # nx.draw_networkx_nodes(G, pos, node_color='r', node_size=1000)
    nx.draw_networkx_labels(G, pos, font_size=10, font_family=font_name)
    nx.draw_networkx_edges(G, pos, edgelist=G.edges(), width=[G[u][v]['weight'] for u,v in G.edges()])
    plt.axis('off')
    plt.show()

    # 네트워크 분석
    degree_centrality = nx.degree_centrality(G)
    betweenness_centrality = nx.betweenness_centrality(G)
    closeness_centrality = nx.closeness_centrality(G)
    print('Degree Centrality:', degree_centrality)
    print('Betweenness Centrality:', betweenness_centrality)
    print('Closeness Centrality:', closeness_centrality)