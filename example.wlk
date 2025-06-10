// Barcos:
// - Necesitan reclutar tripulantes
// - Tienen una misión (pueden cambiar en cualquier momento) y sólo la aceptaran a tripulantes que les sirvan 
// - Se necesita saber si una misión puede ser realizada por un barco
// - Para que un barco pueda realizar una misión deben cumplir:
//        - Tener suficiente tripulación:
//          - La cantidad de tripulantes llega al menos al 90% de su capacidad 
//  - Se necesita saber su capacidad (cuantas personas es capaz de llevar)

// Piratas:
// - Pueden llevar varios ítems
// - Se conoce su nivel de ebriedad y de dinero
// - Se necesita saber si un pirata es útil para una misión

// Misiones:
// - Son 3:
//      - Búsqueda del tesoro:
//          - Son útiles los tripulantes que tengan una brújula, un mapa o una botella de grog
//          - No deben tener más de 5 monedas
//          - Para que un barco pueda realizar la misión, al menos UNO de los tripulantes debe tener una llave de cofre
//      - Convertirse en leyenda:
//          - Debe tener al menos 10 ítems; dentro de esos items debe estar el ítem obligatorio de la misión
//          - No tiene condiciones para el barco
//      - Saqueos:
//          - Objetivos: un barco o una ciudad
//          - Los piratas útiles son los que tengan menos dinero que una cantidad de monedas determinada y que se animen a saquear al objetivo
//          - Para que un barco pueda realizar el saqueo, el objetivo debe ser vulnerable al barco
//          Objetivos:
//          - Barco pirata:
//              - Para que un pirata saquee un barco, debe estar pasado de grog (tener al menos un nivel de ebriedad de 90)
//              - Es vulnerable si tiene como máximo la mitad de los tripulantes que el barco que los quiere saquear
//          - Ciudad costera:
//              - Para que un pirata saquee un barco, debe tener al menos su nivel de ebriedad en 50
//              - Es vulnerable si la cantidad de tripulantes del barco que quiere saquear la ciudad es al menos 40% de la cantidad de habitantes de la ciudad o si todos los tripulantes están pasados de grog

// Objetivos:
// 1) Saber si un pirata es útil para una misión
// 2) Incorporar un pirata a la tripulación de un barco, sólo si esto puede ser llevado a cabo. Esto ocurre cuando el barco tiene lugar para un tripulante más, y además el pirata sirve para la misión del barco.
// 3) Hacer que un barco cambie de misión. Al cambiar de misión, el barco echa a los tripulantes que no sirven para su misión actual.
// 4) Hacer que un barco ancle en una ciudad costera. Cuando los barcos anclan, toda la tripulación  se toma un trago de grogXD, que provoca que el nivel de ebriedad de cada uno suba en 5 unidades y se gasten una moneda. Además, el más ebrio de los tripulantes del barco queda perdido en la ciudad, o sea que deja de formar parte de la tripulación y la ciudad queda con un habitante más.
// 5) Saber si un barco pirata es temible, que consiste en que pueda realizar la misión que tiene asignada 
// 6) Se sabe que algunos tripulantes son espías de la corona. Estos piratas se comportan igual que los piratas comunes a excepción de que nunca están pasados de grogXD y que para animarse a saquear una víctima se tienen que dar las condiciones explicadas anteriormente y además tener el ítem permiso de la corona.
// 7)
//    a) Saber cuántos tripulantes de un barco están pasados de grog
//    b) Saber cuántos tipos distintos de items se juntan entre los tripulantes de un barco que están pasados de grogXD (es decir, los ítems sin repetidos)
//    c) Obtener el tripulante pasado de grogXD con más dinero de la tripulación de un barco.
// 8) Cada tripulante conoce qué tripulante del barco lo invito. Se quiere conocer quién es el tripulante de un barco pirata que invito (satisfactoriamente) a más gente.

class Barco {
  // Constantes
  const property tripulantes = []
  const property capacidad 

  // Variables
  var mision

  // Métodos

  // Método para saber si puede realizar una misión
  method puedeRealizarMision() = self.tieneSuficienteTripulacion()

  method tieneSuficienteTripulacion() = tripulantes.count() >= capacidad * 0.90

  // Método para saber si puede ser saqueado por un pirata
  method puedeSerSaqueado(unPirata) = unPirata.nivelDeEbriedad() >= 90

