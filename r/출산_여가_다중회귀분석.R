#### 라이브러리 관리 ####
library(ggplot2)
#install.packages("fmsb")
library(fmsb)
library(car)
library(leaps)
library(moonBook)
library(nparcomp)
library(pgirmess)

#### 함수 관리 ####
create_beautiful_radarchart <- function(data, color = "#00AFBB", 
                                        vlabels = colnames(data), vlcex = 0.7,
                                        caxislabels = NULL, title = NULL, ...){
  radarchart(
    data, axistype = 1,
    # Customize the polygon
    pcol = color, pfcol = scales::alpha(color, 0.5), plwd = 2, plty = 1,
    # Customize the grid
    cglcol = "grey", cglty = 1, cglwd = 0.8,
    # Customize the axis
    axislabcol = "grey", 
    # Variable labels
    vlcex = vlcex, vlabels = vlabels,
    caxislabels = caxislabels, title = title, ...
  )
}

#### 회귀분석 ####

merge.b.l <- read.csv("./csv/merge_b_l_sido_2014_2021.csv", header = T)
View(merge.b.l)
str(merge.b.l)
merge.b.l <- merge.b.l[,-c(1:2)]
merge.b.l

reg.b.l <- lm(합계출산율 ~ ., data = merge.b.l)
summary(reg.b.l)
#Multiple R-squared:  0.3556,	Adjusted R-squared:  0.3002 
result <- summary(reg.b.l)
result
#2016~
#Multiple R-squared:  0.4048,	Adjusted R-squared:  0.3421 
#(Intercept)       1.3190177  0.0454059  29.050   <2e-16 ***
#문화예술관람활동 -0.0004141  0.0049009  -0.084   0.9329    
#문화예술참여활동  0.0391750  0.0160128   2.446   0.0167 *  
#스포츠관람활동    0.0003597  0.0052540   0.068   0.9456    
#스포츠참여활동   -0.0033473  0.0038041  -0.880   0.3817    
#관광활동         -0.0065658  0.0044257  -1.484   0.1421    
#취미오락활동     -0.0042080  0.0042244  -0.996   0.3223    
#휴식활동          0.0012914  0.0039136   0.330   0.7423    
#사회및.기타활동  -0.0012264  0.0028242  -0.434   0.6653 

#2014~
#Multiple R-squared:  0.3556,	Adjusted R-squared:  0.3002
#(Intercept)       1.3162761  0.0487754  26.986  < 2e-16 ***
#문화예술관람활동  0.0102535  0.0033433   3.067  0.00283 ** 
#문화예술참여활동  0.0226356  0.0142399   1.590  0.11532    
#스포츠관람활동   -0.0047481  0.0051603  -0.920  0.35989    
#스포츠참여활동   -0.0008443  0.0036889  -0.229  0.81946    
#관광활동         -0.0092831  0.0043196  -2.149  0.03423 *  
#취미오락활동     -0.0121310  0.0038721  -3.133  0.00231 ** 
#휴식활동          0.0074419  0.0035363   2.104  0.03804 *  
#사회및.기타활동   0.0006127  0.0026820   0.228  0.81980 

result <- result[["coefficients"]][-1,c(1,4)]
result <- cbind(result, "1-pvalue" = 1 - result[, 2])
result <- t(result[,3])
pvalue <- result[1,]


result <- rbind(result, "Max" = 1.0)
result <- rbind(result, "Min" = 0.0)
result <- rbind(result, pvalue)
result <- result[-1,]
result <- data.frame(result)
radarchart(result)

result

#방사형 그래프 그리기
op <- par(mar = c(1, 2, 2, 1))
create_beautiful_radarchart(result, caxislabels = c(0.2, 0.4, 0.6, 0.8, 1.0))
par(op)


#Residuals VS Fitted    > 선형성 확인   > 0을 중심으로 평행하게 혹은 무작위하게 모여있어야 함.
#Scale-Location         > 등분산성 확인 > 
#Normal Q-Q             > 정규분포 확인 > 선으로부터 가깝게 점들이 모여있어야 함.
#Residuals VS Leverage  > 이상치 확인   > 다중회귀 때 의미가 있음.


full.model <- lm(합계출산율 ~ ., data = merge.b.l)
back.model <- step(full.model, direction = "backward", trace = 0)
back.model


fit <- lm(formula = 합계출산율 ~ 문화예술관람활동 + 문화예술참여활동 + 
            관광활동 + 취미오락활동 + 휴식활동, data = merge.b.l)
