leisure.purpose <- read.csv("C:\\PythonWork\\PycharmWork\\ProjectTeam1\\data\\csv\\leisure\\여가활동의_주된_목적_20230419172850.csv", header = T)

leisure.purpose

View(leisure.purpose)
leisure.purpose[1,1] = "통계분류1"
leisure.purpose[1,2] = "통계분류2"
columns <- leisure.purpose[1,c((1:2),3:(3+9))]
columns

leisure.purpose.2014 <- leisure.purpose[,c(c((1:2),3:12))]
leisure.purpose.2016 <- leisure.purpose[,c(c((1:2),13:23))]
leisure.purpose.2018 <- leisure.purpose[,c(c((1:2),24:34))]
leisure.purpose.2019 <- leisure.purpose[,c(c((1:2),35:45))]
leisure.purpose.2020 <- leisure.purpose[,c(c((1:2),46:56))]
leisure.purpose.2021 <- leisure.purpose[,c(c((1:2),57:67))]

names(leisure.purpose.2014) <- leisure.purpose[1,c(c((1:2),3:12))]
names(leisure.purpose.2016) <- leisure.purpose[1,c(c((1:2),13:23))]
names(leisure.purpose.2018) <- leisure.purpose[1,c(c((1:2),24:34))]
names(leisure.purpose.2019) <- leisure.purpose[1,c(c((1:2),35:45))]
names(leisure.purpose.2020) <- leisure.purpose[1,c(c((1:2),46:56))]
names(leisure.purpose.2021) <- leisure.purpose[1,c(c((1:2),57:67))]

leisure.purpose.2014 <- leisure.purpose.2014[-1,]
leisure.purpose.2016 <- leisure.purpose.2016[-1,]
leisure.purpose.2018 <- leisure.purpose.2018[-1,]
leisure.purpose.2019 <- leisure.purpose.2019[-1,]
leisure.purpose.2020 <- leisure.purpose.2020[-1,]
leisure.purpose.2021 <- leisure.purpose.2021[-1,]

leisure.purpose.2014$연도 <- 2014
leisure.purpose.2016$연도 <- 2016
leisure.purpose.2018$연도 <- 2018
leisure.purpose.2019$연도 <- 2019
leisure.purpose.2020$연도 <- 2020 
leisure.purpose.2021$연도 <- 2021 

View(leisure.purpose.2014)

library(dplyr)
library(reshape2)

keyword <- "전체"

leisure.purpose.2014.1 <- leisure.purpose.2014 %>% filter(통계분류1 == keyword)
leisure.purpose.2014.m <- melt(leisure.purpose.2014.1, id=c("통계분류1","통계분류2","연도"))
leisure.purpose.2014.m$value <- as.numeric(leisure.purpose.2014.m$value)
leisure.purpose.2014.m <- leisure.purpose.2014.m %>% arrange(desc(value))
leisure.purpose.2014.m

leisure.purpose.2016.1 <- leisure.purpose.2016 %>% filter(통계분류1 == keyword)
leisure.purpose.2016.m <- melt(leisure.purpose.2016.1, id=c("통계분류1","통계분류2","연도"))
leisure.purpose.2016.m$value <- as.numeric(leisure.purpose.2016.m$value)
leisure.purpose.2016.m <- leisure.purpose.2016.m %>% arrange(desc(value))
leisure.purpose.2016.m <- leisure.purpose.2016.m[-1,]
leisure.purpose.2016.m

leisure.purpose.2018.1 <- leisure.purpose.2018 %>% filter(통계분류1 == keyword)
leisure.purpose.2018.m <- melt(leisure.purpose.2018.1, id=c("통계분류1","통계분류2","연도"))
leisure.purpose.2018.m$value <- as.numeric(leisure.purpose.2018.m$value)
leisure.purpose.2018.m <- leisure.purpose.2018.m %>% arrange(desc(value))
leisure.purpose.2018.m <- leisure.purpose.2018.m[-1,]
leisure.purpose.2018.m

