# RESULTADOS
# Requisitos 
# - Haber realizado los works y postworks previos 
# - Tener una cuenta en Github o en RStudioCloud 
# Desarrollo 
# Un centro de salud nutricional está interesado en analizar estadísticamente y
# probabilísticamente los patrones de gasto en alimentos saludables y no
# saludables en los hogares mexicanos con base en su nivel socioeconómico, en si
# el hogar tiene recursos financieros extras al ingreso y en si presenta o no
# inseguridad alimentaria. Además, está interesado en un modelo que le permita
# identificar los determinantes socioeconómicos de la inseguridad alimentaria.
# 
# La base de datos es un extracto de la Encuesta Nacional de Salud y Nutrición
# (2012) levantada por el Instituto Nacional de Salud Pública en México. La
# mayoría de las personas afirman que los hogares con menor nivel socioeconómico
# tienden a gastar más en productos no saludables que las personas con mayores
# niveles socioeconómicos y que esto, entre otros determinantes, lleva a que un
# hogar presente cierta inseguridad alimentaria.
#
# La base de datos contiene las siguientes variables:
#
# nse5f (Nivel socioeconómico del hogar): 1 "Bajo", 2 "Medio bajo", 3 "Medio", 4
# "Medio alto", 5 "Alto" 
# area (Zona geográfica): 0 "Zona urbana", 1 "Zona rural"
# numpeho (Número de persona en el hogar) 
# refin (Recursos financieros distintos al ingreso laboral): 0 "no", 1 "sí" 
# edadjef (Edad del jefe/a de familia)
# sexojef (Sexo del jefe/a de familia): 0 "Hombre", 1 "Mujer" 
# añosedu (Años de educación del jefe de familia) 
# ln_als (Logaritmo natural del gasto en alimentos saludables) 
# ln_alns (Logaritmo natural del gasto en alimentos no saludables) 
# IA (Inseguridad alimentaria en el hogar): 0 "No presenta IA", 1 "Presenta IA"
#
# df<-read.csv("https://raw.githubusercontent.com/beduExpert/Programacion-R-Santander-2022/main/Sesion-08/Postwork/inseguridad_alimentaria_bedu.csv")

library(DescTools)
library(ggplot2)
library(dplyr)
library(moments)
library(caret)
#install.packages("vcd")
library(vcd)


#
# I. Plantea el problema del caso 

# El objetivo de este trabajo es saber si es posible identificar los determinantes
# socioeconómicos de la inseguridad alimentaria.

# Con base en la información que maneja el centro nutricional las siguientes
# interrogantes guían este trabajo:
#   
# 1. ¿Cuáles son los patrones de gasto en alimentos saludables y no saludables en 
# los hogares mexicanos considerando su nivel socioeconómico, si cuenta con recursos
# financieros extra y si presenta inseguridad alimentaria?
# 2. ¿Los hogares con menor nivel socioeconómico tienden a gastar más en productos 
#  no saludables que los hogares con mayores niveles socioeconómicos?  
# 3. ¿El que los hogares con menor nivel socioeconómico gasten más en productos
#  no saludables los lleva a que presente inseguridad alimentaria?
# 4. ¿Es posible encontrar un modelo que permita identificar los determinantes 
#   socioeconómicos de la inseguridad alimentaria?


# II. Realiza un análisis descriptivo de la información 

df.raw <-read.csv("https://raw.githubusercontent.com/beduExpert/Programacion-R-Santander-2022/main/Sesion-08/Postwork/inseguridad_alimentaria_bedu.csv")
dim(df.raw)   
# 40809 observaciones y 10 variables

# Visualización de datos
View(df.raw)

# Conocer qué información no está disponible
apply(X = is.na(df.raw), MARGIN = 2, FUN = sum)
apply(X = is.na(df.raw), MARGIN = 2, FUN = mean)

# Porcentajes de datos faltantes:
# ln_alns   42%
# ln_als    19%
# edadjef   12%
# sexojef   12%


