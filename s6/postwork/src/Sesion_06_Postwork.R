# Supongamos que nuestro trabajo consiste en aconsejar a un cliente sobre como
# mejorar las ventas de un producto particular, y el conjunto de datos con el
# que disponemos son datos de publicidad que consisten en las ventas de aquel
# producto en 200 diferentes mercados, junto con presupuestos de publicidad para
# el producto en cada uno de aquellos mercados para tres medios de comunicación
# diferentes: TV, radio, y periódico. No es posible para nuestro cliente
# incrementar directamente las ventas del producto. Por otro lado, ellos pueden
# controlar el gasto en publicidad para cada uno de los tres medios de
# comunicación. Por lo tanto, si determinamos que hay una asociación entre
# publicidad y ventas, entonces podemos instruir a nuestro cliente para que
# ajuste los presupuestos de publicidad, y así indirectamente incrementar las
# ventas.
#
# En otras palabras, nuestro objetivo es desarrollar un modelo preciso que pueda
# ser usado para predecir las ventas sobre la base de los tres presupuestos de
# medios de comunicación. Ajuste modelos de regresión lineal múltiple a los
# datos advertisement.csv y elija el modelo más adecuado siguiendo los
# procedimientos vistos
# 
# Considera:
#   
#  Y: Sales (Ventas de un producto)
# X1: TV (Presupuesto de publicidad en TV para el producto)
# X2: Radio (Presupuesto de publicidad en Radio para el producto)
# X3: Newspaper (Presupuesto de publicidad en Periódico para el producto)

adv <- read.csv("https://raw.githubusercontent.com/beduExpert/Programacion-R-Santander-2022/main/Sesion-06/data/advertising.csv")

# Visualización de los datos
head(adv)

# Matriz de correlación
round(cor(adv),4) 

# Gráfica de dispersión de la matriz de correlación
pairs(~ Sales + TV + Radio + Newspaper, 
      data = adv, gap = 0.4, cex.labels = 1.5)


# Estimación por Mínimos Cuadrados Ordinarios (OLS)
# Y_Sales = beta0 + beta1*TV + beta2*Radio + beta3*Newspaper + e

attach(adv)
m1 <- lm(Sales ~ TV + Radio + Newspaper)
summary(m1)

# De acuerdo con R cuadrada, el modelo explica en 90.11% los cambios en 
# Sales.
# De estos resultados también se puede concluir que la variable Newspaper 
# no es significativa. Se probará el modelo sin la variable Newspaper:
# Y_Sales = beta0 + beta1*TV + beta2*Radio + e

m2 <- lm(Sales ~ TV + Radio)
summary(m2)

# De acuerdo con R cuadrada, el modelo explica en 90.16% los cambios en 
# Sales, un poco más alto que en m1

# Validación del modelo
# 1) El término de error no tiene correlación significativa con las variables 

StanRes2 <- rstandard(m2)
summary(StanRes2)
par(mfrow = c(2, 2))
plot(TV, StanRes2, ylab = "Residuales Estandarizados")
plot(Radio, StanRes2, ylab = "Residuales Estandarizados")
qqnorm(StanRes2)
qqline(StanRes2)


# Se observa que los residuales estandarizados no tienen una correlación
# significativa con las variables

# 2) El término de error sigue una distribución normal
shapiro.test(StanRes2)

# De acuerdo con el valor de W, 0.97535, la distribución de los residuales 
# estandarizados es cercana a 1, por lo que si se acerca a la distribución 
# normal

# Una vez validados estos supuestos, podemos utilizar nuestro modelo estimado 
# para realizar predicciones y obtener su intervalo de confianza

# Datos de ejemplo para predicción de ventas
data <- data.frame(
  TV = c(250.0, 300.0, 350.0, 400.0, 500.0),
  Radio = c(60.0, 80.0, 100.0, 120.0, 140.0)
)


predict(m2, newdata = data, interval = "confidence", level = 0.95)

# Para el caso de designar un presupuesto de TV de $500 y uno de Radio de $140
# se predice un valor de Sales de $46.8598, el intervalo del 95% de 
# confianza asociado con estos presupuestos es de 44.83 a 44.88. Esto
# significa que, de acuerdo con este modelo, el presupuesto para TV de $500
# junto con un presupuesto de Radio de $140 estarían generando $46.85 en
# ventas, con un rango de ventas de $44.83, como mínimo y $48.88 como máximo.
