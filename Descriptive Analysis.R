# Load necessary libraries
install.packages('tidyverse')
install.packages('ggplot2')
install.packages('dplyr')
install.packages('corrplot')

library(tidyverse)
library(ggplot2)
library(dplyr)
library(corrplot)

# Load the data
data <- read.csv("C:/Users/vigne/Downloads/diabetes_dataset.csv")
data_2 <- data  # Create a working copy of the data
glimpse(data)
# 1. Data Summarization ----

# Summary of the dataset
cat("Summary of the dataset:\n")
summary(data_2)

# General structure of the dataset
cat("\nStructure of the dataset:\n")
str(data_2)

# Count total rows in each column to check for completeness
total_rows <- colSums(!is.na(data_2))
cat("\nTotal rows in each column:\n")
print(total_rows)

# Check for null values in each column
null_values <- sapply(data_2, function(x) sum(is.na(x)))
cat("\nNull values in each column:\n")
print(null_values)

# 2. Data Preprocessing ----

# Convert gender, location, and smoking history to factors with proper labels
data_2$gender <- factor(data_2$gender, levels = unique(data_2$gender), labels = c("Male", "Female", "Other"))
data_2$location <- factor(data_2$location)
data_2$smoking_history <- factor(data_2$smoking_history, 
                                 levels = c("never", "former", "current", "not current", "No info"),
                                 labels = c("Never Smoked", "Former Smoker", "Current Smoker", "Not Current", "No Info"))

# Cap BMI values at 45 to limit extreme outliers
data_2$bmi <- ifelse(data_2$bmi > 45, 45, data_2$bmi)

# Convert the target variable 'diabetes' to a factor with labels
data_2$diabetes <- factor(data_2$diabetes, levels = c(0, 1), labels = c("Non-Diabetic", "Diabetic"))

# Create binary flags for high-risk categories
data_2 <- data_2 %>%
  mutate(
    high_bmi_flag = ifelse(bmi > 30, 1, 0),
    high_glucose_flag = ifelse(blood_glucose_level > 140, 1, 0),
    age_over_50_flag = ifelse(age > 50, 1, 0)
  )

# 3. Descriptive Analysis ----

# Age Distribution - Histogram with Density Curve
ggplot(data_2, aes(x = age)) +
  geom_histogram(bins = 30, fill = "skyblue", color = "black") +
  geom_density(color = "red") +
  xlab("Age") +
  ylab("Density") +
  ggtitle("Age Distribution")

# Gender Distribution by Diabetes Status - Bar Plot
ggplot(data_2, aes(x = gender, fill = diabetes)) +
  geom_bar(position = "dodge") +
  xlab("Gender") +
  ylab("Count") +
  ggtitle("Diabetes Distribution Across Genders") +
  scale_fill_manual(values = c("skyblue", "salmon")) +
  geom_text(stat = 'count', aes(label = ..count..), position = position_dodge(width = 0.9), vjust = -0.5)

# HbA1c Level by Diabetes Status - Box Plot
ggplot(data_2, aes(x = diabetes, y = hbA1c_level)) +
  geom_boxplot() +
  xlab("Diabetes Status") +
  ylab("HbA1c Level") +
  ggtitle("HbA1c Level Distribution by Diabetes Status")

# Blood Glucose Level by Diabetes Status - Box Plot
ggplot(data_2, aes(x = diabetes, y = blood_glucose_level)) +
  geom_boxplot() +
  xlab("Diabetes Status") +
  ylab("Blood Glucose Level") +
  ggtitle("Blood Glucose Level Distribution by Diabetes Status")

# 4. BMI Categories and Analysis ----

# Create BMI categories based on health risk levels
data_2 <- data_2 %>%
  mutate(bmi_category = case_when(
    bmi < 18.5 ~ "Underweight",
    bmi >= 18.5 & bmi < 25 ~ "Normal",
    bmi >= 25 & bmi < 30 ~ "Overweight",
    bmi >= 30 ~ "Obese"
  ))

# Diabetes Prevalence within BMI Categories - Proportional Bar Plot
ggplot(data_2, aes(x = bmi_category, fill = diabetes)) +
  geom_bar(position = "fill") +
  labs(title = "Proportion of Diabetes Across BMI Categories",
       x = "BMI Category",
       y = "Proportion",
       fill = "Diabetes Status") +
  theme_minimal()

# 5. Location-Based Analysis ----

# Diabetes Distribution by Location - Bar Plot
ggplot(data_2, aes(x = location, fill = diabetes)) +
  geom_bar(position = "dodge") +
  labs(title = "Diabetes Distribution by Location", x = "Location", y = "Count", fill = "Diabetes Status") +
  scale_fill_manual(values = c("Non-Diabetic" = "gray", "Diabetic" = "red")) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

