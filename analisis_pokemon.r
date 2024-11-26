#Analisis Pokemon
# Hecho Por: Gian Marco Lucatero Tenorio
# Cargar librerias necesarias
library(readr)
library(dplyr)
library(ggplot2)
library(ggrepel)

# Importar la base de datos
data_pokemon <- read_csv("data_pokemon.csv")

# Verificar los primeros registros
head(data_pokemon)

#funcion para crear una nueva variable que clasifique las velocidades de los pokemones en 3 casos: poco veloz (cuando su velocidad es igual o menor a 60), veloz (cuaqndo su velocidad es 61 a 100) y muy veloz (cuando su velocidad es mayor a 100)
data_pokemon <- data_pokemon %>%
    mutate(
        categoria_velocidad = case_when(
            velocidad <= 60 ~ 'Poco veloz',
            velocidad > 60 & velocidad <= 100 ~ 'veloz',
            velocidad > 100 ~ 'Muy veloz'
        )
  )

# tabla para ver los pokemones poco veloz, veloz y muy veloz
tabla1 <- table(data_pokemon$categoria_velocidad)
tabla2 <- prop.table(tabla1) * 100

# Convertir es_legendario a factor con etiquetas
data_pokemon$etiqueta_legendario <- factor(data_pokemon$es_legendario,
                                           levels = c(TRUE, FALSE),
                                           labels = c("Sí es legendario", "No es legendario"))

# Creacion de tabla de contingencia
tabla_contingencia <- table(data_pokemon$categoria_velocidad, data_pokemon$etiqueta_legendario)
# se imprime la tabla para checar que se hizo bien
tabla_contingencia

#sacamos los porcentages de la tabla
tabla_prop <- prop.table(tabla_contingencia) * 100
# ahora esta es la tabla que usaremos para el analizis
tabla_prop

#----------------------------------------------------------------
# Filtrar los Pokémon legendarios y no legendarios
legendarios <- data_pokemon %>% filter(es_legendario == TRUE)
no_legendarios <- data_pokemon %>% filter(es_legendario == FALSE)

# Cálculo de los cuartiles y los bigotes para detectar outliers
Q1 <- quantile(legendarios$velocidad, 0.25)
Q3 <- quantile(legendarios$velocidad, 0.75)
IQR <- Q3 - Q1

# Definir los límites de los bigotes
limite_inferior <- Q1 - 1.5 * IQR
limite_superior <- Q3 + 1.5 * IQR

# Filtrar los puntos atípicos
outliers <- legendarios[legendarios$velocidad < limite_inferior | legendarios$velocidad > limite_superior, ]

# Gráfico de boxplot legendarios
caja_legendarios <- ggplot(legendarios, aes(x = etiqueta_legendario, y = velocidad, fill = etiqueta_legendario)) +
  geom_boxplot() +
  ggtitle("Velocidad de Pokémon Legendarios") +
  xlab("¿Es legendario?") +
  ylab("Velocidad") +
  theme_minimal() +
  scale_fill_brewer(palette = "Set2") +
  # Usar ggrepel para evitar el solapamiento de las etiquetas
  geom_text_repel(data = outliers, aes(x = etiqueta_legendario, y = velocidad, label = nombre_ingles),
                  color = "black", box.padding = 0.35, point.padding = 0.5, 
                  segment.color = 'grey50', size = 3)  # Ajusta tamaño y espacio

# Mostrar el gráfico
print(caja_legendarios)

# Cálculo de los cuartiles y los bigotes para detectar outliers para los no legendarios
Q1_no_legendarios <- quantile(no_legendarios$velocidad, 0.25)
Q3_no_legendarios <- quantile(no_legendarios$velocidad, 0.75)
IQR_no_legendarios <- Q3_no_legendarios - Q1_no_legendarios

# Definir los límites de los bigotes para los no legendarios
limite_inferior_no_legendarios <- Q1_no_legendarios - 1.5 * IQR_no_legendarios
limite_superior_no_legendarios <- Q3_no_legendarios + 1.5 * IQR_no_legendarios

