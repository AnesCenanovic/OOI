using Pkg
Pkg.add("JuMP")
Pkg.add("GLPK")
using JuMP, GLPK
using DelimitedFiles

function general_simplex(goal, c, A, b, csigns, vsigns)

    #data validity

        if(goal !="max" || goal !="min" || A == nothing || b == nothing || c==nothing)
            println("Invalid arguments!")
            return 0
        end

        for i in 1:size(csigns, 1)
            if(csigns[i] != 1 || csigns[i] != -1 || csigns[i] != 0)
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

        rows = size(b, 1);
        if (rows != size(A, 1))
            println("Invalid row number!")
            return 0
        end

        columns = size(c, 1);
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

        for i in 1: kolone
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
        x1 = Vector{Int32}(); # vektor koji sadrži optimalne vrijednosti izravnavajućih promjenljivih
        
        for i in 1:size(csigns, 1)
            coefficient = csigns[i]
            if (csigns[i] == 0)
                v5 += 1 #dodaje se vjestacka
                push!(v3, columns + v6 )
                push!(v4, columns + v6 )
                push!(x1, columns + v6 )
                v6 += 1
            elseif (csigns[i] == -1)
                v5 += 1 #dodaje se dopunska
                push!(v3, columns + v6) 
                push!(x1, columns + v6)
                v6 += 1
            elseif (csigns[i] == 1)
                v5 += 2 #dodaje se i dopunska i vjestacka
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
        
        simplex_table = hcat(simplex_table, matrix); # merge

        
end
