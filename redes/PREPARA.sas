libname lattes "\\sbsb2\dpti\Bases\LATTES2020";


/*
data Tabela_dinamicaz(compress=yes);set lattes.Tabela_dinamicaz;run;
proc contents data=lattes.Tabela_dinamicaz noprint out=c(keep=name);run;
*/




/*	   CASE WHEN [VINCULO] IS NULL THEN '' ELSE [VINCULO] END AS [VINCULO],
	   CASE WHEN [LOCAL_FORMAC] IS NULL THEN '' ELSE [LOCAL_FORMAC] END AS [LOCAL_FORMAC],
	   CASE WHEN [DEDICACAO-EXCLUSIVA] IS NULL THEN '' ELSE [DEDICACAO-EXCLUSIVA] END AS [DEDICACAO-EXCLUSIVA],
	   CASE WHEN [NOTA_CAPES] IS NULL THEN '' ELSE [NOTA_CAPES] END AS [NOTA_CAPES],
	   CASE WHEN [DIRECAO] IS NULL THEN '' ELSE [DIRECAO] END AS [DIRECAO],
	   CASE WHEN [UF-NASCIMENTO] IS NULL THEN '' ELSE [UF-NASCIMENTO] END AS [UF-NASCIMENTO],
	   CASE WHEN [CONTINENTE] IS NULL THEN '' ELSE [CONTINENTE] END AS [CONTINENTE],
	   CASE WHEN [UF-END-PROFISSIONAL] IS NULL THEN '' ELSE [UF-END-PROFISSIONAL] END AS [UF-END-PROFISSIONAL],
	   CASE WHEN SEXO IS NULL THEN '' ELSE SEXO END AS SEXO
*/
DATA TEMP(COMPRESS=YES KEEP=ArquivoXML ANO GRANDE_AREA AREA SEXO TOT_COAUTOR BANCA NOTA_CAPES 
                            PETRO_LAB PETRO_LATTES PETRO_PETRO UF_END_PROFISSIONAL UF_NASCIMENTO 
                            LOCAL_FORMAC IDADE_ACADEMICA VINCULO ORIENTA CURSO APRESEN PROD_TEC);
SET LATTES.TABELA_DINAMICAZ(WHERE=(1990<=ANO<=2022 AND IDADE_ACADEMICA>0));

WHERE GRANDE_AREA IN ('ENGENHARIAS','CIENCIAS_EXATAS_E_DA_TERRA','CIENCIAS_BIOLOGICAS','CIENCIAS_AGRARIAS','OUTROS');




BANCA    = SUM( BANCA_CONC_BRASIL,BANCA_CONC_EXTERIOR,BANCA_DOUT_BRASIL,BANCA_DOUT_EXTERIOR,BANCA_ESPEC_BRASIL,
                BANCA_ESPEC_EXTERIOR,BANCA_GRAD_BRASIL,BANCA_GRAD_EXTERIOR,BANCA_MEST_BRASIL,BANCA_MEST_EXTERIOR,
                BANCA_QUAL_BRASIL,BANCA_QUAL_EXTERIOR,OUTRA_PART_BANCA_BRASIL,OUTRA_PART_BANCA_EXTERIOR,
                OUTRA_BANC_JULG_BRASIL,OUTRA_BANC_JULG_EXTERIOR,BANC_PROF_TIT_BRASIL,BANC_PROF_TIT_EXTERIOR); 

ORIENTA  = SUM(ORI_AND_ESPEC_BRASIL,ORI_AND_ESPEC_EXTERIOR,ORN_AND_DOUT_BRASIL,ORN_AND_DOUT_EXTERIOR,
               ORN_AND_GRAD_BRASIL,ORN_AND_GRAD_EXTERIOR,ORN_AND_MEST_BRASIL,ORN_AND_MEST_EXTERIOR,
               ORN_AND_POS_DOC_BRASIL,ORN_AND_POS_DOC_EXTERIOR,ORN_CONC_DOUT_BRASIL,ORN_CONC_DOUT_EXTERIOR,
               ORN_CONC_MEST_BRASIL,ORN_CONC_MEST_EXTERIOR,ORN_CONC_POS_DOC_BRASIL,ORN_CONC_POS_DOC_EXTERIOR,
               OUTRA_BANC_JULG_BRASIL,OUTRA_BANC_JULG_EXTERIOR,OUTRA_EVE_CONG_BRASIL,OUTRA_EVE_CONG_EXTERIOR,
               OUTRA_ORIEN_ANDA_BRASIL,OUTRA_ORIEN_ANDA_EXTERIOR,OUTRA_ORIEN_CONC_BRASIL,OUTRA_ORIEN_CONC_EXTERIOR,
               PIBIC_BRASIL,PIBIC_EXTERIOR,LIVRE_DOC_BRASIL,LIVRE_DOC_EXTERIOR,LIVRE_DOC_BRASIL,LIVRE_DOC_EXTERIOR);

