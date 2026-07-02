const request = require('supertest');
const app = require('./app');

// START-SNIPPET,estructura
describe('API REST de Videojuegos - Pruebas de Integración', () => {

  /*
    beforeEach: se ejecuta antes de cada test.
    Limpia la base de datos en memoria para que cada prueba comience con un estado limpio y aislado.
  */
  beforeEach(async () => {
    await request(app).delete('/videojuegos');
  });
// END-SNIPPET

// START-SNIPPET,persistencia-cruzada
  // 1. FLUJO DE PERSISTENCIA CRUZADA (POST -> GET)
  test('Flujo POST -> GET: debe crear un videojuego y recuperarlo por su ID', async () => {

    // Datos de prueba: un videojuego válido con todos los campos
    const juegoCreado = {
      nombre: 'The Legend of Zelda',
      genero: 'Aventura',
      stock: 10,
      precio: 59.99
    };

    // Enviar POST para crear el videojuego
    const postResponse = await request(app)
      .post('/videojuegos')
      .send(juegoCreado);

    // Verificar que la creación fue exitosa (código 201)
    expect(postResponse.statusCode).toBe(201);

    // Extraer el ID generado automáticamente por el servidor
    const id = postResponse.body.id;

    // Verificar que el servidor asignó un ID numérico
    expect(id).toBeDefined();
    expect(typeof id).toBe('number');

    // Consultar el videojuego mediante GET usando el ID obtenido
    const getResponse = await request(app)
      .get(`/videojuegos/${id}`);

    // Verificar que la consulta fue exitosa (código 200)
    expect(getResponse.statusCode).toBe(200);

    // Verificar que los datos recuperados coinciden exactamente con los datos enviados en el POST (incluyendo el ID)
    expect(getResponse.body.id).toBe(id);
    expect(getResponse.body.nombre).toBe(juegoCreado.nombre);
    expect(getResponse.body.genero).toBe(juegoCreado.genero);
    expect(getResponse.body.stock).toBe(juegoCreado.stock);
    expect(getResponse.body.precio).toBe(juegoCreado.precio);
  });

// END-SNIPPET

// START-SNIPPET,modificacion-estado
  // 2. SIMULACIÓN DE MODIFICACIÓN DE ESTADO (POST -> PUT stock -> GET)
  test('Flujo POST -> PUT stock -> GET: debe modificar el stock y persistir el cambio', async () => {

    // Crear un videojuego con stock inicial
    const postResponse = await request(app)
      .post('/videojuegos')
      .send({
        nombre: 'Hollow Knight',
        genero: 'Metroidvania',
        stock: 5,
        precio: 24.99
      });

    expect(postResponse.statusCode).toBe(201);
    const id = postResponse.body.id;
    expect(postResponse.body.stock).toBe(5);

    // Modificar el stock mediante PUT /videojuegos/:id/stock
    const putResponse = await request(app)
      .put(`/videojuegos/${id}/stock`)
      .send({ stock: 50 });

    // Verificar que la modificación fue exitosa (código 200)
    expect(putResponse.statusCode).toBe(200);

    // Verificar que la respuesta del PUT ya refleja el nuevo stock
    expect(putResponse.body.stock).toBe(50);

    // Realizar un GET para confirmar que el cambio persistió
    const getResponse = await request(app)
      .get(`/videojuegos/${id}`);

    expect(getResponse.statusCode).toBe(200);

    // Verificar que el stock actualizado quedó persistido
    expect(getResponse.body.stock).toBe(50);

    // Verificar que el resto de los datos no se alteraron
    expect(getResponse.body.nombre).toBe('Hollow Knight');
    expect(getResponse.body.genero).toBe('Metroidvania');
    expect(getResponse.body.precio).toBe(24.99);
  });

// END-SNIPPET

// START-SNIPPET,edge-cases
  // 3. VALIDACIÓN DE ROBUSTEZ (EDGE CASES)

  // 3a. Texto en campo numérico
  test('Debe rechazar con 400 si se envía texto en un campo numérico', async () => {
    // stock es un string en lugar de número: debe fallar
    const response = await request(app)
      .post('/videojuegos')
      .send({
        nombre: 'Celeste',
        genero: 'Plataformas',
        stock: 'diez', // texto en lugar de un numero
        precio: 19.99
      });

    // Verificar que la API responde con error 400
    expect(response.statusCode).toBe(400);

    // Verificar el mensaje de error específico
    expect(response.body.error).toBe('Stock y precio deben ser valores numéricos');
  });

  // 3b. Campos obligatorios faltantes
  test('Debe rechazar con 400 si faltan campos obligatorios', async () => {

    // Enviar solo nombre y genero, omitiendo stock y precio
    const response = await request(app)
      .post('/videojuegos')
      .send({
        nombre: 'Stardew Valley',
        genero: 'Simulación'
        // stock y precio están ausentes
      });

    // Verificar que la API responde con error 400
    expect(response.statusCode).toBe(400);

    // Verificar el mensaje de error específico
    expect(response.body.error).toBe(
      'Todos los campos son obligatorios: nombre, genero, stock, precio'
    );
  });

  // 3c. Verificación adicional: stock negativo
  test('Debe rechazar con 400 si stock es un número negativo', async () => {
    const response = await request(app)
      .post('/videojuegos')
      .send({
        nombre: 'Portal 2',
        genero: 'Puzle',
        stock: -5,
        precio: 9.99
      });

    expect(response.statusCode).toBe(400);
    expect(response.body.error).toBe('Stock y precio deben ser mayores o iguales a 0');
  });

// END-SNIPPET

  // 4. RUTAS NO CUBIERTAS (404 y DELETE)

  // 4a. GET de un videojuego que no existe
  test('GET /videojuegos/:id con ID inexistente debe retornar 404', async () => {

    // Consultar un ID que seguramente no existe (ej: 9999)
    // como la BD se limpia en beforeEach(), cualquier ID mayor a 0 será inexistente.
    const response = await request(app)
      .get('/videojuegos/9999');

    // Verificar que la API responde con 404 (no encontrado)
    expect(response.statusCode).toBe(404);

    // Verificar el mensaje de error específico
    expect(response.body.error).toBe('Videojuego no encontrado');
  });

  // 4b. PUT de stock sobre un videojuego que no existe
  test('PUT /videojuegos/:id/stock con ID inexistente debe retornar 404', async () => {
    // Intentar actualizar el stock de un ID que no existe
    const response = await request(app)
      .put('/videojuegos/9999/stock')
      .send({ stock: 10 });

    // Verificar que la API responde con 404 (no encontrado)
    expect(response.statusCode).toBe(404);

    // Verificar el mensaje de error específico
    expect(response.body.error).toBe('Videojuego no encontrado');
  });

  // 4c. PUT de stock con valor inválido (texto en lugar de número)
  test('PUT /videojuegos/:id/stock con stock no numérico debe retornar 400', async () => {

    // Primero crear un videojuego válido para tener un ID real
    const postResponse = await request(app)
      .post('/videojuegos')
      .send({
        nombre: 'Dark Souls',
        genero: 'RPG',
        stock: 3,
        precio: 39.99
      });

    const id = postResponse.body.id;

    // Intentar actualizar el stock con un valor de texto
    const putResponse = await request(app)
      .put(`/videojuegos/${id}/stock`)
      .send({ stock: 'diez' }); // texto en lugar de número

    // Verificar que la API responde con 400 (error de validación)
    expect(putResponse.statusCode).toBe(400);

    // Verificar el mensaje de error específico del PUT
    expect(putResponse.body.error).toBe('Stock debe ser un número mayor o igual a 0');
  });

  // 4d. DELETE de un videojuego que no existe
  test('DELETE /videojuegos/:id con ID inexistente debe retornar 404', async () => {
    // Intentar eliminar un videojuego cuyo ID no existe
    const response = await request(app)
      .delete('/videojuegos/9999');

    // Verificar que la API responde con 404 (no encontrado)
    expect(response.statusCode).toBe(404);

    // Verificar el mensaje de error específico
    expect(response.body.error).toBe('Videojuego no encontrado');
  });

  // 4e. DELETE de un videojuego existente y verificación posterior
  test('DELETE + GET: debe eliminar un videojuego y luego retornar 404 al consultarlo', async () => {
    // Crear un videojuego para tener un ID que eliminar
    const postResponse = await request(app)
      .post('/videojuegos')
      .send({
        nombre: 'Super Mario Odyssey',
        genero: 'Plataformas',
        stock: 15,
        precio: 49.99
      });

    expect(postResponse.statusCode).toBe(201);
    const id = postResponse.body.id;

    // Eliminar el videojuego mediante DELETE /videojuegos/:id
    const deleteResponse = await request(app)
      .delete(`/videojuegos/${id}`);

    // Verificar que la eliminación fue exitosa (código 200)
    expect(deleteResponse.statusCode).toBe(200);

    // Verificar el mensaje de éxito
    expect(deleteResponse.body.mensaje).toBe('Videojuego eliminado correctamente');

    // Confirmar que el videojuego ya no existe (GET debe dar 404)
    const getResponse = await request(app)
      .get(`/videojuegos/${id}`);

    // Verificar que ahora devuelve 404
    expect(getResponse.statusCode).toBe(404);
    expect(getResponse.body.error).toBe('Videojuego no encontrado');
  });
});
