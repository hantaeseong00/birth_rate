#### 라이브러리 정리 ####
library(reshape2)
library(dplyr)
#install.packages("data.table")
library(data.table)

animal <- read.csv("반려동물+유무+및+취득+경로_20230425121456.csv", na.strings = "-", header = F, encoding = "UTF-8")

animal <- animal[-1,c(1:5)]
animal <- animal %>% filter(V2 == "지역소분류")
names(animal) <- c("연도","분류","시군구별","유","무")
animal <- animal[,-2]

#View(animal)


gu <- read.csv("시군구_출생아수__합계출산율_20230425122427.csv", na.strings = "-", header = F, encoding = "EUC-KR", header = T)

names(gu) <- c("연도","시군구별","합계출산율")

#View(gu)

merge.a.g <- merge(gu, animal, by=c("시군구별","연도"))

View(merge.a.g)

#names(animal) <- animal[,2]

write.csv(merge.a.g, file = "./csv/merge_b_a_gu_2014_2021.csv", row.names = F)

View(merge.a.g)






item <- read.csv("품목별_소비자물가지수_품목성질별_2020100__20230425131250.csv", na.strings = "-", header = T, encoding = "EUC-KR")

names(item) <- c("시군구별","연도","반려동물용품비","반려동물관리비")

birth.rate.m <- read.csv("./csv/birth_rate_sido_2014_2021.csv", header = T)

View(birth.rate.m)


merge.b.ai <- merge(birth.rate.m, item, by=c("시군구별","연도"))

write.csv(merge.b.ai, file = "./csv/merge_b_ai_sido_2014_2021.csv", row.names = F)

View(merge.b.ai)
