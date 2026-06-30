= Pregunta 5: ¿Cómo ayuda la herramienta seleccionada por su grupo a detectar "defectos enmascarados" entre sus subsistemas?

#set par(justify: true)

#v(0.5em)

Las herramientas que seleccionamos *Postman* y *Supertest* ayudan a detectar defectos enmascarados al validar las *interacciones reales* entre subsistemas a través de sus APIs HTTP. Un defecto enmascarado ocurre cuando un error en un subsistema queda oculto porque otro subsistema compensa temporalmente ese error (por ejemplo, con valores por defecto o conversiones implícitas). Postman permite crear colecciones de pruebas que encadenan varias llamadas API, simulando flujos completos del sistema; si un subsistema devuelve datos inesperados pero el siguiente los procesa sin fallar, las aserciones de Postman pueden detectar que la respuesta final no coincide con el contrato esperado. Supertest, por su parte, permite escribir pruebas automatizadas con aserciones precisas sobre los códigos de estado, el cuerpo y los encabezados de cada respuesta. Así, si un cambio en un subsistema modifica sutilmente su salida y otro subsistema se adapta silenciosamente, la prueba falla y revela el defecto enmascarado que de otro modo pasaría desapercibido en producción.