# Examinar la información de Inseguridad alimentaria que no estaría disponible
df.NA.ln_alns <-df.raw[(is.na(df.raw$ln_alns)),]
View(df.NA.ln_alns)
df.NA.ln_alns$IA <- factor(df.NA.ln_alns$IA, labels = c("No presenta IA", "Presenta IA"))
summary(df.NA.ln_alns$IA)
round((3938/(3938 + 13566))*100,2)
round((13566/(3938 + 13566))*100,2)

df.NA.ln_als <-df.raw[(is.na(df.raw$ln_als)),]
df.NA.ln_als$IA <- factor(df.NA.ln_als$IA, labels = c("No presenta IA", "Presenta IA"))
summary(df.NA.ln_als$IA)

# Imputación de datos vs quitar incompletos:
# Decidimos quitar incompletos debido a que requerimos más tiempo para documentarnos
# sobre las diferentes técnicas y la información sobre las razones por las que no 
# están disponibles estos datos para darles un tratamento adecuado.

# Limpieza: se eliminan observaciones incompletas
df <- df.raw[complete.cases(df.raw),]
dim(df)   
# 20280 observaciones completas y 10 variables
View(df)

# Porcentaje de registros con datos faltantes
(40809-20280)/40809
# 50.3%

# 1. Tipos de variables
# El conjunto de datos contiene 10 variables:
# nse5f es cualitativa ordinal
# area, refin, sexoje, IA son cualitativas nominales
# numpeho, edadjef, añosedu son cuantitativas discreta
# ln_als, ln_alns son cuantitativas continuas

# transformación de variable cualitativa con factor
df$nse5f <- factor(df$nse5f, labels = c("Bajo", "Medio bajo", "Medio", "Medio alto", "Alto"))
df$area <- factor(df$area, labels = c("Zona urbana","Zona rural")) 
df$refin <- factor(df$refin, labels = c("no", "sí" ))
df$sexojef <- factor(df$sexojef, labels = c("Hombre","Mujer")) 
df$IA <- factor(df$IA, labels = c("No presenta IA", "Presenta IA"))

# 2. Medidas de tendencia central y posición
summary(df)

# 3. Medidas de dispersión
sd(df$numpeho); sd(df$edadjef); sd(df$añosedu)
sd(df$ln_als); sd(df$ln_alns)

# Exponencial en medidas de gastos
exp(mean(df$ln_als)); exp(mean(df$ln_alns))
exp(sd(df$ln_als)); exp(sd(df$ln_alns))

# Tabla de resumen en reporte

# 4. Formas de distribución
# Sesgo
#s > 0 Sesgo a la derecha
#s = 0 Simétrica
#s < 0 Sesgo a la izquierda

skewness(df$numpeho) 
# 0.9393 - Sesgo a la derecha

skewness(df$edadjef) 
# 0.4853 - Sesgo a la derecha

skewness(df$añosedu) 
# -0.4102 - Sesgo a la izquierda

skewness(df$ln_als)
# -1.1918 - Sesgo a la izquierda

skewness(df$ln_alns)
# 0.2431 - Sesgo a la derecha

# kurtosis
#Leptocúrtica k > 3
#Mesocúrtica k = 3
#Platocúrtica k < 3

kurtosis(df$numpeho) 
# 5.4043 - leptocúrtica

kurtosis(df$edadjef) 
# 2.7270 - platocúrtica

kurtosis(df$añosedu) 
# 3.7990 - leptocúrtica

kurtosis(df$ln_als)
# 6.605526 - leptocúrtica

kurtosis(df$ln_alns)
# 2.5798 - platocúrtica


# Distribución de frecuencias

# Nivel socioeconómico
freq.nse5f <- table(df$nse5f)

transform(freq.nse5f, 
          rel.freq=prop.table(Freq),
          cum.freq=cumsum(prop.table(Freq)))

ggplot(df, aes(x = nse5f)) +
  geom_bar(color = "darkslategray", fill = "skyblue2", linetype = 0)+
  xlab("Nivel socioeconómico") + 
  ylab("Cantidad de hogares") + 
  ggtitle("Distribución de frecuencias")

# Tipo de área
freq_area <- table(df$area)
transform(freq_area, 
          rel.freq=prop.table(Freq))