# Filtrar los outliers para los no legendarios
outliers_no_legendarios <- no_legendarios[no_legendarios$velocidad < limite_inferior_no_legendarios | no_legendarios$velocidad > limite_superior_no_legendarios, ]

# Gráfico de boxplot para los Pokémon no legendarios
caja_no_legendarios <- ggplot(no_legendarios, aes(x = etiqueta_legendario, y = velocidad, fill = etiqueta_legendario)) +
  geom_boxplot() +
  ggtitle("Velocidad de Pokémon No Legendarios") +
  xlab("¿Es legendario?") +
  ylab("Velocidad") +
  theme_minimal() +
  scale_fill_brewer(palette = "Set2") +
  # Usar ggrepel para evitar el solapamiento de las etiquetas de los puntos atípicos
  geom_text_repel(data = outliers_no_legendarios, aes(x = etiqueta_legendario, y = velocidad, label = nombre_ingles),
                  color = "black", box.padding = 0.35, point.padding = 0.5, 
                  segment.color = 'grey50', size = 3)  # Ajusta tamaño y espacio

# Mostrar el gráfico
print(caja_no_legendarios)

#--------------------------------------------------------------------
# Scatter plot con las variables velocidad y fuerza_especial_ataque
scatter_plot <- ggplot(data_pokemon, aes(x = velocidad, y = fuerza_especial_ataque, color = fuerza_especial_ataque)) +
  geom_point() +  # Añadir los puntos
  ggtitle("Diagrama de dispersión: Velocidad vs Fuerza Especial de Ataque") +  # Título del gráfico
  xlab("Velocidad") +  # Etiqueta del eje X
  ylab("Fuerza Especial de Ataque") +  # Etiqueta del eje Y
  theme_minimal() +  
  scale_color_gradient(low = "blue", high = "red")  # Colorear los puntos en un gradiente de azul a rojo

# Mostrar el gráfico
print(scatter_plot)

# Encontrar a Charizar en el Scatter Plot
# Filtrar los Pokémon de tipo Fuego y de la primera generación

pokemon_fuego_1era <- data_pokemon[data_pokemon$tipo_1 == "Fuego" & data_pokemon$generacion == 1, ]

# Filtrar a Charizard
charizard <- pokemon_fuego_1era[pokemon_fuego_1era$nombre_ingles == "Charizard", ]

# Crear el gráfico
scatter_plot_charizard <- ggplot(pokemon_fuego_1era, aes(x = velocidad, y = fuerza_especial_ataque)) +
  geom_point(aes(color = fuerza_especial_ataque), size = 3) +  # Puntos para todos los Pokémon de fuego y 1ra generación
  geom_text(data = charizard, aes(label = nombre_ingles), vjust = -1, color = "red") +  # Añadir nombre de Charizard
  ggtitle("Relación entre Velocidad y Fuerza Especial de Ataque (Pokémon Fuego - 1ra Generación)") +
  xlab("Velocidad") +
  ylab("Fuerza Especial de Ataque") +
  theme_minimal()

# Mostrar el gráfico
print(scatter_plot_charizard)

#-----------------------------------------------------

# Cálculo de los promedios por generación
promedios_generacion <- data_pokemon %>%
  group_by(generacion) %>%
  summarise(
    promedio_velocidad = mean(velocidad, na.rm = TRUE),
    promedio_total = mean(total, na.rm = TRUE)
  )

# Visualización de la velocidad promedio por generación
grafico_velocidad <- ggplot(promedios_generacion, aes(x = generacion)) +
  geom_line(aes(y = promedio_velocidad), color = "blue", linewidth = 1.2) +
  geom_point(aes(y = promedio_velocidad), color = "blue", size = 3) +
  ggtitle("Velocidad Promedio por Generación") +
  xlab("Generación") +
  ylab("Velocidad Promedio") +
  theme_minimal()

