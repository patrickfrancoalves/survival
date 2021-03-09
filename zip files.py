#https://stackoverflow.com/questions/17614467/how-can-unrar-a-file-with-python
from pyunpack import Archive
import os
os.chdir('C:\\Users\\patrick\\Downloads')
Archive('grupos_grande.rar').extractall('grupos_grande')


import patoolib
patoolib.extract_archive("grupos_grande.rar", outdir="grupos_grande")


#https://code.tutsplus.com/pt/tutorials/compressing-and-extracting-files-in-python--cms-26816
import zipfile
import pyreadstat
import pandas as pd

fantasy_zip = zipfile.ZipFile('grupos_grande.rar')
fantasy_zip.extractall('grupos_grande')
fantasy_zip.close()

grupos_grande = pd.read_spss("grupos_grande/grupos_grande.sav")
grupos_grande, meta = pyreadstat.read_sav("grupos_grande/grupos_grande.sav")



'------------------------------------------------------------------------------'
'-   script para extração de todos os arquivos zip em uma determinada pasta   -'
'------------------------------------------------------------------------------'

import zipfile, fnmatch, os

rootPath = r"C:\\Users\\patrick\\OneDrive\\Documentos\\pibmunic\\dados"
pattern = '*.zip'

for root, dirs, files in os.walk(rootPath):
    for filename in fnmatch.filter(files, pattern):
        #print(1,os.path.join(root, filename))
        print(2,filename)
        #print(3,root)
        #print(4,os.path.splitext(filename)[0])
        #zipfile.ZipFile(os.path.join(root, filename)).extractall(os.path.join(root, os.path.splitext(filename)[0]))
        zipfile.ZipFile(os.path.join(root, filename)).extractall(os.path.join(root, root))
