using Pkg
Pkg.add("JuMP")
Pkg.add("GLPK")
using JuMP, GLPK
using DelimitedFiles

function general_simplex(goal, c, A, b, csigns, vsigns)

    #data validity

        if(!(goal =="max" || goal =="min") || A == nothing || b == nothing || c== nothing)
            println("Invalid arguments!")
            return 0
        end

        for i in 1:size(csigns, 1)
            if(!(csigns[i] == 1 || csigns[i] == -1 || csigns[i] == 0))
                println("Invalid condition signs!")
                return 0
            end
        end
    
        for i in 1:size(vsigns, 1)
            if(!(vsigns[i] == 1 || vsigns[i] == -1 || vsigns[i] == 0))
                println("Invalid variable values!")
                return 0
            end 
        end

        rows = size(b, 1)
        if (rows != size(A, 1))
            println("Invalid row number!")
            return 0
        end

        columns = size(c, 1)
        if (columns!= size(A, 2))
            println("Invalid column number!")
            return 0
        end

        #if empty arguments

        if (csigns == nothing) 
            csigns = Vector{Int32}()
            for i in 1: rows
                push!(csigns, -1)
            end
        end
        if (vsigns == nothing) 
            vsigns = Vector{Int32}()
            for i in 1: columns
                push!(vsigns, 1)
            end
        end


        #if negative b

        for i in 1: rows
            coefficient = b[i]
            if(coefficient < 0)
                b[i] = b[i] * (-1)
                for j in 1: size(A, 2)
                    A[i, j] = A[i, j] * (-1)
                end
            end
        end

        v1 = Vector{Int32}() # promjenljive koje imaju znak = 
        v2 = Vector{Int32}() # promjenljive koje imaju znak <=
        v3 = Vector{Int32}() # elementi u bazi
        v4 = Vector{Int32}() # vjestacke promjenljive
        v5 = 0 # help1 variable
        v6 = 1 # help2 variable
        M = Vector{Float64}() # big M

        for i in 1: columns
            if (vsigns[i] == 0)

                push!(v1, columns + 1 + size(v1,1))
                push!(c, c[i] * (-1))

                k1 = Vector{Float64}()

                for j in 1: rows
                    push!(k1, A[j,i] * (-1))
                end

                A = hcat(A, k1)

            elseif (vsigns[i] == -1)
                for j in 1: rows
                    A[j,i] = A[j,i] * (-1)
                    push!(v2, i)
                end
            end
        end

        simplex_table = hcat(b, A)
        x1 = Vector{Int32}() # vektor koji sadrži optimalne vrijednosti izravnavajućih promjenljivih
        
        for i in 1:size(csigns, 1)
            coefficient = csigns[i]
            if (csigns[i] == 0)
                v5 += 1 # vjestacka
                push!(v3, columns + v6 )
                push!(v4, columns + v6 )
                push!(x1, columns + v6 )
                v6 += 1
            elseif (csigns[i] == -1)
                v5 += 1 # dopunska
                push!(v3, columns + v6) 
                push!(x1, columns + v6)
                v6 += 1
            elseif (csigns[i] == 1)
                v5 += 2 # dopunska i vjestacka
                push!(v3, columns + v6 + 1) 
                push!(v4, columns + v6 + 1)
                push!(x1, columns + v6 + 1)
                v6 += 2
            end
        end

        matrix = zeros(rows, v5) # formiranje matrice za dopunske i vjestacke promjenljive
        j = 1
        for i in 1: rows
            if (csigns[i] == 1)
                matrix[i, j] = -1 # dopunska
                matrix[i, j + 1] = 1 # vjestacka 
                j += 2
            elseif (csigns[i] == -1 || csigns[i] == 0)
                matrix[i, j] = 1 # vjestacka 
                j += 1
            end 
        end
        
        simplex_table = hcat(simplex_table, matrix) # merge

        for i in 1: columns + 1
            M1 = 0
            for j in 1: rows
                if(csigns[j] != -1)
                    M1 += simplex_table[j,i]
                end
            end
            push!(M, M1)
        end
    
        for i in (columns + 2) : size(v1, 1) + v5 + columns + 1
            counter = 0 # sluzi nam za provjeravanje da li je element -1
            for j in 1 : rows
                if (simplex_table[j,i] == -1)
                    counter = 1
                end
            end
            if (counter == 0)
                push!(M, 0)
            elseif (counter == 1)
                push!(M, -1)
            end
        end

        M = hcat(M) 
        M = transpose(M)
        simplex_table = vcat(simplex_table, M)
        
        push!(v3,0) 
        simplex_table = hcat(v3, simplex_table) # dodajemo elemente iz baze u tabelu 

    for i in 1 : v5 
        push!(c,0)
    end

    c = hcat(c)
    c = transpose(c)

    Z = Vector{Float64}() # Z red
    push!(Z, 0)
    push!(Z, 0)

    Z = hcat(Z) 
    Z = transpose(Z)

    Z = hcat(Z, c)

    if (goal == "min")
        Z = Z .* (-1)
    end   
    simplex_table = vcat(simplex_table, Z) # final table

    pomocna = true

    while (true)
        writedlm(stdout, simplex_table)
        max_el1 = 0
        max_el2 = 0
        max_column = 3 
        for i in 3 : columns + v5 + 2
            if (simplex_table[rows + 1, i] == max_el1)
                if (simplex_table[rows + 2, i] > max_el2)
                    max_el1 = simplex_table[rows + 1, i]
                    max_el2 = simplex_table[rows + 2, i]
                    max_column = i
                end
            elseif (simplex_table[rows+ 1, i] > max_el1)
                max_el1 = simplex_table[rows + 1, i]
                max_el2 = simplex_table[rows+ 2, i]
                max_column = i
            end
        end


        if (size(v4,1) != 0)
            for i in 1 : rows
                for j in 1 : size(v4, 1) - 1
                    if (simplex_table[i,1] == v4[j])
                        if (max_el1 == 0)
                            pomocna = false
                            for k in 3 : columns + v5 + 2
                                if (simplex_table[rows + 2,i] > max_el1)
                                    max_el1 = simplex_table[rows + 2, k]
                                    max_column = k
                                end
                            end 
                        end      
                    end
                end
            end
        end

        if (max_el1 == 0 && max_el2 == 0)
            for i in 1 : rows # rjesenje ne postoji
                for j in 1 : size(v4, 1)
                    if (simplex_table[i,1] == v4[j])
                        print("Cannot find solution")
                        return 0
                    end
                end
            end
        end

        rjesenje_degenerirano = false
        for i in 1 : rows # degenerirano rjesenje 
            if (simplex_table[i,2] == 0)
                rjesenje_degenerirano = true
                print("Degenerate solution")
            end
        end

        # nejedinstveno rjesenje 
        rjesenje_jedinstveno = true
        for i in 3 : size(simplex_table, 2)
            var_b = false
            var_v = false
            for j in 1 : rows
                if(simplex_table[j, 1] == i - 2)
                    var_b = true
                    break
                end
            end
            if (var_b == false && simplex_table[rows + 2, i] == 0)
                for k in 1 : size(v4, 1) 
                    if (v4[k] == i - 2)
                        var_v = true
                        break
                    end
                end
                if (var_v == false)
                    rjesenje_jedinstveno = false
                    print("Nadjeno rjesenje nije jedinstveno\n")
                    break
                end
            end
        end

        if (rjesenje_jedinstveno == true)
            println("Nadjeno rjesenje je jedinstveno\n")
        end

        status_rjesenja = 0
        if (rjesenje_degenerirano == false && rjesenje_jedinstveno == true) 
            status_rjesenja = 0
        elseif (rjesenje_degenerirano == true && rjesenje_jedinstveno == true)
            status_rjesenja = 1
        elseif (rjesenje_jedinstveno == false) 
            status_rjesenja = 2
        end

        if (size(v2,1) > 0)
            for i in 1 : size(v2, 1)
                for j in 1 : rows
                    if (simplex_table[j,1] == v2[j])
                        simplex_table[j,2] = simplex_table[j,2] * (-1)
                        break
                    end
                 end
            end
        end

        output = Vector{Int32}()
        print("Rjesenja su: \n")
        if (size(v1,1) > 0)
            for i in 1 : size(v1, 1)
                var1 = 0
                var2 = 0
                for j in 1 : rows 
                    if (simplex_table[j,1] == v1[i] - columns)
                        var1 = simplex_table[j,2]
                        break
                    end
                    if (simplex_table[j,1] == v1[i])
                        var2 = simplex_table[j,2]
                        break
                    end
                end

                println("x%d je %f.\n", v1[i] - columns, var1 - var2)
                push!(output, var1)
                push!(output, var2)
            end
        end

        
        for i in 1 : rows
            check = false
            for j in 1 : size(output, 1)
                if (simplex_table[i,1] == output[j])
                    provjera = true
                end
            end
            if (check == false)
                println("x%d je %f. \n", simplex_table[i,1], simplex_table[i,2])
                push!(output, simplex_table[i,1])
            end
        end

        for i in 3 : size(simplex_table,1)
            check = false
            for j in 1 : size(output, 1)
                if (i - 2 == output[j])
                    check = true
                end
            end
            if (check == false)
                println("x%f je 0 \n", i - 2)
                push!(output, i - 2)
            end
        end

        s1 = Vector{Float64}()
        sd1 = Vector{Float64}()
        for i in 3: size(simplex_table, 2)
            check = false
            for j in 1: rows
                if (simplex_table[j, 1] == i - 2)
                    for k in 1: size(x1, 1)
                        if (i - 2 == x1[k])
                            check = true
                            push!(sd1, simplex_table[j, 2])
                        end
                    end
                    if (check == false)
                        check= true
                        push!(s1, simplex_table[j, 2])
                    end
                end
            end
            if (check == false)
                for l in 1: size(x1, 1)
                    if (i - 2 == x1[l])
                        check == true
                        push!(sd1, 0)
                    end
                end
                if (check == false)
                    check = true
                    push!(s1, 0)
                end
            end
        end

        y = Vector{Float64}()
        for i in 1: size(csigns, 1)
            if (csigns[i] == -1 && goal == "max" || csigns[i] == 1 && goal == "min")
                push!(y, simplex_table[rows + 2, columns + i + 2] * (-1))
            elseif (csigns[i] == 1 && goal == "max" || csigns[i] == -1 && goal == "min")
                push!(y, simplex_table[rows + 2, columns + i + 2])
            else
                if (goal == "min")
                    push!(y, simplex_table[rows + 2, columns + i + 2] + simplex_table[rows + 1, columns + i + 2])
                elseif (goal == "max")
                    push!(y, simplex_table[rows + 2, columns + i + 2] * (-1) + simplex_table[rows + 1, columns + i + 2])
                end
            end
        end

        yd = Vector{Float64}()
        for j in 3: size(vsigns, 1) + 2
            push!(yd, simplex_table[rows + 2, j]*(-1))
        end

        print(yd)
        writedlm(stdout, simplex_table)

        rezultat = simplex_table[rows + 2, 2]

        if (goal == "max")
            rezultat= rezultat * (-1)
        end

        println("Konacna vrijednost funkcije cilja Z = ")
        println(rezultat)

        println("Bazne promjenljive optimalnog rjesenja su B = (")

        for i in 1 : rows
            println("x%d ", simplex_table[i,1])
        end

        println(")\n")

        return rezultat, s1, sd1, y, yd, status_rjesenja
    end

    # traženje pivota
    min = 1
    for i in 1 : rows
        # najmanji kolicnik min
        if (simplex_table[i, max_column] > 0)
            min = i
            break
        end
    end

    provjera1 = 0 # positive pivot check
    for i in 1 : rows
        if (simplex_table[i, max_column] > 0)
            provjera = 1
            if (simplex_table[i, 2] / simplex_table[i, max_column] < simplex_table[min, 2] / simplex_table[min, max_column])
                min = i
            end
        end
    end

    if (provjera1 == 0)
        print("Ima beskonačno mnogo rješenja.\n")
        println(max_column)
        return 0
    end
    pivot = simplex_table[min, max_column]

    for i in 2 : columns+ v5 + 2
        simplex_table[min,i] = simplex_table[min,i] * (1/pivot) # 1 na mjestu pivota
    end

    for i in 1 : rows + 2
        if (i != min)
            if (pomocna == false && i == rows + 1)
                i = i + 1
                continue
            end
            for j in 2 : columns + v5 + 2
                simplex_table[i,j] = simplex_table[min,j] * simplex_table[i, max_column] * (-1) + simplex_table[i,j]
                if((simplex_table[i,j] > 0 && simplex_table[i,j] < 0.0000000001) || (simplex_table[i,j] > -0.00000001 && simplex_table[i,j] < 0)) # osjetljivost na veoma male decimale
                    simplex_table[i,j] = 0
            end
        end
    end
    println("Pivot element je: ", pivot)
    println("Element koji ulazi u bazu je x", max_column-2)
    println("Element koji izlazi iz baze je x", simplex_table[min,1])
    simplex_table[min,1] = max_column - 2 # ubacivanje u bazu
    end
end

println("-------------------------------------------------------------------------")

#test1
#Z=3000;  X=(60 20) Xd(90 0 60 100 0 40); Y(0 30 0 0 10 0) Yd(0 0) status(0)
goal="max";
c=[40; 30];
A=[3 1.5;1 1;2 1;3 4;1 0;0 1];
b=[300; 80; 200; 360; 60; 60] 
csigns=[-1; -1; -1; -1; -1; -1] 
vsigns=[1;  1] 
Z,X,Xd,Y,Yd,status
general_simplex(goal,c,A,b,csigns,vsigns)

#test2
#Z=12;  X=(12 0) Xd(14 4 0); Y(0 0 1) Yd(0 0.5); status(0)
goal="min";
c=[1; 1.5];
A=[2 1; 1 1; 1 1];
b=[10; 8; 12] 
csigns=[1; 1; 1] 
vsigns=[1;  1] 
Z,X,Xd,Y,Yd,status
general_simplex(goal,c,A,b,csigns,vsigns)