  // Método para saber si es vulnerable a un barco pirata
  method esVulnerable(unBarco) = self.tripulantes().size() <= unBarco.tripulantes().size() / 2

  // Método para incorporar un pirata a la tripulación
  method incorporar(unPirata) {
    if (self.hayEspacio() && unPirata.esUtil(mision)) {
      self.tripulantes().add(unPirata)
    }
  }

  method hayEspacio() = self.tripulantes().size() < capacidad

  // Método para cambiar la misión
  method cambiarMision(unaMision) {
    mision = unaMision
    const nuevaTripulacion = tripulantes.filter({t => t.esUtil(unaMision)})
    self.tripulantes().clear()
    self.tripulantes().addAll(nuevaTripulacion)
  }

  // Método para anclar el barco en una ciudad costera
  method anclarEnCiudadCostera() {
    self.tripulantes().forEach({t => t.tomarTragoDeGrog()})
    self.tripulantes().remove(self.tripulanteMasEbrio())
  }

  method tripulanteMasEbrio() = self.tripulantes().max({t => t.nivelDeEbriedad()})

  // Método para saber si un barco es temible
  method esTemible() = self.puedeRealizarMision() && self.tripulantes().forEach({t => mision.requerimientosDelPirata(t)}) && mision.requerimientosDelBarco(self)

  // Método para saber si algunos tripulanes son espías de la corona
  method hayAlgunEspiaEnLaTripulacion() = self.tripulantes().any({t => t.esEspia()})
}

class Pirata {
  // Constantes
  const property items = []

  // Variables
  var property nivelDeEbriedad 
  var property monedas

  // Métodos

  // Método para saber si un pirata es útil para una misión
  method esUtil(unaMision) = unaMision.requerimientosDelPirata(self)

  // Método para tomar trago de grog
  method tomarTragoDeGrog() {
    nivelDeEbriedad =+ 5
  }

  // Método para saber si es un espía
  method esEspia() = self.estaPasadoDeGrog() && self.items().contains("permiso de la corona")

  // Método para saber si está pasado de grog
  method estaPasadoDeGrog() = nivelDeEbriedad >= 90
}

class Mision {
  method puedeCompletarMision(unBarco) = unBarco.tieneSuficienteTripulacion()
}

class BusquedaDelTesoro inherits Mision{
  // Métodos

  // Método para saber si una misión puede ser realizada por un pirata
  method requerimientosDelPirata(unPirata) = unPirata.tieneUnaBrujulaOUnMapaOBotellaGrog() && unPirata.noTieneMasDe5Monedas() // HACER ESTOS MÉTODOS

  // Método para saber si una misión pueda ser realizada por un barco
  method requerimientosDelBarco(unBarco) = unBarco.tieneUnoLlaveDelTesoro() // HACER ESTE MÉTODO

  // override method puedeCompletarMision(unBarco) = 
}

class ConvertirseEnLeyenda inherits Mision{
  // Constante
  const property itemObligatorio

  // Métodos

  // Método para saber si una misión puede ser realizada por un pirata
  method requerimientosDelPirata(unPirata) = unPirata.items().size() >= 10 || unPirata.items().contains(itemObligatorio)

  // Método para saber si una misión pueda ser realizada por un barco
  method requerimientosDelBarco(unBarco) {
    // No tiene efecto
  }
}

class Saqueo inherits Mision{
  // Constantes
  // Obejtivos: barco o ciudad
  const property objetivo

  // Métodos
  
  // Método para saber si una misión puede ser realizada por un pirata
  method requerimientosDelPirata(unPirata) = unPirata.monedas() < cantidadDeMonedas.valor() || objetivo.puedeSerSaqueado(unPirata)

  // Método para saber si una misión pueda ser realizada por un barco
  method requerimientosDelBarco(unBarco) = objetivo.esVulnerable(unBarco)

}

//
object cantidadDeMonedas {
  var property valor = 0
}

class CiudadCostera {
  // Constantes
  const property habitantes 

  // Métodos

  // Método para saber si puede ser saqueado por un pirata
  method puedeSerSaqueado(unPirata) = unPirata.nivelDeEbriedad() >= 50

  // Método para saber si es vulnerable a un barco pirata
  method esVulnerable(unBarco) = unBarco.tripulantes().size() >= habitantes * 0.40 || unBarco.tripulantes().all({t => t.estaPasadoDeGrog()})
}