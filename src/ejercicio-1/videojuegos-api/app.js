// ============================================================
// PASO 5: CÓDIGO COMPLETO DEL SERVIDOR - app.js
// ============================================================
// AUTOR: Hancco Mullisaca Sergio Danilo
// DESCRIPCIÓN: API REST para Catálogo de Videojuegos
// ============================================================

// ============================================================
// 5.1: IMPORTAR EXPRESS
// ============================================================
// express: Framework para construir aplicaciones web y APIs en Node.js
const express = require('express');

// Crear la aplicación Express
const app = express();

// Middleware para analizar el cuerpo de las peticiones en formato JSON
// Permite que req.body contenga los datos enviados en el cuerpo de la petición
app.use(express.json());

// ============================================================
// 5.2: BASE DE DATOS EN MEMORIA
// ============================================================
// videojuegos: Arreglo que almacena todos los videojuegos
// Simula una base de datos en memoria
let videojuegos = [];

// idCounter: Contador autoincrementable para asignar IDs únicos a cada videojuego
// Comienza en 1 y se incrementa cada vez que se crea un nuevo videojuego
let idCounter = 1;

// ============================================================
// 5.3: ENDPOINT POST /videojuegos - CREAR VIDEOJUEGO
// ============================================================
// Método: POST
// URL: http://localhost:3000/videojuegos
// Body esperado (JSON):
// {
//   "nombre": "The Legend of Zelda",
//   "genero": "Aventura",
//   "stock": 10,
//   "precio": 59.99
// }
// Respuesta exitosa: Status 201 (Created) con el objeto creado
// Respuesta de error: Status 400 (Bad Request) con mensaje descriptivo
// ============================================================
app.post('/videojuegos', (req, res) => {
  // Extraer los datos del cuerpo de la petición
  // Usando desestructuración de objetos
  const { nombre, genero, stock, precio } = req.body;
  
  // ============================================================
  // VALIDACIÓN 1: Verificar que todos los campos obligatorios estén presentes
  // ============================================================
  // Se verifica que ninguno de los campos sea undefined o vacío
  // stock y precio se verifican con undefined porque pueden ser 0 (valor válido)
  if (!nombre || !genero || stock === undefined || precio === undefined) {
    return res.status(400).json({ 
      error: 'Todos los campos son obligatorios: nombre, genero, stock, precio' 
    });
  }
  
  // ============================================================
  // VALIDACIÓN 2: Verificar que stock y precio sean numéricos
  // ============================================================
  // typeof stock !== 'number' verifica que no sea un string, booleano, etc.
  // Esto evita que el usuario envíe "diez" en lugar de 10
  if (typeof stock !== 'number' || typeof precio !== 'number') {
    return res.status(400).json({ 
      error: 'Stock y precio deben ser valores numéricos' 
    });
  }
  
  // ============================================================
  // VALIDACIÓN 3: Verificar que stock y precio no sean negativos
  // ============================================================
  // Valores lógicos: No puede haber stock negativo ni precio negativo
  if (stock < 0 || precio < 0) {
    return res.status(400).json({ 
      error: 'Stock y precio deben ser mayores o iguales a 0' 
    });
  }

  // ============================================================
  // CREAR EL NUEVO VIDEOJUEGO
  // ============================================================
  // Se crea un objeto con los datos validados
  // id: Se asigna el valor actual de idCounter y luego se incrementa
  const nuevoVideojuego = { 
    id: idCounter++, 
    nombre, 
    genero, 
    stock, 
    precio 
  };
  
  // Agregar el nuevo videojuego al arreglo (base de datos en memoria)
  videojuegos.push(nuevoVideojuego);
  
  // Responder con status 201 (Created) y el objeto creado
  res.status(201).json(nuevoVideojuego);
});

// ============================================================
// 5.4: ENDPOINT GET /videojuegos/:id - LEER VIDEOJUEGO POR ID
// ============================================================
// Método: GET
// URL: http://localhost:3000/videojuegos/1
// Parámetro: id (número) - ID del videojuego a buscar
// Respuesta exitosa: Status 200 con el objeto del videojuego
// Respuesta de error: Status 404 (Not Found) si no existe
// ============================================================
app.get('/videojuegos/:id', (req, res) => {
  // Obtener el ID de los parámetros de la URL
  // req.params.id es un string, se convierte a número con parseInt
  const id = parseInt(req.params.id);
  
  // Buscar el videojuego en el arreglo usando el método find()
  // find() devuelve el primer elemento que cumple con la condición
  const videojuego = videojuegos.find(v => v.id === id);
  
  // ============================================================
  // VALIDACIÓN: Verificar si el videojuego existe
  // ============================================================
  // Si no se encuentra, videojuego será undefined
  if (!videojuego) {
    return res.status(404).json({ error: 'Videojuego no encontrado' });
  }
  
  // Responder con status 200 (OK) y el objeto encontrado
  res.json(videojuego);
});

