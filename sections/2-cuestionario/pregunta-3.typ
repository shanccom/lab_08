= Pregunta 3: Según Myers, ¿por qué es arriesgado que el mismo desarrollador que escribió el código de los módulos diseñe también las pruebas de integración?

#set par(justify: true)

#v(0.5em)

Myers @myers2012 sostiene que el desarrollador que escribió el código tiene *sesgos cognitivos* naturales: conoce su propia lógica y tiende a probar los caminos que ya sabe que funcionan, pasando por alto escenarios que no consideró al programar. En integración, estos sesgos son particularmente peligrosos porque las fallas suelen estar en los *límites* entre módulos, no dentro de ellos. El desarrollador asume que su interfaz se comunica correctamente porque así lo diseñó, pero un ojo fresco —que no tiene esas suposiciones grabadas— tiene más probabilidades de encontrar los defectos reales en la comunicación entre componentes. Myers recomienda que un tercero diseñe las pruebas de integración para romper ese sesgo y garantizar una cobertura más objetiva.
