using Pkg
Pkg.add("JuMP")
Pkg.add("GLPK")
using JuMP, GLPK


function general_simplex(goal, A, b, c, csigns, vsigns)

        #data validity

        if size(b, 1) != size(A, 1) || size(c, 2) != size(A, 2)
            throw("Dimenzije ulaznih parametara nisu validne")
        end
        
        
         # rješenje znakova = i <=
        vmap = []
        for i in 1:lastindex(vsigns)
            if vsigns[i] == -1
                A[:, i] *= -1
                c[i] *= -1
            elseif vsigns[i] == 0
                c = [c -c[i]]
                A = [A -A[:, i]]
                push!(vmap, (i, size(A, 2)))
            end
        end

        A1 = A
        b1 = b
        c1 = c
        rows = size(A,1)
        base = zeros(rows,1)
        M = zeros(1, size(c,2))
        M1 = 0
        vjestacke_var = []
        
   
        for i in 1:rows
        # negative b  
            if b1[i] < 0
                A1[i, :] = -A1[i, :]
                b1[i] = -b1[i]
                csigns[i] = -csigns[i]
            end

        # slack variables
             if csigns[i] == -1
                new_col = zeros(rows, 1)
                new_col[i] = 1
                A1 = [A1 new_col]
                M = [M 0]
                c1 = [c1 0]
                base[i] = size(c1, 2)

            elseif csigns[i] == 1
                new_col = zeros(rows, 1)
                new_col[i] = -1
                A1 = [A1 new_col]
                M = [M 0]
                c1 = [c1 0]
            end
        end

        # artificial variables
        for i in 1:rows
            if csigns[i] == 1
                new_col = zeros(rows, 1)
                new_col[i] = 1
                A1 = [A1 new_col]
                M = [M -1]
                c1 = [c1 0]
                base[i] = size(c1, 2)
                M[:] .= M[:] .+ A1[i, :]
                M1 = M1 .+ b1[i]
                vjestacke_var = [vjestacke_var; size(c1, 2)]
            elseif csigns[i] == 0
                new_col = zeros(rows, 1)
                new_col[i] = 1
                A1 = [A1 new_col]
                M = [M -1]
                c1 = [c1 0]
                base[i] = size(c1, 2)
                M[:] .= M[:] .+ A1[i, :]
                M1 = M1 .+ b1[i]
                vjestacke_var = [vjestacke_var; size(c1, 2)]
            end
        end

        c1 = [0 c1]
        M = [M1 M]

        #konacna tabela spremna za iteriranje

        ST = [b1 A1]
        ST = [ST; M; c1]

        # min/max
        if goal == "min"
            ST[end, :] *= -1
        else
            ST[end-1, 1] = abs(ST[end-1, 1])
        end

        # finding maximum

            row_M = deepcopy(ST[end-1, :])
            popfirst!(row_M)
            (cMax_M, col_index_M) = findmax(row_M) # max u C i M redu
            col_index_M += 1

            col_index = 0
            second_last_row = ST[end-1, :]
            last_row = ST[end, :]
            cMax = -Inf

            for i in 2:lastindex(last_row)
                if last_row[i] > cMax && (second_last_row[i] >= 0 || second_last_row[i] == -0)
                cMax = last_row[i]
                col_index = i
                end
            end

        while cMax > 0 || cMax_M > 0 # iteracije tabele

                if cMax_M > 0
                    pivot_col = col_index_M
                else
                    pivot_col = col_index
                end
        
                    tMax = Inf # temp
                    pivot_row = -1 

                for i in 1:size(ST, 1)-2
                    if ST[i, pivot_col] > 0
                        t_temp = ST[i, 1] / ST[i, pivot_col]
                        if (t_temp < tMax || (t_temp == tMax && rand() > 0.5)) #random izbor zbog degeneracije
                            tMax = t_temp
                            pivot_row = i #odabir pivot elementa
                        end
                    end
                end
                
                if tMax == Inf
                    throw("Rjesenje je neograniceno") # u slucaju neogranicenja
                end
                

                #prelazimo na sređivanje tabele

                    base[pivot_row] = pivot_col - 1
            
                    pivot_element = ST[pivot_row, pivot_col]
            
                    ST[pivot_row, :] ./= pivot_element
        
                for i in 1:size(ST, 1)
                    if i != pivot_row
                        factor = ST[i, pivot_col]
                        for j in 1:size(ST, 2)
                            ST[i, j] -= ST[pivot_row, j] * factor
                        end
                    end
                end
                
                    row_M = deepcopy(ST[end-1, :])
                    popfirst!(row_M)
                    (cMax_M, col_index_M) = findmax(row_M)
                    col_index_M += 1
        
                if cMax_M <= 1e-9   #osjetljivost
                    cMax_M = 0
                end
        
                if cMax_M <= 0
                    nd_last_row = ST[end-1, :]
                    last_row = ST[end, :]
                    cMax = -Inf
                    for i in 2:lastindex(last_row)
                        if last_row[i] > cMax && (nd_last_row[i] >= 0 || nd_last_row[i] == -0)
                            cMax = last_row[i]
                            col_index = i
                        end
                    end
                end
        end

        # artificial variables left

        for i in 1:lastindex(vjestacke_var)
            if (Float64(vjestacke_var[i]) in base)
                throw("Ne postoji rješenje dopustive oblasti")
            end
        end

        x = zeros(1, size(b, 1) + size(c, 2))

        # basic variable values
        for i in 1:lastindex(base)
            x[Int(round(base[i]))] = ST[i, 1]
        end

        # Checking uniqueness
        is_unique = true
        for i in 2:(lastindex(ST[end, :])-lastindex(vjestacke_var))
            if x[i-1] == 0 && ST[end, i] == 0
                is_unique = false
            end
        end

        is_unique_str = is_unique ? "Rjesenje je jedinstveno" : "Rjesenje nije jedinstveno"

        # Adjusting final solution
        if !isempty(vmap)
            for i in 1:lastindex(vmap)
                first_element = findall(y -> y == vmap[i][1], x)
                second_element = findall(y -> y == vmap[i][2], x)
                    if !isempty(first_element) && !isempty(second_element)

                    elseif isempty(first_element) && !isempty(second_element)

                    x[vmap[i][1]] = -x[second_element]
                    deleteat!(x, second_element[1])

                    end
            end
        end

        # degeneracy check
            is_degenerate = false
            for i in 1:(lastindex(ST[:, 1])-2)
                if ST[i, 1] == 0
                    is_degenerate = true
                end
            end

        is_degenerate_str = is_degenerate ? "Rjesenje je degenerirano" : "Rjesenje nije degenerisano"

        # adjusting based on min/max
        Z = goal == "min" ? ST[end, 1] : -ST[end, 1]

    return Z, x, is_unique_str, is_degenerate_str

