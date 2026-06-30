#import "lib.typ": unsa-report
#import "components/code-block.typ": code-block

#show: unsa-report.with(
  course_name: "Pruebas de Software",
  lab_title: "Pruebas de Integracion: API Testing con Postman y Supertest",
  lab_number: "08",
  instructor_name: "Profe. Robert Arisaca",
  members: (
    "Barrios Medina, Mathias Alonso",
    "Cuno Salazar, Eduardo Joel",
    "Hancco Mullisaca, Sergio Danilo",
    "Suclle Suca, Michael Benjamin",
  ),
)

#set image(width: 78%)
#set list(indent: 2pt)
#show raw.where(block: false): it => box(inset: (x: 0.5pt))[#it]

#include "sections/1-resultados.typ"
#v(0.5em)
#include "sections/2-cuestionario.typ"
#v(0.5em)
#include "sections/3-conclusiones.typ"
#v(0.5em)
#include "sections/4-referencias.typ"
