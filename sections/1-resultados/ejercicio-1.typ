= Ejercicio 1: Automatización con Supertest

#import "../../components/code-block.typ": code-block

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

Se creó el proyecto con Node.js y Express. Las dependencias utilizadas se muestran en el archivo #emph("package.json"):

#code-block(file: "src/ejercicio-1/package.json", lang: "json", text-size: 8pt)

=== II. Servidor Implementado

Se implementaron los siguientes endpoints en #emph("app.js"):

- POST /videojuegos - Crear videojuego
- GET /videojuegos/:id - Leer videojuego
- PUT /videojuegos/:id/stock - Actualizar stock
- DELETE /videojuegos/:id - Eliminar videojuego
- DELETE /videojuegos - Limpiar todos (para pruebas)

El archivo #emph("server.js") importa la aplicación desde #emph("app.js") e inicia el servidor en el puerto 3000:

#code-block(file: "src/ejercicio-1/server.js", lang: "javascript", text-size: 8pt)

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

Se envió un POST a `/videojuegos` con un cuerpo JSON conteniendo los campos nombre, género, stock y precio. El servidor validó los datos, asignó un ID único automáticamente y respondió con 201 Created junto con el objeto del videojuego creado.

#figure(
  image("/img/postman_post_crear_videojuego.png", width: 80%),
  caption: [Resultado: Status 201, ID asignado: 1]
)

==== 4.2. Leer Videojuego - GET

A continuación consultamos el recurso recién creado haciendo un GET a `/videojuegos/1` con el ID asignado. El servidor lo encontró en el arreglo en memoria y devolvió 200 OK con los datos completos del videojuego.

#figure(
  image("/img/postman_get_leer_videojuego.png", width: 80%),
  caption: [Resultado: Status 200, datos correctos]
)

==== 4.3. Actualizar Stock - PUT

Probamos modificar el stock del videojuego con un PUT a `/videojuegos/1/stock` enviando el nuevo valor en el cuerpo. El servidor validó que fuera numérico y no negativo, localizó el recurso por su ID y actualizó la propiedad. Respondió con 200 OK y el objeto con el stock modificado.

#figure(
  image("/img/postman_put_actualizar_stock.png", width: 80%),
  caption: [Resultado: Status 200, stock actualizado]
)

==== 4.4. Eliminar Videojuego - DELETE

Luego ejecutamos un DELETE a `/videojuegos/1`. El servidor buscó el videojuego por su ID, lo eliminó del arreglo en memoria y respondió con 200 OK junto con un mensaje de confirmación.

#figure(
  image("/img/postman_delete_eliminar_videojuego.png", width: 80%),
  caption: [Resultado: Status 200, mensaje de éxito]
)

==== 4.5. Verificar Recurso Eliminado - GET 404

Para confirmar la eliminación, hicimos un GET a `/videojuegos/1` sobre el mismo ID. El servidor no encontró el recurso y respondió con 404 Not Found junto con el mensaje "Videojuego no encontrado".

#figure(
  image("/img/postman_get_404_no_encontrado.png", width: 80%),
  caption: [Resultado: Status 404, "Videojuego no encontrado"]
)

==== 4.6. Validaciones - Errores 400

Probamos los casos borde del endpoint POST. Al enviar un valor de tipo texto en el campo stock (por ejemplo, `"diez"` en lugar de un número), el servidor detectó el tipo inválido y respondió con 400 Bad Request y el mensaje correspondiente.

#figure(
  image("/img/postman_error_400_texto_en_stock.png", width: 80%),
  caption: [Resultado: Status 400, "Stock y precio deben ser valores numéricos"]
)

De igual forma, al omitir un campo obligatorio como nombre, el servidor validó su ausencia y respondió con 400 Bad Request indicando que todos los campos son obligatorios.

#figure(
  image("/img/postman_error_400_campo_faltante.png", width: 80%),
  caption: [Resultado: Status 400, "Todos los campos son obligatorios"]
)

=== V. Pruebas Automatizadas con Jest + Supertest

Se implementó una suite de pruebas de integración usando Jest como framework de testing y Supertest para realizar peticiones HTTP contra la API sin necesidad de levantar el servidor real.

==== 5.1. Estructura del Archivo de Pruebas

El archivo #emph("videojuegos.test.js") importa la aplicación desde #emph("app.js") y define los siguientes elementos:

- `beforeEach`: Se ejecuta antes de cada test y limpia la base de datos en memoria (#raw("DELETE /videojuegos")), asegurando que cada prueba comience con un estado aislado y predecible.
- `describe`: Agrupa todos los tests bajo una misma descripción.
- `test`: Cada caso de prueba individual verifica un escenario específico.

Se cubren 3 categorías principales que responden directamente a los requerimientos del enunciado, más un grupo adicional de manejo de errores 404:

#grid(
  columns: (1fr, 1fr),
  gutter: 1em,
  [
    #block(fill: rgb("#E8F5E9"), inset: 0.6em, radius: 6pt)[
      *1. Persistencia Cruzada* \
      Verifica que crear un videojuego (POST) y leerlo (GET) funciona correctamente encadenando el ID generado.
    ]
  ],
  [
    #block(fill: rgb("#E3F2FD"), inset: 0.6em, radius: 6pt)[
      *2. Modificación de Estado* \
      Verifica que actualizar el stock (PUT) persiste el cambio y se refleja en consultas posteriores (GET).
    ]
  ],
  [
    #block(fill: rgb("#FFF3E0"), inset: 0.6em, radius: 6pt)[
      *3. Validación de Robustez* \
      Verifica que la API rechaza datos inválidos con 400 Bad Request (texto en stock, campos faltantes, stock negativo).
    ]
  ],
  [
    #block(fill: rgb("#F3E5F5"), inset: 0.6em, radius: 6pt)[
      *4. Manejo de 404 y otros* \
      Verifica que rutas con IDs inexistentes y operaciones inválidas retornan 404 o 400 según corresponda.
    ]
  ],
)

