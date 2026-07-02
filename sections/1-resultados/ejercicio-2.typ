= Ejercicio 2: Pruebas de Integración del Proyecto Final

#set par(justify: true)

El grupo debe aplicar pruebas de integración sobre la arquitectura de su proyecto de fin de curso. El enfoque debe centrarse en verificar la cohesión y el flujo de datos entre los componentes que han sido desarrollados. El grupo puede elegir la herramienta (Requests, Supertest, REST Assured, Playwright, etc.) que mejor se adapte a su lenguaje de programación.

*Tarea de Análisis de Errores:*

1. *Mapeo de la Frontera:* Identifique el punto donde el Subsistema A entrega el control o los datos al Subsistema B.

2. *Inyección de Fallas de Interfaz:* Diseñe al menos 3 casos de prueba orientados a "romper" la comunicación:
   - *Caso 1 (Sintáctico):* Envíe un objeto con campos faltantes o tipos de datos erróneos.
   - *Caso 2 (Semántico):* Envíe valores legales pero fuera de lógica para el receptor (ej. una fecha de entrega anterior a la de pedido).
   - *Caso 3 (Resiliencia):* Simule una latencia alta en la respuesta del subsistema B y analice si el subsistema A maneja el timeout o colapsa.

3. *Documentación de Discrepancias:* Por cada falla encontrada, complete un Reporte de Incidente que detalle el "Resultado Esperado" vs. el "Resultado Real" observado en la interfaz.

== Desarrollo — Proyecto Final: Actual Budget

=== I. Mapeo de la Frontera

El proyecto final es un monorepo #emph("Actual Budget") con 13 paquetes, desarrollado en TypeScript. La arquitectura se compone de:

- *Subsistema A — Frontend:* Aplicación React + Vite (desktop-client, puerto 3001).
- *Subsistema B — Sync Server:* Servidor Express (sync-server, puerto 5006) que gestiona sincronización CRDT mediante Protocol Buffers.
- *Subsistema C — Core:* Librería compartida (loot-core) con lógica de negocio y acceso a SQLite.

La *frontera de integración* seleccionada para las pruebas es la interfaz HTTP REST entre el Frontend (o cualquier cliente HTTP) y el Sync Server:

#figure(
  image("/img/arquitectura_proyecto_final.png", width: 80%),
  caption: [Diagrama de arquitectura del proyecto final]
)

*Punto de entrega de datos:* El frontend envía requests HTTP (JSON o binario Protobuf) al Sync Server, el cual valida la sesión mediante el middleware #emph("validateSessionMiddleware"), procesa la solicitud a través de handlers como #emph("app-sync.ts") y responde con códigos de estado y payloads JSON.

*Endpoints testeados:*

#figure(
  image("/img/tabla_endpoints.png", width: 80%),
  caption: [Principales endpoints del Sync Server]
)

*Herramienta seleccionada:* Supertest + Vitest, aprovechando que el proyecto ya cuenta con dicha infraestructura de testing. Las pruebas se ejecutan en memoria contra la app Express exportada, sin necesidad de levantar un servidor real. La base de datos SQLite es real (better-sqlite3), no mockeada.

*Archivo de pruebas creado:* #emph("packages/sync-server/src/app-sync-integration.test.ts") (25 tests).

=== II. Inyección de Fallas de Interfaz

==== 2.1 Caso 1 — Fallas Sintácticas

Se diseñaron 10 casos de prueba orientados a romper la comunicación mediante el envío de objetos con campos faltantes o tipos de datos incorrectos.

*Reporte de Incidente Sintáctico — SYN-01 a SYN-10:*

#figure(
  image("/img/resultados_tests_sintactico.png", width: 80%),
  caption: [Ejecución de los 10 casos de prueba sintácticos]
)

#table(
  columns: (auto, auto, auto, auto, auto),
  [*ID*], [*Endpoint*], [*Entrada*], [*Esperado*], [*Real*],
  [SYN-01], [/user-get-key], [Body vacío (sin fileId)], [400 "invalid fileId"], [400 — coincide],
  [SYN-02], [/user-get-key], [{ fileId: 12345 } (number)], [400 "invalid fileId"], [400 — coincide],
  [SYN-03], [/user-get-key], [fileId con caracteres especiales], [400 "invalid fileId"], [400 — coincide],
  [SYN-04], [/user-get-key], [{ fileId: "" } (string vacío)], [400 "invalid fileId"], [400 — coincide],
  [SYN-05], [/user-create-key], [Body sin fileId], [400 "invalid fileId"], [400 — coincide],
  [SYN-06], [/sync], [String crudo no Protobuf], [500 internal-error], [500 — coincide],
  [SYN-07], [/sync], [Protobuf válido pero since=""], [422 "since-required"], [422 — coincide],
  [SYN-08], [/delete-user-file], [Body vacío {}], [422 "fileId-required"], [422 — coincide],
  [SYN-09], [/upload-user-file], [Sin header x-actual-name], [400 "name is required"], [400 — coincide],
  [SYN-10], [/upload-user-file], [Sin header x-actual-file-id], [400 "fileId is required"], [400 — coincide],
)

*Análisis:* Todos los casos sintácticos fueron manejados correctamente por el servidor. El middleware #emph("verifyFileExists()") rechaza tipos no string con #emph("typeof fileId !== 'string'"), y el sistema de parseo de Protobuf captura la excepción #emph("illegal tag") para cuerpos inválidos. No se encontraron fallas en este nivel.

==== 2.2 Caso 2 — Fallas Semánticas

