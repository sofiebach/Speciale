include("BasicFunctions.jl")
include("MIPModel.jl")

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
    
    MIPsol = MIP(MIPdata, 0, 2, 0)

    for p = 1:data.P, t = 1:data.T 
        for n = 1:MIPsol.x[t,p]
            insert!(data, sol, t, p)
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
            #println("Inserted ", p, " at time ", t)
        end
    end

    sorted_idx = sortperm(-data.penalty_S)
    while true
        #println("Vi er i while")
        t, p = bestInsertion(data, sol, sorted_idx)
        if t != 0 && p != 0
            insert!(data, sol, t, p)
            #println("Inserted ", p, " at time ", t)
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
                new_obj = delta_insert(data, sol, p)
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
                new_obj = delta_insert(data, sol, p)
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
