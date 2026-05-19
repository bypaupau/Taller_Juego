personaje('Elara', 5, 100).
personaje('Kael', 3, 80).
personaje('Rin', 7, 120).

% 1. 3 nuevos jugadores
personaje('Daniel', 8, 200).
personaje('Sofia',6,150).
personaje('Nico',3,90).

% dificultad y xp requerido por cada mision
mision(m1, 'Bosque de Sombras', 2, 50).
mision(m2, 'Cueva del Dragon', 5, 120).
mision(m3, 'Torre Arcana', 7, 200).

% caracteristicas de las armas: nivel de ataque
arma(espada,160).
arma(escudo,50).
arma(pocion,40).
arma(arco,15).
arma(flechas,90).
arma(varita,80).
arma(pocion,50).
arma(amuleto,2).


%inventario de cada personaje
inventario('Elara', [espada, escudo, pocion]).
inventario('Kael', [arco, flechas]).
inventario('Rin', [varita, grimorio, pocion, amuleto]).
inventario('Daniel',[espada, pocion, varita, escudo, flechas, arco]).
inventario('Sofia',[varita,pocion]).
inventario('Nico', [espada]).

% las armas que requieren la mision
requiere(m2, escudo).
requiere(m2, pocion).
requiere(m3, grimorio).
requiere(m3, pocion).

% 2. 3 tipos de enemigos y su vida
enemigo('Zombie', 20).
enemigo('Slenderman', 70).
enemigo('Ogro', 150).

% Paso 3: Verificar si un personaje puede aceptar una mision
% Un personaje puede aceptar una mision si el nivel en el que se encuentra, es mayor a la dificultad de la mision

puede_aceptar(Personaje, ID_Mision):-
    personaje(Personaje, Nivel, _),
    mision(ID_Mision, _, Dificultad, _),
    Nivel >= Dificultad.


% 2. Calculo recursivo de XP acumulada (Patron factorial de 2.1)
% Caso base: 0 misiones = 0 XP
xp_acumulada(0,0).

% Paso recursivo: XP(N) = XP(N-1) + (30*N)
xp_acumulada(N, Total):-
    N > 0,
    N1 is N-1, % Intancacion obligatoria antes de recursion
    xp_acumulada(N1, Prev),
    Total is Prev + (30 *N). % Precedencia: * antes de +

% 3. Verificacion de inventario con member/2
tiene_requerido(Personaje, Objeto):-
    inventario(Personaje, Lista),
    member(Objeto, Lista). % funcion built in (2,3)

% Reglas de unificacion y comparacion

% 1. Detectar personajes del mismo nivel exacto (vs unificacion)
mismo_nivel(P1,P2):-
    personaje(P1, N, _),
    personaje(P2, N, _),
    P1 \== P2.

% 2. Validar balance aritmetico estrico
es_balanceado(Personaje):-
    personaje(Personaje, _, Vida),
    Vida =:= 100.

% Procesamiento de listas y nlp
% 1. Fusionar inventarios de dos personajes usando append/3 (2,3)

fusionar_equipos(P1,P2, EquipoFusionado):-
    inventario(P1, L1),
    inventario(P2, L2),
    append(L1,L2, EquipoFusionado).

% Base de conjugacion (Adaptacion directa de conjugar_verbo/5 en 2.3)

tiempo(presente).
tiempo(pasado).
tiempo(futuro).
persona(primera). 
persona(segunda).
persona(tercera).
numero(singular).
numero(plural).

ser(presente, tercera, singular, "es").
ser(pasado, tercera, singular, "fue").
ser(futuro, tercera, singular, "será").
ser(presente, primera, singular, "soy").
ser(presente, primera, plural, "somos").
ser(presente, tercera, plural, "son").

%3. Regla de inferencia con estructura condicional (2.3)

conjugar_accion(Verbo, Tiempo, Persona, Numero, Conjugacion):-
    tiempo(Tiempo), persona(Persona), numero(Numero),
    (Verbo = "ser" ->
        ser(Tiempo, Persona, Numero, R),
        Conjugacion = R
        ; Conjugacion = Verbo). % Si no es "ser", devuelve el infinito


