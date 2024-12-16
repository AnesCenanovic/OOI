using Pkg
Pkg.add("LightGraphs")
using LightGraphs

function cpm(A,P,T)

    g=DiGraph(length(A))

        for(i,pred) in enumerate(P)
            for p in split(pred,", ")
                if p!="-"
                    add_edge!(g, findfirst(x -> x == p, A), i)
                end
            end
        end

    early_start = Dict(a => 0 for a in A)
    early_finish = Dict(a => 0 for a in A)
    late_finish = Dict(a => 0 for a in A)
    late_start = Dict(a => 0 for a in A)

    for a in g
        if length(inneighbors(g, a)) == 0
            early_start[a] = 0
        else
            early_start[a] = maximum(early_finish[p] for p in inneighbors(g, a))
        end
        early_finish[a] = early_start[a] + T[a]
    end

    late_finish[last(g)] = early_finish[last(g)]
    for a in reverse(g)
        if length(outneighbors(g, a)) == 0
            late_start[a] = late_finish[a] - T[a]
        else
            late_start[a] = minimum(late_start[s] - T[s] for s in outneighbors(g, a))
        end
        late_finish[a] = late_start[a] + T[a]
    end

    # Identify the critical path
    critical_path = []
    current = last(g)
    while current != 0
        push!(critical_path, current)
        next_nodes = outneighbors(g, current)
        if length(next_nodes) == 0 || all(late_start[n] == early_start[n] for n in next_nodes)
            current = first(next_nodes)
        else
            current = argmin(late_start, next_nodes)
        end
    end

    return reverse(critical_path), late_finish[last(g)]
end

A = ["A", "B", "C", "D", "E", "F", "G", "H", "I"]
P = ["-", "-", "-", "C", "A", "A", "B, D", "E", "F, G"]
T = [3, 3, 2, 2, 4, 1, 4, 1, 4]

Z, put = cpm(A, P, T)