print(grafico_velocidad)
# Visualización del total promedio por generación
grafico_total <- ggplot(promedios_generacion, aes(x = generacion)) +
  geom_line(aes(y = promedio_total), color = "green", linewidth = 1.2) +
  geom_point(aes(y = promedio_total), color = "green", size = 3) +
  ggtitle("Estadísticas Totales Promedio por Generación") +
  xlab("Generación") +
  ylab("Total Promedio") +
  theme_minimal()

print(grafico_total)

# Análisis de correlación entre generación y estadísticas
correlacion_velocidad <- cor(data_pokemon$generacion, data_pokemon$velocidad, use = "complete.obs")
correlacion_total <- cor(data_pokemon$generacion, data_pokemon$total, use = "complete.obs")

print(paste("Correlación generación vs velocidad:", round(correlacion_velocidad, 2)))
print(paste("Correlación generación vs total:", round(correlacion_total, 2)))

#-----------------------------------------------------------------------------------

# Filtrar los Pokémon de la generación 4
gen4_pokemon <- data_pokemon[data_pokemon$generacion == 4, ]

# Identificar a los Pokémon más rápidos
top_speed <- gen4_pokemon[gen4_pokemon$velocidad > 115, ]

# Identificar a los Pokemones mas lentos
slow_speed <- gen4_pokemon[gen4_pokemon$velocidad < 50, ]

# Crear un histograma para la velocidad de los Pokémon de la generación 4
histograma_gen4 <- ggplot(gen4_pokemon, aes(x = velocidad)) +
  geom_histogram(binwidth = 10, fill = "gold", color = "black") +
  ggtitle("Distribución de Velocidad - Pokémon Generación 4") +
  xlab("Velocidad") +
  ylab("Frecuencia") +
  theme_minimal() +
  # Agregar etiquetas con geom_text_repel
  geom_text_repel(data = top_speed, 
                  aes(x = velocidad, y = 1, label = nombre_ingles),
                  size = 3, color = "blue", 
                  nudge_y = 5, 
                  segment.color = "violet") +
    geom_text_repel(data = slow_speed, 
                  aes(x = velocidad, y = 1, label = nombre_ingles),
                  size = 3, color = "blue", 
                  nudge_y = 5, 
                  segment.color = "violet")


# Mostrar el histograma
print(histograma_gen4)

# Filtrar los Pokémon de la generación 2
gen2_pokemon <- data_pokemon[data_pokemon$generacion == 2, ]

# Identificar a los Pokémon más rápidos
top_speed2 <- gen2_pokemon[gen2_pokemon$velocidad > 110, ]

# Identificar a los pokemones mas lentos
slow_speed2 <- gen2_pokemon[gen2_pokemon$velocidad < 15, ]

# Crear un histograma para la velocidad de los Pokémon de la generación 4
histograma_gen2 <- ggplot(gen2_pokemon, aes(x = velocidad)) +
  geom_histogram(binwidth = 15, fill = "gray", color = "black") +
  ggtitle("Distribución de Velocidad - Pokémon Generación 2") +
  xlab("Velocidad") +
  ylab("Frecuencia") +
  theme_minimal() +
  # Agregar etiquetas con geom_text_repel
  geom_text_repel(data = top_speed2, 
                  aes(x = velocidad, y = 1, label = nombre_ingles),
                  size = 3, color = "red", 
                  nudge_y = 5,
                  segment.color = "violet") +
  geom_text_repel(data = slow_speed2, 
                  aes(x = velocidad, y = 1, label = nombre_ingles),
                  size = 3, color = "red", 
                  nudge_y = 5,
                  segment.color = "violet")


# Mostrar el histograma
print(histograma_gen2)

pokelegen <- subset(data_pokemon, es_legendario == TRUE)
pokegen2vel <- pokelegen[which.min(pokelegen$es_legendario),]
print(pokegen2vel)