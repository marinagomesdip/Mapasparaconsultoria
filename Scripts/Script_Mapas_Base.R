#==============================================================================#
#                   MINICURSO MAPAS PARA CONSULTORIA AMBIENTAL                 #
#                      Contato: gomes.mari.95@gmai.com                         #
#                      Script Atualizado em 03/06/2025                         #
#==============================================================================#

#                      AULA MAPAS PARA CONSULTORIA                             # 

# ---------------------------------------------------------------------------- #

# MAPA 1 - Mapa de caracterização do município de Itatiaia 

# 1. INSTALANDO PACOTES: -------------------------------------------------------------
#install.packages('sf')   # instalando o pacote 'sf'

# 2. CARREGANDO PACOTES: -------------------------------------------------------------
library(sf)                # Carregando o pacote.

# 3. DADOS NECESSÁRIOS --------------------------------------------------------------

# A. Limites do município de Itatiaia

#install.packages('geobr')   # instalando o pacote 'geobr'.

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

# 4.  VERIFICAR CRS --------------------------------------------------------------

#A função para verificar um crs de um mapa é a seguinte:

sf::st_crs(ita)
sf::st_crs(ucs)
sf::st_crs(rios)

#Para confirmar se eles são equivalentes, podemos usar uma igualdade simples
st_crs(ita) == st_crs(rios)

#Para modificar um crs podemos usar:
rios <- st_transform(rios, crs = 5880)
ita <- st_transform(ita, crs = 5880)
ucs <- st_transform(ucs, crs = 5880)

#Vamos conferir se deu certo?
sf::st_crs(rios)

#5. RECORTAR OS SHAPEFILES PRA ÁREA ALVO -----------------------------------------

#5.1 UCS
#usando operações geométricas, como a interseção para recortar o shape
ucs <- st_intersection(ucs, ita)
#aqui vai aparecer um erro por contas das geometrias disponibilizadas pelo pacote
#geobr que nem sempre são perfeitas

# Para isso, vamos corrigir as geometrias
ita <- st_make_valid(ita)  # Shapefile de Itatiaia
ucs <- st_make_valid(ucs)  # Shapefile das UCs

#usando operações geométricas, como a interseção para recortar o shape
ucs <- st_intersection(ucs, ita)

#5.2 Rios
#usando operações geométricas, como a interseção para recortar o shape
rios <- st_intersection(rios, ita)

# 6. MONTANDO O MAPA COM GGPLOT2 --------------------------------------------------
#instalando o pacote
#install.packages('ggplot2')

#carregando o pacote
library(ggplot2)

#6.1 - fazendo o primeiro plot
mapaitatiaia <- ggplot() +
  geom_sf(data = ita,           # Geometria de Itatiaia
          color='black',        # Cor das linhas/bordas da camada.
          fill = 'khaki',       # Cor do preenchimento
          alpha = 0.8)          # Transparência do mapa
          
#visualizando o primeiro plot
mapaitatiaia

#lembre-se que aqui, a ordem dos plots que vamos acresentar faz toda a diferença

#6.2 - Vamos adicionar ao plot que já fizemos, os dados das ucs

mapaitati.uc <- mapaitatiaia +                # Objeto com o mapa de Itatiaia
                geom_sf(data = ucs,           # Dados das UCs presentes no município.
                       color = 'gray31',      # Cor das linhas
                       fill = 'seagreen',     # Cor do preenchimento
                       alpha = 0.3)           # Transparência

#visualizando o novo plot
mapaitati.uc

#6.3 - Vamos adicionar ao plot que já fizemos, os dados de drenagem

mapaitati.uc.rio <- mapaitati.uc +                # Objeto com o mapa de Itatiaia
                    geom_sf(data = rios,          # Dados das UCs presentes no município.
                    color = 'royalblue1',         # Cor das linhas
                    linewidth = 1.2)
                    
#visualizando o novo plot
mapaitati.uc.rio

#6.4 - Agora vamos deixar esse mapa mais visual

mapaitati.uc.rio <- mapaitati.uc.rio + 
  labs(title = 'Município de Itatiaia - Caracterização',                # Acrescenta título
       caption = 'DATUM SIRGAS 2000 | Fonte dos dados: GEOBR & ANA | Elaborado por [Seu Nome]')+
  theme_light()                                     # Muda o tema para deixar mais visual

#visualizando o novo plot
mapaitati.uc.rio

#6.5 - Adicionar elementos obrigatórios
#install.packages('ggspatial')     # instalando o pacote 'ggspatial'.

library(ggspatial)                # Carregando o pacote.
library(grid)                     # Carregando pacote adicional da base R para evitar erros

#Acrescentando elementos obrigatórios
mapaitati.uc.rio <- mapaitati.uc.rio +
  ggspatial::annotation_scale(
    location = 'bl',                           # Localização da escala gráfica.
    bar_cols = c('black','white'),             # Cores das barras.
    height = unit(0.2, "cm"))+                 # Altura da escala gráfica.
  ggspatial::annotation_north_arrow(
    location = 'tr',                           # Localização da seta norte. 
    pad_x = unit(0.30, 'cm'),                  # Distância da borda do eixo x.
    pad_y = unit(0.30, 'cm'),                  # Distância da borda do eixo y.
    height = unit(1.0, 'cm'),                  # Altura  da seta norte.
    width = unit(1.0, 'cm'),                   # Largura da seta norte.
    style = north_arrow_fancy_orienteering(    # Tipo de seta.
      fill = c('grey40', 'white'),             # Cores de preenchimento da seta.
      line_col = 'grey20'))                    # Cor  das linhas da seta.

mapaitati.uc.rio

