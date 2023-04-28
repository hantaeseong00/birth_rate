#### 라이브러리 정리 ####
library(reshape2)
library(dplyr)
#install.packages("data.table")
library(data.table)


file_path <- "현재_예술분야에서_종사하는_주_활동_20230425154808.csv"
yesul <- read.csv(file_path, na.strings = "-", header = T, encoding = "EUC-KR")

str(yesul)
yesul <- yesul[,-c(1,36)]

for (col in names(yesul)) {
  yesul[is.na(yesul[col]),col] <- 0
}
yesul <- yesul %>% filter(통계분류.2. != "모름/무응답")

yesul <- rename(yesul, 시군구별 = "통계분류.2.")
yesul <- rename(yesul, 연도 = "시점")

birth.rate <- read.csv(file = "./csv/birth_rate_sido_2014_2021.csv", header = T)

unique(birth.rate$시군구별)
unique(yesul$시군구별)

birth.rate <- birth.rate %>% 
  mutate(시군구별 = ifelse(시군구별 == "서울특별시", "서울", 시군구별))

su <- birth.rate %>% filter(시군구별 == "서울")

ik <- birth.rate %>% filter(시군구별 %in% c("인천광역시","경기도")) %>% group_by(연도) %>% summarise(합계출산율2 = sum(합계출산율))
ik[,"시군구별"] <- "인천/경기"

ks <- birth.rate %>% filter(시군구별 %in% c("경상북도","경상남도")) %>% group_by(연도) %>% summarise(합계출산율2 = sum(합계출산율))
ks[,"시군구별"] <- "경상권"

kc <- birth.rate %>% filter(시군구별 %in% c("강원도","충청북도","충청남도")) %>% group_by(연도) %>% summarise(합계출산율2 = sum(합계출산율))
kc[,"시군구별"] <- "강원/충청권"

kj <- birth.rate %>% filter(시군구별 %in% c("광주광역시","전라북도","전라남도")) %>% group_by(연도) %>% summarise(합계출산율2 = sum(합계출산율))
kj[,"시군구별"] <- "광주/전라권"



su <- su[,c("연도","합계출산율","시군구별")]
names(su) <- c("연도","합계출산율2","시군구별")


unique(yesul$연도)

new_sido_b <- rbind(su,ik,ks,kc,kj)
new_sido_b <- new_sido_b %>% filter(연도 %in% c("2015","2018","2021"))

merge_sido_b_y <- merge(yesul, new_sido_b, by=c("시군구별","연도"))

View(merge_sido_b_y)
names(merge_sido_b_y)


#### 음악 ####
full.model <- lm(합계출산율2 ~ 연주가.국악제외. 
                      + 가수
                      + 작곡가.및.편곡가.국악제외.
                      + 연주가.국악.
                      + 국악인.가창지휘비평등.
                      + 성악가
                      + 작곡.및.편곡가.국악.
                      + 지휘자
                      + 안무가 , data = merge_sido_b_y)
back.model <- step(full.model, direction = "backward", trace = 0)
back.model


fit.music <- lm(formula = 합계출산율2 ~ 가수 + 연주가.국악. + 안무가, data = merge_sido_b_y)

summary(fit.music)
#Multiple R-squared:  0.8607,	Adjusted R-squared:  0.8143
#가수         -0.14061    0.06923  -2.031 0.072797 .  
#연주가.국악.  0.24851    0.11534   2.155 0.059589 .  
#안무가       -1.10422    0.29913  -3.691 0.004987 ** 
shapiro.test(resid(fit.music))
#p-value = 0.4785
sqrt(vif(fit.music))


#### 그림 ####
full.model <- lm(합계출산율2 ~ 화가.및.조각가
                      + 만화가.웹툰작가포함.
                      + 애니메이터
                      + 성우
                      + 사진작가
                      + 공예가
                      + 디자이너, data = merge_sido_b_y)
back.model <- step(full.model, direction = "backward", trace = 0)
back.model

fit.paint <- lm(formula = 합계출산율2 ~ 만화가.웹툰작가포함. + 애니메이터 + 
            성우 + 디자이너, data = merge_sido_b_y)

summary(fit.paint)
#Multiple R-squared:  0.8321,	Adjusted R-squared:  0.7481 
#만화가.웹툰작가포함.   0.7768     0.2285   3.400 0.009364 ** 
#애니메이터             0.8248     0.5592   1.475 0.178417    
#성우                  -1.1141     0.2762  -4.033 0.003771 ** 
#디자이너              -0.7328     0.2332  -3.142 0.013761 *  
shapiro.test(resid(fit.paint))
#p-value = 0.3081
sqrt(vif(fit.paint))


