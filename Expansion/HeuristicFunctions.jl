include("BasicFunctions.jl")
include("MIPModelSpreading.jl")

function randomDestroy!(data, sol, frac)
    n_destroy = round(sol.num_campaigns*frac)
    while n_destroy > 0 
        p = rand(1:data.P)
        if sum(sol.x[:,p]) == 0
            continue
        end
        r_times = findall(x -> x > 0, sol.x[:,p])

        t = r_times[rand(1:length(r_times))]
        remove!(data, sol, t, p)
        n_destroy -= 1
    end
end

function clusterDestroy!(data, sol, frac)
    t_destroy = Int(round((data.stop - data.start)*frac))
    rand_t = rand(data.start:(data.stop-t_destroy))
    for t = rand_t:(rand_t+t_destroy), p = 1:data.P
        while sol.x[t,p] > 0
            remove!(data,sol,t,p)
        end
    end   
end

function worstDestroy!(data, sol, thres)
    for t = data.start:data.stop, m = 1:data.M
        while sol.f[t,m] > thres
            t_hat = rand((t-data.Q_upper):(t-data.Q_lower))
            p_worst = findall(x -> x > 0, sol.x[t_hat,:].*data.w[:,m])
            if length(p_worst) > 0
                remove!(data,sol,t_hat,rand(p_worst))
            end
        end
    end
end

function relatedDestroy!(data, sol, frac)
    n_destroy = round(sol.num_campaigns*frac)
    sim = findSimilarity(data)
    tabu = []
    while n_destroy > 0
        idx = filter!(x -> x ∉ tabu, collect(1:data.P))
        max_k, p_idx = findmax(sol.k[idx])
        p = idx[p_idx]
        push!(tabu, p)
        p_related = sortperm(-sim[p,:])
        for p_r in p_related 
            if sim[p,p_r] > 0 && sum(sol.x[:,p_r]) > 0
                n_remove = ceil(sum(sol.x[:,p_r]) / 2)
                while n_remove > 0
                    r_times = findall(x -> x > 0, sol.x[:,p_r])
                    t = r_times[rand(1:length(r_times))]
                    remove!(data, sol, t, p_r)
                    n_remove -= 1
                    n_destroy -= 1
                end
                break
            end
        end
    end
end

function modelRepair!(data, sol)
    MIPdata = deepcopy(data)
    MIPdata.I = deepcopy(sol.I_cap)
    MIPdata.H = deepcopy(sol.H_cap)
    MIPdata.H[MIPdata.H .< 0.0] .= 0.0
    MIPdata.F = deepcopy(data.F - transpose(sum(sol.f, dims=1))[:,1])
    MIPdata.S = deepcopy(sol.k)
    
    MIPsol = MIPExpansion(MIPdata, 0, 2, 0)
    if MIPsol == 0
        return
    else
        for p = 1:data.P, t = 1:data.T 
            for n = 1:MIPsol.x[t,p]
                insert!(data, sol, t, p)
            end
        end
    end
end 

function firstRepair!(data, sol)
    for p_bar in data.P_bar, n = 1:sol.k[p_bar]
        t, p = firstInsertion(data, sol, [p_bar])
        if t != 0 && p != 0
            insert!(data, sol, t, p)
            #println("Inserted ", p, " at time ", t)
        end
    end

    shuffled_idx = shuffle(1:data.P)
    while true
        #println("Vi er i while")
        t, p = firstInsertion(data, sol, shuffled_idx)
        if t != 0 && p != 0
            insert!(data, sol, t, p)
            #println("Inserted ", p, " at time ", t)
        else
            break
        end
    end
end

function greedyRepair!(data, sol)
    for p_bar in data.P_bar, n = 1:sol.k[p_bar]
        t, p = bestInsertion(data, sol, [p_bar])
        if t != 0 && p != 0
            insert!(data, sol, t, p)
        end
    end

    sorted_idx = sortperm(-data.penalty_S)
    while true
        t, p = bestInsertion(data, sol, sorted_idx)
        if t != 0 && p != 0
            insert!(data, sol, t, p)
        else
            break
        end
    end
end

function regretRepair!(data, sol)
    for p_bar in data.P_bar, n = 1:sol.k[p_bar]
        t, p = regretInsertion(data, sol, [p_bar])
        if t != 0 && p != 0
            insert!(data, sol, t, p)
        end
    end

    shuffled_idx = shuffle(1:data.P)
    while true
        t, p = regretInsertion(data, sol, shuffled_idx)
        if t != 0 && p != 0
            insert!(data, sol, t, p)
        else
            break
        end
    end
end

function bestInsertion(data, sol, sorted_idx)
    best_obj = sol.obj
    best_p = 0
    best_t = 0
    
    for p in sorted_idx 
        for t = data.start:data.stop
            if fits(data, sol, t, p) 
                new_obj = delta_insert(data, sol, t, p)
                if new_obj < best_obj
                    best_obj = new_obj
                    best_p = p 
                    best_t = t 
                end
            end
        end
    end
    return best_t, best_p
end

function firstInsertion(data, sol, shuffled_idx)
    best_obj = sol.obj
    best_p = 0
    best_t = 0
    
    for t = data.start:data.stop
        for p in shuffled_idx
            if fits(data, sol, t, p) 
                new_obj = delta_insert(data, sol, t, p)
                if new_obj < best_obj
                    best_obj = new_obj
                    best_p = p 
                    best_t = t
                    break
                end 
            end
        end
    end
    return best_t, best_p
end

function regretInsertion(data, sol, priorities)
    obj_best = ones(Float64, data.P)*Inf
    obj_second = ones(Float64, data.P)*Inf
    t_best = zeros(Int64, data.P)
    
    idx = 1
    for p in priorities
        for t = data.start:data.stop
            if fits(data, sol, t, p) 
                new_obj = delta_insert(data, sol, t, p)
                if new_obj < obj_best[idx] && new_obj < sol.obj
                    obj_second[idx] = obj_best[idx]
                    obj_best[idx] = new_obj
                    t_best[idx] = t 
                elseif new_obj < obj_second[idx]
                    obj_second[idx] = new_obj
                end
            end
        end
        idx += 1
    end
    loss = obj_second - obj_best
    replace!(loss, NaN=>-1)
    loss, idx = findmax(loss)
    best_p = priorities[idx]
    if loss >= 0
        best_t = t_best[idx]
    else 
        best_p = 0
        best_t = 0
    end
    return best_t, best_p
end

function swap!(data, sol, t1, p1, t2, p2)
    remove!(data, sol, t1, p1)
    remove!(data, sol, t2, p2)
    insert!(data, sol, t2, p1)
    insert!(data, sol, t1, p2)
end

function diversify!(data, sol)
    max_swaps = 5
    num_swaps = 0
    
    while num_swaps < max_swaps
        r1 = rand(data.start:data.stop)
        r2 = rand(data.start:data.stop)
        p1 = rand(1:data.P)
        p2 = rand(1:data.P)
        t1 = min(r1, r2)
        t2 = max(r1, r2)
        # check if swap if valid
        if (checkSwap(data, sol, t1, p1, t2, p2) && p1 != p2 && t1 != t2)
            swap!(data, sol, t1, p1, t2, p2)
            num_swaps += 1
        end
    end
end

function greedyInsert!(data, sol)
    # loops through all timesteps and checks if it is possible to insert another priority
    for t = data.start:data.stop
        sorted_idx = sortperm(-data.penalty_S)
        for p in sorted_idx
            if sol.k[p] > 0
                if fits(data,sol,t,p) 
                    insert!(data,sol,t,p)
                end
            end
        end
    end
end