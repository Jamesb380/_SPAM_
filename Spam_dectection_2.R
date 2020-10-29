##James Bennett

#************************************************************
#
#				GLM 2 
#				Logistic Regression
#				Evaluation
#
#
#************************************************************

source("testSet.R")
##*****************************
        #
        # Parameter Interpretation
        #
        #*****************************
        
        # How much does a one unit change in
        # variable 57 affect the odds?
        
        # Variable 57 (total number of capital letters)
        # notice that we add one to the variable number (57)
        # to account for the intercept

(exp(spam.glm$coefficients[58]) -1)*100
#This tells us that var57 adds 0.08% likelihood of a message being spam for each extra capital letter
#Percent change
# round to 2 decimal points
round((exp(spam.glm$coefficients[58]) -1)*100, 2)
round((exp(Lspam.glm$coefficients[57]) -1)*100, 2)

#  Is variable 57 significant in the model? 
#  use the likelihood ratio test
Lspam.nc <- glm(V58~., data = Lspam[,-56], family = binomial)
anova(Lspam.nc, Lspam.glm, test = "Chi")

# How much does a one unit change in
# variable 56 affect the odds?
(exp(spam.glm$coefficients[57])-1)*100

# Is variable 56 significant?
spam.nc <- glm(V58~., data = Spam[,-56], family = binomial)
anova(spam.nc, spam.glm, test = "Chi")

# Repeat for Log model with variable 57.
spam.nc <- glm(V58~., data = Spam[,-57], family = binomial)
anova(spam.nc, spam.glm, test = "Chi")
# 



#*****************************
#
# Diagnostics
#
#*****************************

# main effects no transform
par(mfrow=c(2,2))
png("main_effect_model_nologtrans.png")
plot(spam.glm)
dev.off()
par(mfrow=c(1,1))

#see the residuals above
#Two straight lines
#This is what we want for good fit
#Better is closer to two straight lines

#See the q-q above
#Doesn't need to be gaussian

#Want two straight lines in scale-loc, as w/resid-fit

#main effects log transform
par(mfrow=c(2,2))
png("main_effect_model_log_trans.png")
plot(Lspam.glm)
dev.off()
par(mfrow=c(1,1))

#Resid-fit less asymptotic than previous version
#Getting curvature rather than straight lines
#But not much


#*****************************
#
# GLM with stepwise
#`
#*****************************
spam.step <- step(spam.glm)
Lspam.step <- step(Lspam.glm)

# summary


# likelihood ratio test 
# with main effects
anova(spam.glm, spam.step, test="Chi")
anova(Lspam.glm, Lspam.step, test="Chi")


# with log transform of predictors




# summary



# likelihood ratio test




# AIC and BIC for stepwise vs
# main effects models
AIC(spam.glm)
AIC(spam.step)
AIC(Lspam.glm)
AIC(Lspam.step)

BIC(spam.glm)
BIC(spam.step)
BIC(Lspam.glm)
BIC(Lspam.step)


#*****************************
#
#  Principal Components Regression
#
#*****************************

# obtain the principal components for the predictors with a correlation matrix

spam.pca <- princomp(Spam[,-58], cor = T)

# Scree plot
png("screeplot.png")
screeplot(spam.pca)
dev.off()
# Proportion of variance
png("porpotion_variance.png")
plot(spam.pca$sdev^2/sum(spam.pca$sdev^2), type = "h", xlab = "Components", ylab = "Proportion")
dev.off()
# Cumulative Proportion of variance
png("cummulative_sum.png")
plot(cumsum(spam.pca$sdev^2)/sum(spam.pca$sdev^2), type = "h", xlab = "Components", ylab = "Proportion", main = "Cumulative Proportion")
dev.off()
# to see how many components are needed for 90% of the variance we use

var.comp(Lspam.pca, 90)
###39

#How many components do we need for 98%?
var.comp(spam.pca, 98)


# Use pc.glm() to get the principal component regression results.
# choose the amount of variance (e.g., 98%)

spampca.glm98 <- pc.glm(spam.pca, 98, Spam[,58])
spampca.glm90 <- pc.glm(spam.pca, 90, Spam[,58])
Lspampca.glm90 <- pc.glm(Lspam.pca, 90, Lspam[,58])
spampca.null <- pc.null(spam.pca, 90, Spam[,58])
anova(spampca.null, spampca.glm90, test = "Chi")
Lspampca.null <- pc.null(Lspam.pca, 90, Lspam[,58])
anova(Lspampca.null, Lspampca.glm90, test = "Chi")
# Do a model utility test starting with pc.null()

