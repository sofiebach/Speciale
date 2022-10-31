using Random

# Struct for holding the instance
mutable struct HeuristicSol
    obj::Float64
    num_campaigns::Int64
    x::Array{Int64,2}
    f::Array{Float64,2}
    k::Array{Int64,1}
    L::Array{Int64, 1}
    g::Array{Int64,2}
    P::Int64
    T::Int64
    M::Int64
    I_cap::Array{Float64,2}
    H_cap::Array{Float64,2}
    HeuristicSol(data) = new(0.0, 0, zeros(Int64,data.T,data.P), zeros(Float64,data.T,data.M), deepcopy(data.S), zeros(Int64, data.P), zeros(Int64, data.T, data.P), data.P, data.T, data.M, deepcopy(data.I), deepcopy(data.H))
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

function insert!(data, sol, t, p)
    sol.x[t,p] += 1
    sol.num_campaigns += 1

    # update inventory
    l_idx = 1
    for t_hat = (t+data.L_lower):(t+data.L_upper)
        for c = 1:data.C
            sol.I_cap[t_hat, c] -= data.u[l_idx,p,c]
        end
        l_idx += 1
    end

    # update production
    for m = 1:data.M
        for t_hat = (t+data.Q_lower):(t+data.Q_upper)
            sol.H_cap[t_hat, m] -= data.w[p, m]
            if sol.H_cap[t_hat, m] < 0
                sol.f[t_hat, m] = -sol.H_cap[t_hat, m]
            end
        end
    end

    # update scope
    if sol.k[p] > 0
        sol.k[p] -= 1
    end

    # update aimed
    if (sol.x[t,p] > data.aimed[p])
        sol.g[t,p] += 1
    else
        sol.g[t,p] = 0
    end

    sol.L[p] = findMinIdle(data,sol.x[:,p])

    findObjective!(data, sol)
end

function findMinIdle(data, xp)
    # If more priorities at same timestep
    if sum(xp.> 1) > 0 
        return 0
    end
    # If less than 2 priorities planned
    if sum(xp) < 2
        return 0
    end

    minT = Inf
    t1 = findfirst(x -> x==1, xp)
    for t2 = (t1+1):data.stop 
        if xp[t2] > 0
            if t2-t1 < minT
                minT = t2-t1
            end
            t1=t2
        end 
    end
    return minT
end
# np.diff(np.where(np.array(a)>0))-1

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

    for m = 1:data.M
        freelancers_needed = 0
        for t_hat = (t+data.Q_lower):(t+data.Q_upper) 
            if sol.H_cap[t_hat, m] - data.w[p, m] < 0
                freelancers_needed += -(sol.H_cap[t_hat, m] - data.w[p, m])
                if sum(sol.f[:,m]) + freelancers_needed > data.F[m] 
                    return false
                end
            end
        end
    end    
    
    return true
end

function findObjective!(data, sol)
    num_campaigns = sum(sum(sol.x, dims=1) .* transpose(data.reward))
    scope = sum(data.penalty_S .* sol.k)
    aimed_wrong = sum(sum(sol.g))
    idle_times = sum(sol.L)
    # freelance = sum(sum(sol.f, dims=1) .* data.penalty_f)
    sol.obj =  scope - num_campaigns + aimed_wrong - idle_times
end