==== 5.2. Casos de Prueba Implementados

A continuación se detalla cada caso de prueba implementado, organizado por categoría:

#grid(
  columns: (1fr,),
  gutter: 0.5em,

  // ---- Persistencia Cruzada ----
  block(fill: rgb("#E8F5E9"), inset: 0.7em, radius: 6pt)[
    #text(weight: "bold", size: 9pt)[Persistencia Cruzada (1 test)]

    - *Objetivo:* Validar que el ID generado en un POST puede usarse como puente para un GET posterior.
    - *Flujo:* Se envía un POST con los datos de un videojuego válido (nombre, genero, stock, precio). El servidor asigna un ID numérico automáticamente y responde con 201 Created. Luego se toma ese ID y se consulta con un GET, esperando 200 OK y que todos los campos coincidan exactamente con los enviados.
    - *Verificaciones clave:*
      - Código de estado 201 en POST y 200 en GET.
      - El ID generado es un número y está definido.
      - Los datos recuperados en el GET coinciden campo por campo con los datos originales.
  ],

  // ---- Modificación de Estado ----
  block(fill: rgb("#E3F2FD"), inset: 0.7em, radius: 6pt)[
    #text(weight: "bold", size: 9pt)[Modificación de Estado (1 test)]

    - *Objetivo:* Verificar que al modificar el stock mediante PUT, el cambio se consolida en la persistencia y puede verificarse con un GET posterior.
    - *Flujo:* Se crea un videojuego con stock inicial 5. Se envía un PUT a #raw("/videojuegos/:id/stock") con stock = 50. Se confirma que la respuesta del PUT ya refleja el nuevo stock. Luego se realiza un GET para verificar que el cambio persistió.
    - *Verificaciones clave:*
      - PUT responde con 200 y el body muestra stock = 50.
      - GET posterior también devuelve stock = 50.
      - El resto de campos (nombre, genero, precio) no se alteraron.
  ],

  // ---- Validación de Robustez ----
  block(fill: rgb("#FFF3E0"), inset: 0.7em, radius: 6pt)[
    #text(weight: "bold", size: 9pt)[Validación de Robustez (3 tests)]

    Se probaron 3 escenarios de datos inválidos en el endpoint POST:

    - *Texto en campo numérico:* Enviar `stock: "diez"` (string en lugar de número). El servidor detecta el tipo incorrecto y rechaza con 400 Bad Request y el mensaje `"Stock y precio deben ser valores numéricos"`.

    - *Campos obligatorios faltantes:* Enviar solo `nombre` y `genero`, omitiendo `stock` y `precio`. El servidor responde con 400 Bad Request y el mensaje `"Todos los campos son obligatorios: nombre, genero, stock, precio"`.

    - *Valores negativos:* Enviar `stock: -5`. El servidor rechaza con 400 Bad Request y el mensaje `"Stock y precio deben ser mayores o iguales a 0"`.
  ],

  // ---- Manejo de 404 ----
  block(fill: rgb("#F3E5F5"), inset: 0.7em, radius: 6pt)[
    #text(weight: "bold", size: 9pt)[Manejo de 404 y otros escenarios (5 tests)]

    Se verificaron operaciones sobre recursos inexistentes y validaciones adicionales:

    - *GET con ID inexistente:* Consultar `/videojuegos/9999` retorna 404 Not Found con mensaje `"Videojuego no encontrado"`.
    - *PUT stock con ID inexistente:* Actualizar stock de un ID que no existe retorna 404.
    - *PUT stock con valor no numérico:* Sobre un ID existente, enviar `stock: "diez"` retorna 400 con mensaje `"Stock debe ser un número mayor o igual a 0"`.
    - *DELETE con ID inexistente:* Eliminar un ID que no existe retorna 404.
    - *DELETE + GET:* Eliminar un videojuego existente (200) y luego consultarlo confirma que ya no existe (404).
  ],
)

==== 5.3. Fragmentos Clave del Código

*Estructura general:*

#code-block(file: "src/ejercicio-1/videojuegos.test.js", snippet: "estructura", lang: "javascript", text-size: 7pt)

*Persistencia cruzada (POST → GET):*

#code-block(file: "src/ejercicio-1/videojuegos.test.js", snippet: "persistencia-cruzada", lang: "javascript", text-size: 7pt)

*Simulación de modificación de estado (POST → PUT stock → GET):*

#code-block(file: "src/ejercicio-1/videojuegos.test.js", snippet: "modificacion-estado", lang: "javascript", text-size: 7pt)

*Validación de robustez — Edge Cases:*

#code-block(file: "src/ejercicio-1/videojuegos.test.js", snippet: "edge-cases", lang: "javascript", text-size: 7pt)

==== 5.4. Ejecución de las Pruebas

Se ejecutó la suite con el comando #raw("npm test") obteniendo los siguientes resultados:

#figure(
  image("/img/ejecucion de tests.png", width: 60%),
  caption: [Resultado: 10 de 10 tests pasaron]
)

*Resumen final:* Los 10 tests pasaron correctamente, cubriendo persistencia cruzada, modificación de estado y validación de robustez.
