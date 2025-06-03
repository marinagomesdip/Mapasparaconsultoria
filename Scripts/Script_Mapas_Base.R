#==============================================================================#
#                   MINICURSO MAPAS PARA CONSULTORIA AMBIENTAL                 #
#                      Contato: gomes.mari.95@gmai.com                         #
#                      Script Atualizado em 03/06/2025                         #
#==============================================================================#

#                      AULA MAPAS PARA CONSULTORIA                             # 

# ---------------------------------------------------------------------------- #

# MAPA 1 - Mapa de caracterização do município de Itatiaia

# 1. INSTALANDO PACOTES: -------------------------------------------------------------
install.packages('sf')   # instalando o pacote 'sf'

# 2. CARREGANDO PACOTES: -------------------------------------------------------------
library(sf)                # Carregando o pacote.

# 3. DADOS NECESSÁRIOS --------------------------------------------------------------

# A. Limites do município de Itatiaia

install.packages('geobr')   # instalando o pacote 'geobr'.

library(geobr)                # Carregando o pacote.

#Acessar o github do geobr para ver as funções e dados que podemos baixar
#https://github.com/ipeaGIT/geobr
 
#Baixar dados do municipio usando a função do geobr
#Como saber qual código usar?? vamos consultar o help da função
?read_municipality

#segundo o help do pacote, podemos usar o seguinte código para encontrar o código dos municipios:
geobr::lookup_muni("Itatiaia")

#agora vamos baixar a geometria de Itatiaia
ita <- read_municipality(code_muni = 3302254, year = 2020)

#vamos visualizar se conseguimos baixar a geometria corretamente:
plot(ita$geom) 

# B. Unidades de Conservação
#é possível baixar elas através do geobr também
ucs<- read_conservation_units()

#vamos visualizar se conseguimos baixar a geometria corretamente:
plot(ucs$geom) 

# C. Drenagem 
#É possível importar a drenagem através do R, mas como o pacote da ANA foi descontinuado,
#importar do mundo todo geralmente exige alta capacidade de processamento, portanto, 
#vamos usar o mesmo shp que usamos baixado do site da ANA

#Para ler um shp externo:
rios <- st_read("C:/Users/Dell/OneDrive/Área de Trabalho/MINICURSO/Shapefiles/Rios/GEOFT_BHO_REF_RIO.shp")

#vamos visualizar se conseguimos baixar a geometria corretamente:
plot(rios$geom) 