ggplot(df, aes(x = area)) +
  geom_bar(color = "darkslategray", fill = "palegreen2", width = .5, linetype = 0)+
  xlab("Tipo de área") + 
  ylab("Cantidad de hogares") + 
  ggtitle("Distribución de frecuencias")

# Recursos financieros adicionales
freq_refin <- table(df$refin)
transform(freq_refin,
          rel.freq=prop.table(Freq))

ggplot(df, aes(x = refin)) +
  geom_bar(color = "darkslategray", fill = "darkgoldenrod2", width = .5, linetype = 0)+
  xlab("Recursos financieros adicionales") + 
  ylab("Cantidad de hogares") + 
  ggtitle("Distribución de frecuencias")

# Sexo del jefe de familia
freq_sexojef <- table(df$sexojef)
transform(freq_sexojef,
          rel.freq=prop.table(Freq))

ggplot(df, aes(x = sexojef)) +
  geom_bar(color = "darkslategray", fill = "indianred2", width = .5, linetype = 0)+
  xlab("Sexo del jefe/a de familia") + 
  ylab("Cantidad de hogares") + 
  ggtitle("Distribución de frecuencias")

# Inseguridad Alimentaria
freq_IA <- table(df$IA)
transform(freq_IA,
          rel.freq=prop.table(Freq))
ggplot(df, aes(x = IA)) +
  geom_bar(color = "darkslategray", fill = "palevioletred2", width = .5, linetype = 0)+
  xlab("Inseguridad Alimentaria - IA") + 
  ylab("Cantidad de hogares") + 
  ggtitle("Distribución de frecuencias")

# Número de personas en el hogar
k = ceiling(1 + 3.3*log10(length(df$numpeho)))
ac = (max(df$numpeho)-min(df$numpeho))/k

bins <- seq(min(df$numpeho), max(df$numpeho), by = ac)

class.numpeho <- cut(df$numpeho, breaks = bins, include.lowest=TRUE, dig.lab = 10)

dist.freq <- table(class.numpeho)
transform(dist.freq, 
          rel.freq=prop.table(Freq), 
          cum.freq=cumsum(prop.table(Freq)))

ggplot(df) + 
  geom_histogram(bins = k, binwidth = .5,  aes(x = numpeho), fill = 'steelblue') + 
  xlab("Número de personas en el hogar") + 
  ylab("Cantidad de hogares") + 
  ggtitle("Distribución de frecuencias")

# Edad del jefe/a de familia
k = ceiling(1 + 3.3*log10(length(df$edadjef)))
ac = (max(df$edadjef)-min(df$edadjef))/k

bins <- seq(min(df$edadjef), max(df$edadjef), by = ac)

class.edadjef <- cut(df$edadjef, breaks = bins, include.lowest=TRUE, dig.lab = 10)

dist.freq <- table(class.edadjef)
transform(dist.freq, 
          rel.freq=prop.table(Freq), 
          cum.freq=cumsum(prop.table(Freq)))

ggplot(df) + 
    geom_histogram(bins = k, binwidth = 1, aes(x = edadjef), fill = 'steelblue') + 
  xlab("Edad del jefe/a de familia") + 
  ylab("Cantidad de hogares") + 
  ggtitle("Distribución de frecuencias")

sd(df$añosedu)

# Años de educación del jefe/a de familia
k = ceiling(1 + 3.3*log10(length(df$añosedu)))
ac = (max(df$añosedu)-min(df$añosedu))/k

bins <- seq(min(df$añosedu), max(df$añosedu), by = ac)

class.añosedu <- cut(df$añosedu, breaks = bins, include.lowest=TRUE, dig.lab = 10)

dist.freq <- table(class.añosedu)
transform(dist.freq, 
          rel.freq=prop.table(Freq), 
          cum.freq=cumsum(prop.table(Freq)))

ggplot(df) + 
  geom_histogram(binwidth = 1, aes(x = añosedu ), fill = 'steelblue') + 
  xlab("Años de educación del jefe/a de familia") + 
  ylab("Cantidad de hogares") + 
  ggtitle("Distribución de frecuencias")


# Logaritmo natural del gasto en alimentos saludables
k = ceiling(1 + 3.3*log10(length(df$ln_als)))