% Paso recursivo: Valida el primer elemento (Cabeza) y llama a la regla con el Resto.
todos_pueden_aceptar([Personaje | Resto], MisionID) :-
    puede_aceptar(Personaje, MisionID),
    todos_pueden_aceptar(Resto, MisionID).

% 4. Generacion de reporte narrativo
% Caso a: Un solo personaje (Singular)
% Esto me va a dar un reporte que me diga que persona puede aceptar una mision, si la mision puede estar en el mismo nivel que ellas esta y se conjuga el tiempo verbal.
generar_reporte(Personaje, MisionID, Mensaje) :-
    personaje(Personaje, _, _), % 
    puede_aceptar(Personaje, MisionID),
    mision(MisionID, Nombre, Dificultad, XP_Base),
    xp_acumulada(Dificultad, XP_Total), % Obtiene la XP acumulada
    conjugar_accion("ser", presente, tercera, singular, FormaVerbal),
    atomic_list_concat([Personaje, FormaVerbal, "capaz de completar", Nombre, "por", XP_Base, "XP (", XP_Total, "XP acumulada)"], ' ', Mensaje).

% Caso B: Varios personajes (Plural) 

generar_reporte([P1, P2 | Resto], MisionID, Mensaje) :-
    Lista = [P1, P2 | Resto],
    todos_pueden_aceptar(Lista, MisionID), % Llamamos a la regla recursiva
    mision(MisionID, Nombre, Dificultad, XP_Base),
    xp_acumulada(Dificultad, XP_Total), % Obtenemos la XP acumulada
    conjugar_accion("ser", presente, tercera, plural, FormaVerbal), % Usamos el plural
    atomic_list_concat(Lista, ' y ', NombresUnidos), % Une los nombres
    atomic_list_concat([NombresUnidos, FormaVerbal, "capaces de completar", Nombre, "por", XP_Base, "XP (", XP_Total, "XP acumulada)"], ' ', Mensaje).


% Caso base: Si la mochila está vacía, el daño es 0.
sumar_armas([], 0).

% Caso recursivo: Saca la primera arma, busca su daño, y súmala con el resto de la mochila.
sumar_armas([Arma | Resto], Total) :-
    arma(Arma, Dano),
    sumar_armas(Resto, SubTotal),
    Total is Dano + SubTotal.


atacar(Jugador, Enemigo) :-
    % 1. Extraemos la lista de armas del jugador     
    inventario(Jugador, ListaArmas),
    % 2. Sumamos el daño de todas las armas a la vez
    sumar_armas(ListaArmas, DanoTotal),
    % 3. obtenemos la vida del enemigo
    enemigo(Enemigo, Vida),
    % 4. Si el daño total es mayor o igual a la vida, gana.
    ( DanoTotal >= Vida ->
        Resultado = "¡El ataque es letal! El enemigo muere."
    ; 
        Resultado = "El ataque no fue suficiente. El enemigo sobrevive."
    ),

    format('~w ataca a ~w con todo su arsenal (Daño Total: ~w). ~w~n', [Jugador, Enemigo, DanoTotal, Resultado]).


% Caso grupal:
% Caso base: si la lista está vacía, el daño es 0
danogrupal([],0). 

% Caso recursivo: Entra a lista de los jugadores y ve uno por uno el daño que puede sre causado por las armas que tienen

% regla para calcular el total de daño causado por el grupo
% Caso recursivo: Entra a cada jugador y suma TODA su mochila
danogrupal([Jugador | Resto], DanoTotal):-
    inventario(Jugador, ListaArmas),
    sumar_armas(ListaArmas, DanoJugador),
    danogrupal(Resto, DanoResto),
    DanoTotal is DanoJugador + DanoResto.

ataque_grupal(ListaJugadores, Enemigo):-
    enemigo(Enemigo,Vida),
    danogrupal(ListaJugadores, DanoTotal),

    (DanoTotal >= Vida ->
        Resultado = "¡Victoria! El grupo logró vencer al enemigo, ¡yay!";
        Resultado = "No lograron vencer al enemigo :("),

        format('El grupo ataca a ~w (Vida: ~w) con un daño total de ~w. ~w~n', [Enemigo, Vida, DanoTotal, Resultado]).