Se diseñaron 8 casos de prueba con valores legalmente válidos pero ilógicos para el negocio.

*Reporte de Incidente Semántico — SEM-01 a SEM-08:*

#figure(
  image("/img/resultados_tests_semantico.png", width: 80%),
  caption: [Ejecución de los 8 casos de prueba semánticos]
)

#table(
  columns: (auto, auto, auto, auto, auto, auto),
  [*ID*], [*Endpoint*], [*Entrada*], [*Esperado*], [*Real*], [*¿Falla?*],
  [SEM-01], [/sync], [groupId no coincide con BD], [400 "file-has-reset"], [400 — coincide], [No],
  [SEM-02], [/sync], [groupId=NULL en BD (archivo reseteado)], [400 "file-needs-upload"], [400 — coincide], [No],
  [SEM-03], [/sync], [keyId no coincide con BD (cifrado cambiado)], [400 "file-has-new-key"], [400 — coincide], [No],
  [SEM-04], [/sync], [syncVersion=1 (formato obsoleto)], [400 "file-old-version"], [400 — coincide], [No],
  [SEM-05], [/user-get-key], [Usuario BASIC accede a archivo ajeno], [403 "not allowed"], [403 — coincide], [No],
  [SEM-06], [/user-get-key], [Usuario ADMIN accede a archivo ajeno], [200 acceso permitido], [200 — coincide], [No],
  [SEM-07], [/delete-user-file], [Archivo ya eliminado (deleted=1)], [400 "file-not-found"], [400 — defecto de diseño], [*Sí*],
  [SEM-08], [/upload-user-file], [groupId enviado no coincide con BD], [400 "file-has-reset"], [400 — coincide], [No],
)

*Defecto encontrado — SEM-07:*

#emph("FilesService.get()") en #emph("files-service.ts") lanza #emph("FileNotFound") tanto para archivos que nunca existieron como para archivos marcados con #emph("deleted=1"). Esto hace que la operación DELETE no sea idempotente a nivel de API: un segundo DELETE retorna 400 en lugar de 200 (o 404). El sistema no distingue entre "no existe" y "existe pero está eliminado".

*Código relevante (files-service.ts:139-146):*
#figure(
  image("/img/defecto_sem_07.png", width: 80%),
  caption: [Código fuente del defecto SEM-07]
)

*Recomendación:* Modificar #emph("FilesService.get()") para retornar errores diferenciados (ej. #emph("FileDeleted") vs #emph("FileNotFound")) y hacer que el endpoint DELETE sea idempotente.

==== 2.3 Caso 3 — Resiliencia

Se diseñaron 6 casos de prueba para evaluar la capacidad del Sync Server de responder bajo condiciones adversas de latencia y carga.

*Reporte de Incidente de Resiliencia — RES-01 a RES-06:*

#figure(
  image("/img/resultados_tests_resiliencia.png", width: 80%),
  caption: [Ejecución de los 6 casos de prueba de resiliencia]
)

#table(
  columns: (auto, auto, auto, auto, auto),
  [*ID*], [*Endpoint*], [*Condición*], [*Esperado*], [*Real*],
  [RES-01], [/list-user-files], [Consulta de archivos con BD local], [\<500ms], [\<500ms — OK],
  [RES-02], [/user-get-key], [Consulta por PRIMARY KEY en SQLite], [\<300ms], [\<300ms — OK],
  [RES-03], [/user-get-key], [fileId inexistente], [\<300ms sin bloquearse], [\<300ms — OK],
  [RES-04], [/sync], [fileId inexistente], [\<300ms sin bloquearse], [\<300ms — OK],
  [RES-05], [/list-user-files], [Sin token de autenticación], [\<100ms (rechazo temprano)], [\<100ms — OK],
  [RES-06], [/user-get-key], [Sin token de autenticación], [\<100ms (rechazo temprano)], [\<100ms — OK],
)

*Análisis:* Todas las rutas responden rápidamente en condiciones normales con SQLite local. El middleware #emph("validateSessionMiddleware") rechaza solicitudes sin token antes de tocar la base de datos, lo cual es una buena práctica de defensa temprana. Sin embargo, los handlers no implementan timeouts explícitos ni #emph("circuit breakers"). Si la base de datos llegara a bloquearse, las requests quedarían colgadas indefinidamente.

*Recomendación:* Implementar un mecanismo de timeout con #emph("Promise.race") en cada handler y exponer un timeout configurable. Considerar agregar un health check independiente para el estado de la base de datos.

=== III. Resultados de Ejecución

#figure(
  image("/img/tests_ejecucion_completa.png", width: 80%),
  caption: [Ejecución completa: 25 tests pasados, 568 tests totales del proyecto]
)

Los 25 tests de integración se ejecutaron exitosamente en #emph("263ms"). Se integraron sin conflictos con los 543 tests existentes del proyecto (45 test files, 568 tests totales).

*Herramientas utilizadas:* Supertest (HTTP assertions) + Vitest (runner/assertions). Base de datos SQLite real con usuarios y sesiones predefinidos en #emph("globalSetup").

=== IV. Resumen de Hallazgos

#table(
  columns: (auto, auto),
  [*Categoría*], [*Resultado*],
  [Sintáctico (10 tests)], [Todos pasaron. El servidor valida correctamente tipos, formatos y campos obligatorios.],
  [Semántico (8 tests)], [7 pasaron correctamente. Se encontró 1 defecto: DELETE no es idempotente para archivos soft-deleted.],
  [Resiliencia (6 tests)], [Todos pasaron en condiciones normales. No existen timeouts explícitos, lo cual es una debilidad latente.],
)