#7. SALVAR MAPA ----------------------------------------------------------------
#7.1 - descobrir qual a pasta configurada no seu PC
getwd()

#modificar a pasta caso seja de seu interesse 
#setwd("seu_diretório")

#7.2 - Salvar usando a função do ggplot
ggsave("Mapa_Itatiaia.png",     # nome do arquivo a ser salvo
       plot = mapaitati.uc.rio,    # nome do objeto que você quer salvar
       width = 8,              # largura em pixels da imagem
       height = 6,              # altura em pixels da imagem
       dpi = 300)               # qualidade da imagem

#MAPA 2 - Mapa de caracterização de área específica de um projeto a partir de kmz enviado pelo cliente

#1. DADOS NECESSÁRIOS --------------------------------------------------------------

#A. SHP DO MUNICÍPIO DO RIO DE JANEIRO (onde a área está inserida)
#podemos usar o seguinte código para encontrar o código dos municipios:
geobr::lookup_muni("Rio de Janeiro")

#agora vamos baixar a geometria do Rio de Janeiro
rj <- read_municipality(code_muni = 3304557, year = 2020)

#vamos visualizar se conseguimos baixar a geometria corretamente:
plot(rj$geom) 

#B. KMZ do projeto 
#vamos carregar um pacote do R básico (n precisa instalar)
library(utils)

# Passo 1: Extrair o KML do KMZ (sem salvar)
#caminho para o arquivo
kmz_file <- "C:/Users/Dell/OneDrive/Área de Trabalho/MINICURSO/Exemplos/Mapa2/empreendimento.kmz"
#criar um diretório vazio para armazenar temporariamente o arquivo
temp_dir <- tempdir()
#retirar o kml do kmz para a pasta temporária 
unzip(kmz_file, exdir = temp_dir)

# Passo 2: Ler o KML como objeto `sf` 
#lista de arquivos para extrair
kml_file <- list.files(temp_dir, pattern = "\\.kml$", full.names = TRUE)[1]
#ler o arquivo com st_read
empree <- st_read(kml_file)

#vamos visualizar o mapa
plot(empree)

#C. KMZ área de supressão
# Passo 1: Extrair o KML do KMZ (sem salvar)
#caminho para o arquivo
kmz_file <- "C:/Users/Dell/OneDrive/Área de Trabalho/MINICURSO/Exemplos/Mapa2/supressao.kmz"
#criar um diretório vazio para armazenar temporariamente o arquivo
temp_dir <- tempdir()
#retirar o kml do kmz para a pasta temporária 
unzip(kmz_file, exdir = temp_dir)

# Passo 2: Ler o KML como objeto `sf` 
#lista de arquivos para extrair
kml_file <- list.files(temp_dir, pattern = "\\.kml$", full.names = TRUE)[1]
#ler o arquivo com st_read
supre <- st_read(kml_file)

#vamos visualizar o mapa
plot(supre)

#D. KMZ da área de replantio
# Passo 1: Extrair o KML do KMZ (sem salvar)
#caminho para o arquivo
kmz_file <- "C:/Users/Dell/OneDrive/Área de Trabalho/MINICURSO/Exemplos/Mapa2/replantio.kmz"
#criar um diretório vazio para armazenar temporariamente o arquivo
temp_dir <- tempdir()
#retirar o kml do kmz para a pasta temporária 
unzip(kmz_file, exdir = temp_dir)

# Passo 2: Ler o KML como objeto `sf` 
#lista de arquivos para extrair
kml_file <- list.files(temp_dir, pattern = "\\.kml$", full.names = TRUE)[1]
#ler o arquivo com st_read
replan <- st_read(kml_file)

#vamos visualizar o mapa
plot(replan)

# 2.  AJUSTAR CRS  --------------------------------------------------------------

#Para modificar um crs podemos usar:
rj <- st_transform(rj, crs = 5880)
empree <- st_transform(empree, crs = 5880)
supre <- st_transform(supre, crs = 5880)
replan <- st_transform(replan, crs = 5880)

# 3. PLOTAR MAPAS COM GGPLOT2 ----------------------------------------------------
#3.1 - fazendo o primeiro plot (sempre considere o shp mais extenso)
mapa2 <- ggplot() +
  geom_sf(data = rj,           # Geometria de Itatiaia
          color='black',        # Cor das linhas/bordas da camada.
          fill = 'khaki',       # Cor do preenchimento
          alpha = 0.8)          # Transparência do mapa

#visualizando o primeiro plot
mapa2

#3.2 - Vamos adicionar ao plot que já fizemos, os dados do empreendimento

mapa2 <- mapa2 +                 # Objeto com o mapa de Itatiaia
  geom_sf(data = empree,         # Dados extraídos do kmz do empreendimento
          color = 'orange1',     # Cor da llinha
          fill = NA,             # Manter o shp sem preenchimento
          linewidth = 1)         # extensão da linha

#visualizando o novo plot
mapa2

#Agora perceba que o mapa ficou muito grande pro tamanho do empreendimento,
#vamos modificar esse código para facilitar

mapa2 <- mapa2 +                 # Objeto com o mapa de Itatiaia
  geom_sf(data = empree,         # Dados extraídos do kmz do empreendimento
          color = 'orange1',     # Cor da llinha
          fill = NA,             # Manter o shp sem preenchimento
          linewidth = 1) +      # extensão da linha
  coord_sf(
    xlim = c(st_bbox(empree)["xmin"], st_bbox(empree)["xmax"]),
    ylim = c(st_bbox(empree)["ymin"], st_bbox(empree)["ymax"])) 
  
#visualizando o novo plot
mapa2


#MAPA 3 - 

