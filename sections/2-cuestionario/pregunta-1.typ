= Pregunta 1: ¿Por qué las pruebas unitarias exitosas no garantizan que la integración será exitosa?

#set par(justify: true)

#v(0.5em)

Porque una prueba unitaria verifica un módulo de forma aislada, reemplazando sus dependencias con dobles de prueba @spillner2021. Esto significa que nunca se prueba la comunicación real entre módulos. Aunque cada módulo funcione perfectamente por separado, al integrarlos pueden surgir problemas como: diferencias en los formatos de datos que espera cada módulo, suposiciones contradictorias sobre el estado del sistema, errores en los contratos de las interfaces (nombres de métodos, tipos de parámetros, orden de llamadas), o defectos enmascarados donde un error en un módulo es ocultado temporalmente por otro. Las pruebas de integración son las únicas que pueden detectar estos fallos en las interacciones entre componentes reales.
