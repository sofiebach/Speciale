using Random
using Statistics

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

function remove!(data, sol, t, p)
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
    findObjective!(data, sol)
end

function findCampaign(data, sol, n)
    count = 0
    for t = data.start:data.stop, p = 1:data.P
        count += sol.x[t,p]
        if count >= n
            return t, p
        end
    end
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

function fits2times(data, sol, t1, t2, p)
    # Given p will be inserted at t1, can it also be inserted at t2
    # Check if p fits at t2
    if !fits(data, sol, t2, p)
        return false
    end

    t_hat1L = collect((t1+data.L_lower):(t1+data.L_upper))
    t_hat2L = collect((t2+data.L_lower):(t2+data.L_upper))
    t_hat_L_intersect = intersect(t_hat1L,t_hat2L)

    t_hat1Q = collect((t1+data.Q_lower):(t1+data.Q_upper))
    t_hat2Q = collect((t2+data.Q_lower):(t2+data.Q_upper))
    t_hat_Q_intersect = intersect(t_hat1Q,t_hat2Q)

    # Check production
    # Check freelance in case of no overlap in Q
    if length(t_hat_Q_intersect) == 0
        # Compute freelance hours needed for t1 and t2
        for m = 1:data.M  
            freelancers_needed1 = 0
            freelancers_needed2 = 0
            
            for t_hat = (t1+data.Q_lower):(t1+data.Q_upper)
                if sol.H_cap[t_hat, m] - data.w[p, m] < 0
                    freelancers_needed1 += -(sol.H_cap[t_hat, m] - data.w[p, m])
                end
            end

            for t_hat = (t2+data.Q_lower):(t2+data.Q_upper) 
                if sol.H_cap[t_hat, m] - data.w[p, m] < 0
                    freelancers_needed2 += -(sol.H_cap[t_hat, m] - data.w[p, m])
                    if sum(sol.f[:,m]) + freelancers_needed1 + freelancers_needed2 > data.F[m] 
                        return false
                    end
                end
            end
        end
    else #  Check if overlap in Q
        t_hat_cat = vcat(t_hat1Q, t_hat2Q)
        t_count = [count(==(i), t_hat_cat) for i in unique(t_hat_cat)]

        for m = 1:data.M
            idx = 1
            freelancers_needed = 0
            for t_hat = minimum(t_hat_cat):maximum(t_hat_cat) 
                if sol.H_cap[t_hat, m] - data.w[p, m]*t_count[idx] < 0
                    freelancers_needed += -(sol.H_cap[t_hat, m] - data.w[p, m]*t_count[idx])
                    if sum(sol.f[:,m]) + freelancers_needed > data.F[m] 
                        return false
                    end
                end
                idx += 1
            end
        end
    end
    # Check inventory in case of overlap in L
    if length(t_hat_L_intersect) > 0
        # Find l_idx in original t_hats
        l_idx1 = findall(x -> x in t_hat_L_intersect, t_hat1L)
        l_idx2 = findall(x -> x in t_hat_L_intersect, t_hat2L)

        idx = 1
        for t_hat in t_hat_L_intersect
            for c = 1:data.C
                grp = data.u[l_idx1[idx],p,c] + data.u[l_idx2[idx],p,c] # Add grp contribution from both time steps
                if sol.I_cap[t_hat, c] - grp < 0
                    return false
                end
            end
            idx += 1
        end
    end

    return true 
end

function MIPtoSol(data, x)
    sol = Sol(data)
    for t = 1:data.T, p = 1:data.P
        for n = 1:x[t,p]
            insert!(data, sol, t, p)
        end
    end
    return sol
end

function findObjective!(data, sol)
    sol.objective.k_penalty = sum(data.penalty_S .* sol.k)
    sol.objective.g_penalty = sum(sol.g) #sum(1 - 1/(1-sum(sol.g, dims = 1)))
    sol.objective.L_reward = sum(sol.L)

    sol.base_obj = 1000 + sol.objective.k_penalty
    sol.exp_obj = 1000 + sol.objective.k_penalty + (sol.objective.g_penalty - sol.objective.L_reward)
end

function deltaCompareRegret(data, sol, t1, t2, p)
    xp = deepcopy(sol.x[:,p])
    xp[t1] += 1
    xp[t2] += 1
    new_idle = findMinIdle(data,xp)

    aimed_wrong = 0
    if xp[t1] > data.aimed[p]
        aimed_wrong += 1 #aimed wrong penalty is set to 1
    end
    if xp[t2] > data.aimed[p]
        aimed_wrong += 1 #aimed wrong penalty is set to 1
    end
    return -new_idle + aimed_wrong #Minimize
end

function deltaInsert(data, sol, t, p)
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
    delta_exp = sol.exp_obj + penalty_scope + (aimed_wrong + delta_idle)

    if sol.k[p] > 0
        delta_base =  sol.base_obj - data.penalty_S[p]
    else
        delta_base = sol.base_obj
    end

    return (delta_base=delta_base, delta_exp=delta_exp)
end

function deltaRemove(data, sol, t, p)
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
    delta_exp = sol.exp_obj + penalty_scope + aimed_wrong + delta_idle

    if sum(sol.x[:,p])-1 < data.S[p]
        delta_base = sol.base_obj + data.penalty_S[p]
    else
        delta_base = sol.base_obj
    end

    return (delta_base=delta_base, delta_exp=delta_exp)    
end

