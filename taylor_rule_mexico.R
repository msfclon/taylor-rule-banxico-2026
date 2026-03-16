# ==============================================================================
# Estimación de la Regla de Taylor para México y Simulación de Escenarios
# ==============================================================================


library(mFilter)
library(lmtest)
library(sandwich)
library(ggplot2)
library(gridExtra)

# 2. Carga de datos
datos <- read.csv(file.choose(), stringsAsFactors = FALSE)



# Filtro Hodrick-Prescott para la tendencia del IGAE (lambda = 1600)
hp <- hpfilter(log(datos$igae), freq = 1600)

# Cálculo de variables y coerción a formato numérico
datos$brecha    <- as.numeric(100 * (datos$igae - exp(hp$trend)) / exp(hp$trend))
datos$delta_tc  <- as.numeric(c(NA, 100 * diff(datos$tc) / datos$tc[-nrow(datos)]))
datos$tasa_lag1 <- as.numeric(c(NA, datos$tasa_objetivo[-nrow(datos)]))
datos$inflacion <- as.numeric(datos$inflacion)

# Generar subset eliminando NAs producidos por los rezagos
datos_reg <- datos[complete.cases(datos), ]


# 4. Estimación del Modelo (OLS)


modelo <- lm(tasa_objetivo ~ inflacion + brecha + delta_tc + tasa_lag1, data = datos_reg)

# Diagnóstico y resultados robustos (HC1)
summary(modelo)
coeftest(modelo, vcov. = vcovHC(modelo, type = "HC1"))
dwtest(modelo)


# 5. Simulación de Escenarios (Marzo 2026)


# Escenario 1: Condiciones previas al conflicto en Irán
pred_pre <- predict(modelo, newdata = data.frame(
  inflacion = 4.02, brecha = -0.30, delta_tc = -1.72, tasa_lag1 = 7.00
))

# Escenario 2: Conflicto de corta duración
pred_corto <- predict(modelo, newdata = data.frame(
  inflacion = 4.50, brecha = -1.50, delta_tc = 3.00, tasa_lag1 = 7.00
))

# Escenario 3: Conflicto prolongado
pred_largo <- predict(modelo, newdata = data.frame(
  inflacion = 5.20, brecha = -2.50, delta_tc = 6.00, tasa_lag1 = 7.00
))

cat("\n--- Resultados de Simulación ---\n")
cat("Tasa actual de Banxico: 7.00%\n\n")
cat(sprintf("Escenario 1 (Pre-conflicto):   %.2f%%\n", pred_pre))
cat(sprintf("Escenario 2 (Conflicto corto): %.2f%%\n", pred_corto))
cat(sprintf("Escenario 3 (Conflicto largo): %.2f%%\n", pred_largo))


# 6. Gráficos de Resultados


# Almacenar valores predichos
datos_reg$tasa_pred <- fitted(modelo)

# Construcción de vector de fechas para el eje X
datos_reg$anio  <- as.numeric(substr(datos_reg$trimestre, 1, 4))
datos_reg$q     <- as.numeric(substr(datos_reg$trimestre, 7, 7))
datos_reg$fecha <- as.Date(paste0(datos_reg$anio, "-", 
                                  sprintf("%02d", (datos_reg$q - 1) * 3 + 1), 
                                  "-01"))

#Panel 1: Ajuste del modelo 
g1 <- ggplot(datos_reg, aes(x = fecha)) +
  geom_line(aes(y = tasa_objetivo, color = "Tasa Banxico"), linewidth = 1) +
  geom_line(aes(y = tasa_pred, color = "Regla de Taylor"), linewidth = 0.8, linetype = "dashed") +
  scale_color_manual(values = c("Tasa Banxico" = "blue", "Regla de Taylor" = "red")) +
  labs(title = "Tasa observada vs Regla de Taylor", y = "Tasa (%)", x = "", color = "") +
  theme_minimal() +
  theme(legend.position = "bottom")

#Panel 2: Brecha del producto 
g2 <- ggplot(datos_reg, aes(x = fecha, y = brecha)) +
  geom_col(fill = "steelblue", alpha = 0.7) +
  geom_hline(yintercept = 0, linewidth = 0.5) +
  labs(title = "Brecha del producto", y = "% desviación", x = "") +
  theme_minimal()

#Panel 3: Evolución de Inflación 
g3 <- ggplot(datos_reg, aes(x = fecha, y = inflacion)) +
  geom_line(color = "darkgreen", linewidth = 1) +
  geom_hline(yintercept = 3.0, linetype = "dashed", color = "red") +
  labs(title = "Inflación general interanual", y = "%", x = "") +
  theme_minimal()

#Panel 4: Escenarios de política 
escenarios <- data.frame(
  nombre = factor(c("Pre-conflicto", "Conflicto corto", "Conflicto largo"),
                  levels = c("Pre-conflicto", "Conflicto corto", "Conflicto largo")),
  tasa = c(pred_pre, pred_corto, pred_largo)
)

g4 <- ggplot(escenarios, aes(x = nombre, y = tasa, fill = nombre)) +
  geom_col(alpha = 0.8, color = "black") +
  geom_hline(yintercept = 7.00, linetype = "dashed", linewidth = 1) +
  geom_text(aes(label = sprintf("%.2f%%", tasa)), vjust = -0.5, fontface = "bold") +
  scale_fill_manual(values = c("#2196F3", "#FF9800", "#F44336")) +
  labs(title = "Simulación: Tasa Banxico (Marzo 2026)", y = "Tasa predicha (%)", x = "") +
  ylim(0, 8) +
  theme_minimal() +
  theme(legend.position = "none")

#Exportar Dashboard 
panel <- grid.arrange(g1, g2, g3, g4, ncol = 2, top = "Dinámica de la Regla de Taylor en México")

ggsave("taylor_rule_mexico.png", panel, width = 14, height = 10, dpi = 300)
ggsave("taylor_rule_mexico.pdf", panel, width = 14, height = 10)
