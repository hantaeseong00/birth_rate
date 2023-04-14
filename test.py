import ProjFunc

# crawl = ProjFunc.ProJCrawl("반려동물","20230413","20230413")
# try:
#     crawl.getNewsList()
# except:
#     pass
# try:
#     crawl.getArticles()
# except:
#     pass

types = ["sen","word"]
lis = ["저출산", "출산율"]

for li in lis:
    for type in types:
        wc = ProjFunc.ProjWC(li,"20230101","20230413", 30)
        wc.makeWC(area = type)