leisure.purpose.2019.1 <- leisure.purpose.2019 %>% filter(통계분류1 == keyword)
leisure.purpose.2019.m <- melt(leisure.purpose.2019.1, id=c("통계분류1","통계분류2","연도"))
leisure.purpose.2019.m$value <- as.numeric(leisure.purpose.2019.m$value)
leisure.purpose.2019.m <- leisure.purpose.2019.m %>% arrange(desc(value))
leisure.purpose.2019.m <- leisure.purpose.2019.m[-1,]
leisure.purpose.2019.m

leisure.purpose.2020.1 <- leisure.purpose.2020 %>% filter(통계분류1 == keyword)
leisure.purpose.2020.m <- melt(leisure.purpose.2020.1, id=c("통계분류1","통계분류2","연도"))
leisure.purpose.2020.m$value <- as.numeric(leisure.purpose.2020.m$value)
leisure.purpose.2020.m <- leisure.purpose.2020.m %>% arrange(desc(value))
leisure.purpose.2020.m <- leisure.purpose.2020.m[-1,]
leisure.purpose.2020.m

leisure.purpose.2021.1 <- leisure.purpose.2021 %>% filter(통계분류1 == keyword)
leisure.purpose.2021.m <- melt(leisure.purpose.2021.1, id=c("통계분류1","통계분류2","연도"))
leisure.purpose.2021.m$value <- as.numeric(leisure.purpose.2021.m$value)
leisure.purpose.2021.m <- leisure.purpose.2021.m %>% arrange(desc(value))
leisure.purpose.2021.m <- leisure.purpose.2021.m[-1,]
leisure.purpose.2021.m

leisure.purpose.m <- rbind(leisure.purpose.2016.m, leisure.purpose.2018.m,leisure.purpose.2019.m,leisure.purpose.2020.m,leisure.purpose.2021.m)
leisure.purpose.m

names(leisure.purpose.m) <- c("통계분류1","통계분류2","연도","목적","비율")

ggplot(leisure.purpose.m, aes(연도,비율, color = 목적)) + 
  geom_line(size = 1) +
  ggtitle("연도별 여가활동의 주된 목적") +
  xlab("목적") +
  ylab("비율") + 
  theme(plot.title = element_text(size = 18, hjust = 0.5, face = "bold"),
        axis.title.x = element_text(size = 15, face = "bold"),
        axis.title.y = element_text(size = 15, face = "bold"))

install.packages("tidyverse")
install.packages("tsibble")
install.packages("colorspace")
install.packages("gganimate")
library(tidyverse)
library(tsibble)
library(colorspace)
library(gganimate)

View(leisure.purpose.m)

dcast(leisure.purpose.m[-c(1:2)], 연도 ~ 목적)
write.csv(dcast(leisure.purpose.m[-c(1:2)], 연도 ~ 목적), "test.csv")

ggesm <- 
  ggplot(leisure.purpose.m, aes(연도,비율, color = 목적)) + 
  geom_line(linewidth = 1) +
  ggtitle("연도별 여가활동의 주된 목적") +
  xlab("목적") +
  ylab("비율") + 
  theme(plot.title = element_text(size = 18, hjust = 0.5, face = "bold"),
        axis.title.x = element_text(size = 15, face = "bold"),
        axis.title.y = element_text(size = 15, face = "bold"))

ggesm+
  transition_reveal(연도)

install.packages("magick")
library(magick)

# png 파일들을 리스트로 불러오기
png_files <- list.files(pattern = "gganim_plot.")

# png 파일들을 모아서 gif 파일로 만들기
image_read(png_files) %>% image_animate(fps = 10) %>% image_write("animation.gif")

keyword <- "연령별"

leisure.purpose.2016.1 <- leisure.purpose.2016 %>% filter(통계분류1 == keyword)
leisure.purpose.2016.m <- melt(leisure.purpose.2016.1, id=c("통계분류1","통계분류2","연도"))
leisure.purpose.2016.m$value <- as.numeric(leisure.purpose.2016.m$value)
leisure.purpose.2016.m <- leisure.purpose.2016.m %>% arrange(desc(value))
leisure.purpose.2016.m <- leisure.purpose.2016.m[-1,]
leisure.purpose.2016.m

