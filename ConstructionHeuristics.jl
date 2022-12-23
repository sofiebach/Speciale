include("BasicFunctions.jl")
include("Structures.jl")

function randomInitial(data)
    sol = Sol(data)
    
    # Randomly insert according to penalty
    priorities = sortperm(-data.penalty_S)
    randomInsert!(data, sol, priorities)
    
    return sol
end

function randomInsert!(data, sol, priorities)
    for p in priorities
        for n = 1:data.S[p]
            if sol.k[p] == 0
                break
            end
            inserted = false
            r_times = shuffle(collect(data.start:data.stop))
            for t in r_times
                if fits(data, sol, t, p)
                    insert!(data, sol, t, p)
                    inserted = true
                    break
                end
            end
            if !inserted
                break
            end
        end
    end
end