spampc.null <- pc.null(spam.pca, 98, Spam[,58])

anova(spampc.null, spampca.glm98, test = "Chi")


AIC(spampca.glm98)
AIC(spampca.glm90)
AIC(Lspampca.glm90) ##Best

BIC(spampca.glm98)
BIC(spampca.glm90)
BIC(Lspampca.glm90) ##Best

#

#*****************************
#
#   Obtaining test and training sets
#
#*****************************

# Picking 1/3 of the data for the test set
# normally we would use

dim(Spam)
source("TestSet.R")
spam <- test.set(Spam, .33)

# But to get everyone using the same test set 
# we will use a chosen set in TestLabels.txt

# getting the labels for the test set


Labels <- scan("TestLabels.txt")

spam.test <- Spam[Labels,]
spam.train <- Spam[-Labels,]

#Check
nrow(Spam)
nrow(spam.test) + nrow(spam.train)

summary(Spam)
summary(rbind(spam.test,spam.train))


# log transform

Lspam.test <- Lspam[Labels,]
Lspam.train <- Lspam[-Labels,]


# Check of the random draw

#How close are averages in test set & original data (for decision var)
round(abs(mean(spam.test$V58) - mean(Spam$V58)), 2)

#How close are averages in test set & original data (for predictor var)
#Note that 56 and 57 show large skew
apply(spam.test, 2, mean) - apply(spam.train, 2, mean)

summary(spam.test[,c(56,57)])
summary(spam.train[,c(56,57)])
summary(Spam[,56:57])
#Extreme values in training set
#This might be a good thing, allows model to be more inclusive
#'Erring on the side of inclusivity'
png("boxplot56_57.png")
boxplot(Spam[,56:57])
dev.off()

png("boxplot_test_train_full_set.png")
par(mfrow = c(2,2))
boxplot(spam.test[,c(56,57)],ylim = c(min(Spam[,57]),max(Spam[,57])), main = "Test")
boxplot(spam.train[,c(56,57)], ylim = c(min(Spam[,57]),max(Spam[,57])), main = "Train")
boxplot(Spam[,56:57], main = "Full Set")
par(mfrow = c(1,1))
dev.off()
#See that extremes are in train

# The training set is now in spam.train and the test set is in spam.test.

# here is a plot to see how much of the training set is spam.

png("compare_train_test_fullset58.png")
par(mfrow = c(2,2))

barplot(table(spam.train[,58]), xlab = "Email Classfication", main = "Spam in the Training Set", names.arg = c("Ham", "Spam"), col = "steelblue")

barplot(table(spam.test[,58]), xlab = "Email Classfication", main = "Spam in the Test Set", names.arg = c("Ham", "Spam"), col = "steelblue")

barplot(table(Spam[,58]), xlab = "Email Classfication", main = "Spam in the Original Set", names.arg = c("Ham", "Spam"), col = "steelblue")

par(mfrow = c(1,1))
dev.off()
#So, proportions are pretty close


#*****************************
#
# GLM with the training set
#
#*****************************


# Main effects:  all the variables for the model

#spam.trainglm 
spam.trainglm <- glm(V58~., data = spam.train, family = binomial)

# Log model

#Lspam.trainglm 
Lspam.trainglm <- glm(V58~., data = Lspam.train, family = binomial)


# Stepwise

#spam.trainstep 
spam.trainstep <- step(spam.trainglm)
#optimization here is much more difficult than before
#Nonlinear optimization
#Maximum likelihood


#Lspam.trainstep 
Lspam.trainstep <- step(Lspam.trainglm)

#  PCR with training set
#


# obtain the principal components for the 
# training set with a correlation matrix

spam.trainpca <- princomp(spam.train[,-58], cor = T)
Lspam.trainpca <- princomp(Lspam.train[,-58], cor = T)
# Get the principal component regression results.
# choose the amount of variance (e.g., 98%)
#This is leaving orthogonal variables in
#Corrects for multicollinearity

spampcr.train98 <- pc.glm(spam.trainpca, 98, spam.train[,58])
spampcl.train50 <- pc.glm(spam.pca, 50, Spam[,58])

spampcr.train90 <- pc.glm(spam.trainpca, 90, spam.train[,58])
Lspampcr.train90 <- pc.glm(Lspam.trainpca, 90, Lspam.train[,58])
#*****************************
#
# Confusion matrices
#
#*****************************

# test set prediction
# main effects model

glm.pred <- predict(spam.trainglm, newdata = spam.test, type = "response")

