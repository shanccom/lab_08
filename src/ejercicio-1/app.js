const express = require('express');

const app = express();

app.use(express.json());

// Base de datos en memoria
let videojuegos = [];
let idCounter = 1;

// POST /videojuegos - Crear videojuego
app.post('/videojuegos', (req, res) => {
  const { nombre, genero, stock, precio } = req.body;

  // Validar campos obligatorios
  if (!nombre || !genero || stock === undefined || precio === undefined) {
    return res.status(400).json({
      error: 'Todos los campos son obligatorios: nombre, genero, stock, precio'
    });
  }

  // Validar tipos numéricos
  if (typeof stock !== 'number' || typeof precio !== 'number') {
    return res.status(400).json({
      error: 'Stock y precio deben ser valores numéricos'
    });
  }

  // Validar valores no negativos
  if (stock < 0 || precio < 0) {
    return res.status(400).json({
      error: 'Stock y precio deben ser mayores o iguales a 0'
    });
  }

  const nuevoVideojuego = {
    id: idCounter++,
    nombre,
    genero,
    stock,
    precio
  };

  videojuegos.push(nuevoVideojuego);
  res.status(201).json(nuevoVideojuego);
});

// GET /videojuegos/:id - Leer videojuego por ID
app.get('/videojuegos/:id', (req, res) => {
  const id = parseInt(req.params.id);
  const videojuego = videojuegos.find(v => v.id === id);

  // Validar que exista
  if (!videojuego) {
    return res.status(404).json({ error: 'Videojuego no encontrado' });
  }

  res.json(videojuego);
});

// PUT /videojuegos/:id/stock - Actualizar stock
app.put('/videojuegos/:id/stock', (req, res) => {
  const id = parseInt(req.params.id);
  const { stock } = req.body;

  // Validar que stock sea numérico y no negativo
  if (typeof stock !== 'number' || stock < 0) {
    return res.status(400).json({
      error: 'Stock debe ser un número mayor o igual a 0'
    });
  }

  const videojuego = videojuegos.find(v => v.id === id);

  if (!videojuego) {
    return res.status(404).json({ error: 'Videojuego no encontrado' });
  }

  videojuego.stock = stock;
  res.json(videojuego);
});

// DELETE /videojuegos/:id - Eliminar videojuego
app.delete('/videojuegos/:id', (req, res) => {
  const id = parseInt(req.params.id);
  const index = videojuegos.findIndex(v => v.id === id);

  if (index === -1) {
    return res.status(404).json({ error: 'Videojuego no encontrado' });
  }

  videojuegos.splice(index, 1);
  res.status(200).json({ mensaje: 'Videojuego eliminado correctamente' });
});

// DELETE /videojuegos - Limpiar todos (para pruebas)
app.delete('/videojuegos', (req, res) => {
  videojuegos = [];
  idCounter = 1;
  res.status(200).json({ mensaje: 'Base de datos limpiada' });
});

module.exports = app;
