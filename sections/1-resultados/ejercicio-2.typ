= Ejercicio 2: Pruebas de Integración del Proyecto Final

#set par(justify: true)

El grupo debe aplicar pruebas de integración sobre la arquitectura de su proyecto de fin de curso. El enfoque debe centrarse en verificar la cohesión y el flujo de datos entre los componentes que han sido desarrollados. El grupo puede elegir la herramienta (Requests, Supertest, REST Assured, Playwright, etc.) que mejor se adapte a su lenguaje de programación.

*Tarea de Análisis de Errores:*

1. *Mapeo de la Frontera:* Identifique el punto donde el Subsistema A entrega el control o los datos al Subsistema B.

2. *Inyección de Fallas de Interfaz:* Diseñe al menos 3 casos de prueba orientados a "romper" la comunicación:
   - *Caso 1 (Sintáctico):* Envíe un objeto con campos faltantes o tipos de datos erróneos.
   - *Caso 2 (Semántico):* Envíe valores legales pero fuera de lógica para el receptor (ej. una fecha de entrega anterior a la de pedido).
   - *Caso 3 (Resiliencia):* Simule una latencia alta en la respuesta del subsistema B y analice si el subsistema A maneja el timeout o colapsa.

3. *Documentación de Discrepancias:* Por cada falla encontrada, complete un Reporte de Incidente que detalle el "Resultado Esperado" vs. el "Resultado Real" observado en la interfaz.
