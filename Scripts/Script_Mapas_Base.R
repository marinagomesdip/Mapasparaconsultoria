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

#MAPA 2 - 