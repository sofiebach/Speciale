using Statistics

function randomDestroy(data, sol, frac)
    n_destroy = round(sol.num_campaigns*frac)
    while n_destroy > 0 
        p = rand(1:data.P)
        if sum(sol.x[:,p]) == 0
            continue
        end
        r_times = findall(x -> x > 0, sol.x[:,p])

        t = r_times[rand(1:length(r_times))]
        remove(data, sol, t, p)
        n_destroy -= 1
    end
    #println(sol.obj)
end

function clusterDestroy(data, sol, frac)
    t_destroy = Int(round((data.stop - data.start)*frac))
    rand_t = rand(data.start:(data.stop-t_destroy))
    for t = rand_t:(rand_t+t_destroy), p = 1:data.P
        while sol.x[t,p] > 0
            remove(data,sol,t,p)
        end
    end   
end

function worstDestroy(data, sol, thres)
    for t = data.start:data.stop, m = 1:data.M
        while sol.f[t,m] > thres
            t_hat = rand((t-data.Q_upper):(t-data.Q_lower))
            p_worst = findall(x -> x > 0, sol.x[t_hat,:].*data.w[:,m])
            if length(p_worst) > 0
                remove(data,sol,t_hat,rand(p_worst))
            end
        end
    end
end

function relatedDestroy(data, sol, frac)
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
                    remove(data, sol, t, p_r)
                    n_remove -= 1
                    n_destroy -= 1
                end
                break
            end
        end
    end
end

function remove(data, sol, t, p)
    sol.x[t,p] -= 1
    sol.num_campaigns -= 1
    
    # update inventory
    l_idx = 1
    for t_hat = (t+data.L_lower):(t+data.L_upper)
        for c = 1:data.C
            sol.I_cap[t_hat, c] += data.u[l_idx,p,c]
        end
        l_idx += 1
    end
    
    # update production
    for t_hat = (t+data.Q_lower):(t+data.Q_upper) 
        for m = 1:data.M
            sol.H_cap[t_hat, m] += data.w[p, m]
            if sol.H_cap[t_hat, m] < 0
                sol.f[t_hat, m] = -sol.H_cap[t_hat, m]
            else
                sol.f[t_hat,m] = 0
            end
        end
    end

    # update scope
    if sum(sol.x[:,p]) < data.S[p]
        sol.k[p] += 1
    else 
        sol.k[p] = 0
    end
    
    # update aimed
    if sol.g[t,p] > 0
        sol.g[t,p] -= 1
    end

    sol.L[p] = findMinIdle(data,sol.x[:,p])
    # update objective
    findObjective(data, sol)
end

function modelRepair(data, sol)
    MIPdata = deepcopy(data)
    MIPdata.I = deepcopy(sol.I_cap)
    MIPdata.H = deepcopy(sol.H_cap)
    MIPdata.H[MIPdata.H .< 0.0] .= 0.0
    MIPdata.F = deepcopy(data.F - transpose(sum(sol.f, dims=1))[:,1])
    MIPdata.S = deepcopy(sol.k)
    
    MIPsol = MIPExpansion(MIPdata, 0, 2, 0)

    for p = 1:data.P, t = 1:data.T 
        for n = 1:MIPsol.x[t,p]
            insert(data, sol, t, p)
        end
    end
end

function greedyRepair(data, sol)
    for p_bar in data.P_bar, n = 1:sol.k[p_bar]
        t, p = bestInsertion(data, sol, [p_bar])
        if t != 0 && p != 0
            insert(data, sol, t, p)
            #println("Inserted ", p, " at time ", t)
        end
    end

    sorted_idx = sortperm(-data.penalty_S)
    while true
        #println("Vi er i while")
        t, p = bestInsertion(data, sol, sorted_idx)
        if t != 0 && p != 0
            insert(data, sol, t, p)
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

function firstRepair(data, sol)
    for p_bar in data.P_bar, n = 1:sol.k[p_bar]
        t, p = firstInsertion(data, sol, [p_bar])
        if t != 0 && p != 0
            insert(data, sol, t, p)
            #println("Inserted ", p, " at time ", t)
        end
    end

    shuffled_idx = shuffle(1:data.P)
    while true
        #println("Vi er i while")
        t, p = firstInsertion(data, sol, shuffled_idx)
        if t != 0 && p != 0
            insert(data, sol, t, p)
            #println("Inserted ", p, " at time ", t)
        else
            break
        end
    end
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

function delta_insert(data, sol, t, p)
    if sol.k[p] > 0
        penalty_scope = -data.penalty_S[p] 
    else
        penalty_scope = 0
    end
    if sol.x[t,p] + 1 > data.aimed[p]
        aimed_wrong = 1  #aimed wrong penalty is set to 1
    else
        aimed_wrong = 0
    end
    xp = deepcopy(sol.x[:,p])
    xp[t] += 1
    new_idle = findMinIdle(data,xp)
    delta_idle = sol.L[p] - new_idle # Should be positive or zero
    return sol.obj - data.reward[p] + penalty_scope + aimed_wrong + delta_idle
end

