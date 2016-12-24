{
   InCo- Fing
   Programación 1
   Laboratorio 2016
   Segunda Tarea
   Diego Sirio
}

(******************************************************)
(*                Funciones Auxiliares                *)
(******************************************************)
{
La función ‘expbn’ se encarga de calcular la potencia de base ‘n’ y exponente ‘e’. 
La función es auxiliar (su implementación no es obligatoria) pero permite un cálculo 
más eficiente de potencias sin usar números reales.
}
function expbn(e : Natural; n : Natural): Natural; (*Exponente Base n*)
VAR i : Integer;
	resu : Natural;
begin
	resu := 1;
	for i := 1 to e do
		resu := resu*n;
	expbn := resu;
end;

{
La idea del corrimiento de celdas, sobre la que se basa mi código, es universal a varias
funciones y procedimientos, por lo cual puedo reutilizar varias funciones auxiliares:
}

{
La función ‘sumables’ se encarga de verificar si dos celdas cualesquiera son sumables 
(según las reglas del juego).
}
function sumable(a,b : TipoCelda): Boolean; (*Revisar si se puede mejorar*)
var resu : Boolean;
begin
	resu := false;
	if (a.color = blanca) AND (b.color = blanca) then
	begin
		if (a.exponente = b.exponente) then
			resu := true
	end
	else 
		if ((a.color = roja)and(b.color = azul)) 
			OR ((a.color = azul)and(b.color = roja)) then
			resu := true;
	sumable := resu;
end;

{
La función ‘corrible’ se encarga de verificar si alguna de dos celdas cualesquiera 
está vacía.
}
function corrible(a1,a2 : TipoCelda): Boolean; 
begin
	corrible := false;
	if (a1.color = gris) OR (a2.color = gris) then
		corrible := true;	
end;

(******************************************************)
(*         ALGORITMO DE CORRIMIENTO UNIVERSAL         *)
(******************************************************)
{
Dada una fila o columna fija, comienzo (en dicha fila o columna) sobre el borde 
del tablero hacia el cual me voy a mover (como jugador).
Por ejemplo, dada la primera fila del tablero, empiezo en la posicion (1,1) si el
movimiento es hacia la izquierda.
  1)Si la celda actual o la siguiente ESTAN VACIAS, entonces no se van a poder sumar las 
	celdas en toda esa columna o fila, ya que se van a correr todas las celdas a partir 
	de la celda vacía, en direccion del movimiento del jugador.
	Si no, paso a 2)
  2)Si la celda actual y la siguiente SON SUMABLES, entonces se suman con las reglas 
	adecuadas. La celda en la posición siguiente (respecto a la actual) se vuelve vacía. 
	Luego ocurre un corrimiento del resto de la fila o columna a partir de la celda vacía, 
	en direccion del movimiento del jugador y ya no se puede sumar más nada en toda esa 
	fila o columna. 
	Si no, paso a 3)
  3)Si alguna de las dos condiciones anteriores se cumple, entonces 'ya estoy' por esa 
	fila o columna. Si no pasa nada de esto y no estoy al final de dicha fila o columna, 
	me muevo una posición en esa fila o columna, en dirección opuesta al movimiento del 
	jugador y evaluó las dos condiciones anteriores (1 y 2).
}
(******************************************************)
(*      Funciones y Procedimientos Obligatorios       *)
(******************************************************)

{
La función ‘TerminaJuego’ utiliza el Algoritmo de Corrimiento Universal salvo que cuando 
se cumplen alguna de las dos primeras condiciones, ya la función devuelve el valor True.
}
function TerminaJuego(tablero: TipoTablero) : Boolean;
VAR i, j : Integer;
	b : Boolean;(*bandera*)
begin
	i := 1;
	b := false;
	while (i <= MAXTablero) AND (b = false) do
	begin
		j := 1;
		while (j+1 <= MAXTablero) AND (b = false) do
		begin
			if (corrible(tablero[i,j],tablero[i,j+1])) OR (sumable(tablero[i,j],tablero[i,j+1])) then
				b := true;
			j := j+1;
		end;
		i := i+1;
	end;
	j := 1;
	while (j <= MAXTablero) AND (b = false) do
	begin
		i := 1;
		while (i+1 <= MAXTablero) AND (b = false) do
		begin
			if (corrible(tablero[i,j],tablero[i+1,j])) OR (sumable(tablero[i,j],tablero[i+1,j])) then
				b := true;
			i := i+1;
		end;
		j := j+1;
	end;
	TerminaJuego := NOT b;
end;

