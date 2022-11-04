include("BasicFunctions.jl")

# Struct for holding the instance
mutable struct HeuristicSol
    obj::Float64
    num_campaigns::Int64
    x::Array{Int64,2}
    f::Array{Float64,2}
    k::Array{Int64,1}
    P::Int64
    T::Int64
    M::Int64
    I_cap::Array{Float64,2}
    H_cap::Array{Float64,2}
    HeuristicSol(data) = new(0.0, 0, zeros(Int64,data.T,data.P), zeros(Float64,data.T,data.M), deepcopy(data.S), data.P, data.T, data.M, deepcopy(data.I), deepcopy(data.H))
end

function randomInitial(data)
    sol = HeuristicSol(data)
    
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

