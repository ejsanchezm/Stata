* UNIVERSIDAD DE COSTA RICA
* PROYECTO LABORATORIO DATOS ECONOMICOS
* PROFESOR: Jose Francisco Solis
*
* GRUPO #2
* Estudiantes:
*	- Said Martínez
*	- Jose Morera
*	- Eduardo Sánchez
* 	- Iside Villalobos
*
*

* Variable para almacenar el path de la base de datos:
gen ENAHO17 = "C:\ProyectoStata\enaho17_pr.dta"
gen ENAHO18 = "C:\ProyectoStata\enaho18_pr.dta"

* Primero abro la base de datos del 2017*
use ENAHO17, clear

*Generamos el Identificador Unico de hogar(idh) utilizamos el comando concat() para generar un unico numero. 
egen idh = concat(UPM CUESTIONARIO HOGAR)
destring idh, replace

*VARIABLE DE LOS MIEMBROS DEL HOGAR

*Creamos una variable que nos diga la cantidad total de niños menores o igual a 12 años en cada hogar
egen inf12 = total(A5 <= 12 ), by (idh)

*Creamos una variable que nos diga la cantidad total de adultos mayores a 70 años
egen am70 = total (A5 > 70), by(idh)

* Creamos una variable que nos diga la cantidad total de peceptores por hogar calculado con el itpb
*Utilizamos !missing para que no tome en cuenta los missing values en la variable itpb
egen percep = total(!missing(itpb)), by(idh)
browse

*SELECCION DE INDIVUOS QUE ESTARAN EN EL ANALISIS

*vamos solo a dejar en A3 los valores igual a 1 que es jefe y 2 que es esposo (a)
drop if A3 > 2

*vamos a dejar en itrbt solo los valores positivos y no missing
keep if itrbt > 0
drop if itrbt == .

*en horas totales normales dejamos los positivos, conocidos, mayores o iguales que 8 y menores o iguales a 60
keep if HorTotNorm > 0
drop if HorTotNorm == .
keep if HorTotNorm >= 8
keep if HorTotNorm <= 60


*segundo abro la base de datos del 2018*
use "C:\Users\saidm\OneDrive - Universidad de Costa Rica\I 2023\Datos Economicos\Proyecto\enaho18_pr.dta", clear
*Generamos el Identificador Unico de hogar(idh) utilizamos el comando concat() para generar un unico numero. 
egen idh = concat(UPM CUESTIONARIO HOGAR)
destring idh, replace

*VARIABLE DE LOS MIEMBROS DEL HOGAR

*Creamos una variable que nos diga la cantidad total de niños menores o igual a 12 años en cada hogar
egen inf12 = total(A5 <= 12 ), by (idh)

*Creamos una variable que nos diga la cantidad total de adultos mayores a 70 años
egen am70 = total (A5 > 70), by(idh)

* Creamos una variable que nos diga la cantidad total de peceptores por hogar calculado con el itpb
*Utilizamos !missing para que no tome en cuenta los missing values en la variable itpb
egen percep = total(!missing(itpb)), by(idh)
browse

*SELECCION DE INDIVIDUOS QUE ESTARAN EN EL ANALISIS

*vamos solo a dejar en A3 los valores igual a 1 que es jefe y 2 que es esposo (a)
drop if A3 > 2

*vamos a dejar en itrbt solo los valores positivos y conocidos
keep if itrbt > 0
drop if itrbt == .

*en horas totales normales dejamos los positivos, conocidos, mayores o iguales que 8 y menores o iguales a 60
keep if HorTotNorm > 0
drop if HorTotNorm == .
keep if HorTotNorm >= 8
keep if HorTotNorm <= 60

*UNIR LAS BASES DE DATOS 2017 Y 2018
*Procedo a abrir la base de datos 2017
use "C:\Users\saidm\OneDrive - Universidad de Costa Rica\I 2023\Datos Economicos\Proyecto\Enaho17completa.dta", clear
*Procedo a usar append
append using "C:\Users\saidm\OneDrive - Universidad de Costa Rica\I 2023\Datos Economicos\Proyecto\Enaho18completa.dta"



*CREACION Y RECODIFICACION DE VARIABLES

* Crear una variable zona(zon) que tenga valores 0 y 1, con 1 igual a mujer
use "C:\ProyectoStata\EnahoCompleta.dta", clear
* Generamos una nueva variable string ZONA1
* que contiene los valores de ZONA(que son numéricos)

* ZONA es una variable numérica, generamos una variable ZONA1 de
* tipo string para poder comparar y generar la variable zon
decode ZONA, gen(ZONA1)
gen zon=1 if ZONA1="rural"
replace zon=0 if zon==.
* Ya no ocupamos la variable ZONA1, la eliminamos.
drop ZONA1

* Crear una variable de género (mujer) que tenga valores de 0 y 1, 
* con el 1 igual a mujer.
* A4 es la variable que contiene el "sexo"
decode A4, gen(genero1)
gen genero=1 if genero1=="mujer"
replace genero=0 if genero==.
drop genero1

* Crear una variable que separe a las personas según quienes 
* tienen pareja (pareja=1, si están casadas o en unión libre 
* y 0 en los otros casos)
*	
* A6 es la variable que contiene el "estado conyugal"
decode A6, gen(estadoconyugal1)
gen pareja=1 if (estadoconyugal1=="en unión libre o juntado(a)" || estadoconyugal1=="casado(a)")
replace pareja=0 if pareja==.
drop estadoconyugal1


* Crear una variable de años de escolaridad (Esc) en la cual los 
* valores missing estén recodificados como un punto
* E.Sánchez: No hay datos missing en las obsercavaciones(hay que preguntarle a Francisco)
gen Esc = Escolari
replace Esc=. if Escolari=99



* Crear una variable de adulto mayor (am) que tenga valores 0 y 1, 
* con 1 indicando que el hogar sí tiene adulto mayor.
gen am=1 if am70!=0
replace am=0 if am==.

* Crear una variable de rama de actividad, usando RamaEmpPri, 
* que se llame rama y en la cual los valores missing estén 
* recodificados como un punto.
decode RamaEmpPri, gen(RamaEmpPri1)
encode RamaEmpPri1, gen(rama)
replace rama=. if rama=="" 
drop RamaEmpPri1


* Crear una variable de experiencia laboral (con el nombre de: exp), 
* con la siguiente formula: Edad-(Escolaridad-6). La variable exp debe 
* tener valor missing (.) si años de escolaridad es missing (Esc==.). 
* La variable exp debe hacerse igual a cero, si diera negativa.
gen exp=A5-Esc-6
replace exp=. if Esc==.
replace exp=0 if Exp<0

* Crear el Ingreso del trabajo por hora (itrh) usando el Ingreso por 
* trabajo bruto total, para calcular la cantidad de colones por hora, 
* usando Horas totales normales y calculando 4 semanas por mes.
gen itrh = (itrbt/4)/HorTotNorm



