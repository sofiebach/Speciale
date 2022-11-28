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

function worstSpreadDestroy!(data, sol, frac)
    n_destroy = ceil(sol.num_campaigns*frac)
    perfect_spread = data.timeperiod./(sum(sol.x, dims = 1) .- 1)
    div_spread = zeros(Float64, data.P)
    replace!(perfect_spread, Inf=>-1)
    for p = 1:data.P
        if perfect_spread[p] > 0
            div_spread[p] = (perfect_spread[p] - sol.L[p]) / perfect_spread[p]
        end 
    end
    sorted_p = sortperm(-div_spread)
    for p in sorted_p
        if div_spread[p] == 0 || n_destroy == 0 # There are no campaigns to remove in the rest of the array either
            break
        end
        while n_destroy > 0 
            if sum(sol.x[:,p]) == 0
                break
            end
            
            r_times = findall(x -> x > 0, sol.x[:,p])
            t = r_times[rand(1:length(r_times))]
            remove!(data, sol, t, p)
            n_destroy -= 1
        end
    end
end

function stackDestroy!(data, sol, frac)
    for p = 1:data.P
        if maximum(sol.x[:,p]) > data.aimed[p]
            for t = data.start:data.stop
                while sol.x[t,p] > data.aimed[p]
                    remove!(data, sol, t, p)
                end
            end
        end
    end
end

function relatedDestroy!(data,sol,frac)
    n_destroy = ceil(sol.num_campaigns*frac)
    while n_destroy > 0
        
        p = rand(findall(sol.k.>0))
        
        p_related = sortperm(-data.sim[p,:])
        #println("P: ", p)

        p_remove = min(sol.k[p], n_destroy)
        for p_r in p_related 
            if data.sim[p,p_r] <= 0 
                break
            end
            while sum(sol.x[:,p_r]) > 0 && p_remove > 0
                r_times = findall(x -> x > 0, sol.x[:,p_r])
                t = r_times[rand(1:length(r_times))]
                #println("P_related: ", p_r)
                #println("T: ", t)
                remove!(data, sol, t, p_r)
                n_destroy -= 1
                p_remove -= 1
            end
            if p_remove == 0
                break
            end
        end
    end
end

function spreadModelRepair!(data, sol, type)
    MIPdata = deepcopy(data)

    time_limit = 120
    MIPx = MIPExpansion(MIPdata, "HiGHS", 1, time_limit, 0, sol.x)

    if MIPx == 0
        return
    else
        for p = 1:data.P, t = 1:data.T 
            N = MIPx[t,p] - sol.x[t,p]
            for n = 1:N
                insert!(data, sol, t, p)
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

    time_limit = 10
    logging = 1
    sol_limit = 0
    MIPx = MIPBaseline(MIPdata, "HiGHS", logging, time_limit, sol_limit)

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
        t, p = bestInsertion(data, sol, [p_bar], type)
        if t != 0 && p != 0
            insert!(data, sol, t, p)
        end
    end
    for t = data.start:data.stop
        while true
            p = firstInsertion(data, sol, t, type)
            if p == 0
                break
            end
            insert!(data, sol, t, p)
        end
    end
end

function firstInsertion(data, sol, t, type)
    if type == "baseline"
        best_obj = sol.base_obj
    elseif type == "expanded"
        best_obj = sol.exp_obj
    else
        println("Enter valid model type")
        return
    end
    shuffled_idx = shuffle(1:data.P)
    for p in shuffled_idx
        if fits(data, sol, t, p) && sol.k[p] > 0
            delta_obj = deltaInsert(data, sol, t, p)
            if type == "expanded"       
                new_obj = delta_obj.delta_exp 
            elseif type == "baseline"
                new_obj = delta_obj.delta_base
            end
            if new_obj < best_obj
                best_obj = new_obj
                return p
            end
        end
    end
    return 0
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