#### 무대 ####
full.model <- lm(합계출산율2 ~ 배우
                      + 전통예능인
                      + 마술사
                      + 모델
                      + 희극인.개그맨.및.코미디언.
                      + 곡예사
                      + 무용가, data = merge_sido_b_y)
back.model <- step(full.model, direction = "backward", trace = 0)
back.model


fit.show <- lm(formula = 합계출산율2 ~ 배우 + 전통예능인 + 마술사 + 모델 + 
     희극인.개그맨.및.코미디언. + 곡예사 + 무용가, data = merge_sido_b_y)

summary(fit.show)
#Multiple R-squared:  0.8979,	Adjusted R-squared:  0.755 
#배우                        -0.4391     0.1436  -3.057  0.02818 * 
#전통예능인                  -3.3077     0.9099  -3.635  0.01498 * 
#마술사                      -5.8570     2.3081  -2.538  0.05205 . 
#모델                        -5.5002     2.4628  -2.233  0.07585 . 
#희극인.개그맨.및.코미디언.   2.9708     1.5379   1.932  0.11124   
#곡예사                      13.3017     5.8323   2.281  0.07148 . 
#무용가                       0.2341     0.1630   1.437  0.21033  
shapiro.test(resid(fit.show))
#p-value = 0.1734
sqrt(vif(fit.show))
#예능인, 곡예사, 배우는 2가 넘는다.


#### 기타 ####
full.model <- lm(합계출산율2 ~ 감독.및.연출가
                      + 공연.및.전시.기획자
                      + 건축가
                      + 문화.및.예술관련.관리자
                      + 기술지원스태프
                      + 기술감독
                      + 평론가, data = merge_sido_b_y)
back.model <- step(full.model, direction = "backward", trace = 0)
back.model


fit.etc <- lm(formula = 합계출산율2 ~ 공연.및.전시.기획자 + 문화.및.예술관련.관리자 + 
                기술지원스태프, data = merge_sido_b_y)

summary(fit.etc)
#Multiple R-squared:  0.8597,	Adjusted R-squared:  0.813 
#공연.및.전시.기획자      -0.4006     0.1403  -2.856 0.018895 *  
#문화.및.예술관련.관리자  -0.2102     0.1547  -1.358 0.207405    
#기술지원스태프           -1.5298     0.2385  -6.413 0.000123 ***
shapiro.test(resid(fit.etc))
#p-value = 0.3318
sqrt(vif(fit.etc))


full.model <- lm(formula = 합계출산율2 ~ 안무가 + 만화가.웹툰작가포함. + 
                   성우 + 디자이너 + 배우 + 전통예능인 + 공연.및.전시.기획자 + 기술지원스태프, data = merge_sido_b_y)
back.model <- step(full.model, direction = "backward", trace = 0)
back.model

fit.all <- lm(formula = 합계출산율2 ~ 안무가 + 만화가.웹툰작가포함. + 배우 + 
                공연.및.전시.기획자 + 기술지원스태프, data = merge_sido_b_y)
summary(fit.all)
#Multiple R-squared:  0.9306,	Adjusted R-squared:  0.7918 
#안무가               -0.84657    0.34876  -2.427   0.0456 *  
#만화가.웹툰작가포함.  0.28066    0.19810   1.417   0.1995    
#배우                 -0.07099    0.05796  -1.225   0.2602    
#공연.및.전시.기획자  -0.14016    0.11749  -1.193   0.2718    
#기술지원스태프       -0.79919    0.44441  -1.798   0.1152
shapiro.test(resid(fit.all))
#p-value = 0.6723
sqrt(vif(fit.all))
#기술지원스태프가 2가 넘는다.

fit.all <- lm(formula = 합계출산율2 ~ 안무가 + 만화가.웹툰작가포함. + 배우 + 
                공연.및.전시.기획자, data = merge_sido_b_y)
summary(fit.all)
#Multiple R-squared:  0.8916,	Adjusted R-squared:  0.8374
shapiro.test(resid(fit.all))
#p-value = 0.1379
sqrt(vif(fit.all))
#안무가               -1.34112    0.24260  -5.528 0.000555 ***
#만화가.웹툰작가포함.  0.22052    0.22085   0.999 0.347264    
#배우                 -0.14024    0.04899  -2.862 0.021074 *  
#공연.및.전시.기획자  -0.17908    0.13061  -1.371 0.207564   

