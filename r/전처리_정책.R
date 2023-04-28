#### 라이브러리 정리 ####
library(reshape2)
library(dplyr)
install.packages("data.table")
library(data.table)

sido <- c("전국","서울특별시","부산광역시","인천광역시","대구광역시","대전광역시","광주광역시","울산광역시","세종특별자치시","경기도","강원도","충청북도","충청남도","전라북도","전라남도","경상북도","경상남도","제주특별자치도")

#### 2021 ####
file_path <- "C:\\PythonWork\\PycharmWork\\ProjectTeam1\\data\\crawling\\biz_출산_2021.csv"
policy2021 <- read.csv(file_path, na.strings = "-", header = T, encoding = "UTF-8")
  
policy2021$org <- gsub(" [0-9]{4}[.]{1}[0-9]{2}[.]{1}[0-9]{2} ~ [0-9]{4}[.]{1}[0-9]{2}[.]{1}[0-9]{2}", "", policy2021$org)

policy2021$startdate <- gsub("[.]{1}[0-9]{2}[.]{1}[0-9]{2} ", "", policy2021$startdate)
policy2021$enddate <- gsub("[.]{1}[0-9]{2}[.]{1}[0-9]{2}", "", policy2021$enddate)

policy2021$government <- sapply(strsplit(as.character(policy2021$org), split = ">"), "[", 1)
policy2021$시군구별 <- gsub("교육청","",sapply(strsplit(as.character(policy2021$org), split = ">"), "[", 2))
policy2021$시군구별[is.na(policy2021$시군구별)] <- "전국"

policy2021 <- subset(policy2021, 시군구별 %in% sido)

#### 2022 ####
file_path <- "C:\\PythonWork\\PycharmWork\\ProjectTeam1\\data\\crawling\\biz_출산_2022.csv"
policy2022 <- read.csv(file_path, na.strings = "-", header = T, encoding = "UTF-8")

policy2022$org <- gsub(" [0-9]{4}[.]{1}[0-9]{2}[.]{1}[0-9]{2} ~ [0-9]{4}[.]{1}[0-9]{2}[.]{1}[0-9]{2}", "", policy2022$org)

policy2022$startdate <- gsub("[.]{1}[0-9]{2}[.]{1}[0-9]{2} ", "", policy2022$startdate)
policy2022$enddate <- gsub("[.]{1}[0-9]{2}[.]{1}[0-9]{2}", "", policy2022$enddate)

policy2022$government <- sapply(strsplit(as.character(policy2022$org), split = ">"), "[", 1)
policy2022$시군구별 <- gsub("교육청","",sapply(strsplit(as.character(policy2022$org), split = ">"), "[", 2))
policy2022$시군구별[is.na(policy2022$시군구별)] <- "전국"

policy2022 <- subset(policy2022, 시군구별 %in% sido)

View(policy2022)


#### 2023 ####
file_path <- "C:\\PythonWork\\PycharmWork\\ProjectTeam1\\data\\crawling\\biz_출산_2023.csv"
policy2023 <- read.csv(file_path, na.strings = "-", header = T, encoding = "UTF-8")

policy2023$org <- gsub(" [0-9]{4}[.]{1}[0-9]{2}[.]{1}[0-9]{2} ~ [0-9]{4}[.]{1}[0-9]{2}[.]{1}[0-9]{2}", "", policy2023$org)

policy2023$startdate <- gsub("[.]{1}[0-9]{2}[.]{1}[0-9]{2} ", "", policy2023$startdate)
policy2023$enddate <- gsub("[.]{1}[0-9]{2}[.]{1}[0-9]{2}", "", policy2023$enddate)

policy2023$government <- sapply(strsplit(as.character(policy2023$org), split = ">"), "[", 1)
policy2023$시군구별 <- gsub("교육청","",sapply(strsplit(as.character(policy2023$org), split = ">"), "[", 2))
policy2023$시군구별[is.na(policy2023$시군구별)] <- "전국"

