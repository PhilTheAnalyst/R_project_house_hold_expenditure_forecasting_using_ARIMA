file_path <- "C:/Users/user/Desktop/Bachelors Degree In Actuarial 
Science/project 4rth year/PCE.csv"
#PCE_data <- read_csv(file_path)
PCE_data <- read_csv(file_path)
head(PCE_data)
PCE_ts <- ts(PCE_data$PCE, start=c(1959, 1),end = c(2024,7),
frequency=12)
#plotting the data
plot(PCE_ts, main="Plot of Household Expenditure", ylab="PCE",
xlab="Year",type="l")
#data description and summary statistics
# Plot the STL decomposition
PCE_decomposed <- decompose(PCE_ts)  # Additive decomposition
trend_component <- PCE_decomposed$trend
seasonal_component <- PCE_decomposed$seasonal
residual_component <- PCE_decomposed$random
# Apply the HP filter to approximate the cyclical component
hp_filter <- hpfilter(PCE_ts, freq = 1600)  # freq=1600 
is common for monthly data
cyclical_component <- hp_filter$cycle
#cyclical_component<- trend_component + residual_component
# Plot the components: trend, seasonal, cyclical, and residual
par(mfrow=c(4, 1))  # Arrange plots in 4 rows and 1 column
# Plot the trend component
plot(trend_component, main="Trend Component", ylab="Trend", xlab=
"Year")
# Plot the seasonal component
plot(seasonal_component, main="Seasonal Component",
ylab="Seasonality", xlab="Year", ylim=c(-200, 200))
# Plot the cyclical component (approximated using HP filter)
plot(cyclical_component, main="Cyclical Component", 
ylab="Cyclic", xlab="Year")
# Plot the residual component
plot(residual_component, main="Residual Component", ylab=
"Residuals", xlab="Year")
# Reset plotting layout to single plot
par(mfrow=c(1, 1))    
#Transforming the data
PCE_ts2<- log(PCE_ts)
#plot(PCE_ts2)
data_length <- length(PCE_ts2)
# Split into 95:5 ratio
train_size <- floor(0.95* data_length)
# Training set
train_data <- window(PCE_ts2, end=c(1959 + (train_size - 1)
%/% 12, (train_size - 1) %% 12 + 1))
# Testing set
test_data <- window(PCE_ts2, start=c(1959 + train_size %/% 12,
train_size %% 12 + 1))
plot(train_data)
plot(test_data)
#Perform Augmented Dickey-Fuller test for stationarity
adf_test <- adf.test(train_data)
p_value <- adf_test$p.value 
print(adf_test$p.value)# Interpret the result based on the p-value
#how many differences are required to make the series stationary.
d =ndiffs(train_data)
print(d)
#checking for the seasonal differences required
d2 =nsdiffs(train_data)
print(d2)
#taking the difference of the series
PCE_ts_diff <- diff(train_data, differences=d)
#plotting the differenced time series
plot(PCE_ts_diff, main="Differenced Time Series", ylab=
"Differenced PCE", xlab="Year",type="l")
#checking for stationarity of the differenced time series
adf_test2 <- adf.test(PCE_ts_diff)
p_value2 <- adf_test2$p.value
# Interpret the result based on the p-value
#ACF and PACF plots
#Plot the ACF and PACF of the differenced series
#Arrange plots in 2 rows and 1 column

