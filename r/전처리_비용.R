#### 라이브러리 정리 ####
library(reshape2)
library(dplyr)
#install.packages("data.table")
library(data.table)

item <- read.csv("품목별_소비자물가지수_품목성질별_2020100__20230425182156.csv", na.strings = "-", header = T, encoding = "EUC-KR")
item

item <- rename(item, 시군구별 = "시도별")
item <- rename(item, 연도 = "시점")

birth.rate.m <- read.csv("./csv/birth_rate_sido_2014_2021.csv", header = T)

View(birth.rate.m)


merge.b.ai <- merge(birth.rate.m, item, by=c("시군구별","연도"))


write.csv(merge.b.ai, file = "./csv/merge_b_yi_sido_2014_2021.csv", row.names = F)

View(merge.b.ai)
