#### 라이브러리 정리 ####
library(reshape2)
library(dplyr)

#### 함수 정리 ####

rename_location <- function(df) {
  city.names <- read.table("./csv/city_names.txt", stringsAsFactors = FALSE)[,2]

  for (city in unique(df$시군구별)) {
    for (newcity in city.names) {
      idx <- grep(city, newcity)
      if (length(idx) > 0) {
        idx <- which(df$시군구별 == city)
        df$시군구별[idx] <- newcity
      }
      if (city == "전북"){
        idx <- which(df$시군구별 == city)
        df$시군구별[idx] <- "전라북도"
      }
      if (city == "전남"){
        idx <- which(df$시군구별 == city)
        df$시군구별[idx] <- "전라남도"
      }
      if (city == "충북"){
        idx <- which(df$시군구별 == city)
        df$시군구별[idx] <- "충청북도"
      }
      if (city == "충남"){
        idx <- which(df$시군구별 == city)
        df$시군구별[idx] <- "충청남도"
      }
      if (city == "경북"){
        idx <- which(df$시군구별 == city)
        df$시군구별[idx] <- "경상북도"
      }
      if (city == "경남"){
        idx <- which(df$시군구별 == city)
        df$시군구별[idx] <- "경상남도"
      }
    }
  }
  return(df)
}

#### 2016년 이후 시도별 합계출산율 전처리 ####

### 시군구별
birth.rate <- read.csv("시군구_합계출산율__모의_연령별_출산율_20230419080419.csv", na.strings = "-", header = T)
birth.rate[is.na(birth.rate)] <- 0
birth.rate <- birth.rate[-1,-c(2:(2016-2000+1))]

birth.rate.m <- melt(birth.rate, id.vars = "시군구별", variable.name = "연도", value.name = "합계출산율")

birth.rate.m$연도 <- gsub("X", "", birth.rate.m$연도)
birth.rate.m$연도 <- as.integer(birth.rate.m$연도)
birth.rate.m$합계출산율 <- as.numeric(birth.rate.m$합계출산율)

write.csv(birth.rate.m, file = "./csv/birth_rate_sido_2016_2021.csv", row.names = F)

#### 2016년 이후 시도별 가장 많이 참여한 여가활동 전처리 ####

### 시군구별
leisure <- read.csv("지난_1년_동안_가장_많이_참여한_여가활동__12345순위__중분류_20230421084219.csv", na.strings = "-", header = T)
leisure[is.na(leisure)] <- 0
leisure <- subset(leisure, subset = (leisure[,"통계분류.1."] == "17개 시도별"))
leisure <- leisure[-c(2,4)]
leisure <- rename(leisure, 연도 = 시점, 시군구별 = 통계분류.2.)
leisure <- rename_location(leisure)

write.csv(leisure, file = "./csv/leisure_sido_2016_2021.csv", row.names = F)

#### 병합 ####

### 시군구별
merge.b.l <- merge(birth.rate.m, leisure, by= c("시군구별","연도"))
write.csv(merge.b.l, file = "./csv/merge_b_l_sido_2016_2021.csv", row.names = F)



#### 2014년 이후 시도별 합계출산율 전처리 ####

### 시군구별
birth.rate <- read.csv("시군구_합계출산율__모의_연령별_출산율_20230419080419.csv", na.strings = "-", header = T)
birth.rate[is.na(birth.rate)] <- 0
birth.rate <- birth.rate[-1,-c(2:(2014-2000+1))]

birth.rate.m <- melt(birth.rate, id.vars = "시군구별", variable.name = "연도", value.name = "합계출산율")

birth.rate.m$연도 <- gsub("X", "", birth.rate.m$연도)
birth.rate.m$연도 <- as.integer(birth.rate.m$연도)
birth.rate.m$합계출산율 <- as.numeric(birth.rate.m$합계출산율)

write.csv(birth.rate.m, file = "./csv/birth_rate_sido_2014_2021.csv", row.names = F)

#### 2014년 이후 시도별 가장 많이 참여한 여가활동 전처리 ####

### 시군구별
leisure <- read.csv("지난_1년_동안_가장_많이_참여한_여가활동__12345순위__중분류_20230421124000.csv", na.strings = "-", header = T)
leisure[is.na(leisure)] <- 0
leisure <- subset(leisure, subset = (leisure[,"통계분류.1."] == "17개 시도별"))
leisure <- leisure[-c(2,4)]
leisure <- rename(leisure, 연도 = 시점, 시군구별 = 통계분류.2.)
leisure <- rename_location(leisure)

write.csv(leisure, file = "./csv/leisure_sido_2014_2021.csv", row.names = F)

#### 병합 ####

### 시군구별
merge.b.l <- merge(birth.rate.m, leisure, by= c("시군구별","연도"))
write.csv(merge.b.l, file = "./csv/merge_b_l_sido_2014_2021.csv", row.names = F)