summary(fit)
#Multiple R-squared:  0.3491,	Adjusted R-squared:  0.3152 

#(Intercept)       1.316061   0.048202  27.303  < 2e-16 ***
#문화예술관람활동  0.009366   0.002887   3.244 0.001620 ** 
#화예술참여활동  0.021582   0.013136   1.643 0.103663    
#관광활동         -0.009843   0.004139  -2.378 0.019390 *  
#취미오락활동     -0.013210   0.003463  -3.815 0.000241 ***
#휴식활동          0.008276   0.003035   2.726 0.007612 ** 

par(mfrow=c(2,2))
plot(fit)

shapiro.test(resid(fit)) #p-value = 0.599 정규분포다

sqrt(vif(fit))

fit1 <- lm(formula = 합계출산율 ~ 문화예술관람활동 + 문화예술참여활동 + 
            관광활동 + 취미오락활동, data = merge.b.l)
summary(fit1)
#Multiple R-squared:  0.2987,	Adjusted R-squared:  0.2698 
shapiro.test(resid(fit1)) #p-value = 0.09085 정규분포다
sqrt(vif(fit1))

fit2 <- lm(formula = 합계출산율 ~ 문화예술관람활동 + 문화예술참여활동 + 
             관광활동 + 휴식활동, data = merge.b.l)
summary(fit2)
#Multiple R-squared:  0.2504,	Adjusted R-squared:  0.2195 
shapiro.test(resid(fit2)) #p-value = 0.1451 정규분포다
sqrt(vif(fit2))



#### 기혼 미혼 차이가 있을까? ####

leisure <- read.csv("지난_1년_동안_가장_많이_참여한_여가활동__12345순위__중분류_20230421124000.csv", na.strings = "-", header = T)
leisure[is.na(leisure)] <- 0
leisure <- subset(leisure, subset = (leisure[,"통계분류.1."] == "혼인상태별"))

View(leisure[,c("통계분류.2.",
                "문화예술관람활동",
                "문화예술참여활동",
                "관광활동",
                "취미오락활동",
                "휴식활동")])

### 문화예술관람활동
moonBook::densityplot(문화예술관람활동 ~ 통계분류.2., leisure)

out <- aov(문화예술관람활동 ~ 통계분류.2., leisure)
shapiro.test(resid(out)) #p-value:0.3606(36%) > 정규분포가 맞다.

bartlett.test(문화예술관람활동 ~ 통계분류.2., leisure) #p-value:0.00(00%) > 등분산이 아니다.

oneway.test(문화예술관람활동 ~ 통계분류.2., leisure, var.equal = F) #p-value:0.002(00%) > 차이가 있다.

result <- mctp(문화예술관람활동 ~ 통계분류.2., leisure)
summary(result)
# (2-1)미혼-기혼            > Analysis > p.Value > 0.00 > 차이가 있다.
# (3-1)기타-기혼            > Analysis > p.Value > 0.00 > 차이가 있다.
# (3-2)기타-미혼            > Analysis > p.Value > 0.00 > 차이가 있다.



### 문화예술참여활동
moonBook::densityplot(문화예술참여활동 ~ 통계분류.2., leisure)

out <- aov(문화예술참여활동 ~ 통계분류.2., leisure)
shapiro.test(resid(out)) #p-value:0.9306(93%) > 정규분포가 맞다.

bartlett.test(문화예술참여활동 ~ 통계분류.2., leisure) #p-value:0.14(14%) > 등분산이 아니다.

summary(out) # Pr(>F) : 0.726(72%) > 차이가 없다.

TukeyHSD(out)
# (2-1)미혼-기혼            > Analysis > p.Value > 0.88 > 차이가 없다
# (3-1)기타-기혼            > Analysis > p.Value > 0.70 > 차이가 없다
# (3-2)기타-미혼            > Analysis > p.Value > 0.93 > 차이가 없다



### 관광활동
moonBook::densityplot(관광활동 ~ 통계분류.2., leisure)

out <- aov(관광활동 ~ 통계분류.2., leisure)
shapiro.test(resid(out)) #p-value:0.3931(39%) > 정규분포가 맞다.

bartlett.test(관광활동 ~ 통계분류.2., leisure) #p-value:0.00(00%) > 등분산이 아니다.

oneway.test(관광활동 ~ 통계분류.2., leisure, var.equal = F) #p-value:0.00(00%) > 차이가 있다.