end


# primjeri 
b = [150, 60]
A = [[0.5 0.3]; [0.1 0.2]]
c = [3 1]
goal = "max"
constraint_signs = [-1, -1]
var_signs = [1, 1]
(solution, x) = general_simplex(goal, A, b, c, constraint_signs, var_signs)

goal = "max";
c = [4000 2000];
A = [3 3; 2 1; 1 0; 0 1];
b = [12000; 6000; 2500; 3000];
csigns = [-1; -1; -1; -1];
vsigns = [1; 1];
Z, X = general_simplex(goal, A, b, c, csigns, vsigns)

goal = "max";
c = [1 2];
A = [1 1; 3 3];
b = [2; 4];
csigns = [1; -1];
vsigns = [1; 1];
Z, X = general_simplex(goal, A, b, c, csigns, vsigns)

goal = "max";
c = [1 300 -0.3 -0.5];
A = [1 250 0 0; 1 150 0 -1; 1 400 0 -1; 1 200 -1 0];
b = [32; 56; 50; 60];
csigns = [-1; -1; -1; -1];
vsigns = [0; 1; 1; 1];
Z, X = general_simplex(goal, A, b, c, csigns, vsigns)

# glpk i jump testiranje

m=Model(GLPK.Optimizer)
@variable(m,x1>=0)
@variable(m,x2>=0)

@objective(m,Max,x1+x2)

@constraint(m, constraint1, -3x1+x2<=-1)
@constraint(m, constraint2, -x1+3x2>=5)

print(m)

optimize!(m)
termination_status(m)

println("Rješenja: ")
println("x1 = ", value(x1))
println("x2 = ", value(x2))
println("Vrijednost cilja: ")
println(objective_value(m))

general_simplex("max", [-3 1; -1 3], [-1; 5], [1 1], [-1; 1], [1; 1])
