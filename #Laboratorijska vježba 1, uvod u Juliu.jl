#Laboratorijska vježba 1, uvod u Juliu

#Zadatak 1

3*456/23 + 31.54 + 2^6
sin(pi/7) * exp(0.3) * (2+0.9im)
sqrt(2) * log(10)
(5+3im)/(1.2+4.5im)

#Zadatak 2

a=(atan(5)+exp(5.6))/3
b=sin(pi/3)^(1/15)
c=(log(15)+1)/23
d=sin(pi/2)+cos(pi)
(a+b)*c
acos(b)*asin(c/11)
(a-b)^4/d
c^(1/a) + b*im/(3+2*im)

#Zadatak 3

using LinearAlgebra

A=[1 -4*im sqrt(2)
log(Complex(-1)) sin(pi/2) cos(pi/3)
asin(0.5) acos(0.8) exp(0.8)   
]
A'
transpose(A)
A+transpose(A)
A*transpose(A)
transpose(A)*A
det(A)
inv(A)
pinv(A)

#Zadatak 4

zeros(8,9)
ones(7,5)
I(5)
rand(4,9)

#Zadatak 5

a=[2 7 6
9 5 1
4 3 8]
sum(a)
sum(a,dims=1)
sum(a,dims=2)
tr(a)
tr(rotl90(a))
minimum(a)
minimum(a,dims=1)
minimum(a,dims=2)
maximum(diag(a))
maximum(a)
maximum(diag(rotl90(a)))

#Zadatak 6

a=[1 2 3
4 5 6
7 8 9]
b=[1 1 1 
2 2 2
3 3 3]
c=sin.(a)
c=sin.(a)*cos.(b)
c=(a^3)^(1/3)
c=(a.^1).^(1/3)

#Zadatak 7

0:99
[0:99;]'
[0:0.01:0.99;]'
[39:-2:1]'

#Zadatak 8

a=[7*ones(4,4) zeros(4,4)
3*ones(4,8)]
b=I(8)+A
c=b[1:2:8,:]
d=b[:,1:2:8]
e=b[1:2:8,1:2:8]
c[2,:]=c[2,:] *2

#Zadatak 9

import Pkg;
Pkg.add("Plots")
using Plots

x=[-pi:pi/50:pi;];
y=sin.(x)
plot(x,y,title = "Sinus", label = "sin(x)")
xlabel!("x")
ylabel!("y")

x=range(-pi,stop=pi,length=101);
y=cos.(x)
plot(x,y,title = "Kosinus", label = "cos(x)")
xlabel!("x")
ylabel!("y")

x=range(1,stop=10,length=101);
y=sin.(1 ./ x);
plot(x,y,color=:black, label = "sin(1/x)")

x1=range(1,stop=10,length=101);
y1=cos.(1 ./ x1);
plot!(x1,y1,color=:blue,line=(:dot), label = "cos(1/x)")

x=range(-pi, π, length = 101)
y=[sin.(x) cos.(x)]
plot(x,y,shape = [:circle :star5], label = ["sin(x)" "cos(x)"])
title!("Sinus i kosinus")

x=range(-pi, π, length = 101)
y1=sin.(x);
y2=cos.(x);
p1=plot(x,y1,title="Sinus",shape=:circle,label="sin(x)");
p2=plot(x,y2,title="Kosinus",color=:red,shape=:star5,label="cos(x)");
plot(p1,p2,layout=(1,2))

#Zadatak 10

x, y = -8:0.5:8, -8:0.5:8
z(x,y) = sin.(sqrt.(x.^2+y.^2))
surface(x,y,z, st=:surface)

#=

        Julia funkcije, metaprogramiranje i GUI

=#

#Zadatak 1
function zbir_razlika(x=0,y=0)
    if (size(x)===size(y))
     x + y, x-y
    else return (0,0)
    end
end

zbir_razlika([2;2])
zbir_razlika([1 2 3; 4 5 6],[1 2 3])
a,b=zbir_razlika(5,8)
zbir_razlika([1 2 3; 1 2 3], [4 5 6; 4 5 6])
zbir_razlika()

#Zadatak 2
function sume(mat)
    suma_matrice=0
    suma_redova=zeros(size(mat,1))
    suma_kolona=zeros(size(mat,2))
    suma_diagonale=0
    suma_sporedne=0
    for i = 1:size(mat,1)
        for j = 1:size(mat,2)
           suma_matrice+=mat[i,j]
           suma_redova[i]+=mat[i,j]
           suma_kolona[j]+=mat[i,j]
           if size(mat,1) == size(mat,2)
              if i==j
                  suma_diagonale+=mat[i,j]
              end
              if (i + j) == (size(mat,1)+1)
                    suma_sporedne += mat[i,j]; 
              end
           end
        end
    end
    return suma_matrice,suma_redova,suma_kolona, suma_diagonale, suma_sporedne
end

sume([1 2 3; 4 5 6; 7 8 9])
a=[2 7 6; 9 5 1; 4 3 8];
sume(a)
sume(a[2,:])
sume(a[1:2,1:2])

#Zadatak 3
function crtaj(s::String)
    global x=LinRange(-5,5,100)
    x=[x;];
    y = eval(Meta.parse(s))
    plot(x,y)
end
using Plots;

function crtaj2(s::String)
    x=LinRange(-5,5,100)
    x=[x;];
    f = eval(Meta.parse("(x) -> $s"))
    y = Base.invokelatest(f,x)
    plot(x,y)
end

crtaj("x.^2")
crtaj2("x.^2")
crtaj("sin.(x)")
crtaj2("sin.(x)")