glm.pred[1:5]
#These numbers are probabilities of rec'ing spam, based on testing 1st five emails
#Will now compute how well we do based on our predictions
#Will set a threshold above which a message is spam
#Then, see how it handles test set


# Get the confusion matrix with score.table()
# the score table function takes 3 arguments: 
# the predicted values, the actuals,
# and the threshold.

# Thresholds: .4, .5, .6

score.table(glm.pred, spam.test[,58],  .4)
score.table(glm.pred, spam.test[,58],  .5)
score.table(glm.pred, spam.test[,58],  .6)


# score table for the log model

# predict

#Lglm.pred 
Lglm.pred <- predict(Lspam.trainglm, newdata = Lspam.test, type = "response")
# Thresholds: .4, .5, .6
score.table(Lglm.pred, spam.test[,58],  .4)
score.table(Lglm.pred, spam.test[,58],  .5)
score.table(Lglm.pred, spam.test[,58],  .6)


# Evaluate the stepwise models

# Step no transform

# prediction
#glmstep.pred 
glmstep.pred <- predict(spam.trainstep, newdata = spam.test, type = "response")
# confusion matrices
# Thresholds: .4, .5, .6
score.table(glmstep.pred , spam.test[,58],  .4)
score.table(glmstep.pred , spam.test[,58],  .5)
score.table(glmstep.pred , spam.test[,58],  .6)

# Step log transform

# prediction

#Lglmstep.pred
Lglmstep.pred <- predict(Lspam.trainstep, newdata = Lspam.test, type = "response")

# confusion matrices

score.table(Lglmstep.pred , spam.test[,58],  .4)
score.table(Lglmstep.pred , spam.test[,58],  .5)
score.table(Lglmstep.pred , spam.test[,58],  .6)
# Thresholds: .4, .5, .6


# PCR 
# test set prediction
# with predict.pc.glm()

pcr90.pred <- predict.pc.glm(spampcr.train90, spam.trainpca, ndata = spam.test[-58], type = "response")
Lpcr90.pred <- predict.pc.glm(Lspampcr.train90, Lspam.trainpca, ndata = Lspam.test[-58], type = "response")

pcr.pred <- predict.pc.glm(spampcr.train98, spam.trainpca, ndata = spam.test[,-58], type = "response")

#*****************************
#
#   ROC Curves
#
#*****************************
library(rocc)

png("rocc_models_performance.png")
plot.roc(glm.pred, Lspam.test[,58], main = "ROC Curve - SPAM Filter")

lines.roc(Lglm.pred, Lspam.test[,58], col = "orange")
lines.roc(glmstep.pred, spam.test[,58], col = "purple")
lines.roc(Lglmstep.pred, Lspam.test[,58], col = "green")
lines.roc(pcr90.pred, spam.test[,58], col = "red")
lines.roc(Lpcr90.pred, Lspam.test[,58], col ="darkorchid1")

# Add lines for step (purple), log step (green) and pcr (red)


legend(.65, .45, legend = c("Main", "Log", "StepMain", "StepLog", "PCR90", "LogPCR90"), lwd = 2, col = c("blue", "orange", "purple", "green", "red", "darkorchid1"))
dev.off()
#Log and Steplog are doing well
#Makes sense, since steplog is nested from log
#Choose steplog, since this is simpler

#Metric is AUC
#But this doesn't show tradeoff between neg/pos

#AUC's
library(ROCR)
auc.spam <- performance(prediction(glm.pred, spam.test[,58]), measure = "auc")
auc.Lspam <- performance(prediction(Lglm.pred, Lspam.test[,58]), measure = "auc")
auc.spamstep <- performance(prediction(glmstep.pred, spam.test[,58]), measure = "auc")
auc.Lspamstep <- performance(prediction(Lglmstep.pred, Lspam.test[,58]), measure = "auc")
auc.pcr90 <- performance(prediction(pcr90.pred, spam.test[,58]), measure = "auc")
auc.Lpcr90 <- performance(prediction(Lpcr90.pred, Lspam.test[,58]), measure = "auc")
auc.spam@y.values
auc.Lspam@y.values
auc.spamstep@y.values
auc.Lspamstep@y.values
auc.pcr90@y.values
auc.Lpcr90@y.values
# Now add a PCR model using the 
# log transformed data
# Look at its performance using a test and training
# set witht an ROC curve

spam.step <- step(spam.glm)
Lspam.step <- step(Lspam.glm)
score.table(pcr.pred, spam.test[,58],  .4)
score.table(Lglm.pred, spam.test[,58],  .5)
score.table(Lglm.pred, spam.test[,58],  .6)

