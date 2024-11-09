using LinearAlgebra

function initialize(c, A, b)

    # Create a starting matrix of zeros
    m,n = size(A)

    tableau = zeros(m+1, n+m+1)

    # Fill the matrix
    tableau[m+1, 2:n+1] = c'  # Fill the objective row
    tableau[1:m, 1] = b  # Fill the right-hand side column
    tableau[1:m, 2:n+1] = A  # Fill the coefficient matrix
    tableau[1:m, n+2:n+m+1] = I(m) # Fill the identity matrix
end

    function simplex(c, A, b)
        # Initialize table
        m, n = size(A)
        tableau = vcat(hcat(zeros(1,1),hcat(c', zeros(1, m))), hcat(b, A, I(m)))
    
        # Main loop
        while (true)
            # Find the pivot column (entering variable)
            pivot_col = findmax(tableau[1, 2:end])[2] + 1

            #Checking for unboundedness
            if all(tableau[2:end, pivot_col] .<= 0)
                error("Unbounded!")
            end

            # Check for optimality
            if all(tableau[1, 2:end] .<= 0)
                break
            end
    
            # Find the pivot row (leaving variable)
            ratios = tableau[2:end, 1] ./ tableau[2:end, pivot_col]
            ratios[tableau[2:end, pivot_col] .<= 0] .= Inf
            pivot_row = findmin(ratios)[2] + 1
    
            # Pivot operation
            pivot_element = tableau[pivot_row, pivot_col]
            tableau[pivot_row, :] ./= pivot_element
            for i in 1:size(tableau, 1)
                if i != pivot_row
                    tableau[i, :] .-= tableau[i, pivot_col] * tableau[pivot_row, :]
                end
            end
        end
    
        # Extract the optimal solution
        x = tableau[2:end, 1]
        z = -tableau[1, 1]
        return x, z
    end
    

    
   c = [1; 2]
   A = [-2 1
       0 1
       ]
   b = [1; 3]
   c = [3; 1]
   A = [0.5 0.3
        0.1 0.2]
   b=[150; 60]
   result = simplex(c, A, b)
