promise <- read.csv("C:\\PythonWork\\PycharmWork\\ProjectTeam1\\data\\csv\\promise_kr.csv", header = T, encoding = "euckr")
str(promise)
unique(promise$sgId)

nums <- 1:10
cols.T <- paste0("prmsTitle", nums)
cols.C <- paste0("prmmCont", nums)
cols.R <- paste0("prmsRealmName", nums)

cols <- c(cols.T,cols.C,cols.R)

library(tidyr)
library(stringr)
library(dplyr)
promise_new <- promise %>% 
  unite(col = "prmsAll", cols, sep = " ") %>% 
  mutate(prmsAll = str_trim(prmsAll), 
         isTopic = ifelse(grepl("출산", prmsAll), 1, 0)) %>%
  filter(dugsu > 0 & prmsAll != "")

promise_new <- promise_new[complete.cases(promise_new), ]

View(promise_new)

### 주제1. 공약으로 출산을 언급한 정치인의 당선율이 높을까?
# 종속변수 : 당선율(dugyul)
# 독립변수 : 출산언급유무(isTopic)

library(ggplot2)

## 선거 당선자들의 공약에서 출산 관련 내용이 포함되었는지 여부 파악
isTopic <- table(promise_new["isTopic"])
isTopic <- data.frame(isTopic)
isTopic

ggplot(isTopic, aes(x = isTopic, y = Freq, fill=isTopic)) +
  geom_col() +
  ggtitle("선거 당선자들의 공약에서 출산 관련 내용이 포함되었는지 여부 파악") +
  xlab("출산 관련 내용 포함 유무") +
  ylab("당선자 수") + 
  scale_x_discrete(labels = c("미포함", "포함")) +
  theme(plot.title = element_text(size = 18, hjust = 0.5, face = "bold"),
        axis.title.x = element_text(size = 15, face = "bold"),
        axis.title.y = element_text(size = 15, face = "bold"),
        legend.position = "none") + 
  geom_text(aes(label = Freq), vjust = -0.5, size = 5)

ggsave("선거 당선자들의 공약에서 출산 관련 내용이 포함되었는지 여부 파악.png", width = 10, height = 8, dpi = 300)


## 선거 당선자들의 공약에서 출산 관련 내용이 포함되었는지 여부에 따라 당선율의 평균 파악
dugmean <- promise_new %>% group_by(isTopic) %>% summarise(dugmean = mean(dugyul))
View(dugmean)
dugmean$isTopic <- as.integer(dugmean$isTopic)
str(dugmean)

dugmean$isTopic.str <- ifelse(dugmean$isTopic == 1, "포함", "미포함")

ggplot(dugmean, aes(x = isTopic.str, y = dugmean, fill=isTopic.str)) +
  geom_col() +
  ggtitle("선거 당선자들의 공약에서 출산 관련 내용이 포함되었는지 여부에 따라 당선율의 평균") +
  xlab("출산 관련 내용 포함 유무") +
  ylab("당선자 평균") + 
  theme(plot.title = element_text(size = 17, hjust = 0.5, face = "bold"),
        axis.title.x = element_text(size = 15, face = "bold"),
        axis.title.y = element_text(size = 15, face = "bold"),
        legend.position = "none") + 
  geom_text(aes(label = dugmean), vjust = -0.5, size = 5)

ggsave("선거 당선자들의 공약에서 출산 관련 내용이 포함되었는지 여부에 따라 당선율의 평균.png", width = 10, height = 8, dpi = 300)

moonBook::densityplot(dugyul~isTopic, data=promise_new)

# 정규분포 여부 파악
with(promise_new, shapiro.test(dugyul[isTopic == 0])) #p-value:0.00(0%) > 정규분포가 아니다.
with(promise_new, shapiro.test(dugyul[isTopic == 1])) #p-value:0.01(1%) > 정규분포가 아니다.

# 정규분포가 아니기 때문에,
wilcox.test(dugyul ~ isTopic,
            data = promise_new, 
            alt = "two.sided")
#p-value = 0.8271 > 귀무가설 채택 > 차이가 없다.
#즉 공약에서 출산을 언급 하는 것과 당선율은 차이가 없다.

# 만약 정규분포라고 가정했을 때, 등분산 파악
var.test(dugyul ~ isTopic,
         data = promise_new) #p-value:0.1488 > 등분산이 맞다.

t.test(dugyul ~ isTopic,
       data = promise_new,
       alt = "two.sided",
       var.equal = T) 
#p-value:0.8467 > 귀무가설 채택 > 차이가 없다.

#### ======================================================================================= ####
install.packages("reshape")
library(reshape2)

promise_new <- promise_new %>% filter(!(sgId %in% c("20220309","20220601")))
sdRate <- table(promise_new$sdName,promise_new$isTopic)
sdRate <- as.data.frame(sdRate)
sdRate.0 <- subset(sdRate, subset = (Var2 == 0))
sdRate.1 <- subset(sdRate, subset = (Var2 == 1))
sdRate.0
sdRate.1

