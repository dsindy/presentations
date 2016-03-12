install.packages("AppliedPredictiveModeling")
install.packages("lattice")
install.packages("Caret")
install.packages("earth")
install.packages("e1071")
install.packages("mlbench")
install.packages("proxy")
install.packages("gbm")
install.packages("pROC")


library(AppliedPredictiveModeling)
transparentTheme(trans = .4)

library(caret)
featurePlot(x = iris[, 1:4],
            y = iris$Species,
            plot = "pairs",
            ## Add a key at the top
            auto.key = list(columns = 3))


transparentTheme(trans = .9)
featurePlot(x = iris[, 1:4],
            y = iris$Species,
            plot = "density",
            ## Pass in options to xyplot() to 
            ## make it prettier
            scales = list(x = list(relation="free"),
                          y = list(relation="free")),
            adjust = 1.5,
            pch = "|",
            layout = c(4, 1),
            auto.key = list(columns = 3))



featurePlot(x = iris[, 1:4],
            y = iris$Species,
            plot = "box",
            ## Pass in options to bwplot() 
            scales = list(y = list(relation="free"),
                          x = list(rot = 90)),
            layout = c(4,1 ),
            auto.key = list(columns = 2))



featurePlot(x = BostonHousing[, regVar],
            y = BostonHousing$medv,
            plot = "scatter",
            type = c("p", "smooth"),
            span = .5,
            layout = c(3, 1))





# =-------------------------------------------


library(earth)
data(etitanic)
head(model.matrix(survived ~ ., data = etitanic))


data(mdrr)
data.frame(table(mdrrDescr$nR11))



nzv <- nearZeroVar(mdrrDescr, saveMetrics= TRUE)
nzv[nzv$nzv,][1:10,]


dim(mdrrDescr)


nzv <- nearZeroVar(mdrrDescr)
filteredDescr <- mdrrDescr[, -nzv]
dim(filteredDescr)


descrCor <-  cor(filteredDescr)
highCorr <- sum(abs(descrCor[upper.tri(descrCor)]) > .999)


descrCor <- cor(filteredDescr)
summary(descrCor[upper.tri(descrCor)])


highlyCorDescr <- findCorrelation(descrCor, cutoff = .75)
filteredDescr <- filteredDescr[,-highlyCorDescr]
descrCor2 <- cor(filteredDescr)
summary(descrCor2[upper.tri(descrCor2)])


ltfrDesign <- matrix(0, nrow=6, ncol=6)
ltfrDesign[,1] <- c(1, 1, 1, 1, 1, 1)
ltfrDesign[,2] <- c(1, 1, 1, 0, 0, 0)
ltfrDesign[,3] <- c(0, 0, 0, 1, 1, 1)
ltfrDesign[,4] <- c(1, 0, 0, 1, 0, 0)
ltfrDesign[,5] <- c(0, 1, 0, 0, 1, 0)
ltfrDesign[,6] <- c(0, 0, 1, 0, 0, 1)



comboInfo <- findLinearCombos(ltfrDesign)
comboInfo


ltfrDesign[, -comboInfo$remove]



# Centering and Scaling

set.seed(96)
inTrain <- sample(seq(along = mdrrClass), length(mdrrClass)/2)

training <- filteredDescr[inTrain,]
test <- filteredDescr[-inTrain,]
trainMDRR <- mdrrClass[inTrain]
testMDRR <- mdrrClass[-inTrain]

preProcValues <- preProcess(training, method = c("center", "scale"))

trainTransformed <- predict(preProcValues, training)
testTransformed <- predict(preProcValues, test)


# Imputation

library(AppliedPredictiveModeling)
transparentTheme(trans = .4)
plotSubset <- data.frame(scale(mdrrDescr[, c("nC", "X4v")]))
xyplot(nC ~ X4v,
       data = plotSubset,
       groups = mdrrClass,
       auto.key = list(columns = 2))



transformed <- spatialSign(plotSubset)
transformed <- as.data.frame(transformed)
xyplot(nC ~ X4v,
       data = transformed,
       groups = mdrrClass,
       auto.key = list(columns = 2))



preProcValues2 <- preProcess(training, method = "BoxCox")
trainBC <- predict(preProcValues2, training)
testBC <- predict(preProcValues2, test)
preProcValues2



# PUTTING TOGETHER


library(AppliedPredictiveModeling)
data(schedulingData)
str(schedulingData)

pp_hpc <- preProcess(schedulingData[,-1], method = c("center", "scale"))

pp_hpc


# ----------------------------

Data Splitting


# 

library(caret)
set.seed(3456)
trainIndex <- createDataPartition(iris$Species, p = .8,
                                  list = FALSE,
                                  times = 1)
head(trainIndex)


irisTrain <- iris[ trainIndex,]
irisTest  <- iris[-trainIndex,]



library(mlbench)

data(BostonHousing)

testing <- scale(BostonHousing[, c("age", "nox")])
set.seed(5)
## A random sample of 5 data points
startSet <- sample(1:dim(testing)[1], 5)
samplePool <- testing[-startSet,]
start <- testing[startSet,]
newSamp <- maxDissim(start, samplePool, n = 20)
head(newSamp)



#-----------------------------

# Model Performance


library(mlbench)
data(Sonar)
str(Sonar[, 1:10])


library(caret)
library(pROC)

set.seed(998)
inTraining <- createDataPartition(Sonar$Class, p = .75, list = FALSE)
training <- Sonar[ inTraining,]
testing  <- Sonar[-inTraining,]


fitControl <- trainControl(## 10-fold CV
  method = "repeatedcv",
  number = 10,
  ## repeated ten times
  repeats = 10)


set.seed(825)
gbmFit1 <- train(Class ~ ., data = training,
                 method = "gbm",
                 trControl = fitControl,
                 ## This last option is actually one
                 ## for gbm() that passes through
                 verbose = FALSE)
gbmFit1


gbmGrid <-  expand.grid(interaction.depth = c(1, 5, 9),
                        n.trees = (1:30)*50,
                        shrinkage = 0.1,
                        n.minobsinnode = 20)

nrow(gbmGrid)

set.seed(825)
gbmFit2 <- train(Class ~ ., data = training,
                 method = "gbm",
                 trControl = fitControl,
                 verbose = FALSE,
                 ## Now specify the exact models 
                 ## to evaluate:
                 tuneGrid = gbmGrid)
gbmFit2


trellis.par.set(caretTheme())
plot(gbmFit2)



trellis.par.set(caretTheme())
plot(gbmFit2, metric = "Kappa")


trellis.par.set(caretTheme())
plot(gbmFit2, metric = "Kappa", plotType = "level",
     scales = list(x = list(rot = 90)))


ggplot(gbmFit2)


head(twoClassSummary)




fitControl <- trainControl(method = "repeatedcv",
                           number = 10,
                           repeats = 10,
                           ## Estimate class probabilities
                           classProbs = TRUE,
                           ## Evaluate performance using 
                           ## the following function
                           summaryFunction = twoClassSummary)

set.seed(825)
gbmFit3 <- train(Class ~ ., data = training,
                 method = "gbm",
                 trControl = fitControl,
                 verbose = FALSE,
                 tuneGrid = gbmGrid,
                 ## Specify which metric to optimize
                 metric = "ROC")
gbmFit3



testPred <- predict(gbmFit3, testing)
postResample(testPred, testing$Class)




whichTwoPct <- tolerance(gbmFit3$results, metric = "ROC",
                         tol = 2, maximize = TRUE)
cat("best model within 2 pct of best:\n")






