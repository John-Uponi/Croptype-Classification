library(terra)
library(devtools)
library(caret)
library(raster)
library(RStoolbox)
library(lattice)
library(caretEnsemble)
library(randomForest)
library(mlbench)
library(dplyr)
library(ModelMetrics)
library(data.table)
library(Boruta)


#SAR and Sentinel 2 data combined##########
SAR2bb <- rast("T:/Projects/Project2024/CroptypeMapping/New SAR S2 analysis/SAR_SARmean_S2_2022_combined_2.tif")

################Training Polygon###########
v <- vect("T:/Projects/Project2024/CroptypeMapping/New SAR S2 analysis/new_training2025/adjusted_training_samples_planet2024b_Multipart2.shp")

#### Divide polygons into train and test###
set.seed(1)
#convert spatvector to dataframe
dfv3 <- as.data.frame(v, row.names=NULL, optional=FALSE, geom=NULL)
dfv3d <- dfv3


#Use 70% of dataset as training set and remaining 30% as testing set
dfv3f <- sample(c(TRUE, FALSE), nrow(dfv3d), replace=TRUE, prob=c(0.7,0.3))
train  <- dfv3d[dfv3f, ]
test   <- dfv3d[!dfv3f, ]
train$testdata <- 0
test$testdata <- 1
df_merge <- rbind(train,test)
df_merge2 <- df_merge[,c("ORIG_FID","testdata")]

#merge table with testdata to spatvector 
v3a1 <- merge(v, df_merge2, by.x = "ORIG_FID", by.y = "ORIG_FID")
new_training_SAR_sen2_oyo <- extract(SAR2bb,v3a1,df=TRUE)
df4 <- new_training_SAR_sen2_oyo
df4$Class <- as.factor(v3a1$Classname[df4$ID])
df4$TestData <- as.factor(v3a1$testdata[df4$ID])
df4a <-df4[complete.cases(df4),]

outdir <- "T:/Projects/Project2024/CroptypeMapping/New SAR S2 analysis/NewCM2025"

write.csv(df4a,file.path(outdir,"SAR_SARmean_S2_new_training2025_all.csv"))
df4a <- read.csv("T:/Projects/Project2024/CroptypeMapping/New SAR S2 analysis/SAR_SARmean_S2_new_training2025_all.csv")
#write.csv(df4a,"T:/Projects/Project2024/CroptypeMapping/New SAR S2 analysis/SAR_SARmean_S2_new_training2024_all.csv")

df1 <- df4a
df1_split <-split(df1,df1$TestData)
df1_test <-df1_split$`1`
df1_train <- df1_split$`0`
dim(df1_test)
dim(df1_train)

names(df1_test)

#All
df1_test <- df1_test[c(2:43)]
df1_train <- df1_train[c(2:43)] 

#S2
df1_test <- df1_test[c(2,33:43)]
df1_train <- df1_train[c(2,33:43)]


#SAR only
df1_test <- df1_test[c(3:32,43)]
df1_train <- df1_train[c(3:32,43)]

df1_test1 <-df1_test[,2:42]
df1_train1 <-df1_train[,2:42]
tundata <- df1_train1

names(df1_test1)

df1_test1$Class <- as.factor(df1_test1$Class)

##### Modelling starts
seed <-7
# try ensembles models
trainControl <- trainControl(method="repeatedcv", number=10, repeats=3)
metric <- "Accuracy"
TestData <-dfs_test1 
set.seed(seed)

startrfmodel <- Sys.time()#Catching start time for RF
fit.rf1 <- train(Class~., data= df1_train1, method="ranger", metric=metric, preProc=c("BoxCox"),
                 trControl=trainControl)

endrfmodel <- Sys.time()
endrfmodel-startrfmodel # Computing time for RF model
saveRDS(fit.rf1,("T:/Projects/Project2024/CroptypeMapping/New SAR S2 analysis/NewCM2025/fit_rf1_2025_SAR_SARmean_S2_all5.rds"))

##### Testing & Prediction
rfranger.predict<- predict(fit.rf1,TestData[,-41 ])
confusionMatrix <- caret::confusionMatrix(rfranger.predict,df1_test1$Class)
capture.output(confusionMatrix, file="T:/Projects/Project2024/CroptypeMapping/New SAR S2 analysis/NewCM2025/SAR_SARmean_S2_confusionMatrix2025e.txt")
predict(SAR2bb, fit.rf1, overwrite=TRUE, na.rm=TRUE, filename="T:/Projects/Project2024/CroptypeMapping/New SAR S2 analysis/NewCM2025/rf_Oyo_prediction_SAR_SARmean_S2_2025e.tif")