result <- mctp(관광활동 ~ 통계분류.2., leisure)
summary(result)
# (2-1)미혼-기혼            > Analysis > p.Value > 0.00 > 차이가 없다
# (3-1)기타-기혼            > Analysis > p.Value > 0.00 > 차이가 있다
# (3-2)기타-미혼            > Analysis > p.Value > 0.63 > 차이가 없다



### 취미오락활동
moonBook::densityplot(취미오락활동 ~ 통계분류.2., leisure)

out <- aov(취미오락활동 ~ 통계분류.2., leisure)
shapiro.test(resid(out)) #p-value:0.03(3%) > 정규분포가 아니다

kruskal.test(취미오락활동 ~ 통계분류.2., leisure) #p-value:0.00(00%) > 차이가 있다.

kruskalmc(취미오락활동 ~ 통계분류.2., leisure)
# (2-1)미혼-기혼            > stat.signif > FALSE > 차이가 없다
# (3-1)기타-기혼            > stat.signif > FALSE > 차이가 없다
# (3-2)기타-미혼            > stat.signif > TRUE > 차이가 있다



### 휴식활동
moonBook::densityplot(휴식활동 ~ 통계분류.2., leisure)

out <- aov(휴식활동 ~ 통계분류.2., leisure)
shapiro.test(resid(out)) #p-value:0.06(6%) > 정규분포가 맞다.

bartlett.test(휴식활동 ~ 통계분류.2., leisure) #p-value:0.00(00%) > 등분산이 아니다.

oneway.test(휴식활동 ~ 통계분류.2., leisure, var.equal = F) #p-value:0.00(00%) > 차이가 있다.

result <- mctp(휴식활동 ~ 통계분류.2., leisure)
summary(result)
# (2-1)미혼-기혼            > Analysis > p.Value > 0.00 > 차이가 없다
# (3-1)기타-기혼            > Analysis > p.Value > 0.00 > 차이가 있다
# (3-2)기타-미혼            > Analysis > p.Value > 0.63 > 차이가 없다




#### 세부적으로 확인 ####

### 1. 문화관람
merge.b.l <- read.csv("./csv/merge_b_l_1_sido_2016_2021.csv", header = T)
View(merge.b.l)
str(merge.b.l)
merge.b.l <- merge.b.l[,-c(1,2)]
merge.b.l[is.na(merge.b.l)] <- 0

reg.b.l <- lm(합계출산율 ~ ., data = merge.b.l)
result <- summary(reg.b.l)
result
#Multiple R-squared:  0.3625,	Adjusted R-squared:  0.2954 

full.model <- lm(합계출산율 ~ ., data = merge.b.l)
back.model <- step(full.model, direction = "backward", trace = 0)
back.model

fit1 <- lm(formula = 합계출산율 ~ 전시회관람 + 박물관.관람 + 연극공연.관람 + 
             음악연주회.관람 + 무용공연.관람, data = merge.b.l)
summary(fit1)
#Multiple R-squared:  0.3552,	Adjusted R-squared:  0.3144
#전시회관람      -0.038854   0.010466  -3.712 0.000381 ***
#박물관.관람      0.032463   0.007292   4.452 2.76e-05 ***
#연극공연.관람   -0.015477   0.005266  -2.939 0.004316 ** 
#음악연주회.관람  0.018660   0.011465   1.628 0.107578    
#무용공연.관람    0.082160   0.024704   3.326 0.001339 ** 

shapiro.test(resid(fit1)) #p-value = 0.06 정규분포가 맞다.
sqrt(vif(fit1))



### 2. 문화참여
merge.b.l <- read.csv("./csv/merge_b_l_2_sido_2016_2021.csv", header = T)
View(merge.b.l)
str(merge.b.l)
merge.b.l <- merge.b.l[,-c(1,2)]
merge.b.l[is.na(merge.b.l)] <- 0

reg.b.l <- lm(합계출산율 ~ ., data = merge.b.l)
result <- summary(reg.b.l)
result
#Multiple R-squared:  0.2177,	Adjusted R-squared:  0.1466 

full.model <- lm(합계출산율 ~ ., data = merge.b.l)
back.model <- step(full.model, direction = "backward", trace = 0)
back.model

fit2 <- lm(formula = 합계출산율 ~ 사진촬영 + 악기연주.노래교실 + 춤.무용, 
           data = merge.b.l)
summary(fit2)
#Multiple R-squared:  0.1883,	Adjusted R-squared:  0.1583 

shapiro.test(resid(fit2)) #p-value = 0.02 정규분포가 아니다.

fit2 <- lm(formula = log(합계출산율) ~ 사진촬영 + 악기연주.노래교실 + 춤.무용, 
           data = merge.b.l)
