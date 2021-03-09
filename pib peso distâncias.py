# -*- coding: utf-8 -*-
import pandas as pd
import time
from random import uniform
import math
import os
#print(os.getcwdb())

os.chdir('C:\\pibmunic')


nomes =['ano','codigo','pib']


pibm = pd.read_excel ('PIB MUNICIPIOS 2010 2016.xlsx', sheet_name='PIB_MUNICIPIOS',usecols =[0,6,39],names =nomes)
#pibm = pd.read_excel ('PIB MUNICIPIOS 2010 2016.xlsx', sheet_name='PIB_MUNICIPIOS')
pibm.head(5)


#-----------------------------------
dist = pd.read_csv('distancias3.csv')
dist.head()

dist.shape

relevantes = dist.drop('maximo',axis=1).columns.values[1:]

rel = []
for i in relevantes:
    rel.append(int(i))

pibm2 = pibm[(pibm['codigo'].isin(rel)) & (pibm['ano']==2016)].drop('ano',axis=1)

pibm2.head()
pibm2 = pibm2.set_index(['codigo']).transpose()

pibm2.head()
pibm2.shape
dist.shape

pibm2.columns.values
dist.columns.values


teste = dist.mul(pibm2)

teste[['3550308', '1100205', '2510808']].head()
