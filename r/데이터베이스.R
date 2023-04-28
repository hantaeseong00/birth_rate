library(DBI)
library(RMySQL)

library(stringi)
library(dplyr)

# DB 연결 설정
con <- dbConnect(RMySQL::MySQL(),
                 host = "localhost",
                 user = "root",
                 password = "1111",
                 dbname = "teamproject1",
                 port = 3306,
                 charset='utf8')

# 테이블 생성
hospital_information <- read.csv("C:/PythonWork/PycharmWork/WindowProject/hodir/ho/hospital_medical_information_kr.csv", header = T, encoding = "EUC-KR")
View(hospital)

hospital[] <- lapply(hospital, function(x) if(is.character(x)) stri_encode(x, "UTF-8") else x)

hospital %>% 
  mutate_if(is.character, stri_enc_mark) %>% 
  select_if(function(x) any(is.raw(x)))

View(hospital)

dbCreateTable()
names(hospital_information) <- c("hospital_id", "type", "city", "county", "addr", "tel")

dbWriteTable(con, "hospital_information", hospital_information, overwrite = TRUE)

# DB 연결 해제
dbDisconnect(con)