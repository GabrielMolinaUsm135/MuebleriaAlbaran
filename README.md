# Proyecto Inteligencia de Negocios

CASO 1: Muebleria Albarrán

## Integrantes
  - Gabriel Molina - 'GabrielMolinaUsm135'
  - Macarena Mogollón - 'makimogollon'
  - Lukas Cordova - 'lukascordova'
  - Daniel Garcia - 

**Sección:** 300
**Profesor:** Hernan Saavedra.

## Descripcion del problema

Mueblería Albarrán es una empresa que ha experimentado un crecimiento acelerado en sus operaciones comerciales. Actualmente, la organización almacena sus datos operativos en una base de datos transaccional relacional que registra sucursales, clientes, empleados, ventas y productos. No obstante, no dispone de un sistema centralizado de Inteligencia de Negocios optimizado para analítica, lo que dificulta la consolidación de información histórica y la toma de decisiones estratégicas de manera oportuna y eficiente por parte de su administración.

## Objetivo del proyecto

Diseñar e implementar la primera fase de una solución de Inteligencia de Negocios mediante el diseño de un modelo dimensional (Data Warehouse) y la construcción de procesos de extracción, transformación y carga (ETL) de los datos, permitiendo unificar la información de ventas e identificar las bases para la analítica del rendimiento del negocio.

1. **Total de Ventas Netas ($):**
   - **Fórmula:** $\sum (\text{Cantidad} \times \text{PrecioUnitario} - \text{Descuento})$
   - **Justificación:** Mide los ingresos reales generados por la venta de muebles tras aplicar los descuentos correspondientes, siendo fundamental para evaluar la salud financiera del negocio.

2. **Volumen de Unidades Vendidas:**
   - **Fórmula:** $\sum \text{Cantidad}$
   - **Justificación:** Permite identificar la rotación de stock, la demanda por categoría de productos y el volumen físico comercializado por sucursal.

3. **Ticket Promedio por Venta ($):**
   - **Fórmula:** $\frac{\text{Total Ventas Netas}}{\text{Número de Transacciones}}$
   - **Justificación:** Cuantifica el desembolso medio por transacción realizada, permitiendo evaluar la efectividad comercial y comportamientos de compra.

4. **Descuento Promedio Otorgado (%):**
   - **Fórmula:** $\frac{\sum \text{Descuento}}{\sum (\text{Cantidad} \times \text{PrecioUnitario})} \times 100$
   - **Justificación:** Controla el impacto y margen cedido en estrategias y promociones comerciales.