// ============================================================
// 5.5: ENDPOINT PUT /videojuegos/:id/stock - ACTUALIZAR STOCK
// ============================================================
// Método: PUT
// URL: http://localhost:3000/videojuegos/1/stock
// Body esperado (JSON):
// {
//   "stock": 15
// }
// Respuesta exitosa: Status 200 con el objeto actualizado
// Respuesta de error: Status 400 (Bad Request) o 404 (Not Found)
// ============================================================
app.put('/videojuegos/:id/stock', (req, res) => {
  // Obtener el ID de los parámetros de la URL
  const id = parseInt(req.params.id);
  
  // Obtener el nuevo stock del cuerpo de la petición
  const { stock } = req.body;
  
  // ============================================================
  // VALIDACIÓN 1: Verificar que stock sea numérico y no negativo
  // ============================================================
  if (typeof stock !== 'number' || stock < 0) {
    return res.status(400).json({ 
      error: 'Stock debe ser un número mayor o igual a 0' 
    });
  }
  
  // Buscar el videojuego en el arreglo
  const videojuego = videojuegos.find(v => v.id === id);
  
  // ============================================================
  // VALIDACIÓN 2: Verificar si el videojuego existe
  // ============================================================
  if (!videojuego) {
    return res.status(404).json({ error: 'Videojuego no encontrado' });
  }
  
  // ============================================================
  // ACTUALIZAR EL STOCK
  // ============================================================
  // Se modifica la propiedad stock del objeto encontrado
  videojuego.stock = stock;
  
  // Responder con status 200 (OK) y el objeto actualizado
  res.json(videojuego);
});

// ============================================================
// 5.6: ENDPOINT DELETE /videojuegos/:id - ELIMINAR VIDEOJUEGO
// ============================================================
// Método: DELETE
// URL: http://localhost:3000/videojuegos/1
// Parámetro: id (número) - ID del videojuego a eliminar
// Respuesta exitosa: Status 200 con mensaje de éxito
// Respuesta de error: Status 404 (Not Found) si no existe
// ============================================================
app.delete('/videojuegos/:id', (req, res) => {
  // Obtener el ID de los parámetros de la URL
  const id = parseInt(req.params.id);
  
  // Buscar el índice del videojuego en el arreglo usando findIndex()
  // findIndex() devuelve la posición del elemento o -1 si no existe
  const index = videojuegos.findIndex(v => v.id === id);
  
  // ============================================================
  // VALIDACIÓN: Verificar si el videojuego existe
  // ============================================================
  if (index === -1) {
    return res.status(404).json({ error: 'Videojuego no encontrado' });
  }
  
  // ============================================================
  // ELIMINAR EL VIDEOJUEGO DEL ARREGLO
  // ============================================================
  // splice(index, 1) elimina 1 elemento en la posición especificada
  videojuegos.splice(index, 1);
  
  // Responder con status 200 (OK) y mensaje de éxito
  res.status(200).json({ mensaje: 'Videojuego eliminado correctamente' });
});

// ============================================================
// 5.7: ENDPOINT DELETE /videojuegos - LIMPIAR TODOS (PARA PRUEBAS)
// ============================================================
// Método: DELETE
// URL: http://localhost:3000/videojuegos
// Respuesta exitosa: Status 200 con mensaje de éxito
// Este endpoint es útil para las pruebas de integración
// Permite limpiar la base de datos entre cada prueba
// ============================================================
app.delete('/videojuegos', (req, res) => {
  // ============================================================
  // LIMPIAR LA BASE DE DATOS
  // ============================================================
  // Vaciar el arreglo de videojuegos
  videojuegos = [];
  
  // Reiniciar el contador de IDs a 1
  idCounter = 1;
  
  // Responder con status 200 (OK) y mensaje de éxito
  res.status(200).json({ mensaje: 'Base de datos limpiada' });
});

// ============================================================
// 5.8: EXPORTAR LA APLICACIÓN
// ============================================================
// module.exports permite que otros archivos puedan importar esta aplicación
// Ejemplo: const app = require('./app');
// Esto es necesario para que las pruebas de integración puedan usar la API
// ============================================================
module.exports = app;