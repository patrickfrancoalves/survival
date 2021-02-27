#-----------------------------------------------------------------------#
#---            Modelos de Machine Learning e AvaliaÃ§Ã£o PSM          ---#
#-----------------------------------------------------------------------#
#install.packages("caret")

options(digits = 3, scipen = 9) 
library(DBI)
library(odbc)
library(dplyr)
library(mlbench)
library(caret)
library(haven)

remove(AI_CENPES_LATTES,AI_PETRO_PETRO,AI_PETRO_LATTES,df,DICT,
       example.df,example.df1,TRAT_CENPES_LATTES,TRAT_PETRO_PETRO,
       TRAT_PETRO_LATTES,dicion,x,fn,digitsByRows)

#-----------------------------------------------------------------------#
#---              Passo 01: ConexÃ£o ODBC com servidor                ---#
#-----------------------------------------------------------------------#

# conectando
con      <- dbConnect(odbc::odbc() , dsn="LATTES")
result   <- dbSendQuery(con , "SELECT * FROM [LATTES].[SAS].[TABELA-DINAMICAW]
                               WHERE (ARTIGO+PROD_TEC+CURSO+ORIENT+BANCA)>0")

# load the dataset
tabpetro <- dbFetch(result)

# Tamanho : 923,812,976 bytes 
# Linhas: 730,065,517
object.size(tabpetro)     

# desconectando
dbDisconnect(con)


#-----------------------------------------------------------------------#
#---              Passo 02: Tratamento das variáveis                 ---#
#-----------------------------------------------------------------------#


estaticos <- read_sas("GitHub/survival/redes/estaticos.sas7bdat")
names(estaticos)


estaticos2 <- estaticos %>% mutate(PETRO_PETRO    =factor(PETRO_PETRO)  , 
                                   PETRO_LATTES   =factor(PETRO_LATTES) , 
                                   CENPES_LATTES  =factor(CENPES_LATTES), 
                                   PETRO_LAB      =factor(PETRO_LAB)    , 
                                   CENPES_LATTES  =factor(CENPES_LATTES), 
                                   ANP_LATTES     =factor(ANP_LATTES)   , 
                                   ANP_ANP        =factor(ANP_ANP)      , 
                                   UF_NASCN       =factor(UF_NASCN)     ,
                                   LOCAL_FORMACN  =factor(LOCAL_FORMACN),
                                   GRANDE_AREAN   =factor(GRANDE_AREAN) , 
                                   DIRECAO        =factor(DIRECAO)      ,
                                   SEXON          =factor(SEXON)        ,
                                   VINCULON       =factor(VINCULON) ) %>% 
  select(c(PETRO_PETRO,PETRO_LATTES,CENPES_LATTES,PETRO_LAB,CENPES_LATTES,
           ANP_LATTES,ANP_ANP,UF_NASCN,LOCAL_FORMACN,GRANDE_AREAN,DIRECAO,
           SEXON,VINCULON,LN_IDADE,LN_COAUTOR,LN_LOC_TRAB,LN_CAPES))


 
#-----------------------------------------------------------------------#
#---              Passo 03: Prepare the Training scheme              ---#
#-----------------------------------------------------------------------#

 
control <- trainControl(method="repeatedcv", number=4, repeats=4)

#-----------------------------------------------------------------------#
#---              Passo 02: Treinamento do PETRO_PETRO               ---#
#-----------------------------------------------------------------------#

# CART
set.seed(7)
fit.cart <- train( PETRO_PETRO ~ UF_NASCN+LOCAL_FORMACN+GRANDE_AREAN+DIRECAO+SEXON+ 
                                 VINCULON+LN_IDADE+LN_COAUTOR+LN_LOC_TRAB+LN_CAPES , 
                                 data=estaticos2,method="rpart",trControl=control)


# LDA
set.seed(7)
fit.lda <- train( PETRO_PETRO ~ UF_NASCN+LOCAL_FORMACN+GRANDE_AREAN+DIRECAO+SEXON + 
                                VINCULON+LN_IDADE+LN_COAUTOR+LN_LOC_TRAB+LN_CAPES , 
                                data=estaticos2,method="lda",trControl=control)


# SVM
set.seed(7)
fit.svm <- train( PETRO_PETRO ~ UF_NASCN+LOCAL_FORMACN+GRANDE_AREAN+DIRECAO+SEXON + 
                                VINCULON+LN_IDADE+LN_COAUTOR+LN_LOC_TRAB+LN_CAPES , 
                                data=estaticos2,method="svmRadial",trControl=control)

# kNN
set.seed(7)
fit.knn <- train( PETRO_PETRO ~ UF_NASCN+LOCAL_FORMACN+GRANDE_AREAN+DIRECAO+SEXON + 
                                VINCULON+LN_IDADE+LN_COAUTOR+LN_LOC_TRAB+LN_CAPES , 
                                data=estaticos2,method="knn",trControl=control)


# Random Forest
set.seed(7)
fit.rf <- train( PETRO_PETRO ~ UF_NASCN+LOCAL_FORMACN+GRANDE_AREAN+DIRECAO+SEXON + 
                               VINCULON+LN_IDADE+LN_COAUTOR+LN_LOC_TRAB+LN_CAPES , 
                                data=estaticos2,method="rf",trControl=control)



# collect resamples
results <- resamples(list(CART=fit.cart, LDA=fit.lda, SVM=fit.svm, KNN=fit.knn, RF=fit.rf))




#-----------------------------------------------------------------------#
#---              Passo 02: Treinamento do PETRO_LATTES               ---#
#-----------------------------------------------------------------------#

# CART
set.seedPETRO_LATTES
fit.cart <- train( PETRO_PETRO ~ UF_NASCN+LOCAL_FORMACN+GRANDE_AREAN+DIRECAO+SEXON+ 
                     VINCULON+LN_IDADE+LN_COAUTOR+LN_LOC_TRAB+LN_CAPES , 
                   data=estaticos2,method="rpart",trControl=control)

#PETRO_LATTES,CENPES_LATTES,PETRO_LAB,CENPES_LATTES,ANP_LATTES,ANP_ANP,

#---------------------------------------------------------------------------------#
#--                      Difference-in-Differences                              --#
#--  https://www.analyticsvidhya.com/blog/2016/01/xgboost-algorithm-easy-steps/ --#
#---------------------------------------------------------------------------------#

library(Matrix)
library(randomForest)
library(haven)
library(xgboost)
library(tidyverse)
library(caret)
library(did)

painel <- read_sas("//sbsb2/DPTI/Usuarios/Patrick Alves/Denegri/painel.sas7bdat")


names(painel)


prop.table(table(as.factor(painel$particao))) 


trash <- c("particao","CONTRATOS","PO_TGRAU","PO_FEMININO","PO_EXTRANG","REN_MEDIA",
           "CNAE10","PESQ","ENG","CIEN","exp","estrato_cepal","estrato_ocde1",
           "estrato_ocde2","estrato_ocde3","estrato_ocde4","prop_eng","prop_cien")


painelx <- painel %>% filter(dexp!=2) %>% select(-trash) %>% 
  mutate(partiu = case_when(fator_aleatorio <= 70 ~ "TRAIN", fator_aleatorio > 70 ~"TEST"))


prop.table(table(as.factor(painelx$partiu))) 

#https://www.kaggle.com/jijosunny/xgboost-in-r-randomforest
#Inspired from Xgboonst benchmark 0.38019 by Devin. (diff)

features = c("TEMP_ESTUD_MED","EXPERIENCIA_MED","ROTATIVIDADE","SHARE","FILIAIS",
             "NATJUR","UF","prop_3g","prop_fem","prop_extr","lpot","lmsal","ano",
             "cnae20_3d","IDADE_MED","imp","bndes","partiu","lesc","dexp")

#------------------------------------------------------------------------#
#---                    One-hot-encoding features                     ---#
#------------------------------------------------------------------------#
library(ade4)
ohe_feats = c("cnae20_3d","NATJUR","UF")

for (f in ohe_feats){
  df_all_dummy = acm.disjonctif(painelx[f] %>% as.matrix())
  painelx[f] = NULL
  painelx = cbind(painelx, df_all_dummy)
}


out_features = c("CNAE20","EMPR_ANOS","MSAL","multi","taxa_po","taxa_esc","setor",
                 "taxa_potec","estrato_ocde","fator_aleatorio","lpotec","partiu")


train <- painelx %>% filter((partiu=='TRAIN') & (dexp!=2)) %>% select(-out_features)  
test  <- painelx %>% filter((partiu=='TEST') & (dexp!=2)) %>% select(-out_features) 
names(train)

# Transform the two data sets into xgb.Matrix
xgb.train = xgb.DMatrix(data=train %>% select(-dexp,-EMPRESA) %>% as.matrix , label=train$dexp %>% as.matrix)
xgb.test  = xgb.DMatrix(data=test %>% select(-dexp,-EMPRESA) %>% as.matrix, label=test$dexp %>% as.matrix)


# Write to the log:
cat(sprintf("Training set has %d rows and %d columns\n", nrow(train), ncol(train)))
cat(sprintf("Test set has %d rows and %d columns\n", nrow(test), ncol(test)))



#------------------------------------------------------------------------#
#---                   Train the XGBoost classifer                    ---#
#------------------------------------------------------------------------#

xgb.fit <- xgb.train(data = xgb.train, nrounds = 300, booster="gbtree", max_depth=6,
                     min_child_weight=2, subsample=0.75 , gamma=666 , eta=0.03,
                     watchlist = list(val=xgb.test,train=xgb.train), alpha=0.9,
                     colsample_bytree=0.7, objective="binary:logistic",
                     early_stopping_rounds = 10 , eval_metric = "auc")



xgb.fit$best_iteration
xgb.fit$handle
xgb.fit$best_ntreelimit
xgb.fit$evaluation_log
xgb.fit$raw
xgb.fit$params


predicted = predict(xgb.fit, xgb.test)
dexp_predicted = case_when(predicted <= 0.5 ~ 0, predicted > 0.5 ~ 1 )

residuals = test$dexp - dexp_predicted
RMSE = sqrt(mean(residuals^2))
cat('The root mean square error of the test data is ', round(RMSE,3),'\n')



#------------------------------------------------------------------------#
#---          confusion matrix and accuracy statistics                ---#
#------------------------------------------------------------------------#

library(caret)
confusionMatrix(as.factor(test$dexp),as.factor(dexp_predicted))

table(dexp_predicted)
table(test$dexp)


xgb.all = xgb.DMatrix(data=painelx %>% select(-out_features,-dexp,-EMPRESA) %>% as.matrix, label=painelx$dexp %>% as.matrix)


pred_all = predict(xgb.fit, xgb.all)

dexp_pred_all = case_when(pred_all <= 0.5 ~ 0, pred_all > 0.5 ~ 1 )

sum(table(dexp_pred_all))
sum(table(painelx$dexp))

confusionMatrix(as.factor(painelx$dexp),as.factor(dexp_pred_all))


#------------------------------------------------------------------------#
#---                   predicted probabilities                    ---#
#------------------------------------------------------------------------#


painelxx = cbind(painel %>% select(-fator_aleatorio,-trash) %>% filter(dexp!=2) , pred_all)


painelxx = painelxx %>%  mutate(pesow = case_when(dexp > 0 ~ pred_all^-1 , dexp <=0 ~ (1-pred_all)^-1 )) 


names(painelxx)

#------------------------------------------------------------------------#
#---                   Difference-in-Differences                      ---#
#------------------------------------------------------------------------#


model = lm(taxa_potec ~ dexp + SHARE + lmsal + FILIAIS + ROTATIVIDADE + lage + prop_extr + imp + 
             lpo_Tgrau + prop_fem + as.factor(ano) + as.factor(estrato_ocde) , 
           weights=pesow , data = painelxx)
#
#taxa_po taxa_esc
summary(model)






 