# 6. Proportion of Diabetes by Age Group ----

# Create age groups for analysis
data_2 <- data_2 %>%
  mutate(age_group = cut(age, breaks = c(0, 20, 40, 60, 80, 100), labels = c("0-20", "21-40", "41-60", "61-80", "81-100")))

# Diabetes Proportion by Age Group - Proportional Bar Plot
ggplot(data_2, aes(x = age_group, fill = diabetes)) +
  geom_bar(position = "fill") +
  xlab("Age Group") +
  ylab("Proportion") +
  ggtitle("Proportion of Diabetes Across Age Groups") +
  scale_fill_manual(values = c("Non-Diabetic" = "skyblue", "Diabetic" = "salmon")) +
  theme_minimal()

# 7. Correlation Analysis ----

# Select numeric columns and calculate correlation matrix
numeric_data <- select(data_2, where(is.numeric))
correlation_matrix <- cor(numeric_data, use = "complete.obs")

# Plot correlation matrix
corrplot(correlation_matrix, method = "color", type = "upper", tl.col = "black", tl.srt = 45, 
         col = colorRampPalette(c("blue", "white", "red"))(200))

# 8. Scatter Plots for Target and Independent Variables ----

# Scatter plot of Age vs Diabetes Status
ggplot(data_2, aes(x = age, y = as.numeric(diabetes) - 1)) +
  geom_jitter(aes(color = diabetes), width = 0.3, height = 0.1) +
  labs(title = "Scatter Plot of Age vs Diabetes Status", x = "Age", y = "Diabetes (0 = Non-Diabetic, 1 = Diabetic)") +
  theme_minimal() +
  scale_color_manual(values = c("skyblue", "salmon"))

# Scatter plot of BMI vs Diabetes Status
ggplot(data_2, aes(x = bmi, y = as.numeric(diabetes) - 1)) +
  geom_jitter(aes(color = diabetes), width = 0.3, height = 0.1) +
  labs(title = "Scatter Plot of BMI vs Diabetes Status", x = "BMI", y = "Diabetes (0 = Non-Diabetic, 1 = Diabetic)") +
  theme_minimal() +
  scale_color_manual(values = c("skyblue", "salmon"))

# Scatter plot of Blood Glucose Level vs Diabetes Status
ggplot(data_2, aes(x = blood_glucose_level, y = as.numeric(diabetes) - 1)) +
  geom_jitter(aes(color = diabetes), width = 0.3, height = 0.1) +
  labs(title = "Scatter Plot of Blood Glucose Level vs Diabetes Status", x = "Blood Glucose Level", y = "Diabetes (0 = Non-Diabetic, 1 = Diabetic)") +
  theme_minimal() +
  scale_color_manual(values = c("skyblue", "salmon"))


# Scatter plot of HbA1c Level vs Diabetes Status
ggplot(data_2, aes(x = hbA1c_level, y = as.numeric(diabetes) - 1)) +
  geom_jitter(aes(color = diabetes), width = 0.3, height = 0.1) +
  labs(title = "Scatter Plot of HbA1c Level vs Diabetes Status", 
       x = "HbA1c Level", 
       y = "Diabetes (0 = Non-Diabetic, 1 = Diabetic)") +
  theme_minimal() +
  scale_color_manual(values = c("skyblue", "salmon"))


# Scatter plot of Age vs Blood Glucose Level by Diabetes Status
ggplot(data_2, aes(x = age, y = blood_glucose_level, color = diabetes)) +
  geom_point(alpha = 0.6) +
  labs(title = "Scatter Plot of Age vs Blood Glucose Level by Diabetes Status", 
       x = "Age", 
       y = "Blood Glucose Level") +
  theme_minimal() +
  scale_color_manual(values = c("skyblue", "salmon"))

# Scatter plot of BMI vs HbA1c Level by Diabetes Status
ggplot(data_2, aes(x = bmi, y = hbA1c_level, color = diabetes)) +
  geom_point(alpha = 0.6) +
  labs(title = "Scatter Plot of BMI vs HbA1c Level by Diabetes Status", 
       x = "BMI", 
       y = "HbA1c Level") +
  theme_minimal() +
  scale_color_manual(values = c("skyblue", "salmon"))

# Scatter plot of HbA1c Level vs Blood Glucose Level by Diabetes Status
ggplot(data_2, aes(x = hbA1c_level, y = blood_glucose_level, color = diabetes)) +
  geom_point(alpha = 0.6) +
  labs(title = "Scatter Plot of HbA1c Level vs Blood Glucose Level by Diabetes Status", 
       x = "HbA1c Level", 
       y = "Blood Glucose Level") +
  theme_minimal() +
  scale_color_manual(values = c("skyblue", "salmon"))
