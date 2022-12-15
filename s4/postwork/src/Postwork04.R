# Postwork: Llamadas internacionales
# Objetivo
# ● Realizar un análisis probabilístico del total de cargos internacionales de
# una compañía de telecomunicaciones
# Requisitos
# ● R, RStudio
# ● Haber trabajado con el prework y el work
# Desarrollo
# Utilizando la variable total_intl_charge de la base de datos
# telecom_service.csv de la sesión 3, realiza un análisis probabilístico. Para ello,
# debes determinar la función de distribución de probabilidad que más se
# acerque el comportamiento de los datos. Hint: Puedes apoyarte de medidas
# descriptivas o técnicas de visualización.

df <- read.csv("https://raw.githubusercontent.com/beduExpert/Programacion-R-Santander-2022/main/Sesion-03/Data/telecom_service.csv")

value.mean <- mean(df$total_intl_charge)
value.median <- median(df$total_intl_charge)
value.sd = sd(df$total_intl_charge)

# Media (2.76)  <  Mediana (2.78)   
# un poco más del 50% de los datos están por encima de la media, por lo que 
# está más "abultada" hacia la izquierda

# dispersion alrededor de la media
# IQR(df$total_intl_charge)  
#summary(df$total_intl_charge)

library(moments)
skewness(df$total_intl_charge)  #s > 0 Sesgo a la derecha, #s = 0 Simétrica, #s < 0 Sesgo a la izquierda
# sesgo a la izquierda

kurtosis(df$total_intl_charge) #Leptocúrtica k > 3, Mesocúrtica k = 3, Platocúrtica k < 3
# leptocúrtica

hist(df$total_intl_charge, main = "Histograma total_intl_charges")

# library(ggplot2)
# ggplot(df, aes(total_intl_charge)) +
#   geom_histogram() + 
#   labs(title = "Histograma", 
#        x = "total_intl_charge",
#        y = "Frequency") + 
#   theme_classic()

library(ggplot2)
ggplot(df, aes(total_intl_charge)) +
  geom_histogram(bins=25) + 
  labs(title = "Histograma", 
       x = "total_intl_charge",
       y = "Frequency") + 
  theme_classic()

# Las gráficas muestran que el sesgo a la izquierda
# es ligero y que presenta una forma muy cercana a
# la distribución normal.


# Una vez que hayas seleccionado el modelo, realiza lo siguiente:
#   1. Grafica la distribución teórica de la variable aleatoria total_intl_charge

x <- seq(-4, 4, 0.01)*value.sd + value.mean
y <- dnorm(x, mean = value.mean, sd = value.sd) 
plot(x, y, type = "l", xlab = "X", ylab = "f(x)",
     main = "Densidad de Probabilidad", 
     sub = expression(paste(mu == 2.76, " y ", sigma == 0.75)))

# 2. ¿Cuál es la probabilidad de que el total de cargos internacionales sea
# menor a 1.85 usd?
pnorm(1.85, mean = value.mean, sd = value.sd)

#   3. ¿Cuál es la probabilidad de que el total de cargos internacionales sea
# mayor a 3 usd?
pnorm(3.0, mean = value.mean, sd = value.sd, lower.tail = FALSE)

#   4. ¿Cuál es la probabilidad de que el total de cargos internacionales esté
# entre 2.35usd y 4.85 usd?
pnorm(4.85, mean = value.mean, sd = value.sd) - pnorm(2.35, mean = value.mean, sd = value.sd)

#   5. Con una probabilidad de 0.48, ¿cuál es el total de cargos internacionales
# más alto que podría esperar?
qnorm(0.48, mean = value.mean, sd = value.sd, lower.tail = FALSE)

#   6. ¿Cuáles son los valores del total de cargos internacionales que dejan
# exactamente al centro el 80% de probabilidad?
qnorm(p = 0.10, mean = value.mean, sd = value.sd)
qnorm(p = 0.10, mean = value.mean, sd = value.sd, lower.tail = FALSE)