ac = (max(df$ln_als)-min(df$ln_als))/k

bins <- seq(min(df$ln_als), max(df$ln_als), by = ac)

class.ln_als <- cut(df$ln_als, breaks = bins, include.lowest=TRUE, dig.lab = 10)

dist.freq <- table(class.ln_als)
transform(dist.freq, 
          rel.freq=prop.table(Freq), 
          cum.freq=cumsum(prop.table(Freq)))

ggplot(df) + 
  geom_histogram( aes(x = ln_als ), fill = 'steelblue') + 
  xlab("Logaritmo natural del gasto en alimentos saludables") + 
  ylab("Cantidad de hogares") + 
  ggtitle("Distribución de frecuencias")

# Logaritmo natural del gasto en alimentos no saludables
k = ceiling(1 + 3.3*log10(length(exp(df$ln_alns))))
ac = (max(df$ln_alns)-min(df$ln_alns))/k

bins <- seq(min(df$ln_alns), max(df$ln_alns), by = ac)

class.ln_alns <- cut(df$ln_alns, breaks = bins, include.lowest=TRUE, dig.lab = 10)

dist.freq <- table(class.ln_alns)
transform(dist.freq, 
          rel.freq=prop.table(Freq), 
          cum.freq=cumsum(prop.table(Freq)))

ggplot(df) + 
  geom_histogram(bins=k, aes(x = ln_alns ), fill = 'steelblue') + 
  xlab("Logaritmo natural del gasto en alimentos no saludables") + 
  ylab("Cantidad de hogares") + 
  ggtitle("Distribución de frecuencias")


# Correlacion entre variables cuantitativas

dfcorr.select <- select(df, numpeho, edadjef, añosedu, ln_als, ln_alns)
corr_matrix <- round(cor(dfcorr.select),4)
corr_matrix

# Interpretación de la matriz en el reporte


# Exploración gráfica para encontrar patrones en gastos

# ¿Cuáles son los patrones de gasto en alimentos saludables y no saludables en 
# los hogares mexicanos considerando su nivel socioeconómico, si cuenta con recursos
# financieros extra y si presenta inseguridad alimentaria?
# 
# - ¿Los hogares con menor nivel socioeconómico tienden a gastar más en productos 
#  no saludables que los hogares con mayores niveles socioeconómicos?  
# De acuerdo con las gráficas de caja, los niveles socioeconómicos más altos
# presentan un patrón de gastar más en alimentos no saludables.

# - ¿El que los hogares con menor nivel socioeconómico gasten más en productos
#  no saludables los lleva a que presente inseguridad alimentaria?
# En las graficas de caja se observa que, en todos los niveles socioeconómicos,
# los hogares con inseguridad alimentaria presentan un gasto mayor
# en alimentos no saludables, no sólo los niveles socioeconómicos bajos.

# Gasto en alimentos no saludables
ggplot(df, aes(x=ln_alns, y=nse5f)) +
  geom_boxplot() +
  xlab("Gasto en alimentos no saludables") + 
  ylab("Nivel socioeconómico") + 
  ggtitle("Gasto en alimentos no saludables y nivel Socioeconomico")+
  theme_classic()

ggplot(df, aes(x=ln_alns, y=nse5f, color=IA)) +
  geom_boxplot() +
  xlab("Gasto en alimentos no saludables") + 
  ylab("Nivel socioeconómico") + 
  ggtitle("Gasto en alimentos no saludables y nivel Socioeconomico")+
  theme_classic()

ggplot(df, aes(x=ln_alns, y=refin, color=IA)) +
  geom_boxplot() +
  xlab("Gasto en alimentos no saludables") + 
  ylab("Recursos financieros adicionales") + 
  ggtitle("Gasto en alimentos no saludables y recursos adicionales")+
  theme_classic()

# Gasto en alimentos saludables
ggplot(df, aes(x=ln_als, y=nse5f)) +
  geom_boxplot() +
  xlab("Gasto en alimentos saludables") + 
  ylab("Nivel socioeconómico") + 
  ggtitle("Gasto en alimentos saludables y nivel Socioeconomico")+
  theme_classic()


