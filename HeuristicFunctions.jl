include("BasicFunctions.jl")

function randomDestroy!(data, sol, frac)
    n_destroy = ceil(sol.num_campaigns*frac)
    while n_destroy > 0 
        n = rand(1:sol.num_campaigns)
        t, p = findCampaign(data, sol, n)
        remove!(data, sol, t, p)
        n_destroy -= 1
    end
end

function clusterDestroy!(data, sol, frac)
    n_destroy = ceil(sol.num_campaigns*frac)
    n = rand(1:sol.num_campaigns)
    n = sol.num_campaigns-3
    while n_destroy > 0 
        if n > sol.num_campaigns
            n = 1
        end
        t, p = findCampaign(data,sol,n)
        remove!(data,sol,t,p)
        n_destroy -= 1
    end   
end

function worstIdleDestroy!(data, sol, frac)
    n_destroy = ceil(sol.num_campaigns*frac)
    spread_obj = zeros(Float64, data.P)
    for p = 1:data.P
        if sum(sol.x[:,p]) < 2
            spread_obj[p] = NaN
        else
            spread_obj[p] = - data.weight_idle[p] * sol.L[p] + data.weight_idle[p] * sol.y[p]
        end
    end
    replace!(spread_obj, NaN=>-1)
    sorted_p = sortperm(-spread_obj)
    for p in sorted_p
        if spread_obj[p] == -1 || n_destroy == 0 # There are no campaigns to remove in the rest of the array either
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

    # Remove the rest randomly
    while n_destroy > 0 
        n = rand(1:sol.num_campaigns)
        t, p = findCampaign(data, sol, n)
        remove!(data, sol, t, p)
        n_destroy -= 1
    end
end

function stackDestroy!(data, sol, frac)
    n_destroy = ceil(sol.num_campaigns*frac)
    while n_destroy > 0
        val, idx = findmax(sol.g)
        if val == 0
            break
        end
        t = idx[1]
        p = idx[2]
        remove!(data, sol, t, p)
        n_destroy -= 1
    end

    # Remove the rest randomly
    while n_destroy > 0 
        n = rand(1:sol.num_campaigns)
        t, p = findCampaign(data, sol, n)
        remove!(data, sol, t, p)
        n_destroy -= 1
    end
end

function relatedDestroy!(data,sol,frac)
    n_destroy = ceil(sol.num_campaigns*frac)
    while n_destroy > 0
        
        p = rand(findall(sol.k.>0))
        
        p_related = sortperm(-data.sim[p,:])

        p_remove = min(sol.k[p], n_destroy)
        for p_r in p_related 
            if data.sim[p,p_r] <= 0 
                break
            end
            while sum(sol.x[:,p_r]) > 0 && p_remove > 0
                r_times = findall(x -> x > 0, sol.x[:,p_r])
                t = r_times[rand(1:length(r_times))]
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
        t, p = greedyInsertion(data, sol, [p_bar], type)
        if t != 0 && p != 0
            insert!(data, sol, t, p)
        end
    end

    while true
        t, p = greedyInsertion(data, sol, collect(1:data.P), type)
        if t != 0 && p != 0
            insert!(data, sol, t, p)
        else
            break
        end
    end
end

function greedyInsertion(data, sol, priorities, type)
    ratio = zeros(Float64, data.P)
    for p in priorities
        ratio[p] = data.penalty_S[p] / (sum(data.u[:,p,:]) / sum(data.I) + sum(data.w[p,:]) / sum(data.H))
    end

    sorted_priorities = sortperm(-ratio)
    for p in sorted_priorities 
        times = shuffle(data.start:data.stop)
        for t in times
            if fits(data,sol,t,p)
                return t, p
            end
        end
    end
    return 0, 0
end

function bestInsertion(data, sol, priorities, type)
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
    
    for p in priorities 
        #times = shuffle(data.start:data.stop)
        times = data.start:data.stop
        for t in times
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

function flexibilityRepair!(data, sol, type)
    for p_bar in data.P_bar, n = 1:sol.k[p_bar]
        t, p = bestInsertion(data, sol, [p_bar], type)
        if t != 0 && p != 0
            insert!(data, sol, t, p)
        end
    end
    count = 1
    while true
        t, p = flexibilityInsertion(data, sol, collect(1:data.P))
        if t != 0 && p != 0
            insert!(data, sol, t, p)
            # drawRadioSchedule(data, sol, string(count)*"_radio")
            # drawTVSchedule(data, sol, string(count)*"_tv")
            count += 1
        else
            break
        end
    end
end

function flexibilityInsertion(data, sol, priorities)
    n_fits = zeros(Int64, data.P)
    ts = zeros(Int64, data.P)
    
    for p in priorities
        t_values = []
        for t = data.start:data.stop
            if fits(data, sol, t, p) && sol.k[p] > 0
                n_fits[p] += 1
                append!(t_values, t)
            end
        end
        if n_fits[p] > 0
            ts[p] = rand(t_values)
        end
    end

    replace!(n_fits, 0=>data.T)
    idxs = sortperm(n_fits)
    p = idxs[1]
    if n_fits[p] == data.T
        return 0, 0
    end
    return ts[p], p
end

