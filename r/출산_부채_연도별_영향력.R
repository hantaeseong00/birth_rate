#### 라이브러리 정리 ####

library(dplyr)
library(ggplot2)

#### 함수 정리 ####

rename_location <- function(df) {
  city.names <- read.table("C:\\RWork\\StatProject/csv/city_names.txt", stringsAsFactors = FALSE)[,2]
  
  for (city in unique(df$시도별)) {
    for (newcity in city.names) {
      idx <- grep(city, newcity)
      if (length(idx) > 0) {
        idx <- which(df$시도별 == city)
        df$시도별[idx] <- newcity
      }
      if (city == "전북"){
        idx <- which(df$시도별 == city)
        df$시도별[idx] <- "전라북도"
      }
      if (city == "전남"){
        idx <- which(df$시도별 == city)
        df$시도별[idx] <- "전라남도"
      }
      if (city == "충북"){
        idx <- which(df$시도별 == city)
        df$시도별[idx] <- "충청북도"
      }
      if (city == "충남"){
        idx <- which(df$시도별 == city)
        df$시도별[idx] <- "충청남도"
      }
      if (city == "경북"){
        idx <- which(df$시도별 == city)
        df$시도별[idx] <- "경상북도"
      }
      if (city == "경남"){
        idx <- which(df$시도별 == city)
        df$시도별[idx] <- "경상남도"
      }
    }
  }
  return(df)
}

effection_by_year <- function(df.n, br.2012) {
  df.n$시점 <- as.numeric(df.n$시점)
  df.n <- df.n[,-c(3:4)]
  df.n.l.1 <- df.n
  df.n.l.2 <- df.n
  df.n.l.3 <- df.n
  df.n.l.4 <- df.n
  df.n.l.5 <- df.n
  
  df.n.l.1$시점 <- df.n.l.1$시점 - 1
  df.n.l.2$시점 <- df.n.l.2$시점 - 2
  df.n.l.3$시점 <- df.n.l.3$시점 - 3
  df.n.l.4$시점 <- df.n.l.4$시점 - 4
  df.n.l.5$시점 <- df.n.l.5$시점 - 5
  
  names(df.n.l.1) <- c("시도별","시점","1년전")
  names(df.n.l.2) <- c("시도별","시점","2년전")
  names(df.n.l.3) <- c("시도별","시점","3년전")
  names(df.n.l.4) <- c("시도별","시점","4년전")
  names(df.n.l.5) <- c("시도별","시점","5년전")
  
  merged_df <- merge(df.n, df.n.l.1, by = c("시도별", "시점"))
  merged_df <- merge(merged_df, df.n.l.2, by = c("시도별", "시점"))
  merged_df <- merge(merged_df, df.n.l.3, by = c("시도별", "시점"))
  merged_df <- merge(merged_df, df.n.l.4, by = c("시도별", "시점"))
  merged_df <- merge(merged_df, df.n.l.5, by = c("시도별", "시점"))
  
  merged_df <- rename_location(merged_df)
  merged_df <- merge(br.2012, merged_df, by = c("시도별","시점"))
  
  str(unique(merged_df$시도별))
  
  for (col_idx in c(4:9)) {
    merged_df[,col_idx] <- as.numeric(merged_df[,col_idx])
  }
  
  merged_r <- merged_df[,-c(1:2)]
  
  full.model <- lm(합계출산율 ~ ., data = merged_r)
  back.model <- step(full.model, direction = "backward", trace = 0)
  back.model
  
  fit <- lm(formula = 합계출산율 ~ ., data = merged_r)
  print(summary(fit))
  
  return(merged_r)
}

#### 파일 불러오기 ####

file_path <- "C:\\RWork\\StatProject\\시도별_자산__부채__소득_현황_20230426093202_분석(전년_대비_증감,증감률).csv"
df.2017 <- read.csv(file_path, na.strings = "-", header = T, encoding = "EUC-KR")

file_path <- "C:\\RWork\\StatProject\\시도별_자산__부채__소득_현황_20230426094604_분석(전년_대비_증감,증감률).csv"
df.2021 <- read.csv(file_path, na.strings = "-", header = T, encoding = "EUC-KR")
df.2021 <- df.2021 %>% filter(시점 != "2017")

file_path <- "C:\\RWork\\StatProject\\시도_합계출산율__모의_연령별_출산율_20230426115410_분석(전년_대비_증감,증감률).csv"
br.2012 <- read.csv(file_path, na.strings = "-", header = T, encoding = "EUC-KR")
br.2012 <- br.2012[,-c(3:4)]
br.2012 <- br.2012[-1,]
names(br.2012) <- c("시도별","시점","합계출산율")

#### 분석 ####

main_list = list()
sub_list = c("경상소득","자산","부채","순자산액")

for (idx in c(1:length(sub_list))) {
  term = 3
  base_idx = c(2,3)
  start_idx = 13 + (idx-1) * term
  end_idx = start_idx + term - 1
  
  ndf.2017 <- df.2017[,c(base_idx,c(start_idx:end_idx))]
  names(ndf.2017) <- ndf.2017[1,]
  ndf.2017 <- ndf.2017[-1,]
  
  ndf.2021 <- df.2021[,c(base_idx,c(start_idx:end_idx))]
  names(ndf.2021) <- ndf.2021[1,]
  ndf.2021 <- ndf.2021[-1,]
  
  ndf <- rbind(ndf.2017, ndf.2021) %>% arrange(시도별, 시점)
  main_list[[idx]] <- ndf
}

