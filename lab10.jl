function rasporedi(M)

    original = deepcopy(M) # Zbog kasnijeg rezultata
    M = float(M)  # Zbog inf

    
    # Korak 1 : Redukcija po redovima
    for i in 1:size(M, 1)
        M[i, :] .-= minimum(M[i, :])
    end

    # Korak 2 : Redukcija po kolonama
    for j in 1:size(M, 2)
        M[:, j] .-= minimum(M[:, j])
    end

    raspored = zeros(Int, size(M))

    while any(M .== 0)
        # Korak 3 i 4: Jedinstvene nule u redovima
        for i in 1:size(M, 1)
            row_zeros = findall(x -> x == 0, M[i, :])
            if length(row_zeros) == 1
                j = row_zeros[1]
                raspored[i, j] = 1  # Dodajemo nulu u rezultat
                M[:, j] .= Inf     
                M[i, :] .= Inf     # Elminacija tog reda i kolone
            end
        end

        # Korak 5: Jedinistvene nule u columns
        for j in 1:size(M, 2)
            col_zeros = findall(x -> x == 0, M[:, j])
            if length(col_zeros) == 1
                i = col_zeros[1]
                raspored[i, j] = 1  # Dodajemo nulu u rezultat
                M[:, j] .= Inf     
                M[i, :] .= Inf     # Eliminacija tog reda i kolone
            end
        end
    end

    # Ukupni trošak
    Z = sum(raspored .* original)

    return raspored, Z
end

M = [3 2 5 4; 6 4 7 8; 1 6 3 7]

raspored, rezultat = rasporedi(M);

M = [80 20 23; 31 40 12; 61 1 1]

raspored, rezultat = rasporedi(M)

M = [25 55 40 80; 75 40 60 95; 35 50 120 80; 15 30 55 65]

raspored, rezultat = rasporedi(M)