function deltaSwap(sol, t1, p1, t2, p2)
    xp_1 = deepcopy(sol.x[:,p1])
    xp_2 = deepcopy(sol.x[:,p2])

    # Remove only changes the objective wrt idle time and g
    if sol.g[t1,p1] > 0
        aimed_wrong_p1 = -1  #aimed wrong penalty is set to 1
    else
        aimed_wrong_p1 = 0
    end
    if sol.g[t2,p2] > 0
        aimed_wrong_p2 = -1  #aimed wrong penalty is set to 1
    else
        aimed_wrong_p2 = 0
    end
    xp_1[t1] -= 1
    remove_idle_p1 = findMinIdle(data,xp_1)
    delta_idle_p1 = sol.L[p1] - remove_idle_p1 # Should be negative or zero
    xp_2[t2] -= 1
    remove_idle_p2 = findMinIdle(data,xp_2)
    delta_idle_p2 = sol.L[p2] - remove_idle_p2 # Should be negative or zero
    delta_remove = aimed_wrong_p1 + aimed_wrong_p2 + delta_idle_p1 + delta_idle_p2

    # Insert
    if xp_2[t1] + 1 > data.aimed[p2]
        aimed_wrong_p2 = 1  #aimed wrong penalty is set to 1
    else
        aimed_wrong_p2 = 0
    end
    if xp_1[t2] + 1 > data.aimed[p1]
        aimed_wrong_p1 = 1  #aimed wrong penalty is set to 1
    else
        aimed_wrong_p1 = 0
    end
    xp_1[t2] += 1
    new_idle_p1 = findMinIdle(data,xp_1)
    delta_idle_p1 = remove_idle_p1 - new_idle_p1 # Should be positive or zero
    xp_2[t1] += 1
    new_idle_p2 = findMinIdle(data,xp_2)
    delta_idle_p2 = remove_idle_p2 - new_idle_p2 # Should be positive or zero
    delta_insert = aimed_wrong_p1 + aimed_wrong_p2 + delta_idle_p1 + delta_idle_p2

    return sol.obj + delta_remove + delta_insert
end

function elapsedTime(start_time)
    return round((time_ns()-start_time)/1e9, digits = 3)
end

function checkReplace(data, sol, t1, p1, p2)
    # checks if p2 can be placed at t1 INSTEAD of p1
    if t1 < data.start || t1 > data.stop 
        println("Select t between start and stop.")
        return false
    end

    # Inventory check
    l_idx = 1
    for t_hat = (t1+data.L_lower):(t1+data.L_upper)
        for c = 1:data.C
            grp_p1 = data.u[l_idx,p1,c]
            grp_p2 = data.u[l_idx,p2,c]
            if sol.I_cap[t_hat, c] + grp_p1 - grp_p2 < 0
                return false
            end
        end
        l_idx += 1
    end

    # Production check
    return checkReplaceProduction(data, sol, t1, p1, p2)
end

function checkReplaceProduction(data, sol, t1, p1, p2)
    for m = 1:data.M
        freelancers_needed = 0
        for t_hat = (t1+data.Q_lower):(t1+data.Q_upper) 
            work_p1 = data.w[p1, m]
            work_p2 = data.w[p2, m]
            extra_work = work_p2 - work_p1
            if sol.H_cap[t_hat,m] - extra_work < 0
                freelancers_needed += -(sol.H_cap[t_hat,m] - extra_work)
                if sum(sol.f[:,m]) + freelancers_needed > data.F[m] 
                    return false
                end
            end
        end
    end

    return true
end

function checkSwap(data, sol, t1, p1, t2, p2)
    if t1 < data.start || t1 > data.stop || t2 < data.start || t2 > data.stop
        println("Select times between start and stop.")
        return false
    end

    if p1 == p2
        return false
    end

    if sol.x[t1,p1] == 0 || sol.x[t2,p2] == 0
        return false
    end

    # If t1 and t2 doesnt overlap
    if (t1+data.L_upper) < (t2+data.L_lower)
        return checkReplace(data, sol, t1, p1, p2) && checkReplace(data, sol, t2, p2, p1)
    end

    # If t1 and t2 overlaps
    # Inventory check
    for c = 1:data.C
        l_idx1 = 0
        l_idx2 = 0
        for t_hat = (t1+data.L_lower):(t2+data.L_upper)
            if t_hat < t2+data.L_lower 
                # før overlap
                l_idx1 += 1
                old_grp1 = data.u[l_idx1,p1,c]
                new_grp2 = data.u[l_idx1,p2,c]
                if sol.I_cap[t_hat, c] + old_grp1 - new_grp2 < 0 
                    return false
                end
            elseif t_hat > t1+data.L_upper 
                # efter overlap
                l_idx2 += 1
                old_grp2 = data.u[l_idx2,p2,c]
                new_grp1 = data.u[l_idx2,p1,c]
                if sol.I_cap[t_hat, c] + old_grp2 - new_grp1 < 0 
                    return false
                end
            else
                # overlap
                l_idx1 += 1
                l_idx2 += 1
                old_grp1 = data.u[l_idx1,p1,c]
                new_grp2 = data.u[l_idx1,p2,c]
                old_grp2 = data.u[l_idx2,p2,c]
                new_grp1 = data.u[l_idx2,p1,c]
                if sol.I_cap[t_hat, c] + old_grp2 + old_grp1 - new_grp1 - new_grp2 < 0 
                    return false
                end
            end
        end
    end

    # Production check
    return checkReplaceProduction(data, sol, t1, p1, p2) && checkReplaceProduction(data, sol, t2, p2, p1)
end

