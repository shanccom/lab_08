// ============================================================
// PASO 6: SERVIDOR - server.js
// ============================================================
// AUTOR: Hancco Mullisaca Sergio Danilo
// DESCRIPCIÓN: Archivo para ejecutar el servidor de la API
// ============================================================

// ============================================================
// 6.1: IMPORTAR LA APLICACIÓN
// ============================================================
// Se importa la aplicación desde app.js
// Esto permite ejecutar el servidor con todos los endpoints definidos
const app = require('./app');

// ============================================================
// 6.2: DEFINIR EL PUERTO
// ============================================================
// Puerto 3000 es común para desarrollo local
// Si el puerto 3000 está ocupado, se puede cambiar a 3001, 3002, etc.
const PORT = 3000;

// ============================================================
// 6.3: INICIAR EL SERVIDOR
// ============================================================
// app.listen() pone el servidor en escucha en el puerto especificado
// Cuando el servidor inicia correctamente, se ejecuta la función callback
// y se muestra un mensaje en la consola
app.listen(PORT, () => {
  console.log(`========================================`);
  console.log(`🎮 SERVIDOR DE VIDEOJUEGOS`);
  console.log(`========================================`);
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
