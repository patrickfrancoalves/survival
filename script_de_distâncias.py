# -*- coding: utf-8 -*-
import pandas as pd
import time
from random import uniform
import math
import os

print(os.getcwdb())
os.chdir('C:\\Users\\patrick\\OneDrive\\Documentos\\pibmunic')

coord = pd.read_stata('brazil_mun.dta')
novas_colunas = {"x_stub":"lng","y_stub": "lat", "NM_MUNICIP": "cidade","cod_munic": "codigo"}
coord.rename(columns=novas_colunas, inplace=True)

coord.head()
coord.drop(['center','CD_GEOCMU'], axis=1, inplace=True)
coord.dtypes


def haversine(coord1, coord2):
    R = 6372800
    lat1, lon1 = coord1
    lat2, lon2 = coord2
    phi1, phi2 = math.radians(lat1), math.radians(lat2)
    dphi = math.radians(lat2 - lat1)
    dlambda = math.radians(lon2 - lon1)

    a = math.sin(dphi/2)**2 + \
        math.cos(phi1)*math.cos(phi2)*math.sin(dlambda/2)**2
    return 2*R*math.atan2(math.sqrt(a), math.sqrt(1 - a))/1000


'------------------------------------------------------------'
'--- Script de Distância cidades e regiões metropolitanas ---'
'------------------------------------------------------------'

nomes = ['ano', 'codigo', 'nome_mun', 'rm', 'pib']

pibm = pd.read_excel('PIB MUNICIPIOS 2010 2016.xlsx', sheet_name='PIB_MUNICIPIOS', usecols=[0,6,7,8,39], names =nomes)

pibm['rmx'] = pibm['rm'].str[3:25]

pibm.head()

capital = pibm[['codigo', 'nome_mun', 'rmx']][pibm['nome_mun'] == pibm['rmx']]

cap = capital.codigo.unique()
cap.size

cap.sort()

pibm[pibm['codigo'].isin(cap)].head()



pibm[['codigo', 'ano', 'pib']][(pibm['codigo'].isin(cap)) & (pibm['ano'] == 2015)].head()

pibrm = pibm[['codigo', 'ano', 'pib']][(pibm['codigo'].isin(cap)) & (pibm['ano'] == 2015)].drop('ano',axis=1)


pibrm.head()


#COGN3, BRKM3, ABEV3, CVCB3, BRFS3, BRKM5, UGPA3
#

'----------------------------------------------------'
'---             calcular distâncias              ---'
'----------------------------------------------------'

distancias = pd.DataFrame({'codigo1': [], 'codigo2': [], 'distancia': [] })

i =0
for a, b, c in zip(coord['codigo'],coord['lat'],coord['lng']):
  for x, y, z in zip(coord['codigo'],coord['lat'],coord['lng']):
      if x in cap:
          i=i+1
          coorda = [b,c]
          coordb = [y,z]
          d = haversine(coorda, coordb)
          distancias = distancias.append({'codigo1': a, 'codigo2': x, 'distancia': d }, ignore_index=True)
          print('Distância entre {0} e {1} na interação: {2}'.format(a,x,i))

distancias.to_csv("distancias.csv")
distancias.head()
distancias.groupby('codigo2').count()

distancias.codigo1 = distancias.codigo1.astype(int)
distancias.codigo2 = distancias.codigo2.astype(int)
'terceira parte do bagulho'


'----------------------------------------------------'
'---   Usando distâncias para calcular métricas   ---'
'----------------------------------------------------'

distancias = pd.read_csv('distancias.csv')
distancias.head()

distancias2 = distancias.pivot(index='codigo1',columns='codigo2',values='distancia')
distancias2.head()



distancias2.reset_index().set_index('codigo1',inplace=True)
distancias2['maximo'] = distancias2.max(axis=1)
distancias2.head()


distancias3 = 1-distancias2.div(distancias2['maximo'],axis=0)


distancias3.reset_index(inplace=True)

distancias3.columns.name= None
distancias3.columns



distancias3.to_csv("distancias3.csv")

'--------------------------------------------------------------'
'---      Agora a parte difícil é multiplicar pelo PIB      ---'
'--------------------------------------------------------------'

#distancias3 = pd.read_csv('distancias3.csv')


pib_rms = pibrm[pibrm['codigo'].isin(cap)].set_index('codigo').transpose().reset_index()
pib_rms.columns.values



for mun in cap:
    distancias3['pibw_'+str(mun)] = distancias3[[mun]]*pib_rms[mun][0]

distancias3[distancias3['codigo1']==1100015].transpose().tail(10)

#distancias3.columns

import re
r = re.compile(".*codigo|.*pibw")

newlist = list(filter(r.match,teste[39:] )) # Read Note

newlist.append('codigo1')

distancias3[newlist].to_csv("distw.csv")


distancias3[newlist].head()
