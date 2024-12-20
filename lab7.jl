

function cpm(A, P, T)

    number = size(A,1) # broj aktivnosti
    start = zeros(1, number + 1) # pohrana najranijeg mogućeg vremena početka

    for i = 1:number
        predecessor = P[i]
        if predecessor == "-"
            start[1, i] = 0
        elseif length(predecessor) == 1
            start[1, i] = start[1, Int(only(predecessor)) - 64] + T[Int(only(predecessor)) - 64]
        else
            predecessors = split(predecessor, ",")
            max = 0
            for j = 1:length(predecessors)
                if start[1, Int(only(predecessors[j])) - 64] + T[i] > max
                    max = start[Int(only(predecessors[j])) - 64] + T[Int(only(predecessors[j])) - 64]
                end
            end
            start[1, i] = max
        end
    end


    max = 0;
    last = "";
    for i = 1:number
        if start[1, Int(only(A[i])) - 64] + T[i] > max
            max = start[1, Int(only(A[i])) - 64] + T[i];
            last = A[i];
        end
    end

    start[size(start, 1)] = max;
    Z = max;
    total = max - T[Int(only(last)) - 64];
    path = [last];
    current = last;

    while true
        i = Int(only(current)) - 64
        predecessor = P[i];
        if predecessor == "-"
            break
        elseif (length(predecessor) == 1)
            total -= T[i];
            current = predecessor;
            path = [current "-" path];
        else
            predecessors = split(predecessor, ",");
            for j = 1:size(predecessors, 1)
                if start[1, Int(only(predecessors[j])) - 64] + T[Int(only(predecessors[j])) - 64] == total
                    total -= T[Int(only(predecessors[j])) - 64];
                    current = predecessors[j];
                    path = [current "-" path];
                    break
                end
            end
        end
    end
    return Z, path;
end

#Z = 12 put = "C – D – G – I"
display("Test 1:")
A = ["A", "B", "C", "D", "E", "F", "G", "H", "I"]
P = ["-", "-", "-", "C", "A", "A", "B,D", "E", "F,G"]
T = [3, 3, 2, 2, 4, 1, 4, 1, 4]
Z, put = CPM(A, P, T)
display(Z)
display(put)

#Z = 11 put = "B - E - G"
display("Test 2:")
A = ["A", "B", "C", "D", "E", "F", "G", "H", "I"]
P = ["-", "-", "-", "A", "A,B", "C", "D,E,F", "C", "H"]
T = [2,5,4,4,2,2,4,1,2]
Z, put = CPM(A, P, T);
display(Z)
display(put)

#Z = 121 put = "A - B - C - G"
display("Test 3:")
A = ["A", "B", "C", "D", "E", "F", "G"]
P = ["-", "A", "B", "A", "D", "E", "C,F"]
T = [25, 30, 60, 1, 50, 4, 6]
Z, put = CPM(A, P, T);
display(Z)
display(put)