function delta_remove(data, sol, t, p)
    if sum(sol.x[:,p])-1 < data.S[p]
        penalty_scope = data.penalty_S[p]
    else
        penalty_scope = 0
    end
    if sol.g[t,p] > 0
        aimed_wrong = -1  #aimed wrong penalty is set to 1
    else
        aimed_wrong = 0
    end
    xp = deepcopy(sol.x[:,p])
    xp[t] -= 1
    new_idle = findMinIdle(data,xp)
    delta_idle = sol.L[p] - new_idle # Should be negative or zero
    return sol.obj + data.reward[p] + penalty_scope + aimed_wrong + delta_idle
end


function elapsed_time(start_time)
    return round((time_ns()-start_time)/1e9, digits = 3)
end

function setProb(rho, prob)
    for i = 1:length(prob)
        prob[i] = rho[i]/sum(rho[:])
    end
    return prob
end

function findSimilarity(data)
    sim = zeros(data.P, data.P)
    for p1 = 1:(data.P-1)
        for p2 = (p1+1):data.P
            sim_u = PearsonSimilarity(data.u[:,p1,:], data.u[:,p2,:])
            sim_w = PearsonSimilarity(data.w[p1,:], data.w[p2,:])

            sim[p1,p2] = mean([sim_u, sim_w])
            sim[p2,p1] = mean([sim_u, sim_w])
        end 
    end
    return sim
end

function PearsonSimilarity(a, b)
    mu_a =  mean(a)
    mu_b = mean(b)
    t = (sum((a.-mu_a).*(b.-mu_b)))
    n = sqrt(sum((a.-mu_a).^2))*sqrt(sum((b.-mu_b).^2))
    return t/n
end

function selectMethod(prob)
    chosen = rand()
    next_prob = 0
    for i=1:length(prob)
        next_prob += prob[i]
        if chosen <= next_prob
            return i
        end
    end
end

function ALNS(data, time_limit)
    it = 0
    T = 1000
    alpha = 0.999
    sol = randomInitial(data)
    best_sol = deepcopy(sol)
    temp_sol = deepcopy(sol)
    start_time = time_ns()

    rho_destroy = ones(4)
    rho_repair = ones(3)

    prob_destroy = zeros(4)
    prob_repair = zeros(3)

    prob_destroy = setProb(rho_destroy, prob_destroy)
    prob_repair = setProb(rho_repair, prob_repair)

    w1 = 10
    w2 = 5
    w3 = 1
    w4 = 0

    gamma = 0.9

    destroys = []
    repairs = []
    current_obj = []
    current_best = []
    status = []

    while elapsed_time(start_time) < time_limit
    #while it < 100
        valid = true
        it += 1
        # update probabilities
        if (it % 10 == 0)
            prob_destroy = setProb(rho_destroy, prob_destroy)
            prob_repair = setProb(rho_repair, prob_repair)
        end

        # Choose destroy method
        selected_destroy = selectMethod(prob_destroy)
        if selected_destroy == 1
            frac = 0.1
            clusterDestroy(data,temp_sol,frac)
        elseif selected_destroy == 2
            frac = 0.1
            randomDestroy(data,temp_sol,frac)
        elseif selected_destroy == 3
            thres = 10
            worstDestroy(data,temp_sol,thres)
        else
            frac = 0.2
            relatedDestroy(data, sol, frac)
        end
        
        # Choose repair method
        selected_repair = selectMethod(prob_repair)
        
        if selected_repair == 1
            greedyRepair(data,temp_sol)
            # Check if P_bar constraint is exceeded
            for p_bar in data.P_bar 
                if temp_sol.k[p_bar] > 0
                    temp_sol = deepcopy(sol)
                    valid = false
                    break
                end
            end
        elseif selected_repair == 2
            firstRepair(data,temp_sol)

            # Check if P_bar constraint is exceeded
            for p_bar in data.P_bar 
                if temp_sol.k[p_bar] > 0
                    temp_sol = deepcopy(sol)
                    valid = false
                    break
                end
            end
        else
            modelRepair(data,temp_sol)
        end

        if !valid
            continue
        end
        append!(repairs, selected_repair)
        append!(destroys, selected_destroy)
        append!(current_obj, temp_sol.obj)
        w = w4

        # Check acceptance criteria
        if temp_sol.obj < sol.obj
            sol = deepcopy(temp_sol)
            w = w2
            #println("Better than sol")
        else
            if rand() < exp(-(temp_sol.obj-sol.obj)/T)
                sol = deepcopy(temp_sol)
                w = w3
                #println("Annealing")
            end
        end

        if temp_sol.obj < best_sol.obj
            best_sol = deepcopy(temp_sol)
            w = w1
            println("New best")
            println(best_sol.obj)
        end
        append!(status, w)
        append!(current_best, best_sol.obj)

        rho_destroy[selected_destroy] = gamma*rho_destroy[selected_destroy] + (1-gamma)*w
        rho_repair[selected_repair] = gamma*rho_repair[selected_repair] + (1-gamma)*w
        T = alpha * T
     
    end
    return best_sol, (prob_destroy=prob_destroy, prob_repair=prob_repair, destroys=destroys, repairs=repairs, current_obj=current_obj, current_best=current_best, status=status)
end