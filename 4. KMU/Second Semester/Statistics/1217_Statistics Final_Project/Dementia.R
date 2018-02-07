install.packages("GPArotation")
install.packages("pROC")
install.packages("C50")
install.packages("ROCR")
install.packages("e1071")
install.packages("Epi")
install.packages("pROC")
library(psych)
library(GPArotation)
library(lattice)
library(caret)
library(C50)
library(ROCR)
library(e1071)
library(Epi)
library(pROC)
library(ggplot2)
library(scales)
library(plyr)
library(reshape2)
library(RColorBrewer)

# KDSQ:Korean Dementia Screen Questionnaire- 보호자용 설문지
# SIADL:Seoul Instrumental Activities of Daily Living- 도구적 일상생활능력평가지
# NPI:Neuropsychistric Inventory- 신경정신과적 증상 평가지
# MMSE:Meni-Mental State Examination- 환자용 평가지
# KGDS:Korean Geriatric Depression Scale- 한국형 노인우울증 평가지

NP_test <- read.csv("NP_test.csv", header = TRUE)

#범주형 자료 변환 
NP_test$Gender <- factor(NP_test$Gender, labels = c("Female", "Male")) #성별

NP_test$Dx <- factor(NP_test$Dx, labels = c("control", "MCI", "dementia")) #진단명 
NP_test$Dx1 <- factor(NP_test$Dx1, labels = c("control", "Cog dysfunc"))
NP_test$Dx2 <- factor(NP_test$Dx2, labels = c("control", "dementia"))

NP_test$Smoking <- factor(NP_test$Smoking, labels = c("none", "current smoker")) #기타 
NP_test$FHx_dementia <- factor(NP_test$FHx_dementia, labels = c("none", "Family history of dementia"))
NP_test$Diabetes <- factor(NP_test$Diabetes, labels = c("none", "Diabetes mellitus"))
NP_test$HTN <- factor(NP_test$HTN, labels = c("none", "Hypertension"))
NP_test$Dyslipid <- factor(NP_test$Dyslipid, labels =c("none", "Dyslipidemia"))
NP_test$Heart <- factor(NP_test$Heart, labels = c("none", "Heart disease"))
NP_test$Stroke <- factor(NP_test$Stroke, labels = c("none", "Stroke"))

# Smoking:current smoker; FHx_dementia:치매 가족력; Diabetes:당뇨병; 
# HTN:고혈압; Dyslipid:고지혈증; Heart:심장병; Stroke:뇌졸중
colnames(NP_test)

table(NP_test$Dx)

xtabs(~Dx + Smoking, data=NP_test)

##################
##### SAMPLE #####
##################

## 1-1. 분석대상자의 인구학적 특성 
summary(NP_test[,c(3:8, 10:15)]) #진단명, 성별/교육/나이, 위험인자 분포 

## 1-2. 주요 인지기능검사 분포 
summary(NP_test[,c(89,106:109)]) #MMSE[,89], MMSE-R[,110]

par(mfrow = c(1, 5))
hist(NP_test[,89], main="", xlab="MMSE")
abline(v=mean(NP_test[,89]), lty=3, col="red")
hist(NP_test[,106], main="", xlab="KDSQ")
abline(v=mean(NP_test[,106]), lty=3, col="red")
hist(NP_test[,107], main="", xlab="SIADL")
abline(v=mean(NP_test[,107]), lty=3, col="red")
hist(NP_test[,108], main="", xlab="NPI")
abline(v=mean(NP_test[,108]), lty=3, col="red")
hist(NP_test[,109], main="", xlab="KGDS")
abline(v=mean(NP_test[,109]), lty=3, col="red")

## 1-3. 진단명에 따른 Hist + 평균 
mmse.mu <- ddply(NP_test[,c(3,89)], "Dx", summarise, grp.mean=mean(MMSE))
ggplot(NP_test[,c(3,89)], aes(x=MMSE, fill=Dx, color=Dx)) +
  geom_histogram(alpha=0.5, position="identity", bins = 30)
p <- ggplot(NP_test[,c(3,89)], aes(x=MMSE, fill=Dx, color=Dx)) +
  geom_histogram(position="identity", alpha=0.5, bins = 30)