{
La función ‘Puntaje’ realiza una recorrida completa del tablero actualizando el 
resultado ‘resu’ según los exponentes de las celdas blancas que me encuentro. 
Al final devuelve ‘resu’.
}
function Puntaje(tablero: TipoTablero) : Natural;
VAR i,j : Integer;
	resu : Natural;
begin
	resu := 0;
	for i := 1 to MAXTablero do
		for j := 1 to MAXTablero do
			if tablero[i,j].color = blanca then
				resu := resu + expbn(tablero[i,j].exponente + 1,3);
	Puntaje := resu;
end;

{
El procedimiento ‘DesplazamientoIzquierda’ se encarga de actualizar el tablero usando 
el Algoritmo de Corrimiento Universal, restringiéndome al movimiento hacia la izquierda 
(del jugador). Este algoritmo se aplica a TODAS  las filas, y la búsqueda mencionada 
se aplica de izquierda a derecha (en este caso).
El corrimiento de celdas que no van a ser sumadas utiliza un procedimiento auxiliar 
‘corrimiento’ ya que la acción se realiza más de una vez en ‘DesplazamientoIzquierda’.
Observacion: Este procediemento no utiliza la funcion corrible, si no que se fija si
la celda en la que estoy es vacia o no (sin mirar la siguiente).
}
procedure DesplazamientoIzquierda(var tablero : TipoTablero; var cambios : boolean);
VAR i,j : Integer;
	b,c : Boolean; (*bandera*)
procedure corrimiento(a : Integer; var tablero : TipoTablero);
VAR k : Integer;
begin
	for k := a to (MAXTablero-1) do
		tablero[i,k] := tablero[i,k+1];
	tablero[i,MAXTablero].color := gris;
end;
begin
	c := false;
	for i := 1 to MAXTablero do
	begin
		b := false;
		j := 1;
		while (j+1 <= MAXTablero) AND (b = false) do
			if (tablero[i,j].color = gris) then
			begin
				corrimiento(j,tablero);
				b := true;
			end 
			else  
				if (sumable(tablero[i,j],tablero[i,j+1])) then
				begin
					if (tablero[i,j].color = roja) OR (tablero[i,j].color = azul) then
					begin
						tablero[i,j].color := blanca;
						tablero[i,j].exponente := 0;	
					end 
					else
						tablero[i,j].exponente := tablero[i,j].exponente + 1;
					corrimiento(j+1,tablero);
					b := true;
				end 
				else j := j + 1;
		if (c = false) AND (b = true) then
			c := true;
	end;
	cambios := c;
end;

{
El procedimiento ‘SimetriaVertical’ se encarga de realizar la simetría de la matriz 
recorriendo CADA fila hasta la mitad del tablero (el eje de la matriz) e intercambiando 
con las celdas simétricas respecto a dicho eje.
}
procedure  SimetriaVertical(var tablero : TipoTablero);
VAR i,j : Integer;
	aux : TipoCelda;
begin
	for i := 1 to MAXTablero do
		for j := 1 to (MAXTablero DIV 2) do
		begin
			aux := tablero[i,j];
			tablero[i,j] := tablero[i,MAXTablero-j+1];
			tablero[i,MAXTablero-j+1] := aux;
		end;
end;

{
Tanto el procedimiento ‘RotacionDerecha’ y ‘RotacionIzquierda’ intercambian las celdas 
del tablero directamente para realizar la rotaciones. Si pensamos el tablero como un 
cuadrado con un borde cuadrado, guardamos ese borde y lo sacamos. Obtenemos otro cuadrado 
con un borde cuadrado. Guardamos ese borde y lo sacamos…, y así hasta quedar con una 
sola celda o con ninguna (Según si MAXTablero es Impar o Par). En esos bordes se mueven 
las celdas como un ciclo hasta que se obtiene el borde rotado (hacia la Derecha o Izquierda). 
Sin embargo en mi caso estos ciclos los realizo intercambiando 4 celdas en cada lado del 
borde en cuestión, y repitiendo por todo el lado del borde.
}
procedure RotacionDerecha(var tablero : TipoTablero);
VAR i,j : Integer;
	aux : TipoCelda;
begin
	for j := 1 to (MAXTablero DIV 2) do 
		for i := j to (MAXTablero - j) do
		begin
			aux := tablero[i,MAXTablero+1-j];{1}
			tablero[i,MAXTablero+1-j]{1} := tablero[j,i];{4}
			tablero[j,i]{4} := tablero[MAXTablero+1-i,j];{3}
			tablero[MAXTablero+1-i,j]{3} := tablero[MAXTablero+1-j,MAXTablero+1-i];{2}
			tablero[MAXTablero+1-j,MAXTablero+1-i]{2} := aux;
		end;
