import Pkg;
Pkg.add("JuMP")
Pkg.add("GLPK")

using JuMP,GLPK

#Zadatak 1

# Neko preduzeće plasira na tržište dvije vrste mljevene kafe K1 i K2. Očekivana zarada je 3
# novčane jedinice (skraćeno n.j.) po kilogramu za kafu K1 (tj. 3n.j./kg), a 2 n.j./kg za kafu K2. Pogon
# za prženje kafe je na raspolaganju 150 sati sedmično, a pogon za mljevenje kafe 60 sati sedmično.
# Utrošeni sati za prženje i mljevenje po kilogramu proizvoda dati su u sljedećoj tabeli:
# Formirati matematički model iz kojeg se može odrediti koliko treba proizvesti kafe K1,
# a koliko kafe K2, tako da ukupna zarada bude maksimalna.

m=Model(GLPK.Optimizer)
@variable(m,x1>=0)
@variable(m,x2>=0)

@objective(m,Max,3x1+2x2)

@constraint(m, constraint1, 0.5x1+0.3x2<=150)
@constraint(m, constraint2, 0.1x1+0.2x2<=60)

print(m)

optimize!(m)
termination_status(m)

println("Rješenja: ")
println("x1 = ", value(x1))
println("x2 = ", value(x2))
println("Vrijednost cilja: ")
println(objective_value(m))


# Potrebno je obezbijediti vitaminsku terapiju koja će sadržavati četiri vrste vitamina V1, V2,
# V3 i V4. Na raspolaganju su dvije vrste vitaminskih sirupa S1 i S2 čije su cijene 40 n.j./g i 30 n.j./g
# respektivno. Vitaminski koktel mora sadrţavati najmanje 0.2 g, 0.3 g, 3 g i 1.2 g vitamina V1, V2, V3 i
# V4 respektivno. Sljedeća tabela pokazuje sastav pojedinih vitamina u obje vrste vitaminskih sirupa:
# Formirati matematički model iz kojeg se može odrediti koliko treba nabaviti sirupa S1,
# a koliko sirupa S2, tako da ukupni trošak bude minimalan.

m2=Model(GLPK.Optimizer)
@variable(m2,x1>=0)
@variable(m2,x2>=0)

@objective(m2,Min,40x1+30x2)

@constraint(m2, constraint1, 0.1x1>=0.2)
@constraint(m2, constraint2, 0.1x2>=0.3)
@constraint(m2, constraint3, 0.5x1+0.3x2>=3)
@constraint(m2, constraint4, 0.1x1+0.2x2>=1.2)

print(m2)

optimize!(m2)
termination_status(m2)

println("Rješenja: ")
println("x1 = ", value(x1))
println("x2 = ", value(x2))
println("Vrijednost cilja: ")
println(objective_value(m2))

# Planira se proizvodnja tri tipa detrdženta D1, D2 i D3. Sa trgovačkom mrežom je dogovorena
# isporuka tačno 100 kg detrdženta bez obzira na tip. Za uvoz odgovarajućeg repromaterijala planirano
# su sredstva u iznosu od 110 $. Po jednom kilogramu detrdženta, za proizvodnju detrdţenata D1, D2 i
# D3 treba nabaviti repromaterijala u vrijednosti 2 $, 1.5 $ odnosno 0.5 $. Također je planirano da se za
# proizvodnju uposle radnici sa angažmanom od ukupno barem 120 radnih sati, pri čemu je za
# proizvodnju jednog kilograma detrdženata D1, D2 i D3 potrebno uložiti respektivno 2 sata, 1 sat
# odnosno 1 sat. Prodajna cijena detrdženata D1, D2 i D3 po kilogramu respektivno iznosi 10 KM, 5 KM odnosno 8 KM. 
# Formirati matematski model iz kojeg se može odrediti koliko treba proizvesti svakog
# od tipova detrdženata da se pri tome ostvari maksimalna moguća zarada.

