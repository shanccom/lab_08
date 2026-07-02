= Conclusión 1

#set par(justify: true)

#v(0.5em)

En este laboratorio se abordaron dos niveles complementarios de pruebas de integración sobre APIs REST. En el primer ejercicio, se implementó una API de catálogo de videojuegos en Node.js con Express y se verificó su comportamiento mediante pruebas manuales con Postman y pruebas automatizadas con Supertest + Jest. La suite de 10 tests cubrió flujos de persistencia cruzada (POST a GET), modificación de estado (PUT de stock) y validación de robustez (rechazo de datos inválidos con HTTP 400), demostrando que la API responde correctamente tanto en escenarios normales como en casos borde.

En el segundo ejercicio, se aplicaron pruebas de integración al Sync Server del proyecto final *Actual Budget*, utilizando Supertest + Vitest. Se identificó la frontera de comunicación HTTP entre el cliente y el servidor Express, y se diseñaron 25 casos de prueba organizados en tres categorías: fallas sintácticas (campos faltantes, tipos incorrectos), fallas semánticas (datos válidos pero inconsistentes con el estado del negocio) y resiliencia (latencia y rechazo temprano). Los resultados fueron mayoritariamente positivos: el servidor maneja correctamente las validaciones de entrada y el control de acceso. Sin embargo, se identificó un defecto de diseño en el servicio de archivos (`FilesService.get()`), que no distingue entre un archivo inexistente y uno eliminado lógicamente (`soft-delete`), haciendo que la operación DELETE no sea idempotente. Asimismo, se observó que los handlers carecen de timeouts explícitos, lo cual constituye una debilidad latente ante fallas de infraestructura.

Las pruebas de integración demostraron ser esenciales para detectar problemas que las pruebas unitarias no habrían revelado, particularmente aquellos relacionados con la coordinación de contratos de interfaz, la semántica del negocio en flujos multi-componente y la robustez ante condiciones adversas.
