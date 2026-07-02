const app = require('./app');

// Puerto para el servidor local
const PORT = 3000;

app.listen(PORT, () => {
  console.log(`SERVIDOR DE VIDEOJUEGOS`);
  console.log(` Servidor corriendo en:`);
  console.log(`   http://localhost:${PORT}`);
  console.log(` Endpoints disponibles:`);
  console.log(`   POST   /videojuegos         - Crear videojuego`);
  console.log(`   GET    /videojuegos/:id     - Leer videojuego`);
  console.log(`   PUT    /videojuegos/:id/stock - Actualizar stock`);
  console.log(`   DELETE /videojuegos/:id     - Eliminar videojuego`);
  console.log(`   DELETE /videojuegos         - Limpiar todos (para pruebas)`);
  console.log(`========================================`);
  console.log(` Presiona Ctrl+C para detener el servidor`);
});
