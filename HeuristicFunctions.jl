include("BasicFunctions.jl")

function randomDestroy!(data, sol, frac)
    n_destroy = ceil(sol.num_campaigns*frac)
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
    t_destroy = Int(ceil((data.stop - data.start)*frac))
    rand_t = rand(data.start:(data.stop-t_destroy))
    for t = rand_t:(rand_t+t_destroy), p = 1:data.P
        while sol.x[t,p] > 0
            remove!(data, sol, t, p)
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

function modelRepair!(data, sol, type)
    MIPdata = deepcopy(data)
    MIPdata.I = deepcopy(sol.I_cap)
    MIPdata.H = deepcopy(sol.H_cap)
    MIPdata.H[MIPdata.H .< 0.0] .= 0.0
    MIPdata.F = deepcopy(data.F - transpose(sum(sol.f, dims=1))[:,1])
    MIPdata.S = deepcopy(sol.k)

    sol_limit = 2
    if type == "expanded"
        time_limit = 10
        MIPx = MIPExpansion(MIPdata, "HiGHS", 0, time_limit, 0)
    elseif type == "baseline" 
        time_limit = 10
        MIPx = MIPBaseline(MIPdata, "HiGHS", 0, time_limit, 0)
    else
        println("Enter valid model type")
        return
    end

    if MIPx == 0
        return
    else
        for p = 1:data.P, t = 1:data.T 
            for n = 1:MIPx[t,p]
                insert!(data, sol, t, p)
            end
        end
    end
end 

function firstRepair!(data, sol, type)
    for p_bar in data.P_bar, n = 1:sol.k[p_bar]
        t, p = firstInsertion(data, sol, [p_bar], type)
        if t != 0 && p != 0
            insert!(data, sol, t, p)
        end
    end

    shuffled_idx = shuffle(1:data.P)
    while true
        #println("Vi er i while")
        t, p = firstInsertion(data, sol, shuffled_idx, type)
        if t != 0 && p != 0
            insert!(data, sol, t, p)
        else
            break
        end
    end
end

function greedyRepair!(data, sol, type)
    for p_bar in data.P_bar, n = 1:sol.k[p_bar]
        t, p = bestInsertion(data, sol, [p_bar], type)
        if t != 0 && p != 0
            insert!(data, sol, t, p)
        end
    end

    sorted_idx = sortperm(-data.penalty_S)
    while true
        t, p = bestInsertion(data, sol, sorted_idx, type)
        if t != 0 && p != 0
            insert!(data, sol, t, p)
        else
            break
        end
    end
end

function bestInsertion(data, sol, sorted_idx, type)
    if type == "baseline"
        best_obj = sol.base_obj
    elseif type == "expanded"
        best_obj = sol.exp_obj
    else
        println("Enter valid model type")
        return
    end
    best_p = 0
    best_t = 0
    
    for p in sorted_idx 
        for t = data.start:data.stop
            if fits(data, sol, t, p) 
                delta_obj = deltaInsert(data, sol, t, p)
                if type == "expanded"
                    new_obj = delta_obj.delta_exp 
                elseif type == "baseline"
                    new_obj = delta_obj.delta_base
                else
                    println("Enter valid model type")
                    return
                end

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


function firstInsertion(data, sol, shuffled_idx, type)
    if type == "baseline"
        best_obj = sol.base_obj
    elseif type == "expanded"
        best_obj = sol.exp_obj
    else
        println("Enter valid model type")
        return
    end
    best_p = 0
    best_t = 0
    
    for t = data.start:data.stop
        for p in shuffled_idx
            if fits(data, sol, t, p) 
                delta_obj = deltaInsert(data, sol, t, p)
                if type == "expanded"
                    new_obj = delta_obj.delta_exp 
                elseif type == "baseline"
                    new_obj = delta_obj.delta_base
                else
                    println("Enter valid model type")
                    return
                end

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

function regretRepair!(data, sol, type)
    for p_bar in data.P_bar, n = 1:sol.k[p_bar]
        t, p = regretInsertion(data, sol, [p_bar], type)
        if t != 0 && p != 0
            insert!(data, sol, t, p)
        end
    end

    shuffled_idx = shuffle(1:data.P)
    while true
        t, p = regretInsertion(data, sol, shuffled_idx, type)
        if t != 0 && p != 0
            insert!(data, sol, t, p)
        else
            break
        end
    end
end

function regretInsertion(data, sol, priorities, type)
    obj_best = ones(Float64, data.P)*Inf
    obj_second = ones(Float64, data.P)*Inf
    t_best = zeros(Int64, data.P)
    
    idx = 1
    for p in priorities
        for t = data.start:data.stop
            if fits(data, sol, t, p) 
                delta_obj = deltaInsert(data, sol, t, p)
                if type == "expanded"
                    new_obj = delta_obj.delta_exp
                    sol_obj = sol.exp_obj
                elseif type == "baseline"
                    new_obj = delta_obj.delta_base
                    sol_obj = sol.base_obj
                else
                    println("Enter valid model type")
                    return
                end

                if new_obj < obj_best[idx] && new_obj < sol_obj
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