shapiro.test(resid(fit2)) #p-value = 0.90 정규분포가 아니다.
summary(fit2)
#Multiple R-squared:  0.1869,	Adjusted R-squared:  0.1568 
#사진촬영          -0.002659   0.001731  -1.536   0.1285    
#악기연주.노래교실  0.040712   0.009655   4.217 6.41e-05 ***
#춤.무용           -0.065701   0.025225  -2.605   0.0109 * 
sqrt(vif(fit2))


### 3. 관광활동
merge.b.l <- read.csv("./csv/merge_b_l_3_sido_2016_2021.csv", header = T)
View(merge.b.l)
str(merge.b.l)
merge.b.l <- merge.b.l[,-c(1,2)]
merge.b.l[is.na(merge.b.l)] <- 0

reg.b.l <- lm(합계출산율 ~ ., data = merge.b.l)
result <- summary(reg.b.l)
result
#Multiple R-squared:  0.3502,	Adjusted R-squared:  0.2523

full.model <- lm(합계출산율 ~ ., data = merge.b.l)
back.model <- step(full.model, direction = "backward", trace = 0)
back.model

fit3 <- lm(formula = 합계출산율 ~ 자연명승 + 테마파크가기 + 지역축제참가 + 
             해외여행, data = merge.b.l)
summary(fit3)
#Multiple R-squared:  0.3003,	Adjusted R-squared:  0.2653 
#자연명승     -0.004994   0.001691  -2.954  0.00412 ** 
#테마파크가기  0.008464   0.003421   2.474  0.01548 *  
#지역축제참가  0.004854   0.001545   3.141  0.00236 ** 
#해외여행     -0.007821   0.003904  -2.003  0.04852 * 

shapiro.test(resid(fit3)) #p-value = 0.01 정규분포가 아니다.

fit3 <- lm(formula = log(합계출산율) ~ 자연명승 + 테마파크가기 + 지역축제참가 + 
             해외여행, data = merge.b.l)
summary(fit3)
#Multiple R-squared:  0.3017,	Adjusted R-squared:  0.2668 
#자연명승     -0.004363   0.001576  -2.769 0.006989 ** 
#테마파크가기  0.006203   0.003188   1.946 0.055202 .  
#지역축제참가  0.005256   0.001440   3.649 0.000467 ***
#해외여행     -0.007016   0.003638  -1.929 0.057329 . 

shapiro.test(resid(fit3)) #p-value = 0.37 정규분포가 맞다.
sqrt(vif(fit3))


### 4. 취미오락
merge.b.l <- read.csv("./csv/merge_b_l_4_sido_2016_2021.csv", header = T)
View(merge.b.l)
str(merge.b.l)
merge.b.l <- merge.b.l[,-c(1,2)]
merge.b.l[is.na(merge.b.l)] <- 0

reg.b.l <- lm(합계출산율 ~ ., data = merge.b.l)
result <- summary(reg.b.l)
result
#Multiple R-squared:  0.5026,	Adjusted R-squared:  0.3261 

full.model <- lm(합계출산율 ~ ., data = merge.b.l)
back.model <- step(full.model, direction = "backward", trace = 0)
back.model

fit4 <- lm(formula = 합계출산율 ~ 쇼핑.외식 + 미용 + 게임 + 등산 + 독서 + 
             요리하기 + 만화보기 + 노래방가기 + 보드게임.퍼즐.큐브.맞추기 + 
             겜블 + 바둑.장기 + 수집활동, data = merge.b.l)
summary(fit4)
#Multiple R-squared:  0.4805,	Adjusted R-squared:  0.3939 
#쇼핑.외식                  0.007388   0.003583   2.062  0.04279 *  
#미용                      -0.005648   0.001666  -3.389  0.00114 ** 
#게임                      -0.005300   0.003529  -1.502  0.13746    
#등산                      -0.010311   0.004630  -2.227  0.02906 *  
#독서                       0.005537   0.003790   1.461  0.14832    
#요리하기                  -0.008458   0.003362  -2.516  0.01410 *  
#만화보기                  -0.016329   0.003225  -5.063 3.06e-06 ***
#노래방가기                 0.007708   0.002384   3.233  0.00185 ** 
#보드게임.퍼즐.큐브.맞추기  0.014816   0.008784   1.687  0.09601 .  
#겜블                       0.005848   0.003343   1.749  0.08452 .  
#바둑.장기                 -0.035354   0.013085  -2.702  0.00860 ** 
#수집활동                   0.028379   0.016216   1.750  0.08437 . 

