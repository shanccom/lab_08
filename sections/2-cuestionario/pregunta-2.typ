= Pregunta 2: Explique la diferencia entre un Stub y un Driver y proporcione un ejemplo de cuándo usó uno de ellos en su proyecto.

#set par(justify: true)

#v(0.5em)

Un *Stub* es un componente de prueba que reemplaza a un módulo subordinado (llamado) durante las pruebas de integración ascendentes (bottom-up). Recibe las llamadas del módulo bajo prueba y devuelve respuestas predefinidas, simulando el comportamiento del módulo real sin contener lógica propia. Un *Driver* es el componente inverso: reemplaza al módulo superior (llamante) y se encarga de invocar al módulo bajo prueba con los parámetros adecuados, simulando el flujo de control que vendría desde las capas superiores @myers2012.

En nuestro proyecto final *Actual Budget*, utilizamos Supertest como un *Driver* para probar la integración del Sync Server. Supertest actúa como un cliente HTTP simulado que invoca los endpoints de Express (`/sync`, `/user-get-key`, `/upload-user-file`) directamente en memoria, sin necesidad de levantar un navegador ni un cliente real. De esta forma, el driver envía peticiones con parámetros controlados y verifica las respuestas del servidor, permitiéndonos ejecutar 25 casos de prueba de integración que validan el flujo de datos entre el cliente y el servidor sin depender del frontend React completo.
