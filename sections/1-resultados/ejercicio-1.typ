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

== Desarrollo del Backend - Catálogo de Videojuegos

=== I. Configuración del Proyecto

Se creó el proyecto #emph("videojuegos-api") con Node.js y Express.

#figure(
  image("/img/package_json_dependencias.png", width: 80%),
  caption: [Archivo #emph("package.json") con las dependencias instaladas]
)

=== II. Servidor Implementado

Se implementaron los siguientes endpoints en #emph("app.js"):

- POST /videojuegos - Crear videojuego
- GET /videojuegos/:id - Leer videojuego
- PUT /videojuegos/:id/stock - Actualizar stock
- DELETE /videojuegos/:id - Eliminar videojuego
- DELETE /videojuegos - Limpiar todos (para pruebas)

*Validaciones en POST:*
- Campos obligatorios: nombre, genero, stock, precio
- Tipos de datos: stock y precio numéricos
- Valores lógicos: stock y precio >= 0

=== III. Servidor en Ejecución

El servidor corre en #link("http://localhost:3000")[http://localhost:3000].

#figure(
  image("/img/servidor_corriendo.png", width: 80%),
  caption: [Servidor ejecutándose en la terminal]
)

=== IV. Pruebas Manuales con Postman

==== 4.1. Crear Videojuego - POST

#figure(
  image("/img/postman_post_crear_videojuego.png", width: 80%),
  caption: [Resultado: Status 201, ID asignado: 1]
)

==== 4.2. Leer Videojuego - GET

#figure(
  image("/img/postman_get_leer_videojuego.png", width: 80%),
  caption: [Resultado: Status 200, datos correctos]
)

==== 4.3. Actualizar Stock - PUT

#figure(
  image("/img/postman_put_actualizar_stock.png", width: 80%),
  caption: [Resultado: Status 200, stock actualizado]
)

==== 4.4. Eliminar Videojuego - DELETE

#figure(
  image("/img/postman_delete_eliminar_videojuego.png", width: 80%),
  caption: [Resultado: Status 200, mensaje de éxito]
)

==== 4.5. Verificar Recurso Eliminado - GET 404

#figure(
  image("/img/postman_get_404_no_encontrado.png", width: 80%),
  caption: [Resultado: Status 404, "Videojuego no encontrado"]
)

==== 4.6. Validaciones - Errores 400

#figure(
  image("/img/postman_error_400_texto_en_stock.png", width: 80%),
  caption: [Resultado: Status 400, "Stock y precio deben ser valores numéricos"]
)

#figure(
  image("/img/postman_error_400_campo_faltante.png", width: 80%),
  caption: [Resultado: Status 400, "Todos los campos son obligatorios"]
)

=== Obteniendo nuestro sistema listo para ser testeado

- Servidor implementado: Completado
- Servidor en ejecución: Completado
- Pruebas manuales Postman: Completado
- Capturas de evidencias: Completado

=== Test:

- Continuando con la parte de test ahora procederemos a aplicar lo que paso
