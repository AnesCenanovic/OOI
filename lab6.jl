function najkraci_put(M)
    n = size(M, 1)
    dist = fill(Inf, n)
    prev = fill(1, n)
    dist[1] = 0  # Prvi čvor je početni, stoga je udaljenost do njega 0

    for u in 1:n
        for v in 1:n
            if M[u, v] != 0 && dist[u] != Inf && dist[u] + M[u, v] < dist[v]
                dist[v] = dist[u] + M[u, v]
                prev[v] = u
            end
        end
    end

    putevi = hcat(collect(1:n), dist, prev)
    return putevi
end

M = [
    0 1 3 0 0 0;
    0 0 2 3 0 0;
    0 0 0 -4 9 0;
    0 0 0 0 1 2;
    0 0 0 0 0 2;
    0 0 0 0 0 0;
]

# Ima više rješenja za dolazak u drugi čvor

rezultat = najkraci_put(M)
println(rezultat)