p+geom_vline(data=mmse.mu, aes(xintercept=grp.mean, color=Dx),
             linetype="dashed")

kdsq.mu <- ddply(NP_test[,c(3,106)], "Dx", summarise, grp.mean=mean(KDSQ_total))
ggplot(NP_test[,c(3,106)], aes(x=KDSQ_total, fill=Dx, color=Dx)) +
  geom_histogram(alpha=0.5, position="identity",bins = 30)
p <- ggplot(NP_test[,c(3,106)], aes(x=KDSQ_total, fill=Dx, color=Dx)) +
  geom_histogram(position="identity", alpha=0.5, bins = 30)
p+geom_vline(data=kdsq.mu, aes(xintercept=grp.mean, color=Dx),
             linetype="dashed")

siadl.mu <- ddply(NP_test[,c(3,107)], "Dx", summarise, grp.mean=mean(SIADL_total))
ggplot(NP_test[,c(3,107)], aes(x=SIADL_total, fill=Dx, color=Dx)) +
  geom_histogram(alpha=0.5, position="identity",bins = 20)
p <- ggplot(NP_test[,c(3,107)], aes(x=SIADL_total, fill=Dx, color=Dx)) +
  geom_histogram(position="identity", alpha=0.5, bins = 20)
p+geom_vline(data=siadl.mu, aes(xintercept=grp.mean, color=Dx),
             linetype="dashed")

npi.mu <- ddply(NP_test[,c(3,108)], "Dx", summarise, grp.mean=mean(NPI_total))
ggplot(NP_test[,c(3,108)], aes(x=NPI_total, fill=Dx, color=Dx)) +
  geom_histogram(alpha=0.5, position="identity",bins = 15)
p <- ggplot(NP_test[,c(3,108)], aes(x=NPI_total, fill=Dx, color=Dx)) +
  geom_histogram(position="identity", alpha=0.5, bins = 15)
p+geom_vline(data=npi.mu, aes(xintercept=grp.mean, color=Dx),
             linetype="dashed")

kgds.mu <- ddply(NP_test[,c(3,109)], "Dx", summarise, grp.mean=mean(KGDS_total))
ggplot(NP_test[,c(3,109)], aes(x=KGDS_total, fill=Dx, color=Dx)) +
  geom_histogram(alpha=0.5, position="identity",bins = 15)
p <- ggplot(NP_test[,c(3,109)], aes(x=KGDS_total, fill=Dx, color=Dx)) +
  geom_histogram(position="identity", alpha=0.5, bins = 15)
p+geom_vline(data=kgds.mu, aes(xintercept=grp.mean, color=Dx),
             linetype="dashed")



##################
#### Diagnosis ###
##################

## 2-1. 진단명에 따른 clinical findings (1)
par(mfrow = c(1, 3))

#성별
plot(prop.table(table(NP_test$Dx, NP_test$Gender),1), type="h", col=c("white", "grey"),
     main="Gender")
chisq.test(table(NP_test$Gender, NP_test$Dx))

#나이
boxplot(Age~Dx, data=NP_test, main="Age")
out=aov(Age~Dx, data=NP_test)
summary(out)
TukeyHSD(out)

#학력
boxplot(Education~Dx, data=NP_test, main="Education")
out=aov(Education~Dx, data=NP_test)
summary(out)
TukeyHSD(out)


## 2-2. 진단명에 따른 clinical findings (2)
par(mfrow = c(2, 4))
plot(prop.table(table(NP_test$Dx, NP_test$Smoking),1), type="h", col=c("white", "grey"),
     main="Smoking")
plot(prop.table(table(NP_test$Dx, NP_test$FHx_dementia),1), type="h", col=c("white", "grey"),
     main="Family history of Dementia")
plot(prop.table(table(NP_test$Dx, NP_test$Diabetes),1), type="h", col=c("white", "grey"),
     main="Diabetic mellitus")
plot(prop.table(table(NP_test$Dx, NP_test$HTN),1), type="h", col=c("white", "grey"),
     main="Hypertension")
plot(prop.table(table(NP_test$Dx, NP_test$Dyslipid),1), type="h", col=c("white", "grey"),
     main="Dyslipidemia")