sdRate <- merge(sdRate.0, sdRate.1, by = "Var1")
sdRate$rate <- sdRate[, "Freq.y"] / sdRate[, "Freq.x"]

sdRate <- na.omit(sdRate)
sdRate <- sdRate %>% filter(Var1 != "전국") %>% select(Var1, Freq.x, Freq.y, rate) %>% arrange(desc(rate))

sdRate <- dcast(sdRate, Var1 ~ Var2, value.var = Freq)
colnames(sdRate) <- c("시도별","출산미포함_당선인","출산포함_당선인","비율")
sdRate

birth_rate <- read.csv("시도_합계출산율__모의_연령별_출산율_20230418154653.csv", header = T, encoding = "euc-kr")
birth_rate <- birth_rate[-c(1:2),]
birth_rate$X2017 <- as.numeric(birth_rate$X2017)
birth_rate$X2018 <- as.numeric(birth_rate$X2018)
birth_rate$X2019 <- as.numeric(birth_rate$X2019)
birth_rate$X2020 <- as.numeric(birth_rate$X2020)
birth_rate$X2021 <- as.numeric(birth_rate$X2021)
str(birth_rate)
birth_rate$X.sum <- apply(birth_rate[,-1], 1, median)
#birth_rate$X.sum <- median(birth_rate[,-1])
birth_rate

mydata <- merge(sdRate, birth_rate, by = "시도별")
mydata <- mydata %>% filter(시도별 != "대전광역시") %>% arrange(비율)
mydata

library(ggplot2)

plot(비율 ~ X.sum, data = mydata)

?lm
fit <- lm(비율 ~ X.sum, data = mydata)
fit
x = mydata$비율
y = mydata$X.sum
cor(x, y)

abline(fit, col="blue")

summary(fit)





#### 추가 테스트 ####
### 만약 성별로 해본다면?
moonBook::densityplot(dugyul~gender, data=promise_new)
# 정규분포 여부 파악
with(promise_new, shapiro.test(dugyul[gender == "남"])) #p-value:0.00(0%) > 정규분포가 아니다.
with(promise_new, shapiro.test(dugyul[gender == "여"])) #p-value:0.39(39%) > 정규분포다.

wilcox.test(dugyul ~ gender,
            data = promise_new, 
            alt = "two.sided")
# p-value = 0.4771 > 차이가 없다.


### 만약 정당으로 해본다면?
table(promise_new$jdName)
out <- aov(dugyul ~ jdName, promise_new)
shapiro.test(resid(out)) #p-value:0.00(0%) > 정규분포가 아니다.
kruskal.test(dugyul ~ jdName, promise_new)
# p-value = 0.002103 > 차이가 있다.
library(pgirmess)
kruskalmc(promise_new$dugyul, promise_new$jdName)
#국민의힘-무소속         55.510449     39.73855        TRUE

result <- table(promise_new$jdName, promise_new$isTopic)
result

chisq.test(result)
fisher.test(result)
# p-value = 0.7113 > 정당별 출산 언급은 관계가 없다.

dif.com <- kruskalmc(promise_new$dugyul, promise_new$jdName)[3]$dif.com
kruskalmc(promise_new$dugyul, promise_new$jdName)[3]$dif.com %>% filter(stat.signif == TRUE)


### 만약 지역으로 해본다면?
table(promise_new$sdName)
out <- aov(dugyul ~ sdName, promise_new)
par(mfrow=c(2,2))
plot(out)
par()
shapiro.test(resid(out)) #p-value:0.00(0%) > 정규분포가 아니다.
kruskal.test(dugyul ~ sdName, promise_new)
# p-value = 3.429e-08 > 차이가 있다.

dif.com <- kruskalmc(promise_new$dugyul, promise_new$sdName)[3]$dif.com
kruskalmc(promise_new$dugyul, promise_new$sdName)[3]$dif.com %>% filter(stat.signif == TRUE)
#강원도-경상북도        85.88000     78.37961        TRUE
#강원도-대구광역시     143.50000    110.69800        TRUE
#경기도-경상북도        81.41030     71.09229        TRUE
#경기도-대구광역시     139.03030    105.66361        TRUE
#경기도-부산광역시      78.75253     78.56468        TRUE
#대구광역시-대전광역시 152.50000    138.76729        TRUE
#대구광역시-서울특별시 130.75926    107.93012        TRUE
#대구광역시-인천광역시 154.90000    127.18232        TRUE
#대구광역시-전라북도   116.55882    114.95717        TRUE
#대구광역시-충청남도   119.44444    113.93074        TRUE
dif.com[grep("대구광역시", rownames(dif.com)), ]

result <- table(promise_new$isTopic,promise_new$sdName)
result

chisq.test(result)
fisher.test(result,simulate.p.value = TRUE)
# p-value = 0.7113 > 정당별 출산 언급은 관계가 없다.


x = with(promise_new, cbind(sgTypecode, isTopic))
cor(x)

plot(promise_new$sgTypecode, promise_new$isTopic)