function regretRepair!(data, sol, type)
    for p_bar in data.P_bar, n = 1:sol.k[p_bar]
        t1, t2, p = regretInsertion(data, sol, [p_bar], type)
        if t1 != 0 && t2 != 0 && p != 0
            insert!(data, sol, t1, p)
            insert!(data, sol, t2, p)
        end
    end
    count = 1
    while true
        priorities = shuffle(collect(1:data.P))
        t1, t2, p = regretInsertion(data, sol, priorities, type)
        if t1 != 0 && t2 != 0 && p != 0
            insert!(data, sol, t1, p)
            insert!(data, sol, t2, p)
            # println("INSERTED p: ", p, " t1: ", t1, " t2: ", t2)
            # drawRadioSchedule(data, sol, string(count)*"_radio")
            # drawTVSchedule(data, sol, string(count)*"_tv")
            count += 1
        else
            break
        end
    end
end

function regretInsertion(data, sol, priorities, type)
    # loss = zeros(Float64, data.P)*NaN
    # ts = zeros(Int64, data.P, 2)
    loss = zeros(Float64, length(priorities))*NaN
    ts = zeros(Int64, length(priorities), 2)
    p_idx = 1
    for p in priorities
        if sol.k[p] < 2
            continue
        end
        best_delta1 = Inf
        best_delta2 = Inf
        t1, _ = bestInsertion(data, sol, [p], type)
        if t1 == 0
            continue
        end
        temp1 = 0
        temp2 = 0
        for t2 = data.start:data.stop
            if fits2times(data, sol, t1, t2, p)
                delta1 = deltaCompareRegret(data, sol, t1, t2, p)
                if delta1 < best_delta1
                    best_delta1 = delta1
                    temp1 = t1
                    temp2 = t2
                end
            end
        end
        # println("p: ", p)
        # println("t1: ", temp1)
        # println("t2: ", temp2)
        # println("delta: ", best_delta1)
        for t1 = data.start:data.stop
            if fits(data, sol, t1, p)
                for t2 = data.start:data.stop
                    if fits2times(data, sol, t1, t2, p)
                        delta2 = deltaCompareRegret(data, sol, t1, t2, p)
                        if delta2 < best_delta2
                            best_delta2 = delta2
                            ts[p_idx,:] = [t1,t2]
                        end
                    end
                end
            end
        end
        # println("t1: ", ts[p_idx,1])
        # println("t2: ", ts[p_idx,2])
        # println("delta: ", best_delta2)
        # println("----------------")
        loss[p_idx] = best_delta1 - best_delta2
        p_idx += 1
    end
    replace!(loss, NaN=>-1)

    # println(loss)
    loss, idx = findmax(loss)
    best_p = priorities[idx]
    t1 = ts[idx,1]
    t2 = ts[idx,2]
    # best_p = collect(1:data.P)[idx]
    #println("BEST P: ",best_p)
    # t1 = ts[best_p,1]
    # t2 = ts[best_p,2]
    #println(t1, " ", t2)
    #println("------------")
    if t1 == 0 || t2 == 0
        return 0, 0, 0
    end
    return t1, t2, best_p
end


#function spreadModelRepair!(data, sol, type)
#    MIPdata = deepcopy(data)
#
#    time_limit = 120
#    MIPx = MIPExpansion(MIPdata, "HiGHS", 1, time_limit, 0, sol.x)
#
#    if MIPx == 0
#        return
#    else
#        for p = 1:data.P, t = 1:data.T 
#            N = MIPx[t,p] - sol.x[t,p]
#            for n = 1:N
#                insert!(data, sol, t, p)
#            end
#        end
#    end
#end
#function regretRepair!(data, sol, type)
#    for p_bar in data.P_bar, n = 1:sol.k[p_bar]
#        t, p = regretInsertion(data, sol, [p_bar], type)
#        if t != 0 && p != 0
#            insert!(data, sol, t, p)
#        end
#    end
#
#    while true
#        t, p = regretInsertion(data, sol, collect(1:data.P), type)
#        if t != 0 && p != 0
#            insert!(data, sol, t, p)
#        else
#            break
#        end
#    end
#end
#
#function regretInsertion(data, sol, priorities, type)
#    obj_best = ones(Float64, data.P)*Inf
#    obj_second = ones(Float64, data.P)*Inf
#    t_best = zeros(Int64, data.P)
#    
#    idx = 1
#    for p in priorities
#        for t = data.start:data.stop
#            if fits(data, sol, t, p) 
#                delta_obj = deltaInsert(data, sol, t, p)
#                if type == "expanded"
#                    new_obj = delta_obj.delta_exp
#                    sol_obj = sol.exp_obj
#                elseif type == "baseline"
#                    new_obj = delta_obj.delta_base
#                    sol_obj = sol.base_obj
#                else
#                    println("Enter valid model type")
#                    return
#                end
#
#                if new_obj < obj_best[idx] && new_obj < sol_obj
#                    obj_second[idx] = obj_best[idx]
#                    obj_best[idx] = new_obj
#                    t_best[idx] = t 
#                elseif new_obj < obj_second[idx]
#                    obj_second[idx] = new_obj
#                end
#            end
#        end
#        idx += 1
#    end
#    loss = obj_second - obj_best
#    replace!(loss, NaN=>-1)
#    loss, idx = findmax(loss)
#    best_p = priorities[idx]
#    if loss >= 0
#        best_t = t_best[idx]
#    else 
#        best_p = 0
#        best_t = 0
#    end
#    return best_t, best_p
#end