m3=Model(GLPK.Optimizer)
@variable(m3,x1>=0)
@variable(m3,x2>=0)
@variable(m3,x3>=0)
@objective(m3,Max,10x1+5x2+8x3)
@constraint(m3, constraint1, x1+x2+x3==100) 
@constraint(m3, constraint2, 2x1+1.5x2+0.5x3<=110) 
@constraint(m3, constraint3, 2x1+x2+x3>=120) 
print(m3)
optimize!(m3)
termination_status(m3)
println("Rješenja:") 
println("x1 = ", value(x1))
println("x2 = ", value(x2))
println("x3 = ", value(x3))
println("Vrijednost cilja:")
println(objective_value(m3))

#Zadatak 2

# Fabrika proizvodi dva proizvoda. Za proizvodnju oba proizvoda koristi se jedna sirovina čija količina je
# ograničena na 20 kg u planskom periodu. Za pravljenje svakog kilograma prvog proizvoda potroši se 250
# grama sirovine,a za pravljenje svakog kilograma drugog proizvoda potroši se 750 grama sirovine. 
# Dobit od prvog proizvoda je 3 KM po kilogramu, a od drugog 7 KM po kilogramu. 
# Potrebno je napraviti plan proizvodnje koji maksimizira dobit, pri čemu je potrebno povesti računa da je količina proizvoda koji se
# mogu plasirati na tržište ograničena. Prvog proizvoda može se prodati maksimalno 10 kg, a drugog 9 kg.

a=Model(GLPK.Optimizer)
@variable(a,x1>=0)
@variable(a,x2>=0)

@objective(a, Max, 3x1 + 7x2)

@constraint(a, constraint1, 0.25x1 + 0.75x2 <=20)
@constraint(a, constraint2, x1<=10)
@constraint(a, constraint3, x2<=9)

print(a)

optimize!(a)
termination_status(a)

println("Rješenja: ")
println("x1 = ", value(x1))
println("x2 = ", value(x2))
println("Vrijednost cilja: ")
println(objective_value(a))

# Neka fabrika proizvodi geveznice i kataklingere, pri čemu je prodajna cijena geveznica 150 KM po
# kubnom metru, a kataklingera 40 KM po kilogramu. Za proizvodnju jednog kubnog metra geveznica
# potrebna su 3 kilograma cincozni i 9 vrećica šnaus-mufni, dok su za proizvodnju jednog kilograma
# kataklingera potrebna 2 litra kalamute i 4 vrećice šnaus-mufni. Fabrika raspolaže zalihama od 36 kilograma
# cincozni, 54 litara kalamute i 144 vrećice šnaus-mufni. Potrebno je naći optimalni plan proizvodnje koji će
# maksimizirati moguću zaradu koja će se ostvariti prodajom, u skladu sa raspoloživim zalihama.


b=Model(GLPK.Optimizer)
@variable(b,x1>=0)
@variable(b,x2>=0)

@objective(b, Max, 150x1 + 40x2)

@constraint(b, constraint1, 3x1<=36)
@constraint(b, constraint2, 2x2<=54)
@constraint(b, constraint3, 9x1 + 4x2 <= 144)

print(b)

optimize!(b)
termination_status(b)

println("Rješenja: ")
println("x1 = ", value(x1))
println("x2 = ", value(x2))
println("Vrijednost cilja: ")
println(objective_value(b))


# Dva tipa vitamina V1 i V2 mogu se konzumirati putem dva tipa tableta, T1 i T2, čije su cijene redom 24
# odnosno 25 feninga po tableti. Dnevno treba konzumirati minimalno 17 jedinica vitamina V1 i 11 jedinica
# vitamina V2. Tableta T1 sadrži 1 jedinicu vitamina V1 i 4 jedinice vitamina V2. Tableta T2 sadrži 5 jedinica
# vitamina V1 i jednu jedinicu vitamina V2. Potrebno je utvrditi koliko tableta i kojih treba da se utroši
# svakog dana da se zadovolje dnevne potrebe za vitaminima uz minimalne troškove

c=Model(GLPK.Optimizer)
@variable(c,x1>=0)
@variable(c,x2>=0)

@objective(c, Min, 24x1 + 25x2)

@constraint(c, constraint1, x1+ 5x2 >=17)
@constraint(c, constraint2, 4x1 + x2 >=11)

print(c)

optimize!(c)
termination_status(c)

println("Rješenja: ")
println("x1 = ", value(x1))
println("x2 = ", value(x2))
println("Vrijednost cilja: ")
println(objective_value(c))