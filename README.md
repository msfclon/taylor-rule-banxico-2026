# 📈 Regla de Taylor para México: Análisis del Shock de Irán y la Decisión de Banxico (Marzo 2026)

Curso:Macroeconomía Financiera — UDLAP  
Autor: Mario Sánchez Flores  
Fecha:Marzo 2026

---

## Descripción

Este proyecto estima una **Regla de Taylor extendida para economía abierta** mediante
Mínimos Cuadrados Ordinarios (OLS) con errores robustos (HC1), usando 72 observaciones
trimestrales de México (2008:Q1–2025:Q4). A partir del modelo estimado, se simulan tres
escenarios del conflicto bélico EE.UU.–Israel–Irán (febrero 2026) para predecir la decisión
de política monetaria de Banxico del 26 de marzo de 2026.

**Conclusión:** El modelo predice una tasa entre 6.74% y 6.83%, respaldando la predicción
de que Banxico mantendría la tasa en 7.00%.

---

## Metodología

Modelo de Regla de Taylor con inercia para economía abierta (Clarida et al., 1998; Ball, 1999):

$$i_t = \alpha + \beta_1\pi_t + \beta_2\tilde{y}_t + \beta_3\Delta e_t + \rho\, i_{t-1} + \varepsilon_t$$

- **Estimación:** OLS con errores estándar robustos a heterocedasticidad (White HC1)
- **Brecha del producto:** Filtro Hodrick-Prescott (λ = 1,600) sobre IGAE desestacionalizado
- **R² ajustado:** 0.97 | **Coeficiente de inercia:** ρ̂ = 0.8918

---

## Resultados principales

| Variable | Coeficiente | p-valor |
|---|---|---|
| Inflación (β₁) | 0.2259 | 0.000 *** |
| Brecha del producto (β₂) | 0.1109 | 0.003 ** |
| Variación tipo de cambio (β₃) | 0.0085 | 0.520 |
| Tasa rezagada (ρ) | 0.8918 | 0.000 *** |

##Simulación de escenarios — Marzo 2026

| Escenario | Tasa predicha |
|---|---|
| Pre-conflicto | 6.74% |
| Conflicto corto | 6.75% |
| Conflicto prolongado | 6.83% |

---

##Archivos
```
├── taylor_banxico.R       # Código: estimación OLS, filtro HP, simulación
├── reporte.pdf            # Ensayo final con tablas, figuras y referencias
└── README.md
```

---

## 🛠️ Herramientas

![R](https://img.shields.io/badge/R-276DC3?style=flat&logo=r&logoColor=white)
![LaTeX](https://img.shields.io/badge/LaTeX-008080?style=flat&logo=latex&logoColor=white)

- **R:** `lmtest`, `sandwich`, `mFilter`, `ggplot2`
- **Datos:** Banxico SIE · INEGI BIE · FRED (DEXMXUS)

---

## 📚 Referencias clave

- Taylor, J.B. (1993). *Discretion Versus Policy Rules in Practice.* Carnegie-Rochester.
- Clarida, Galí & Gertler (1998). *Monetary Policy Rules in Practice.* European Economic Review.
- Ball (1999). *Policy Rules for Open Economies.* University of Chicago Press.