plot(prop.table(table(NP_test$Dx, NP_test$Heart),1), type="h", col=c("white", "grey"),
     main="Heart")
plot(prop.table(table(NP_test$Dx, NP_test$Stroke),1), type="h", col=c("white", "grey"),
     main="Stroke")
chisq.test(table(NP_test$Smoking, NP_test$Dx))
chisq.test(table(NP_test$FHx_dementia, NP_test$Dx))
chisq.test(table(NP_test$Diabetes, NP_test$Dx))
chisq.test(table(NP_test$HTN, NP_test$Dx))
chisq.test(table(NP_test$Dyslipid, NP_test$Dx))
chisq.test(table(NP_test$Heart, NP_test$Dx))
chisq.test(table(NP_test$Stroke, NP_test$Dx))


## 2-3. 진단명에 따른 인지기능검사
par(mfrow = c(1, 5))

#MMSE
boxplot(MMSE~Dx, data=NP_test, main="MMSE")
out=aov(MMSE~Dx, data=NP_test)
summary(out)
TukeyHSD(out)

#KDSQ
boxplot(KDSQ_total~Dx, data=NP_test, main="KDSQ")
out=aov(KDSQ_total~Dx, data=NP_test)
summary(out)
TukeyHSD(out)

#SIADL
boxplot(SIADL_total~Dx, data=NP_test, main="SIADL")
out=aov(SIADL_total~Dx, data=NP_test)
summary(out)
TukeyHSD(out)

#NPI
boxplot(NPI_total~Dx, data=NP_test, main="NPI")
out=aov(NPI_total~Dx, data=NP_test)
summary(out)
TukeyHSD(out)

#KGDS
boxplot(KGDS_total~Dx, data=NP_test, main="KGDS")
out=aov(KGDS_total~Dx, data=NP_test)
summary(out)
TukeyHSD(out)

##################
#### 요인분석 ####
##################

## 3-1. MMSE의 Factor analysis를 통한 structure확인
par(mfrow = c(1, 1))
(MMSE_fa <- fa(scale(NP_test[59:88]),8))
fa.diagram(MMSE_fa, sort=FALSE)

## 3-2. KDSQ의 Factor analysis를 통한 structure확인 
(KDSQ_fa <- fa(scale(NP_test[17:31]),3))
fa.diagram(KDSQ_fa, sort=FALSE)

## 3-3. NPI의 Factor analysis를 통한 structure확인
(NPI_fa <- fa(scale(NP_test[47:58]),6))
fa.diagram(NPI_fa, sort=FALSE)





##################
#### 회귀분석 ####
##################

## 4-1. Demographic data와 MMSE의 관계
cor.test(NP_test$Age, NP_test$MMSE)
cor.test(NP_test$Education, NP_test$MMSE)
pairs.panels(NP_test[,c(7,8,89)])

var.test(MMSE~Gender, data=NP_test)
t.test(MMSE~Gender,data=NP_test)

par(mfrow = c(2, 3))
smoothScatter(NP_test$Age, NP_test$MMSE, xlab="Age", ylab="MMSE")
smoothScatter(NP_test$Education, NP_test$MMSE, xlab="Education", ylab="")
boxplot(MMSE~Gender, data=NP_test)

summary(lm (MMSE ~ Age + Education + Gender, data=NP_test)) #다중회귀분석 


## 4-2. Demographic data와 KDSQE의 관계
cor.test(NP_test$Age, NP_test$KDSQ_total)
cor.test(NP_test$Education, NP_test$KDSQ_total)
pairs.panels(NP_test[,c(7,8,106)])

var.test(KDSQ_total~Gender, data=NP_test)
t.test(KDSQ_total~Gender,data=NP_test)

par(mfrow = c(2, 3))
smoothScatter(NP_test$Age, NP_test$KDSQ_total, xlab="Age", ylab="KDSQ")
smoothScatter(NP_test$Education, NP_test$KDSQ_total, xlab="Education", ylab="")
boxplot(KDSQ_total~Gender, data=NP_test)

summary(lm (KDSQ_total ~ Age + Education, data=NP_test))


## 4-3. Demographic data와 SIAL의 관계
cor.test(NP_test$Age, NP_test$SIADL_total)
cor.test(NP_test$Education, NP_test$SIADL_total)
pairs.panels(NP_test[,c(7,8,107)])

