#### 라이브러리 관리 ####
library(ggplot2)
#install.packages("fmsb")
library(fmsb)
library(car)
library(leaps)

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
par(mfrow=c(2,2))
plot(fit)

shapiro.test(resid(fit)) #p-value = 0.599 정규분포다
summary(fit)
sqrt(vif(fit))
cor.test(fit)
