#### 라이브러리 관리 ####
library(ggplot2)
#install.packages("fmsb")
library(fmsb)
library(car)
library(leaps)
library(moonBook)
library(nparcomp)
library(pgirmess)
library(ggpmisc)

merge.b.a <- read.csv("./csv/merge_b_a_gu_2014_2021.csv", header = T)
merge.b.a

cor.test(merge.b.a$합계출산율, merge.b.a$유)
#cor -0.07866499

x = merge.b.a$유
y = merge.b.a$합계출산율
# 회귀분석 실행
fit <- lm(y ~ x)

fit

# 산점도와 회귀선, 회귀식 함께 그리기
ggplot(data = data.frame(x, y), aes(x = x, y = y)) +
  geom_point() +
  geom_smooth(method = "lm", se = FALSE, color = "red") +
  stat_poly_eq(formula = y ~ x, aes(label = paste(..eq.label.., ..rr.label.., sep = "~~~~")), 
               parse = TRUE, label.x.npc = 0.9, label.y.npc = 0.1, 
               formula.y = list(label = list(parse = TRUE)))


merge.b.ai <- read.csv("./csv/merge_b_ai_sido_2014_2021.csv", header = T)

View(merge.b.ai)
merge.b.ai <- merge.b.ai[,-c(1:2)]


reg.b.ai <- lm(합계출산율 ~ ., data = merge.b.ai)
result <- summary(reg.b.ai)
result
#Multiple R-squared:  0.3667,	Adjusted R-squared:  0.3567
shapiro.test(resid(reg.b.ai)) #p-value = 0.2551 정규분포다
sqrt(vif(reg.b.ai))


x = reg.b.ai$반려동물용품비
y = reg.b.ai$합계출산율
# 회귀분석 실행
fit <- lm(y ~ x)

fit <- lm(합계출산율 ~ 반려동물용품비, data = merge.b.ai)

fit

cor.test(merge.b.ai$반려동물용품비, merge.b.ai$합계출산율)
#-0.2740825 

cor.test(merge.b.ai$반려동물관리비, merge.b.ai$합계출산율)
#-0.5619343 

# 산점도와 회귀선, 회귀식 함께 그리기
par(mfrow = c(2,2))

p1 <- ggplot(data = merge.b.ai, aes(x = 반려동물용품비, y = 합계출산율)) +
  geom_point() + geom_smooth(method="lm") 

p2 <- ggplot(data = merge.b.ai, aes(x = 반려동물관리비, y = 합계출산율)) +
  geom_point() + geom_smooth(method="lm") 


# 두 차트를 결합하여 하나의 출력으로 생성
grid.arrange(p1, p2, ncol = 2)