end;
procedure RotacionIzquierda(var tablero : TipoTablero);
VAR i,j : Integer;
	aux : TipoCelda;
begin
	for j := 1 to (MAXTablero DIV 2) do 
		for i := j to (MAXTablero - j) do
		begin
			aux := tablero[i,j];{1}
			tablero[i,j]{1} := tablero[j,MAXTablero+1-i];{4}
			tablero[j,MAXTablero+1-i]{4} := tablero[MAXTablero+1-i,MAXTablero+1-j];{3}
			tablero[MAXTablero+1-i,MAXTablero+1-j]{3} := tablero[MAXTablero-j+1,i];{2}
			tablero[MAXTablero-j+1,i]{2} := aux;
		end;
end;

{
El procedimiento ‘PosiblesSumas’ utiliza el Algoritmo de Corrimiento Universal
(pero sin realizar ningun corrimiento).
Se encarga de en CADA fila y columna del tablero y en todas las direcciones, encontrar 
las celdas sumables (Segunda condición del algoritmo) y guardar estas celdas en una lista
junto con el movimiento que realiza el jugador para obtener dicha suma, y el valor de esta.
Para ello utilizo un procedimiento auxiliar llamado ‘Agregar’, que agrega 
registros con estos datos al principio de una lista.
}
function PosiblesSumas(tablero : TipoTablero) : ListaSumables;
VAR i,j,a : Integer;
	s,e : Natural;
	m : TipoDireccion;
	b : Boolean;
	lista : ListaSumables;
procedure Agregar(var l : ListaSumables; f, c : RangoIndice; mov : TipoDireccion; s : Natural);
VAR p : ListaSumables;
begin
	new(p);
	p^.posicion.fila := f;
	p^.posicion.columna := c;
	p^.movimiento := mov;
	p^.suma := s;
	p^.siguiente := l;
	l:= p;
end;
begin
	lista := nil;
	for i := 1 to MAXTablero do
		for a := 0 to 1 do
		begin
			b := false;
			j := 1;
			while (j+1 <= MAXTablero) AND (NOT corrible(tablero[i,j + a*(MAXTablero+1-2*j)],
					tablero[i,j+1 + a*(MAXTablero+1-2*(j+1))])) AND (NOT b) do
			begin
				if (sumable(tablero[i,j + a*(MAXTablero+1-2*j)],
							tablero[i,j+1 + a*(MAXTablero+1-2*(j+1))])) then
				begin
					if tablero[i,j + a*(MAXTablero+1-2*j)].color = blanca then
					begin
						e := tablero[i,j + a*(MAXTablero+1-2*j)].exponente;
						s := 3*expbn(e+1,2);
					end
					else s := 3;
					Case a of
					0 : m := izquierda;
					1 : m := derecha;
					end;
					Agregar(lista,i,j + a*(MAXTablero+1-2*j),m,s);
					b := true;
				end;
				j := j+1;
			end;
		end;
	for j := 1 to MAXTablero do
		for a := 0 to 1 do
		begin
			b := false;
			i := 1;
			while (i+1 <= MAXTablero) AND (NOT corrible(tablero[i + a*(MAXTablero+1-2*i),j],
					tablero[i+1 + a*(MAXTablero+1-2*(i+1)),j])) AND (NOT b) do
			begin
				if (sumable(tablero[i + a*(MAXTablero+1-2*i),j],
							tablero[i+1 + a*(MAXTablero+1-2*(i+1)),j])) then
				begin
					if tablero[i + a*(MAXTablero+1-2*i),j].color = blanca then
					begin
						e := tablero[i + a*(MAXTablero+1-2*i),j].exponente;
						s := 3*expbn(e+1,2);
					end
					else s := 3;
					Case a of
					0 : m := arriba;
					1 : m := abajo;
					end;
					Agregar(lista,i + a*(MAXTablero+1-2*i),j,m,s);
					b := true;
				end;
				i := i+1;
			end;
		end;
	PosiblesSumas := lista;
end;

{
Por último la función ‘ObtenerCeldaPosicion’, dado un natural ‘k’, realiza un recorrido 
(en la lista creada en el procedimiento anterior) parando en la k-iteración 
(Si antes no se terminó la lista). Si la lista termina ahí devuelve NIL 
y si existe un registro devuelve el puntero que señala a dicho registro.
}
function  ObtenerCeldaPosicion(k : Natural; lista : ListaSumables) : ListaSumables;
VAR i : Integer;
	p : ListaSumables;
begin
	i := 0;
	p := lista;
	while (p <> nil) AND (i < k) do
	begin
		p := p^.siguiente;
		i := i + 1;
	end;
	ObtenerCeldaPosicion := p;
end;