ggplot(df, aes(x=ln_als, y=nse5f, color=IA)) +
  geom_boxplot() +
  xlab("Gasto en alimentos saludables") + 
  ylab("Recursos financieros adicionales") + 
  ggtitle("Gasto en alimentos saludables y nivel Socioeconomico")+
  theme_classic()

ggplot(df, aes(x=ln_als, y=refin, color=IA)) +
  geom_boxplot() +
  xlab("Gasto en alimentos saludables") + 
  ylab("Recursos financieros adicionales") + 
  ggtitle("Gasto en alimentos saludables y recursos adicionales")+
  theme_classic()


# III. Calcula probabilidades que nos permitan entender el problema en México 

# Para el gasto en alimentos saludables
x.als <- df$ln_als
mean.als <- mean(df$ln_als)
sd.als <- sd(df$ln_als)

hist(x.als, main = "Histograma Gasto en Alimentos Saludables",
     xlab = "", ylab = "Densidad", prob = TRUE)

y.als <- dnorm(x.als, mean = mean.als, sd = sd.als)*sd.als+mean.als 

plot(x.als, y.als, type = "p", xlab = "X", ylab = "f(x)",
     main = "Densidad de Probabilidad Alimentos Saludables", 
     sub = expression(paste(mu == 6.192, " y ", sigma == 0.688)))
abline(v = mean.als, lwd = 2, lty = 2)

# Para el gasto en alimentos no saludables
x.alns <- df$ln_alns
mean.alns <- mean(df$ln_alns)
sd.alns <- sd(df$ln_alns)

hist(x.alns, main = "Histograma Gasto en Alimentos No Saludables",
     xlab = "", ylab="Densidad", prob = TRUE)

x.alns <- df$ln_alns
y.alns <- dnorm(x.alns, mean = mean.alns, sd = sd.alns) 

plot(x.alns, y.alns, type = "p", xlab = "X", ylab = "f(x)",
     main = "Densidad de Probabilidad Alimentos No Saludables", 
     sub = expression(paste(mu == 4.118, " y ", sigma == 1.041)))
abline(v = mean.alns, lwd = 2, lty = 2) 

# ¿Cuál es la probabilidad de que el gasto en alimento no saludable sea
# mayor a un 50% del promedio del gasto en alimento saludable?
prob1 <- pnorm(q = 0.5*mean.als, mean = mean.alns, sd = sd.alns, lower.tail = FALSE)
prob1
# 0.8369784

# ¿Hasta cuanto gastan en alimento no saludable el 90% de los  hogares?
quant <- qnorm(p = 0.9, mean = mean.alns, sd = sd.alns)
exp(quant)
#233.5857

# ¿Cuál es el rango de gasto en alimento no saludable en el que
# se encuentra el 80% de los hogares?
rango1 <- qnorm(p = 0.2/2, mean = mean.alns, sd = sd.alns)
rango2 <- qnorm(p = 0.2/2, mean = mean.alns, sd = sd.alns, lower.tail = FALSE)
exp(rango1)
exp(rango2)
# El 80% de los hogares gasta entre 16.18 y 233.58 en alimentos no saludables


# IV. Plantea hipótesis estadísticas y concluye sobre ellas para entender el 
# problema en México 

# Se grafican Los niveles socioeconpomicos con relación al Gasto de alimentos no saludables.
boxplot(df$ln_alns ~ df$nse5f, 
        data = df,
        xlab = "Niveles Socioeconómicos", 
        ylab = "Gasto en alimentos no saludables", 
        main = "Gráfica de la Hipótesis", 
        col = rgb(0, 1, 1, alpha = 0.4))

# Se aplica el análisis de varianza (de un factor) el cual nos permite comparar la media de una variable 
# considerando dos o más niveles/grupos de factor. En este caso la media del gasto de alimentos no saludables considerando
# Los 5 niveles socioeconómicos.
anova <- aov(df$ln_alns ~ df$nse5f,
             data = df)

# Se muestra el resultado del análisis.
summary(anova)

# Resultado:
# A nivel de mayor al 99%, Existe evidencia estadística para rechazar la Ho referente a que hogares con menor nivel socioeconómico tienden a 
# gastar más en productos no saludables que las personas con mayores niveles socioeconómicos. 

