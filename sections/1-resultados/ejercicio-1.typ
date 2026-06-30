= Ejercicio 1: Automatización con Supertest

#set par(justify: true)

Elijan una temática de su preferencia (ej. catálogo de videojuegos, gestión de una biblioteca musical, reserva de películas, etc.) e implementen una API REST básica en Node.js + Express.

Posteriormente, diseñen y ejecuten una suite completa de pruebas de integración utilizando Supertest y Jest/Mocha.

*Requerimientos de la Prueba:*

- *Flujo de Persistencia Cruzada:* Validar la integración secuencial entre la creación de un recurso (POST /recurso) y su posterior lectura (GET /recurso/:id), asegurando que el ID generado dinámicamente en el primer endpoint sea el puente de entrada para el segundo.

- *Simulación de Modificación de Estado:* Implementar y verificar un endpoint que altere una propiedad cuantitativa del recurso (ej. restar stock, cambiar nivel, actualizar reproducciones) y confirmar mediante un GET posterior que el cambio se consolidó en el mock de persistencia o base de datos de pruebas.

- *Validación de Robustez (Edge Cases):* Asegurar que el sistema maneje correctamente los desajustes de datos o tipos inválidos (ej. enviar un texto en un campo numérico o dejar campos obligatorios vacíos) devolviendo exactamente el código de estado HTTP 400 (Bad Request) junto con su respectivo mensaje de error.

*Entregables:*
- Archivo de la API (app.js).
- Archivo de pruebas (tema_libre.test.js).
- Captura de pantalla o reporte en texto del resultado de la ejecución en la terminal usando Jest/Mocha.