CURSO    = SUM(AVALIACAO_CURSOS_BRASIL,AVALIACAO_CURSOS_EXTERIOR,CURSO_CURTA_DURACAO_BRASIL,CURSO_CURTA_DURACAO_EXTERIOR,
               CURSO_CURTA_DUR_BRASIL,CURSO_CURTA_DUR_EXTERIOR);

APRESEN  = SUM(APRE_TRAB_BRASIL,APRE_TRAB_EXTERIOR,OUTRA_EVE_CONG_BRASIL,OUTRA_EVE_CONG_EXTERIOR,PARTIC_CONG_BRASIL,
               PARTIC_CONG_EXTERIOR,ORG_EVENTO_BRASIL,ORG_EVENTO_EXTERIOR,PARTIC_ENCONTRO_BRASIL,PARTIC_ENCONTRO_EXTERIOR,
               PARTIC_EXPO_BRASIL,PARTIC_EXPO_EXTERIOR,PARTIC_FEIRA_BRASIL,PARTIC_FEIRA_EXTERIOR,PARTIC_OFICINA_BRASIL,
               PARTIC_OFICINA_EXTERIOR,PARTIC_OLIMPIADA_BRASIL,PARTIC_OLIMPIADA_EXTERIOR,PARTIC_SEMINARIO_BRASIL,
               PARTIC_SEMINARIO_EXTERIOR,PARTIC_SIMPOSIO_BRASIL,PARTIC_SIMPOSIO_EXTERIOR);

PROD_TEC = SUM(BLOG_BRASIL,BLOG_EXTERIOR,CARTA_MAPA_BRASIL,CARTA_MAPA_EXTERIOR,CULTIVAR_BRASIL,CULTIVAR_EXTERIOR,
               DEMAIS_TRAB_BRASIL,DEMAIS_TRAB_EXTERIOR,DESENHO_IND_BRASIL,DESENHO_IND_EXTERIOR,EDITORACAO_BRASIL,
               EDITORACAO_EXTERIOR,LIVRO_BRASIL,LIVRO_EXTERIOR,MANUT_OBRA_ART_BRASIL,MANUT_OBRA_ART_EXTERIOR,MAQUETE_BRASIL,
               MAQUETE_EXTERIOR,MARCA_BRASIL,MARCA_EXTERIOR,MATERIAL_DIDATICO_BRASIL,MATERIAL_DIDATICO_EXTERIOR,
               OUTRA_PRODUCAO_BRASIL,OUTRA_PRODUCAO_EXTERIOR,OUTRA_PROD_TEC_CULT_BRASIL,OUTRA_PROD_TEC_CULT_EXTERIOR,
               PREFACIO_POSFACIO_BRASIL,PREFACIO_POSFACIO_EXTERIOR,PROCESSOS_TECNICAS_BRASIL,PROCESSOS_TECNICAS_EXTERIOR,
               PRODUTO_TECN_BRASIL,PRODUTO_TECN_EXTERIOR,PROGR_RADIO_TV_BRASIL,PROGR_RADIO_TV_EXTERIOR,RADIO_TV_BRASIL,
               RADIO_TV_EXTERIOR,RELAT_PESQUISA_BRASIL,RELAT_PESQUISA_EXTERIOR,TEXTO_BRASIL,TEXTO_EXTERIOR,TOPOG_CIRC_INTE_BRASIL,
               TOPOG_CIRC_INTE_EXTERIOR,TRABALHO_BRASIL,TRABALHO_EXTERIOR,TRABALHO_TECNICO_BRASIL,TRABALHO_TECNICO_EXTERIOR,
               TRADUCAO_BRASIL,TRADUCAO_EXTERIOR);

RUN;