# Ideas:
# Comparar gasto en alimento no saludable, con nse, rfin e IA, si las medidas de tendencia
# central son iguales entre los grupos de nse, por ejemplo, el gasto en alimento
# saludable no depende del nivel socioeconómico, y así para las otras dos variables y
# sus grupos

# Ho: El gasto en alimentos no saludables es igual en los hogares que presentan
# inseguridad alimentaria que en los que no presentan inseguridad alimentaria
# Ha: El gasto en alimentos no saludables es diferente en los hogares que
# presentan inseguridad alimentaria que en los que no presentan inseguridad
# alimentaria
# - contrastar gasto en alimento saludable


# V. Estima un modelo de regresión, lineal o logístico, para identificar los
# determinantes de la inseguridad alimentaria en México 

attach(df)

#Se usa el modelo de regresion logistica con el metodo de máxima verosimilitud

#Primer modelo incluyendo todas las variables
logistic.1a <- glm(IA ~ nse5f + numpeho + refin + añosedu + ln_als + ln_alns
                  + sexojef + area, family = binomial)
summary(logistic.1a)
# De acuerdo con los valores p obtenidos, todas las variables
# presentan significancia o determinan en cierta medida el comportamiento
# de IA, pero se observa que las que tienen menor significación comparadas
# con el resto son: area y gasto en alimentos saludables.

#Modelo sin la variable area
logistic.1 <- glm(IA ~ nse5f + numpeho + refin + añosedu + ln_als + ln_alns
                  + sexojef , family = binomial)

#Se revisa que las variables tengan significacion
summary(logistic.1)
# Se observa que el criterio de Akaike (AIC) para determinar un mejor desempeño 
# de modelo fue 3 puntos mayor, por lo que, al parecer incluir todas las 
# variables de la base de datos describe mejor el comportamiento de eliminar
# las de menor significación


#Se realiza el test anova para ver la signifcacion de las variables
anova(logistic.1, test = "Chisq")


#Comparación de clasificación predicha y observaciones

#Limite 0.5
#Si la probabilidad de que la variable adquiera el valor 1 
#"Presenta Inseguridad alimentaria" es superior a 0.5 para la prueba
#se asigna a este nivel "Presenta Inseguridad Alimentaria"
df$predicho_5 <- as.numeric(logistic.1$fitted.values>=0.5)
df$predicho_5 <- factor(df$predicho_5, labels = levels(df$IA))

#Reference (Muestra)
table(df$IA)

#Matriz de confusión para revisar los resultados predichos del modelos contra las observaciones
(mc_5 <- caret::confusionMatrix(df$predicho_5, df$IA, positive = "Presenta IA"))

#Grafica de los resultados
mosaic(mc_5$table, shade = T, colorize = T, main = "Limite 0.5", 
       gp = gpar(fill = matrix(c("Tan", "orange", "orange", "Tan"), 2, 2)))



#Limite 0.7 
#Si la probabilidad de que la variable adquiera el valor 1 
#"Presenta Inseguridad alimentaria" es superior a 0.7 para la prueba
#se asigna a este nivel "Presenta Inseguridad Alimentaria"
df$predicho_7 <- as.numeric(logistic.1$fitted.values>=0.7)
df$predicho_7 <- factor(df$predicho_7, labels = levels(df$IA))
#Reference (Muestra)
table(df$IA)
#Matriz de confucion para revisar los resultados predichos del modelos contra las observaciones
(mc_7 <- caret::confusionMatrix(df$predicho_7, df$IA, positive = "Presenta IA"))

#Grafica de los resultados
mosaic(mc_7$table, shade = T, colorize = T, main = "Limite 0.7", 
       gp = gpar(fill = matrix(c("Tan", "orange", "orange", "Tan"), 2, 2)))

# Tal vez se logren mejores niveles de precisión al incluir con un mejor
# tratamiento los datos que fueron eliminiamos por estar incompletos


# VI. Escribe tu análisis en un archivo README.MD y tu código en un script de R y 
# publica ambos en un repositorio de Github.


