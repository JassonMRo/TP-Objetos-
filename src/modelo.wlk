class Receta{
	const property ingredientes = []
	const property nivelDeDificultad
	
	method esDificil() = nivelDeDificultad > 5 || self.cantidadDeIngredientes() > 10
	
	method cantidadDeIngredientes() = ingredientes.size()
	
	method experienciaAportada() = self.cantidadDeIngredientes() * nivelDeDificultad
}

///////////////////////////

class Cocinero{
	const property preparaciones = []
	
	method preparacionExitosa(receta){
		self.agregarPreparacion(self.preparacionComida(receta))
		if(self.superoNivelDeAprendizaje()){
			self.subirDeNivel()
		}
	}
	
	method agregarPreparacion(comida){
		preparaciones.add(comida)
	}
	
	method experienciaAdquirida() = preparaciones.sum({comida => comida.experienciaAportada()})
	
	method laComidaQueMasExperienciaLeAporta(recetario) = 
			recetario.filter({receta =>self.puedePreparar(receta)}).max({receta => receta.experienciaAportada()})
	
	method superoNivelDeAprendizaje()
	
	method subirDeNivel()
	
	method puedePreparar(receta)
	
	method preparacionComida(receta)
	
}

class Principiante inherits Cocinero{ //elaboran comidas de calidad pobre o normal
	
	
	override method puedePreparar(receta) = not receta.esDificil()
	
	override method superoNivelDeAprendizaje() = self.experienciaAdquirida() > 100
	
	override method preparacionComida(receta){
		if(self.puedePreparar(receta)){
			if(receta.cantidadDeIngredientes() < 4){
				return new ComidaNormal(ingredientes = receta.ingredientes(), nivelDeDificultad = receta.nivelDeDificultad(), calidad = "Normal")
			}else{
				return new ComidaNormal(ingredientes = receta.ingredientes(), nivelDeDificultad = receta.nivelDeDificultad(), calidad = "Pobre")
				 	
			}
		}else{
			throw new SinCondicionesParaRealizarlo(message = "No se puede llevar a cabo la Preparacion")
		}	
	}
	
	override method subirDeNivel(){
		return new Experimentado(preparaciones = self.preparaciones())
	}
}

class Experimentado inherits Principiante{ //elaboran comidas de calidad normal o superior
	override method puedePreparar(receta) = super(receta) || self.recetasSimilares(receta) > 0
	
	method recetasSimilares(receta) = 
		preparaciones.count({comida => comida.ingredientes() == receta.ingredientes() ||
		receta.nivelDeDificultad() - comida.nivelDeDificultad() <= 1 })
			
	override method superoNivelDeAprendizaje() = self.comidasDificiles() > 5
	
	method comidasDificiles() = preparaciones.count({receta => receta.esDificil()})
	
	method perfeccionarReceta(receta) = self.experienciaAdquirida() >= 3*receta.experienciaAportada()
	
	override method preparacionComida(receta){
		if(self.puedePreparar(receta)){
			if(self.perfeccionarReceta(receta)){
				return new ComidaSuperior(ingredientes = receta.ingredientes(),
				 	nivelDeDificultad = receta.nivelDeDificultad(), plusComidaSuperior = self.plusPerfeccionReceta(receta))
			}else{
				return new ComidaNormal(ingredientes = receta.ingredientes(), nivelDeDificultad = receta.nivelDeDificultad(), calidad = "Normal")
				 	
			}
		}else
			throw new SinCondicionesParaRealizarlo(message = "No se puede llevar a cabo la Preparacion")	
	}
	
	method plusPerfeccionReceta(receta) = self.recetasSimilares(receta) / 10
		
	}

class Chef inherits Experimentado{ //capaces de preparar cualquier receta
	override method puedePreparar(receta) = true
	
	override method superoNivelDeAprendizaje(){
		throw new NoHayNivelMasAvanzado(message = "El nivel Chef es el mas avanzado")
	}
}

////////////////////////////////

class ComidaPobre inherits Receta{
	const property calidad = "pobre"
	const property puntoMaximo
	
	override method experienciaAportada() = puntoMaximo * nivelDeDificultad
	
}

class ComidaNormal inherits Receta{
	const property calidad
	//override method experienciaAportada () = receta.experienciaAportada()
}

class ComidaSuperior inherits Receta{
	const property calidad = "superior"
	const property plusComidaSuperior 
	
	override method experienciaAportada() = super() + plusComidaSuperior 
}

class NoHayNivelMasAvanzado inherits DomainException{
	
}

class SinCondicionesParaRealizarlo inherits DomainException{
	
}

////////////////////////

class RecetaGourmet inherits Receta{
	
	override method esDificil() = true
	
	override method experienciaAportada() = super() * 2	
}


object academia{
	var property estudiantes = []
	var property recetario = []
	
	method entrenarEstudiantes(){
		estudiantes.forEach({estudiante => estudiante.preparacionExitosa(estudiante.laComidaQueMasExperienciaLeAporta(recetario))})
	}
}