var.test(SIADL_total~Gender, data=NP_test)
t.test(SIADL_total~Gender,data=NP_test, var.equal=TRUE)

par(mfrow = c(2, 3))
smoothScatter(NP_test$Age, NP_test$SIADL_total, xlab="Age", ylab="SIADL")
smoothScatter(NP_test$Education, NP_test$SIADL_total, xlab="Education", ylab="")
boxplot(SIADL_total~Gender, data=NP_test)

summary(lm (SIADL_total ~ Age + Education, data=NP_test))


## 4-4. Demographic data와 NPI의 관계
cor.test(NP_test$Age, NP_test$NPI_total)
cor.test(NP_test$Education, NP_test$NPI_total)
pairs.panels(NP_test[,c(7,8,108)])

var.test(NPI_total~Gender, data=NP_test)
t.test(NPI_total~Gender,data=NP_test, var.equal=TRUE)

par(mfrow = c(2, 3))
smoothScatter(NP_test$Age, NP_test$NPI_total, xlab="Age", ylab="NPI")
smoothScatter(NP_test$Education, NP_test$NPI_total, xlab="Education", ylab="")
boxplot(NPI_total~Gender, data=NP_test)

summary(lm (NPI_total ~ Age + Education, data=NP_test))


## 4-5. Demographic data와 KGDS의 관계
cor.test(NP_test$Age, NP_test$KGDS_total)
cor.test(NP_test$Education, NP_test$KGDS_total)
pairs.panels(NP_test[,c(7,8,109)])

var.test(KGDS_total~Gender, data=NP_test)
t.test(KGDS_total~Gender,data=NP_test)

par(mfrow = c(2, 3))
smoothScatter(NP_test$Age, NP_test$KGDS_total, xlab="Age", ylab="KGDS")
smoothScatter(NP_test$Education, NP_test$KGDS_total, xlab="Education", ylab="")
boxplot(KGDS_total~Gender, data=NP_test)

summary(lm (KGDS_total ~ Education, data=NP_test))





##################
#### 판별분석 ####
##################

## 5-1. 인지기능검사도구의 Tree모형
#Dx: control, MCI, dementia
NP_tools <-cbind(NP_test[c(3,6:8, 10:58,89,91:105)])
c5_options <- C5.0Control(winnow=TRUE, noGlobalPruning=FALSE, CF=0.010)
c5_model <- C5.0(Dx ~ ., data=NP_tools, control=c5_options, rules=FALSE, levels=1)
summary(c5_model)
plot(c5_model)

NP_pred <- predict(c5_model, NP_tools, type="class")
confusionMatrix(NP_pred, NP_tools$Dx)

## 5-2. 인지기능검사도구의 Tree모형
#Dx1: control, Cog dysfunc
NP_tools1 <-cbind(NP_test[c(4,6:8, 10:58,89,91:105)])
c5_options1 <- C5.0Control(winnow=TRUE, noGlobalPruning=FALSE, CF=0.010)
c5_model1 <- C5.0(Dx1 ~ ., data=NP_tools1, control=c5_options, rules=FALSE, levels=1)

summary(c5_model1)
plot(c5_model1)

NP_pred1 <- predict(c5_model1, NP_tools1, type="class")
NP_pred1_prob <- predict(c5_model, NP_tools1, type="prob")
NP_pred1_ROC <- prediction(NP_pred_prob[,2], NP_tools1$Dx1)
confusionMatrix(NP_pred1, NP_tools1$Dx1, positive = "Cog dysfunc")
ROC(form=NP_tools1$Dx1~NP_pred1_prob[,2], plot="ROC")

##5-3.기존 도구와의 비교 
NP_tools1$Dx_MMSE <- ifelse(NP_tools1$MMSE>=20, 1, 2) #MMSE의 기준점 
ROC(form=NP_tools1$Dx1~NP_tools1$Dx_MMSE, plot="ROC")

roc1 <- roc(NP_tools1$Dx1, NP_pred1_prob[,2])
roc2 <- roc(NP_tools1$Dx1, NP_tools1$Dx_MMSE)
roc.test(roc1, roc2) #2개의 ROC 비교 