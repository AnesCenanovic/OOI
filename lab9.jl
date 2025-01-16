function nadji_pocetno_SZU(C, I, O)
    m, n = length(I), length(O)
    A = zeros(m, n)  
    i, j = 1, 1      # počinjemo od krajnjeg lijevog ugla (SZU)

    
    while i <= m && j <= n
        allocation = min(I[i], O[j]) # tražimo najveću alokaciju iz skladišta u prodavnicu
        A[i, j] = allocation
        I[i] -= allocation
        O[j] -= allocation

        # kretanje na sljedeće polje tabele
        if I[i] == 0  # ponuda iscrpljena
            i += 1
        end
        if O[j] == 0  # Potražnja zadovoljena
            j += 1
        end
    end

    # totalna cijena
    T = sum(A .* C)
    return A, T
end

# Test Case 1, primjer 5.1
C1 = [8 9 4 6; 
      6 9 5 3; 
      5 6 7 4]  # Cost matrix
I1 = [100, 120, 140]  # Supply
O1 = [90, 125, 80, 65]  # Demand

A1, T1 = nadji_pocetno_SZU(C1, I1, O1)

# Test Case 2
C2 = [4 8 7; 
      2 6 5; 
      3 8 4]  # Cost matrix
I2 = [15, 25, 35]  # Supply
O2 = [20, 30, 25]  # Demand

A2, T2 = nadji_pocetno_SZU(C2, I2, O2)

# Test Case 3
C3 = [3 9 5 2; 
      4 7 3 6; 
      6 8 4 7]  # Cost matrix
I3 = [50, 60, 40]  # Supply
O3 = [30, 40, 50, 30]  # Demand

A3, T3 = nadji_pocetno_SZU(C3, I3, O3)
