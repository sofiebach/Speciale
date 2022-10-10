include("ConstructionHeuristics.jl")
include("ValidateSolution.jl")
include("MIPModel.jl")

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
    println(sol.num_campaigns)
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
    
    MIPsol = MIP(MIPdata, 5)

    for p = 1:data.P, t = 1:data.T 
        for n = 1:MIPsol.x[t,p]
            insert(data, sol, t, p)
        end
    end
end

function greedyRepair(data, sol)
    t = 0 
    p = 0
    while t != 0 && p != 0
        t, p = bestInsertion(data, sol)
        insert(data, sol, t, p)
        println(sol.obj)
    end
end

function bestInsertion(data, sol)
    best_obj = sol.obj
    best_p = 0
    best_t = 0
    sorted_idx = sortperm(-data.penalty_S)
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

function delta_insert(data, sol, p)
    if sol.k[p] > 0
        return sol.obj - data.penalty_S[p] - data.reward[p]
    else
        return sol.obj - data.reward[p]
    end
end

function delta_remove(data, sol, p)
    if sum(sol.x[:,p])-1 < data.S[p]
        return sol.obj + data.penalty_S[p] + data.reward[p]
    else
        return sol.obj + data.reward[p]
    end
end

function LNS(data)
    sol = randomInitial(data)
    #println(sol.obj)

    frac = 0.2
    randomDestroy(data,sol,frac)
    greedyRepair(data,sol)

    # check if P_bar is valid 

    #println(sol.obj)
    return sol
end

function ALNS(data, time_limit)
    start_time = time_ns()
    it = 1
    T = 1000
    alpha = 0.999
    valid = true
    sol = randomInitial(data)
    best_sol = deepcopy(sol)
    temp_sol = deepcopy(sol)
    while elapsed_time(start_time) < time_limit
        # Choose destroy method
        frac = 0.2
        randomDestroy(data,temp_sol,frac)

        # Choose repair method
        greedyRepair(data,temp_sol)

        # Check if P_bar constraint is exceeded
        for p_bar in data.P_bar 
            if temp_sol.k[p_bar] > 0
                temp_sol = deepcopy(sol)
                valid = false
                break
            end
        end
        
        if !valid
            continue
        end
        # Check acceptance criteria
        if temp_sol.obj < sol.obj
            sol = deepcopy(temp_sol)
        else
            if rand() < exp(-(temp_sol.obj-sol.obj)/T)
                sol = deepcopy(temp_sol)
            end
        end

        if temp_sol.obj < best_sol.obj
            best_sol = deepcopy(temp_sol)
            println(best_sol.obj)
        end
        if it % 100 == 0
            println("Iteration: ", it)
        end

        T = alpha * T
        it += 1
    end
    return best_sol
end

function elapsed_time(start_time)
    return round((time_ns()-start_time)/1e9, digits = 3)
end

P = 37
data = read_DR_data(P)

sol = ALNS(data, 10)

sol = LNS(data)
checkSolution(data, sol)

# sol = randomInitial(data)
#println(delta_insert(data, sol, 1))

#insert(data,sol,10,1)
#println(findObjective(data, sol))


