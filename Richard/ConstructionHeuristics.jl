include("BasicFunctions.jl")
include("Structures.jl")

function randomInitial(data)
    sol = Sol(data)
    
    # Randomly insert priorities from P_bar
    randomInsert!(data, sol, data.P_bar)

    # Randomly insert according to penalty
    sorted_idx = sortperm(-data.penalty_S)
    randomInsert!(data, sol, sorted_idx)
    
    return sol
end

function randomInsert!(data, sol, priorities)
    for p in priorities
        r_times = shuffle(collect(data.start:data.stop))
        for n = 1:data.S[p], t in r_times
            if sol.k[p] == 0
                break
            end
            if fits(data, sol, t, p)
                insert!(data, sol, t, p)
            end
        end
    end
end