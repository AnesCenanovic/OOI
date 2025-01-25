using Pkg
Pkg.add("JuMP")
Pkg.add("GLPK")
using JuMP, GLPK


function transport(cost, supply, demand)
    
    suppliers, consumers = size(cost)
    
    m = Model(GLPK.Optimizer)
    
    # varijabla x[i,j] transport izmedu supply i & demand j
    @variable(m, x[1:suppliers, 1:consumers] >= 0)
    
    # Objektivna funckija : minimalni trošak transporta
    @objective(m, Min, sum(cost[i, j] * x[i, j] for i in 1:suppliers, j in 1:consumers))
    
    # ograničenje da individualni supplies ne mogu sumarno biti veći od total supply
    @constraint(m, [i=1:suppliers], sum(x[i, j] for j in 1:consumers) <= supply[i])
    
    # ograničenje da ukupna potrosnja mora biti jednaka demand
    @constraint(m, [j=1:consumers], sum(x[i, j] for i in 1:suppliers) == demand[j])
    
    optimize!(m)
    
    if termination_status(m) == MOI.OPTIMAL
        
        result = [value(x[i, j]) for i in 1:suppliers, j in 1:consumers]
        total_cost = objective_value(m)
        return result, total_cost
    else
        error("The optimization problem could not be solved to optimality.")
    end
end

# Primjer iz postavke
cost = [3 2 10; 5 8 12; 4 10 5; 7 15 10]
supply = [20; 50; 60; 10]
demand = [20; 40; 30]

result, total_cost = transport(cost, supply, demand)

# Test case 1
cost = [7  10  5  7;
6   8  6  4;
4   7  8  5]
supply = [95; 130; 135]
demand = [85; 120; 90; 65]

result, total_cost = transport(cost, supply, demand)
# Test case 2
cost = [13 17 16;
11 18 19;
15  6  5;
13  8  7;
20 14 11]
supply = [35; 50; 55; 40; 37]
demand = [65; 48; 54]

result, total_cost = transport(cost, supply, demand)
# Test case 3
cost = [ 4 11  6  3  4;  8  6  9  5 11;  6  9 16  8 13; 11 13 11  9  5;  8  2  2  7  6]
supply = [190; 210; 160; 195; 260]
demand = [95; 195; 390; 190; 105]
result, total_cost = transport(cost, supply, demand)

