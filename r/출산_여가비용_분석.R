
merge.b.yi <- read.csv("./csv/merge_b_yi_sido_2014_2021.csv", header = T)

View(merge.b.yi)
merge.b.yi <- merge.b.yi[,-c(1:2)]
merge.b.yi <- na.omit(merge.b.yi)

reg.b.yi <- lm(합계출산율 ~ ., data = merge.b.yi)
result <- summary(reg.b.yi)
result
#Multiple R-squared:  0.719,	Adjusted R-squared:  0.6432 
shapiro.test(resid(reg.b.yi)) #p-value = 0.4151 정규분포다
sqrt(vif(reg.b.yi))

full.model <- lm(합계출산율 ~ . , data = merge.b.yi)
back.model <- step(full.model, direction = "backward", trace = 0)
back.model


fit <- lm(formula = 합계출산율 ~ 볼링장이용료 + 골프연습장이용료 + 당구장이용료 + 
                  노래방이용료 + 놀이시설이용료 + 문화강습료 + 여관숙박료 + 
                  찜질방이용료 + 뷰티미용료, data = merge.b.yi)

summary(fit)

#Multiple R-squared:  0.7073,	Adjusted R-squared:  0.682 
#볼링장이용료     -0.006776   0.004073  -1.664 0.099210 .  
#골프연습장이용료  0.013307   0.004467   2.979 0.003601 ** 
#당구장이용료      0.016563   0.004316   3.838 0.000213 ***
#노래방이용료     -0.009035   0.003878  -2.330 0.021759 *  
#놀이시설이용료   -0.030962   0.008148  -3.800 0.000244 ***
#문화강습료       -0.010315   0.003849  -2.680 0.008564 ** 
#여관숙박료        0.008234   0.003274   2.515 0.013437 *  
#찜질방이용료      0.013088   0.005512   2.374 0.019419 *  
#뷰티미용료        0.007813   0.004984   1.567 0.120041 