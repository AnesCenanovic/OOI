using Pkg
Pkg.add("JuMP")
Pkg.add("GLPK")
using JuMP, GLPK

function max_flow(C)
    n = size(C, 1)  # Broj čvorova
    source = 1      # Source čvor
    sink = n        # Sink čvor


    model = Model(GLPK.Optimizer)
    @variable(model, x[1:n, 1:n] >= 0, Int) # model sa ograničenjima


    for i in 1:n, j in 1:n
        @constraint(model, x[i, j] <= C[i, j]) # ograničenje na max protox
    end

    # funckija cilja
    @objective(model, Max, sum(x[i, sink] for i in 1:n))

    
    for k in 2:(n-1)
        @constraint(model, sum(x[i, k] for i in 1:n) == sum(x[k, j] for j in 1:n)) # ograničenje na izlaz i ulaz u čvor
    end

    optimize!(model)
    X = value.(x)
    V = objective_value(model)

    return X, V
end

# Test 3, rj. V = 23
C = [
    0 16 13  0  0  0;
    0  0 10 12  0  0;
    0  4  0  0 14  0;
    0  0  9  0  0 20;
    0  0  0  7  0  4;
    0  0  0  0  0  0
]

# Test 2, rj. V = 15
C = [
    0 10  5  0  0;
    0  0 15 10  0;
    0  0  0  0 10;
    0  0  0  0 15;
    0  0  0  0  0
]

# Test 1 iz postavke, rj. V = 5
C = [
    0 3 0 3 0 0 0 0;
    0 0 4 0 0 0 0 0;
    0 0 0 1 2 0 0 0;
    0 0 0 0 2 6 0 0;
    0 1 0 0 0 0 0 1;
    0 0 0 0 2 0 9 0;
    0 0 0 0 3 0 0 5;
    0 0 0 0 0 0 0 0;
]

X, V = max_flow(C)
X

println("X = ")
println(X)
println("V = ", V)