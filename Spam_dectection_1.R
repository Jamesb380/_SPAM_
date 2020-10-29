###James Bennett

source("SPM_Panel.R")
source("pc.glm.R")
source("PCAplots.R")
source("ROC.R")
source("FactorPlots.R")

url <- "http://archive.ics.uci.edu/ml/machine-learning-databases/spambase/spambase.data"
path <- getwd()
download.file(url, file.path(path, "spamdata.txt"))

Spam <- read.table("./spamdata.txt", header = F,sep = ",")

sum(Spam$V58) ###Spams

nrow(Spam) - sum(Spam$V58) ##hams


sum(Spam$V58)/nrow(Spam) ###portion of spam .394

png("hamvspam.png")
barplot(table(Spam[,58]),main = "Spam in the Data", xlab = "Classification of emails", names.arg = c("Ham", "Spam"), col = "magenta")
dev.off()
####Max of each variable
summary(Spam[,1:48])[6,]


###which vwork is more commonly used in Spam - V4
max(apply(Spam[,1:48], 2, max))
which(apply(Spam[,1:48], 2, max) == max(apply(Spam[,1:48], 2, max)))

max(apply(Spam[,49:58], 2, max))

which(apply(Spam[,49:58], 2, max) == max(apply(Spam[,49:58], 2, max)))



# Obtain boxplots with variables 1-9 vs. the response.
# These are also called factor plots
# Which variable are more discriminatory?

# Variables 1-9
png("boxplot1_9.png")
par(mfrow = c(3,3))
for(i in 1:9)
{
        boxplot(Spam[,i]~Spam[,"V58"], xlab = "Type of Email", ylab = "Count", main = paste("Variable", i))	
}
par(mfrow = c(1,1))
dev.off()

png("boxplot49_57.png")
par(mfrow = c(3,3))
for(i in 49:57)
{
        boxplot(Spam[,i]~Spam[,58], xlab = "Type of Email", ylab = "Count", main = paste("Variable", i))	
}
par(mfrow = c(1,1))
dev.off()


#*****************************
#
# 	 Plots with log transform
#	
#*****************************


# Log transform of the variables
# offset of 0.01
#Offset removes zero values -> can't do log of zero
#Creating 'equivalent of zero'
Lspam <- log(Spam[,1:57]+0.01)
# Add the response to the data frame
#This is col 58
Lspam$V58 <- Spam$V58

# Check with summary()
summary(Lspam$V58)

# Scatter plot matrices with 
# log transform of variables 1-8, 58
# use uva.pairs()
png("scatterlog1_8v58.png")
uva.pairs(Lspam[,c(1:8, 58)])
dev.off()
#Here we want an s shape
#V7 looks good
#So does V8

# Scatter plot matrices with 
# log transform of variables 48-58.
png("scatterlog47_57v58.png")
uva.pairs(Lspam[,c(47:57, 58)])
dev.off()
#Seeing collinearity



#Factor plots
# Variables 1-9
#THese are now more discriminatory since we've done log xform
png("factorplot1_9.png")
par(mfrow = c(3,3))
for(i in 1:9)
{
        boxplot(Lspam[,i]~Lspam[,58], xlab = "Type of Email", ylab = "Count", main = paste("Log Variable", i))	
}
dev.off()

par(mfrow = c(1,1))

# Variables 49-57
png("factorplot49_57.png")
par(mfrow = c(3,3))
for(i in 49:57)
{
        boxplot(Lspam[,i]~Lspam[,58], xlab = "Type of Email", ylab = "Count", main = paste("Log Variable", i))	
}
dev.off()

par(mfrow = c(1,1))

# Variables 20-25
png("factorplot20_25.png")
par(mfrow = c(3,3))
for(i in 20:25)
{
        boxplot(Lspam[,i]~Lspam[,58], xlab = "Type of Email", ylab = "Count", main = paste("Log Variable", i))	
}
dev.off()
par(mfrow = c(1,1))

#****************************************************
#
#		Principal Component Analysis
#
#****************************************************

# Obtain the principal components for variables 1-57. 
# Look at the biplot and explain what you see.

spam.pca = princomp(Spam[,1:57], cor = T)

# Get the biplot


# What is the outlier?

max(spam.pca$scores[,2])

which(spam.pca$scores[,2] == max(spam.pca$scores[,2]))


# What are the outlier's values for the variables
# that contribute to component 2?

summary(Spam[,which(abs(spam.pca$loadings[,2]) > 0.2)])

Spam[1754,which(abs(spam.pca$loadings[,2]) > 0.2)]

# What are the loadings for the primary variables
# in component 1?

summary(Spam[,which(abs(spam.pca$loadings[,1]) > 0.2)])

spam.pca$loadings[which(abs(spam.pca$loadings[,1]) > 0.2),1]
png("barplotloadings.png")
barplot(spam.pca$loadings[which(abs(spam.pca$loadings[,1]) > 0.2),1])
dev.off()
# Obtain the biplot.fact of your principal components.
# Explain what you see.

biplot.fact(spam.pca, Spam[,58])
png("biplot.png")
legend(-20, 0, legend = c("Spam", "Ham"), pch = c(18, 19), col = c("red", "blue"))
dev.off()
#Ham & spam are laregely separated from each other into different components
#Some intermix

# Repeat the principal component analysis for 
# the log transformed variables

Lspam.pca = princomp(Lspam[,1:57], cor = T)

biplot.fact(Lspam.pca, Lspam[,58])
png("biplotlogtrans.png")
legend(-8, 0, legend = c("Spam", "Ham"), pch = c(18, 19), col = c("red", "blue"))
dev.off()

#*****************************
#
# GLM
#`
#*****************************

# main effects model
#glm will default to gaussian if we don't define fam as binomial
spam.glm <- glm(V58~., data = Spam, family = binomial)
#Warning message: glm.fit: fitted probabilities numerically 0 or 1 occurred 
#This means we got a very close fit
#This is a good thing

# Summary
summary(spam.glm)
#Z value and p value are gaussian approximations
#Want to use chi squared instead
#Need to do model utility test


# model utility test
#H0 = all betas equal zero
#Need to make null model
#This null model predicts spam based on average (0.39)
spam.null <- glm(V58~1, data = Spam, family = binomial)
anova(spam.null, spam.glm, test = "Chi")
#Can reject null hypothesis that all B are zero


# Log transform
Lspam.glm <- glm(V58~., data = Lspam, family = binomial)


# model utility test for log transform
Lspam.null <- glm(V58~1, data = Lspam, family = binomial)
anova(Lspam.null, Lspam.glm, test = "Chi")
#again, passes




# parameter tests
# using likelihood ratio
# compare to Gaussian approximation

library(MASS)

drop1(spam.glm, test = "Chi")
#Compares model by dropping one term at a time
#Chi sq prob for significance of each variable
#Equivalent of t test, better than using Pr(z)
Lspam2.glm <- glm(V58~c(1:46), data = Lspam, family = binomial)

# compare to Gaussian approx
# given in summary


# repeat for log model
drop1(Lspam.glm, test = "Chi")

# can also use dropterm()

dropterm(spam.glm, test = "Chi")


#*****************************
#
# AIC and BIC Model comparisons
#
#*****************************

# Use AIC & BIC to compare the main effects
# model with no transformtion to the 
# main effects model with log transformed
# predictors

AIC(spam.glm)
AIC(Lspam.glm)

BIC(spam.glm)
BIC(Lspam.glm)

#Lspam does better on both AIC and BIC