# Plot ACF of the differenced series
acf(PCE_ts_diff, main="ACF of Differenced Time Series")
# Plot PACF of the differenced series
pacf(PCE_ts_diff, main="PACF of Differenced Time Series")
par(mfrow=c(1,1))   
#selecting the model with the lowest AIC and BIC from the
candidate models
# Define the range of p and q values
p_values <- 1:5
q_values <- 1:2
# Initialize lists to store AIC, BIC, and HQC values
aic_values <- c()
bic_values <- c()
hqc_values <- c()
model_summaries <- list()
# Loop through all combinations of p and q
for (p in p_values) {
for (q in q_values) {
# Fit ARIMA model
model <- arima(train_data, order = c(p, 2, q))
# Extract AIC, BIC, and HQC
aic <- AIC(model)
bic <- BIC(model)
# Calculate HQC
n <- length(train_data)  # Number of observations
k <- length(model$coef)  # Number of parameters
hqc <- -2 * logLik(model) + 2 * k * log(log(n))  # HQC formula
# Store AIC, BIC, and HQC values
aic_values <- c(aic_values, aic)
bic_values <- c(bic_values, bic)
hqc_values <- c(hqc_values, hqc)
# Store model summary
model_summaries[[paste("ARIMA(", p, ",2,", q, ")", sep="")]]
<- model}}     
# Create a data frame with AIC, BIC, and HQC values
results_df <- data.frame(
Model = names(model_summaries),
AIC = aic_values,
BIC = bic_values,
HQC = hqc_values
)
# Print the results
print(results_df)
# Find the model with the lowest AIC, BIC, and HQC
best_aic_model <- results_df[which.min(results_df$AIC), ]
best_bic_model <- results_df[which.min(results_df$BIC), ]
best_hqc_model <- results_df[which.min(results_df$HQC), ]
# Output the best models
cat("Model with the lowest AIC:\n")
print(best_aic_model)
cat("\nModel with the lowest BIC:\n")
print(best_bic_model)
cat("\nModel with the lowest HQC:\n")
print(best_hqc_model)    
#maximum likelihood estimation.
model <- arima(train_data, order = c(1, 2, 1), method = "ML")
# Display the model summary with parameter estimates
summary(model)
best_model <- arima(train_data, order = c(1, 2, 1))
##Checking the adequacy of the selected model
#Normality of residuals 
#shapiro-wilk statistical test
# Extract residuals from the fitted model
residuals <- ts(best_model$residuals)
# Perform Shapiro-Wilk test
shapiro_test <- shapiro.test(residuals)
# Print the Shapiro-Wilk test result
cat("Shapiro-Wilk normality test result:\n")
print(shapiro_test)
#Histogram of residuals
par(mfrow=c(1,1))
library(ggplot2)
# Plot QQ plot
qqnorm(residuals, main = "QQ Plot of Residuals")
qqline(residuals, col = "red")
# Plot histogram of residuals
residuals_df <- data.frame(residuals)
# Plot histogram with normal distribution curve using ggplot2
ggplot(residuals_df, aes(x = residuals)) +
geom_histogram(aes(y = ..density..), bins = 20, fill = 
"lightblue", color = "black") +
stat_function(fun = dnorm, 
args = list(mean = mean(residuals), sd = sd(residuals)),
color = "red", size = 1) +
labs(title = "Histogram of Residuals with Normal Distribution
Overlay",
x = "Residuals",
y = "Density") +
theme_minimal()
#Autocorrelation of residuals
#PACF plot of model residuals
acf(residuals,main="ACF of Residuals")
pacf(residuals,main="PACF of Residuals")
par(mfow=c(1,1))
# Ljung-Box Test for autocorrelation
ljung_box_test <- Box.test(residuals, lag = 20, type = "Ljung-Box")
alpha <- 0.05  # Significance level
#Stationarity of residuals
#ADF test on model residuals
adf_test <- adf.test(residuals, alternative = "stationary")
# Print the ADF test result
cat("ADF test result:\n")
print(adf_test)
# Hypothesis testing
alpha <- 0.05  # Significance level
#forecasting using the one step ahead forecast
# Forecast for the length of the test set
full_forecast <- forecast(best_model, h=length(test_data))
# Transform the values back from log scale
test_data_exp1 <- exp(test_data)
forecasts_exp1 <- exp(full_forecast$mean)
# Plotting One-Step Ahead Forecast with whole years on the x-axis
par(mfrow=c(1,1))
# Plot the transformed (original scale) forecasted values 
against the actual test data
plot(test_data_exp1, main = "One-Step Ahead Forecast vs Test
Data ", 
col = "blue", type = "l", xlab = "Time", ylab = "Household 
Expenditure", xaxt="n", ylim = range(test_data_exp1,
forecasts_exp1))
# Custom x-axis with whole years
years <- seq(from=floor(time(test_data_exp1)[1]),to=ceiling(time
(test_data_exp1)[length(test_data_exp1)]), by=1)
axis(1, at=years, labels=years)
# Add forecasted values
lines(forecasts_exp1, col = "red", lty = 2)
legend("topleft", legend = c("Test Data", "Forecast"), col =
c("blue", "red"), lty = 1:2)
#forecasting using rolling forecast technique
forecasts <- ts(numeric(length(test_data)), start=start(test_data)
, frequency=12)
# Rolling forecast
for (i in 1:length(test_data)) {
# Expand the training set by adding one test data point at a time
extended_train_data <- window(PCE_ts2, end = c(1959 + 
(train_size + i - 1) %/% 12, (train_size + i - 1) %% 12 + 1))
# Fit the ARIMA model with specified orders
updated_model <- Arima(extended_train_data, order=c(1,2,1))
# Get the one-step ahead forecast and store the mean forecast
forecasts[i] <- forecast(updated_model, h=1)$mean
}   
# Transform the values back from log scale
test_data_exp <- exp(test_data)
forecasts_exp <- exp(forecasts)
par(mfrow=c(1,1))
# Plot the transformed (original scale) forecasted values
against the actual test data
plot(test_data_exp, main = "Rolling Forecast vs Test Data ", 
col = "blue", type = "l", xlab = "Time", ylab = "Household
Expenditure", xaxt="n", ylim = range(test_data_exp, forecasts_exp))
# Custom x-axis with whole years
axis(1, at=years, labels=years)
# Add forecasted values
lines(forecasts_exp, col = "red", lty = 2)
legend("topleft", legend = c("Test Data", "Forecast"), col =
c("blue", "red"), lty = 1:2)
# Create a table of the actual values, one-step ahead 
forecast, and rolling forecast
forecast_table <- data.frame(
"Actual Values" = test_data_exp,
"One-Step Ahead Forecast" = forecasts_exp1,
"Rolling Forecast" = forecasts_exp
)
# Calculate Mean Square Error (MSE)  onestep ahead forecast
mse1 <- mean((test_data_exp - forecasts_exp1) ^ 2)
# Calculate Theil's Inequality Coefficient (U)  onestep ahead
forecast
# Theil's U is calculated as: sqrt(sum((actual - forecast)^2)
/ sum((actual - mean(actual))^2))
theils_U1 <- sqrt(mean((test_data_exp - forecasts_exp1) ^ 2) /
mean((test_data_exp - mean(test_data_exp)) ^ 2))
# Output the results using cat statements
cat("Mean Square Error (MSE):", mse1, "\n")
cat("Theil's Inequality Coefficient (U):", theils_U1, "\n")
# Calculate Mean Square Error (MSE) rolling forecast
mse <- mean((test_data_exp - forecasts_exp) ^ 2)
# Calculate Theil's Inequality Coefficient (U) rolling forecast
# Theil's U is calculated as: sqrt(sum((actual - forecast)^2)
/ sum((actual - mean(actual))^2))
theils_U <- sqrt(mean((test_data_exp - forecasts_exp) ^ 2) /
mean((test_data_exp - mean(test_data_exp)) ^ 2))
# Output the results using cat statements
cat("Mean Square Error (MSE):", mse, "\n")
cat("Theil's Inequality Coefficient (U):", theils_U, "\n")