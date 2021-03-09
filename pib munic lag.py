# -*- coding: utf-8 -*-
import requests
import pandas as pd
import numpy as np
import random
from geopy.geocoders import Nominatim
import os

# libraries for displaying images
from IPython.display import Image
from IPython.core.display import HTML
from IPython.display import HTML
from pandas.io.json import json_normalize
import warnings
warnings.filterwarnings("ignore")
warnings.filterwarnings(action="ignore",category=DeprecationWarning)
warnings.filterwarnings(action="ignore",category=FutureWarning)

pibma = pd.read_excel('PIB MUNICIPIOS 1999 2015.xlsx', sheet_name='PIB_MUNICIPIOS',usecols =[0,3,14])

pibma.columns.values


pibma.rename(columns={"cod_munic": "codigo"}, inplace=True)

pibma.groupby('ano').count()



pibmb = pd.read_excel('PIB MUNICIPIOS 2010 2016.xlsx', sheet_name = 'PIB_MUNICIPIOS',
usecols =[0,6,39],names =['ano','codigo','pib'])
pibmb.dtypes

'----------------------------------------------------'
'-- Veja tutorial sobre lags em um painel de dados --'
'----------------------------------------------------'
#https://towardsdatascience.com/timeseries-data-munging-lagging-variables-that-are-distributed-across-multiple-groups-86e0a038460c


pibmb[['codigo','ano']].groupby('ano').count()


pibmb.shape
pibmb.columns

'-----------------------------------------------------'
'---              Não rodar essa parte             ---'
'-----------------------------------------------------'
colunas = [pibmb.columns[0],pibmb.columns[6],pibmb.columns[39]]


colunas
pibmb[['Código do Município','Ano']].groupby('Ano').count()
pibm_reduzido = pibmb[colunas].copy()

pibm_reduzido.shape

novas_colunas = {"Ano":"ano",
                 "Código do Município": "codigo",
                 "Produto Interno Bruto, a preços correntes\n(R$ 1.000)": "pib"}

pibm_reduzido.rename(columns=novas_colunas, inplace=True)

pibm_reduzido.sort_values(by=["codigo","ano"], ascending=True).reset_index(inplace=True)
pibm_reduzido.head()
pibmy = pibm_reduzido.append(pibmx)

pibmy.groupby('ano').count()



'-----------------------------------------------------'
'---  Tentativa de usar outro método para os lags  ---'
'-----------------------------------------------------'

df = pibmb.append(pibma[pibma['ano']<2010])
df.groupby('ano').count()

df = df.set_index(["ano", "codigo"])


pib_list = []

for i in range(0, 17):
    pib_list.append(df.unstack().shift(i))
    pib_list[i] = pib_list[i].stack(dropna=True)
    pib_list[i].rename(columns={"pib": "pib_{0}".format(i)}, inplace=True)
    pib_list[i].reset_index(inplace=True)
    pib_list[i] = pib_list[i].loc[pib_list[i]['ano'] == 2016].dropna().copy()
    pib_list[i].set_index("codigo", inplace=True)
    pib_list[i].drop(columns=["ano"], inplace=True)

pib_list[4].head()

from functools import reduce
df_final = reduce(lambda left,right: pd.merge(left,right,on='codigo'), pib_list)

#pib_lags = pib_list[0].join(pib_list[1]).join(pib_list[2]).join(pib_list[3]).join(pib_list[4]).join(pib_list[5]).join(pib_list[6]).join(pib_list[7]).join(pib_list[8]).join(pib_list[9]).join(pib_list[10]).join(pib_list[11]).join(pib_list[12]).join(pib_list[13]).join(pib_list[14]).join(pib_list[15])

df_final.head(10)

#df_final.to_csv("pib_lags.csv")


distw = pd.read_csv('distw.csv')
distw.head()
distw.columns.values



distw.set_index('codigo1',inplace = True)

df_final = df_final.merge(distw,left_index=True,right_index=True)


df_final.columns


df_final.corr()


'-----------------------------------------------'
'---     Exemplo de Multilayer Perceptron    ---'
'-----------------------------------------------'

import re
r = re.compile(".*pib_")

newlist = list(filter(r.match, list(df_final.columns.values)))
newlist.remove('pib_0')


X = df_final[newlist]
y = df_final['pib_0']

X.shape

from sklearn.neural_network import MLPRegressor
import numpy as np
import matplotlib.pyplot as plt
import numpy as np
from sklearn import preprocessing
from sklearn.model_selection import train_test_split
from neupy import algorithms
from sklearn.preprocessing import MinMaxScaler
from sklearn.preprocessing import StandardScaler


#x_train, x_test, y_train, y_test = train_test_split(preprocessing.minmax_scale(X),
#preprocessing.minmax_scale(y),test_size=0.3)


x_train, x_test, y_train, y_test = train_test_split(preprocessing.minmax_scale(X),y,test_size=0.3)

nn = MLPRegressor(hidden_layer_sizes=(17,),  activation='relu', solver='adam',
alpha=0.0005,batch_size='auto', learning_rate='constant', learning_rate_init=0.0025,
power_t=0.5, shuffle=True, random_state=0, tol=0.0001, verbose=False,
warm_start=False,momentum=0.9, nesterovs_momentum=True,
validation_fraction=0.15,beta_1=0.9, beta_2=0.999, epsilon=1e-08)


n = nn.fit(x_train, y_train)
y_test_pred = n.predict(x_test)
print(np.corrcoef(y_test_pred, y_test))


y_all = nn.predict(preprocessing.minmax_scale(X))
print(np.corrcoef(y_all, preprocessing.minmax_scale(y)))



'-----------------------------------------------'
'---       Support Vector Regression         ---'
'-----------------------------------------------'
from sklearn.svm import SVR
from sklearn.model_selection import GridSearchCV
from sklearn.model_selection import learning_curve
from sklearn.kernel_ridge import KernelRidge

metricas = ['accuracy', 'average_precision', 'f1', 'precision', 'recall', 'roc_auc']


svr = GridSearchCV(SVR(kernel='rbf', gamma=0.1),
                   param_grid={"C": [1e0, 1e1, 1e2, 1e3],
                               "gamma": np.logspace(-2, 2, 5)})

kr = GridSearchCV(KernelRidge(kernel='rbf', gamma=0.1),
                  param_grid={"alpha": [1e0, 0.1, 1e-2, 1e-3],
                              "gamma": np.logspace(-2, 2, 5)})


svr.fit(x_train, y_train)

#x_train, x_test, y_train, y_test
import time
t0 = time.time()
svr_fit = time.time() - t0
print("SVR complexity and bandwidth selected and model fitted in %.3f s"  % svr_fit)

t0 = time.time()
kr.fit(x_train, y_train)
kr_fit = time.time() - t0
print("KRR complexity and bandwidth selected and model fitted in %.3f s"  % kr_fit)
