#### 라이브러리 관리 ####
library(ggplot2)
#install.packages("fmsb")
library(fmsb)

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


exam_scores <- data.frame(
  row.names = c("Student.1", "Student.2", "Student.3"),
  Biology = c(7.9, 3.9, 9.4),
  Physics = c(10, 20, 0),
  Maths = c(3.7, 11.5, 2.5),
  Sport = c(8.7, 20, 4),
  English = c(7.9, 7.2, 12.4),
  Geography = c(6.4, 10.5, 6.5),
  Art = c(2.4, 0.2, 9.8),
  Programming = c(0, 0, 20),
  Music = c(20, 20, 20)
)
exam_scores

# Define the variable ranges: maximum and minimum
max_min <- data.frame(
  Biology = c(20, 0), Physics = c(20, 0), Maths = c(20, 0),
  Sport = c(20, 0), English = c(20, 0), Geography = c(20, 0),
  Art = c(20, 0), Programming = c(20, 0), Music = c(20, 0)
)
rownames(max_min) <- c("Max", "Min")

# Bind the variable ranges to the data
df <- rbind(max_min, exam_scores)
df
# Plot the data for student 1
student1_data <- df[c("Max", "Min", "Student.1"), ]
radarchart(student1_data)

student1_data

#단일
op <- par(mar = c(1, 2, 2, 1))
create_beautiful_radarchart(student1_data, caxislabels = c(0, 5, 10, 15, 20))
par(op)

#다중 - 겹치게
# Reduce plot margin using par()
op <- par(mar = c(1, 2, 2, 2))
# Create the radar charts
create_beautiful_radarchart(
  data = df, caxislabels = c(0, 5, 10, 15, 20),
  color = c("#00AFBB", "#E7B800", "#FC4E07")
)
# Add an horizontal legend
legend(
  x = "bottom", legend = rownames(df[-c(1,2),]), horiz = TRUE,
  bty = "n", pch = 20 , col = c("#00AFBB", "#E7B800", "#FC4E07"),
  text.col = "black", cex = 1, pt.cex = 1.5
)
par(op)



#다중 - 안겹치게
# Define colors and titles
colors <- c("#00AFBB", "#E7B800", "#FC4E07")
titles <- c("Student.1", "Student.2", "Student.3")

# Reduce plot margin using par()
# Split the screen in 3 parts
op <- par(mar = c(1, 1, 1, 1))
par(mfrow = c(1,3))

# Create the radar chart
for(i in 1:3){
  create_beautiful_radarchart(
    data = df[c(1, 2, i+2), ], caxislabels = c(0, 5, 10, 15, 20),
    color = colors[i], title = titles[i]
  )
}
par(op)


#다중 - 여러개를 데이터가 확 눈에 띄게

set.seed(123)
df <- as.data.frame(
  matrix(sample(2:20 , 90 , replace = TRUE),
         ncol=9, byrow = TRUE)
)
colnames(df) <- c(
  "Biology", "Physics", "Maths", "Sport", "English", 
  "Geography", "Art", "Programming", "Music"
)
rownames(df) <- paste0("Student.", 1:nrow(df))
head(df)

library(scales)
df_scaled <- round(apply(df, 2, scales::rescale), 2)
df_scaled <- as.data.frame(df_scaled)
head(df_scaled)

# Variables summary
# Get the minimum and the max of every column  
col_max <- apply(df_scaled, 2, max)
col_min <- apply(df_scaled, 2, min)
# Calculate the average profile 
col_mean <- apply(df_scaled, 2, mean)
# Put together the summary of columns
col_summary <- t(data.frame(Max = col_max, Min = col_min, Average = col_mean))


# Bind variables summary to the data
df_scaled2 <- as.data.frame(rbind(col_summary, df_scaled))
head(df_scaled2)

opar <- par() 
# Define settings for plotting in a 3x4 grid, with appropriate margins:
par(mar = rep(0.8,4))
par(mfrow = c(3,4))
# Produce a radar-chart for each student
for (i in 4:nrow(df_scaled2)) {
  radarchart(
    df_scaled2[c(1:3, i), ],
    pfcol = c("#99999980",NA),
    pcol= c(NA,2), plty = 1, plwd = 2,
    title = row.names(df_scaled2)[i]
  )
}
# Restore the standard par() settings
par <- par(opar) 