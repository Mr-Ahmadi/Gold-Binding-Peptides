## Machine Learning Classification Model for Gold-Binding Peptides
## Author: Jose Isagani B. Janairo
## Department of Biology, De La Salle University
## Corresponding author: jose.isagani.janairo@dlsu.edu.ph
install.packages("ggpubr", dependencies = TRUE)
library(Peptides)
# Setup
set.seed(1234)
library(Peptides)
library(dplyr)
library(caret)
library(ggpubr)
library(iml)
library(cowplot)

# Load data and compute Kidera factors
df <- read.csv("../data/train.csv", header = TRUE)
kf <- kideraFactors(seq = df$Sequence)
kf_df <- as.data.frame(do.call(rbind, kf))
mother_dataset <- cbind(df, kf_df)
mother_dataset$Class <- as.factor(mother_dataset$Class)

# Prepare dataset (features only)
dataset <- mother_dataset[, c(3:13)]  # select features and Class

# Split into training and validation sets
set.seed(1234)
index <- createDataPartition(dataset$Class, p = 0.75, list = FALSE)
train <- dataset[index, ]
validation <- dataset[-index, ]
validation$Class <- as.factor(validation$Class)

# Training control
tctrl <- trainControl(method = "cv", number = 10)
metric <- "Accuracy"

# Train models
fit_glm   <- train(Class ~ ., data = train,  method = "glm",         metric = metric, trControl = tctrl)
fit_cart  <- train(Class ~ ., data = train,  method = "rpart",       metric = metric, trControl = tctrl)
fit_knn   <- train(Class ~ ., data = train,  method = "knn",         metric = metric, trControl = tctrl)
fit_svmL  <- train(Class ~ ., data = train,  method = "svmLinear",   metric = metric, trControl = tctrl)
fit_svmR  <- train(Class ~ ., data = train,  method = "svmRadial",   metric = metric, trControl = tctrl)
fit_svmP  <- train(Class ~ ., data = train,  method = "svmPoly",     metric = metric, trControl = tctrl)
fit_ann   <- train(Class ~ ., data = train,  method = "nnet",        metric = metric, trControl = tctrl)

# Feature-selected SVM-R model
svmR_sel_formula <- as.formula("Class ~ KF2 + KF3 + KF4 + KF5 + KF6 + KF7 + KF9 + KF10")
fit_svmR_sel <- train(svmR_sel_formula, data = train, method = "svmRadial", metric = metric, trControl = tctrl)

# Evaluate on validation set
predictions <- predict(fit_svmR_sel, validation)
conf_matrix <- confusionMatrix(predictions, validation$Class)
print(conf_matrix)

# Feature importance (using iml)
x_vars <- train[, names(train) != "Class"]
pred <- Predictor$new(fit_svmR_sel, data = x_vars, y = train$Class)
imp <- FeatureImp$new(pred, loss = "ce")
print(imp$results)

# Plot variable importance
p1 <- ggplot(imp$results, aes(x = feature, y = importance)) +
  geom_segment(aes(xend = feature, yend = 0), color = "grey") +
  geom_point(color = "orange", size = 4) +
  theme_light() +
  theme(panel.grid.major.x = element_blank(),
        panel.border = element_blank(),
        axis.ticks.x = element_blank()) +
  xlab("Classification Variable") + ylab("Variable Importance")

p2 <- ggplot(imp$results, aes(x = importance, y = reorder(feature, importance))) +
  geom_point(size = 5) +
  xlab("Variable Importance") + ylab("Classification Variable") +
  theme_bw(base_size = 14) +
  theme(panel.grid.major.x = element_blank(),
        panel.grid.minor.x = element_blank(),
        panel.grid.major.y = element_line(colour = "grey60", linetype = "dashed"))

# Plot SVM-R tuning results and combine
p3 <- ggplot(fit_svmR$results, aes(x = sigma, y = Accuracy, colour = C)) +
  geom_point(size = 5, alpha = 0.7) +
  theme_classic(base_size = 14) +
  theme(legend.position = "none",
        axis.title.x = element_blank(),
        axis.title.y = element_blank()) +
  xlim(0, 0.1) + ylim(0.7, 0.85)

# Display plots
print(p1)
print(p2)
print(p3)

# End of script