policy2023 <- subset(policy2023, 시군구별 %in% sido)

View(policy2023)

#### 병합 ####
policy <- rbind(policy2021,policy2022,policy2023)
policy <- policy[policy$startdate != "", ]

policy$startdate <- as.numeric(policy$startdate)
policy$enddate <- as.numeric(policy$enddate)

write.csv(merge.a.g, file = "./csv/merge_p_2021_2023.csv", row.names = F)

#### 시도별 ####

policy_sido_2020 <- policy %>% filter(startdate<=2020 & enddate>=2020) %>% group_by(시군구별) %>% summarise(개수 = n())

policy_sido_2021 <- policy %>% filter(startdate<=2021 & enddate>=2021) %>% group_by(시군구별) %>% summarise(개수 = n())

policy_sido_2022 <- policy %>% filter(startdate<=2022 & enddate>=2022) %>% group_by(시군구별) %>% summarise(개수 = n())

policy_sido_2023 <- policy %>% filter(startdate<=2023 & enddate>=2023) %>% group_by(시군구별) %>% summarise(개수 = n())

policy_sido_2020[,"연도"] = 2020
policy_sido_2021[,"연도"] = 2021
policy_sido_2022[,"연도"] = 2022
policy_sido_2023[,"연도"] = 2023

policy_sido <- rbind(policy_sido_2020, policy_sido_2021, policy_sido_2022, policy_sido_2023)
policy_year <- policy_sido %>% group_by(연도) %>% summarise(합계 = sum(개수))
policy_year

ggplot(policy_year, aes(연도, 합계)) +
  geom_line()

#### 부서별 ####

policy_gov_2020 <- policy %>% filter(startdate<=2020 & enddate>=2020) %>% group_by(government) %>% summarise(개수 = n())

policy_gov_2021 <- policy %>% filter(startdate<=2021 & enddate>=2021) %>% group_by(government) %>% summarise(개수 = n())

policy_gov_2022 <- policy %>% filter(startdate<=2022 & enddate>=2022) %>% group_by(government) %>% summarise(개수 = n())

policy_gov_2023 <- policy %>% filter(startdate<=2023 & enddate>=2023) %>% group_by(government) %>% summarise(개수 = n())

policy_gov_2020[,"연도"] = 2020
policy_gov_2021[,"연도"] = 2021
policy_gov_2022[,"연도"] = 2022
policy_gov_2023[,"연도"] = 2023

policy_gov_sido <- rbind(policy_gov_2020, policy_gov_2021, policy_gov_2022, policy_gov_2023)
policy_gov_year <- policy_sido %>% group_by(연도,government) %>% summarise(합계 = sum(개수))
View(policy_gov_year)

ggplot(policy_gov_year, aes(연도, 합계, col=government)) +
  geom_line()

#### 시도별 2021,2022 합계출산율과 정책 수 상관분석 ####

policy_sido <- policy_sido %>% filter(연도 %in% c(2021:2022))

file_path <- "./csv/birth_rate_sido_2016_2022.csv"
birth.rate.2022 <- read.csv(file_path, na.strings = "-", header = T, encoding = "EUC-KR")
birth.rate.2022 <- birth.rate.2022[,-c(2:6,8)]
names(birth.rate.2022) <- c("시군구별","2021","2022")

birth.rate.2022 <- melt(birth.rate.2022, id.vars = "시군구별", variable.name = "연도", value.name = "출산율")
birth.rate.2022 <- birth.rate.2022 %>% filter(연도 %in% c(2021:2022))
View(policy_sido)
View(birth.rate.2022)

merge.b.ps <- merge(birth.rate.2022,policy_sido, by=c("시군구별","연도"))

cor.test(merge.b.ps$개수, merge.b.ps$출산율)
ggplot(data = merge.b.ps, aes(x = 개수, y = 출산율)) +
  geom_point() + geom_smooth(method="lm") 