shapiro.test(resid(fit4)) #p-value = 0.12 정규분포다.
sqrt(vif(fit4))

### 5. 휴식활동
merge.b.l <- read.csv("./csv/merge_b_l_5_sido_2016_2021.csv", header = T)
View(merge.b.l)
str(merge.b.l)
merge.b.l <- merge.b.l[,-c(1,2)]
merge.b.l[is.na(merge.b.l)] <- 0

reg.b.l <- lm(합계출산율 ~ ., data = merge.b.l)
result <- summary(reg.b.l)
result
#Multiple R-squared:  0.4233,	Adjusted R-squared:  0.3453 
#TV시청                0.0135976  0.0087035   1.562  0.12248   
#산책.및.걷기         -0.0102260  0.0033573  -3.046  0.00321 **
#모바일.컨텐츠.시청   -0.0031868  0.0016562  -1.924  0.05818 . 
#낮잠                  0.0030496  0.0025242   1.208  0.23084   
#음악감상             -0.0002305  0.0029519  -0.078  0.93798   
#목욕.사우나           0.0003910  0.0017333   0.226  0.82216   
#아무것도.안.하기      0.0014199  0.0017756   0.800  0.42648   
#라디오.팟캐스트.청취  0.0051032  0.0029290   1.742  0.08561 . 
#신문.잡지.보기       -0.0039376  0.0037955  -1.037  0.30291   
#비디오.DVD.시청      -0.0011744  0.0046268  -0.254  0.80034

full.model <- lm(합계출산율 ~ ., data = merge.b.l)
back.model <- step(full.model, direction = "backward", trace = 0)
back.model

fit5 <- lm(formula = 합계출산율 ~ TV시청 + 산책.및.걷기 + 모바일.컨텐츠.시청 + 
             낮잠 + 라디오.팟캐스트.청취, data = merge.b.l)
summary(fit5)
#Multiple R-squared:  0.4079,	Adjusted R-squared:  0.3704 
#TV시청                0.0158480  0.0081308   1.949  0.05483 . 
#산책.및.걷기         -0.0099808  0.0031592  -3.159  0.00224 **
#모바일.컨텐츠.시청   -0.0023064  0.0009198  -2.507  0.01421 * 
#낮잠                  0.0031100  0.0020927   1.486  0.14122   
#라디오.팟캐스트.청취  0.0039747  0.0025662   1.549  0.12541  
shapiro.test(resid(fit5)) #p-value = 0.00 정규분포가 아니다.
sqrt(vif(fit5))

summary(powerTransform(merge.b.l$합계출산율))
#merge.b.l$합계출산율   -0.1865
fit5 <- lm(formula = 합계출산율^-1.1865 ~ TV시청 + 산책.및.걷기 + 모바일.컨텐츠.시청 + 
             낮잠 + 라디오.팟캐스트.청취, data = merge.b.l)
summary(fit5)
#Multiple R-squared:  0.4262,	Adjusted R-squared:  0.3899 
#TV시청               -0.021027   0.008841  -2.378 0.019807 *  
#산책.및.걷기          0.011844   0.003435   3.448 0.000908 ***
#모바일.컨텐츠.시청    0.002298   0.001000   2.298 0.024236 *  
#낮잠                 -0.004453   0.002275  -1.957 0.053891 .  
#라디오.팟캐스트.청취 -0.003408   0.002790  -1.221 0.225574   
shapiro.test(resid(fit5)) #p-value = 0.20 정규분포가 맞다.
sqrt(vif(fit5))

fit5 <- lm(formula = log(합계출산율) ~ TV시청 + 산책.및.걷기 + 모바일.컨텐츠.시청 +
             낮잠 + 라디오.팟캐스트.청취, data = merge.b.l)

summary(fit5)
#Multiple R-squared:  0.4266,	Adjusted R-squared:  0.3903 
#TV시청                0.0161653  0.0074642   2.166   0.0333 * 
#산책.및.걷기         -0.0097433  0.0029002  -3.360   0.0012 **
#모바일.컨텐츠.시청   -0.0020924  0.0008444  -2.478   0.0153 * 
#낮잠                  0.0033387  0.0019211   1.738   0.0861 . 
#라디오.팟캐스트.청취  0.0033330  0.0023558   1.415   0.1610   

shapiro.test(resid(fit5)) #p-value = 0.36 정규분포가 맞다.
sqrt(vif(fit5))

AIC(reg.b.l, fit5)
#reg.b.l 12 -41.79037
#fit5     7 -64.09393
#fit5가 더 좋은 모델