leisure.purpose.2018.1 <- leisure.purpose.2018 %>% filter(통계분류1 == keyword)
leisure.purpose.2018.m <- melt(leisure.purpose.2018.1, id=c("통계분류1","통계분류2","연도"))
leisure.purpose.2018.m$value <- as.numeric(leisure.purpose.2018.m$value)
leisure.purpose.2018.m <- leisure.purpose.2018.m %>% arrange(desc(value))
leisure.purpose.2018.m <- leisure.purpose.2018.m[-1,]
leisure.purpose.2018.m

leisure.purpose.2019.1

leisure.purpose.2019.1 <- leisure.purpose.2019 %>% filter(통계분류1 == keyword)
leisure.purpose.2019.1$기타 <- ifelse(leisure.purpose.2019.1$기타 == "-", 0, leisure.purpose.2019.1$기타)
leisure.purpose.2019.m <- melt(leisure.purpose.2019.1, id=c("통계분류1","통계분류2","연도"))
leisure.purpose.2019.m$value <- as.numeric(leisure.purpose.2019.m$value)
leisure.purpose.2019.m <- leisure.purpose.2019.m %>% arrange(desc(value))
leisure.purpose.2019.m <- leisure.purpose.2019.m[-1,]
leisure.purpose.2019.m

leisure.purpose.2020.1 <- leisure.purpose.2020 %>% filter(통계분류1 == keyword)
leisure.purpose.2020.1$기타 <- ifelse(leisure.purpose.2020.1$기타 == "-", 0, leisure.purpose.2020.1$기타)
leisure.purpose.2020.m <- melt(leisure.purpose.2020.1, id=c("통계분류1","통계분류2","연도"))
leisure.purpose.2020.m$value <- as.numeric(leisure.purpose.2020.m$value)
leisure.purpose.2020.m <- leisure.purpose.2020.m %>% arrange(desc(value))
leisure.purpose.2020.m <- leisure.purpose.2020.m[-1,]
leisure.purpose.2020.m

leisure.purpose.2021.1 <- leisure.purpose.2021 %>% filter(통계분류1 == keyword)
leisure.purpose.2021.1$기타 <- ifelse(leisure.purpose.2021.1$기타 == "-", 0, leisure.purpose.2021.1$기타)
leisure.purpose.2021.m <- melt(leisure.purpose.2021.1, id=c("통계분류1","통계분류2","연도"))
leisure.purpose.2021.m$value <- as.numeric(leisure.purpose.2021.m$value)
leisure.purpose.2021.m <- leisure.purpose.2021.m %>% arrange(desc(value))
leisure.purpose.2021.m <- leisure.purpose.2021.m[-1,]
leisure.purpose.2021.m

leisure.purpose.m <- rbind(leisure.purpose.2016.m, leisure.purpose.2018.m,leisure.purpose.2019.m,leisure.purpose.2020.m,leisure.purpose.2021.m)
leisure.purpose.m

names(leisure.purpose.m) <- c("통계분류1","통계분류2","연도","목적","비율")
leisure.purpose.m

leisure.purpose.m.19 <- subset(leisure.purpose.m, subset = (통계분류2 == "15~19세"))
leisure.purpose.m.19 <- subset(leisure.purpose.m.19, subset = (목적 != "표본수"))
leisure.purpose.m.19

ggplot(leisure.purpose.m.19, aes(연도,비율, color = 목적)) + 
  geom_line(size = 1) +
  ggtitle("15-19세 여가활동의 주된 목적") +
  xlab("목적") +
  ylab("비율") + 
  theme(plot.title = element_text(size = 18, hjust = 0.5, face = "bold"),
        axis.title.x = element_text(size = 15, face = "bold"),
        axis.title.y = element_text(size = 15, face = "bold"))
