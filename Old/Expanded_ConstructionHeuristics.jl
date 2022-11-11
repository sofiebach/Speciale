include("BasicFunctions.jl")
include("../Structures.jl")

function randomInitial(data)
    sol = ExpandedSol(data)
    
    # Randomly insert priorities from P_bar
    randomInsert!(data, sol, data.P_bar)

    # Randomly insert according to penalty
    sorted_idx = sortperm(-data.penalty_S)
    randomInsert!(data, sol, sorted_idx)

    # Check if anything "out of scope" can be inserted
    for t = data.start:data.stop
        sorted_idx = sortperm(-data.penalty_S)
        for p in sorted_idx
            if fits(data,sol,t,p) 
                insert!(data,sol,t,p)
            end
        end
    end
    
    return sol
end
