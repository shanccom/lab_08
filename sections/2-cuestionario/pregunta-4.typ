= Pregunta 4: Defina "Integración Incremental" y explique por qué el enfoque "Big Bang" debe evitarse en proyectos complejos.

#set par(justify: true)

#v(0.5em)

La *Integración Incremental* consiste en integrar y probar los módulos de uno en uno (o en pequeños grupos), añadiendo módulos gradualmente y probando después cada adición. Esto permite aislar defectos rápidamente: si al agregar un módulo aparece un error, el problema está en la interacción entre el nuevo módulo y los ya integrados.

El enfoque *Big Bang*, por el contrario, integra todos los módulos de una sola vez al final del desarrollo. En proyectos complejos esto es peligroso porque, cuando ocurre una falla, es imposible determinar qué interacción entre qué módulos la causó. Hay demasiadas variables simultáneas: decenas o cientos de interfaces comunicándose por primera vez. Depurar se convierte en encontrar una aguja en un pajar. El Big Bang retrasa la detección de errores hasta el final del ciclo, cuando corregirlos es más caro y riesgoso.
