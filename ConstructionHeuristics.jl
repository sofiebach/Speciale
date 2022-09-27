using Random

include("ReadWrite.jl")
include("ValidateSolution.jl")
include("PlotSolution.jl")

# Struct for holding the instance
mutable struct HeuristicSol
    obj::Float64
    num_campaigns::Int64
    x::Array{Int64,2}
    f::Array{Int64,2}
    k::Array{Int64,1}
    P::Int64
    T::Int64
    M::Int64
    I_cap::Array{Float64,2}
    H_cap::Array{Float64,2}
    HeuristicSol(data) = new(0.0, 0, zeros(Int64,data.T,data.P), zeros(Int64,data.T,data.M), zeros(Int64,data.P), data.P, data.T, data.M, deepcopy(data.I), deepcopy(data.H))
end

function randomInitial(data)
    P_bar = [1, 8]
    sol = HeuristicSol(data)
    
    # Randomly insert priorities from P_bar
    for p_bar in P_bar 
        for s = 1:data.S[p_bar]
            inserted = false
            r_times = shuffle(collect(data.start:data.stop))
            for t in r_times
                if fits(data, sol, t, p_bar)
                    insert(data, sol, t, p_bar)
                    inserted = true
                    break
                end
            end
        end
    end

    # Compute list of priorities to choose from
    choose_from = []
    for p = 1:data.P 
        if p in P_bar
            continue
        end
        append!(choose_from, repeat([p], Int(data.S[p])))
    end
    shuffle!(choose_from)
    
    # Randomly insert priorities from list
    for p in choose_from
        inserted = false
        n_tries = 3
        for n = 1:n_tries
            t = rand(data.start:data.stop)
            if fits(data, sol, t, p)
                insert(data, sol, t, p)
                inserted = true
                break
            end
        end
        if !inserted
            sol.k[p] += 1
        end
    end

    return sol
end

function insert(data, sol, t, p)
    sol.x[t,p] += 1

    # update inventory
    l_idx = 1
    for t_hat = (t+data.L_lower):(t+data.L_upper)
        for c = 1:data.C
            sol.I_cap[t_hat, c] -= data.u[l_idx,p,c]
        end
        l_idx += 1
    end

    # update production
    for t_hat = (t+data.Q_lower):(t+data.Q_upper) 
        for m = 1:data.M
            sol.H_cap[t_hat, m] -= data.w[p, m]
            if sol.H_cap[t_hat, m] < 0
                sol.f[t_hat, m] = Int(ceil(-sol.H_cap[t_hat, m])) 
            end
        end
    end

    findObjective(data, sol)
    sol.num_campaigns += 1
end


function fits(data, sol, t, p)
    if t < data.start || t > data.stop
        println("Select t between start and stop.")
        return false
    end

    l_idx = 1
    for t_hat = (t+data.L_lower):(t+data.L_upper)
        for c = 1:data.C
            grp = data.u[l_idx,p,c]
            if sol.I_cap[t_hat, c] - grp < 0
                return false
            end
        end
        l_idx += 1
    end

    for t_hat = (t+data.Q_lower):(t+data.Q_upper) 
        for m = 1:data.M
            if sol.H_cap[t_hat, m] - data.w[p, m] < 0
                freelancers_needed = Int(ceil(-(sol.H_cap[t_hat, m] - data.w[p, m])))
                if sum(sol.f[:,m]) + freelancers_needed > data.F[m] 
                    return false
                end
            end
        end
    end    
    
    return true
end

function findObjective(data, sol)
    num_campaigns = sum(sol.x)
    scope = sum(data.penalty_S .* sol.k)
    freelance = sum(sum(sol.f, dims=1) .* data.penalty_f)
    minmax = sum(maximum(sol.x, dims=1) - minimum(sol.x, dims=1))

    sol.obj = num_campaigns - scope - freelance - minmax
end


#P = 37
#data = read_DR_data(P)
#
#sol = randomInitial(data)
#
#checkSolution(data, sol)
#
#drawSolution(data,sol,"random_initial")
#
#inventory_used = (data.I - sol.I_cap) ./ data.I
#heatmapInventory(inventory_used, data, "random_initial")
#
#staff_used = (data.H - sol.H_cap) ./ (data.H + sol.f)
#heatmapStaff(staff_used, data, "random_initial")


