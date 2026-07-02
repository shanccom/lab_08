# README - Laboratorio 08 - Ejercicio 1

## Catalogo de Videojuegos - API REST


## REQUERIMIENTOS DEL SISTEMA

- Node.js (version 14 o superior)
- npm (version 6 o superior)
- Postman (opcional, para pruebas manuales)

---

## INSTALACION Y CONFIGURACION

### 1. Clonar el repositorio

git clone <url-del-repositorio>
cd videojuegos-api

### 2. Instalar dependencias

npm install

### 3. Verificar dependencias instaladas

npm list

---

## EJECUTAR EL SERVIDOR

### 1. Iniciar el servidor

node server.js

### 2. Verificar que el servidor esta corriendo

Deberias ver el siguiente mensaje:

========================================
SERVIDOR DE VIDEOJUEGOS
========================================
Servidor corriendo en:
   http://localhost:3000
Endpoints disponibles:
   POST   /videojuegos         - Crear videojuego
   GET    /videojuegos/:id     - Leer videojuego
   PUT    /videojuegos/:id/stock - Actualizar stock
   DELETE /videojuegos/:id     - Eliminar videojuego
   DELETE /videojuegos         - Limpiar todos (para pruebas)
========================================
Presiona Ctrl+C para detener el servidor

### 3. Mantener el servidor en ejecucion

IMPORTANTE: No cerrar la terminal. El servidor debe quedar corriendo.

---

## ENDPOINTS DISPONIBLES

POST /videojuegos - Crear un nuevo videojuego
GET /videojuegos/:id - Obtener videojuego por ID
PUT /videojuegos/:id/stock - Actualizar stock de un videojuego
DELETE /videojuegos/:id - Eliminar un videojuego
DELETE /videojuegos - Limpiar todos los videojuegos (para pruebas)

---

## PROBAR LA API CON POSTMAN

### 1. Crear un videojuego (POST)

Metodo: POST
URL: http://localhost:3000/videojuegos
Body (JSON):

{
  "nombre": "The Legend of Zelda: Tears of the Kingdom",
  "genero": "Aventura",
  "stock": 15,
  "precio": 59.99
}

Respuesta esperada: Status 201, objeto con ID asignado

### 2. Leer un videojuego (GET)

Metodo: GET
URL: http://localhost:3000/videojuegos/1
Respuesta esperada: Status 200, objeto del videojuego

### 3. Actualizar stock (PUT)

Metodo: PUT
URL: http://localhost:3000/videojuegos/1/stock
Body (JSON):

{
  "stock": 10
}

Respuesta esperada: Status 200, stock actualizado

### 4. Eliminar un videojuego (DELETE)

Metodo: DELETE
URL: http://localhost:3000/videojuegos/1
Respuesta esperada: Status 200, mensaje de exito

### 5. Probar recurso no encontrado (GET 404)

Metodo: GET
URL: http://localhost:3000/videojuegos/99
Respuesta esperada: Status 404, "Videojuego no encontrado"

---

## VALIDACIONES IMPLEMENTADAS

El endpoint POST /videojuegos incluye las siguientes validaciones:

Campos obligatorios: nombre, genero, stock, precio
Respuesta: 400 - "Todos los campos son obligatorios"

Tipos de datos: stock y precio deben ser numericos
Respuesta: 400 - "Stock y precio deben ser valores numericos"

Valores logicos: stock y precio >= 0
Respuesta: 400 - "Stock y precio deben ser mayores o iguales a 0"

Ejemplo de error (texto en stock):

{
  "nombre": "Prueba Error",
  "genero": "Accion",
  "stock": "diez",
  "precio": 39.99
}

Respuesta: Status 400, "Stock y precio deben ser valores numericos"

Ejemplo de error (campo faltante):

{
  "nombre": "Prueba Error",
  "genero": "Accion",
  "stock": 5
}

Respuesta: Status 400, "Todos los campos son obligatorios"

---

## ESTRUCTURA DEL PROYECTO

videojuegos-api/
│
├── app.js              # Codigo de la API (endpoints y validaciones)
├── server.js           # Servidor para ejecutar la API
├── package.json        # Dependencias y scripts
├── package-lock.json   # Versiones exactas de dependencias
└── node_modules/       # Dependencias instaladas

## SOLUCION DE PROBLEMAS COMUNES

"Cannot find module 'express'" - Ejecutar npm install
"ECONNREFUSED" - El servidor no esta corriendo. Ejecutar node server.js
Puerto 3000 en uso - Cambiar el puerto en server.js a 3001 o 3002
Error 404 - Verificar que la URL sea correcta
Error 500 - Verificar que el JSON este bien escrito