### 경상소득
r.oi <- effection_by_year(main_list[[which(sub_list == "경상소득")]], br.2012)
#Multiple R-squared:  0.1043,	Adjusted R-squared:  0.03063 
#1년전     -0.26805    0.22132  -1.211   0.2297  
#2년전     -0.29537    0.21201  -1.393   0.1678  
#3년전      0.02620    0.20946   0.125   0.9008  
#4년전     -0.13123    0.20479  -0.641   0.5237  
#5년전     -0.45309    0.20426  -2.218   0.0297 *
r.oi <- r.oi[,c(1,7)]

### 자산
r.a <- effection_by_year(main_list[[which(sub_list == "자산")]], br.2012)
#Multiple R-squared:  0.4193,	Adjusted R-squared:  0.3716 
#1년전     -0.05306    0.11111  -0.478  0.63442    
#2년전      0.28232    0.10091   2.798  0.00657 ** 
#3년전      0.09525    0.09698   0.982  0.32927    
#4년전     -0.20882    0.08321  -2.509  0.01431 *  
#5년전     -0.45103    0.08339  -5.409 7.67e-07 ***
r.a <- r.a[,c(1,4,6,7)]

### 부채
r.l <- effection_by_year(main_list[[which(sub_list == "부채")]], br.2012)
#Multiple R-squared:  0.1594,	Adjusted R-squared:  0.09034 
#1년전      0.07116    0.07872   0.904  0.36894   
#2년전      0.24307    0.07573   3.209  0.00198 **
#3년전     -0.01642    0.07580  -0.217  0.82907   
#4년전     -0.02124    0.07817  -0.272  0.78658   
#5년전     -0.06268    0.08278  -0.757  0.45137   
r.l <- r.l[,c(1,4)]

### 순자산액
r.nw <- effection_by_year(main_list[[which(sub_list == "순자산액")]], br.2012)
#Multiple R-squared:  0.4225,	Adjusted R-squared:  0.375 
#1년전     -0.04868    0.10167  -0.479   0.6335    
#2년전      0.20877    0.09616   2.171   0.0332 *  
#3년전      0.11648    0.09158   1.272   0.2074    
#4년전     -0.18359    0.07579  -2.423   0.0179 *  
#5년전     -0.41804    0.07639  -5.472 5.95e-07 ***
r.nw <- r.nw[,c(1,4,6,7)]

names(r.oi) <- c("합계출산율","경상소득.5년전")
names(r.a) <- c("합계출산율","자산.2년전","자산.4년전","자산.5년전")
names(r.l) <- c("합계출산율","부채.2년전")
names(r.nw) <- c("합계출산율","순자산.2년전","순자산.4년전","순자산.5년전")

result <- merge(r.oi, r.a, by = c("합계출산율"))
result <- merge(result, r.l, by = c("합계출산율"))
result <- merge(result, r.nw, by = c("합계출산율"))

#### 추가 ####
fit <- lm(formula = 합계출산율 ~ ., data = result)
print(summary(fit))
#Multiple R-squared:  0.5002,	Adjusted R-squared:  0.4886 
#경상소득.5년전 -0.08097    0.07313  -1.107 0.268960    
#자산.2년전      0.11310    0.04292   2.635 0.008784 ** 
#자산.4년전     -0.06532    0.05360  -1.219 0.223739    
#자산.5년전     -0.27584    0.04667  -5.910 8.19e-09 ***
#부채.2년전      0.10697    0.03165   3.380 0.000808 ***
#순자산.2년전    0.08585    0.03734   2.299 0.022098 *  
#순자산.4년전   -0.07087    0.05044  -1.405 0.160857    
#순자산.5년전   -0.23581    0.04101  -5.751 1.96e-08 ***
shapiro.test(resid(fit)) #p-value = 0.0221 정규분포가 아니다.

full.model <- lm(합계출산율 ~ ., data = result)
back.model <- step(full.model, direction = "backward", trace = 0)
back.model

fit <- lm(formula = 합계출산율 ~ 자산.2년전 + 자산.5년전 + 부채.2년전 + 
            순자산.2년전 + 순자산.4년전 + 순자산.5년전, data = result)
print(summary(fit))
#Multiple R-squared:  0.4962,	Adjusted R-squared:  0.4875 
#자산.2년전    0.11811    0.04275   2.763 0.006038 ** 
#자산.5년전   -0.29182    0.04567  -6.389 5.37e-10 ***
#부채.2년전    0.10690    0.03166   3.376 0.000817 ***
#순자산.2년전  0.08781    0.03714   2.364 0.018622 *  
#순자산.4년전 -0.12012    0.03338  -3.598 0.000367 ***
#순자산.5년전 -0.23124    0.04026  -5.744 2.03e-08 ***
shapiro.test(resid(fit)) #p-value = 0.017 정규분포가 아니다.
