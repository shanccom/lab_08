= Conclusión 1

#set par(justify: true)

#v(0.5em)

Este laboratorio nos permitió experimentar dos enfoques complementarios de pruebas de integración sobre APIs REST. En el primer ejercicio implementamos desde cero una API de catálogo de videojuegos con Node.js y Express. Nos llamó la atención lo sencillo que resultó pasar de las pruebas manuales con Postman —que fueron útiles para entender el comportamiento de cada endpoint— a una suite automatizada con Supertest y Jest. Los 10 tests que escribimos cubrieron el flujo completo: crear un recurso, leerlo con el ID generado, modificar su estado y validar que los datos incorrectos fueran rechazados con 400. Ver los tests pasar en verde confirmó que nuestra API se comportaba correctamente incluso en los casos borde.

El segundo ejercicio fue más retador, porque implicó probar la integración de un proyecto real con arquitectura compleja: el Sync Server de *Actual Budget*. Aprendimos que identificar la frontera entre subsistemas es un paso crítico —si no entiendes dónde y cómo se pasan los datos, no puedes diseñar buenos casos de prueba. Usando Supertest con Vitest escribimos 25 tests adicionales organizados en tres categorías. La mayoría del sistema respondió correctamente, pero encontramos algo que nos sorprendió: el método `FilesService.get()` no distingue entre un archivo inexistente y uno que ya fue eliminado. Esto significa que eliminar dos veces el mismo archivo no es idempotente —el segundo intento devuelve 400 en vez de 200. Es un defecto sutil que probablemente nunca se habría detectado con pruebas unitarias aisladas. También notamos que los handlers no tienen timeouts, una debilidad que no se manifiesta en SQLite local pero que podría ser crítica en producción.

La principal lección que nos llevamos es que las pruebas de integración no son un lujo: son la única forma de verificar que los contratos entre componentes realmente se cumplen. Las pruebas unitarias nos dicen que cada pieza funciona por separado; las de integración nos dicen si las piezas encajan.
