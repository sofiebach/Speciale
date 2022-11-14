include("HeuristicFunctions.jl")
include("ConstructionHeuristics.jl")
include("MIPModels.jl")

function setProb(rho)
    return rho./sum(rho)
end

function selectMethod(prob)
    n = length(prob)
    chosen = rand()
    next_prob = 0
    for i=1:n
        next_prob += prob[i]
        if chosen <= next_prob
            return i
        end
    end
end

function isValid(data, temp_sol, sol)
    # Check if P_bar constraint is exceeded
    for p_bar in data.P_bar 
        if temp_sol.k[p_bar] > 0
            temp_sol = deepcopy(sol)
            return false
        end
    end
    return true
end


function ALNS(data,time_limit,type="baseline",modelRepair=false,T=10000,alpha=0.99975,gamma=0.9,frac_cluster=0.2,frac_random=0.2,thres_worst=10,frac_related=0.2)    
    it = 1
    # best_it = 1
    # long_term_update = 1000
    T_start = T
    T_threshold = 5 # Minimum T before we want to intensify

    sol = randomInitial(data)
    best_sol = deepcopy(sol)
    temp_sol = deepcopy(sol)
    start_time = time_ns()

    n_d = 4
    destroy_functions = [clusterDestroy!, randomDestroy!, worstDestroy!, relatedDestroy!]
    rho_destroy = ones(n_d)
    time_destroy = zeros(n_d)
    num_destroy = zeros(Int64, n_d)
    destroy_names = string.(destroy_functions)[1:n_d]
    destroy_fracs = [frac_cluster, frac_random, thres_worst, frac_related]

    if type == "baseline"
        repair_functions = [greedyRepair!, firstRepair!, modelRepair!]
        if modelRepair
            n_r = 3
        else
            n_r = 2
        end
    elseif type == "expanded"
        repair_functions = [greedyRepair!, firstRepair!, regretRepair!, modelRepair!]
        if modelRepair
            n_r = 4
        else
            n_r = 3
        end
    else
        println("Enter valid model type")
        return
    end
    rho_repair = ones(n_r)
    time_repair = zeros(n_r)
    num_repair = zeros(Int64, n_r)
    repair_names = string.(repair_functions)[1:n_r]
    
    prob_destroy = setProb(rho_destroy)
    prob_repair = setProb(rho_repair)

    w1 = 10
    w2 = 5
    w3 = 1
    w4 = 0

    destroys = []
    repairs = []
    current_obj = []
    current_best = []
    status = []
    prob_destroy_it = [] 
    prob_repair_it = []
    T_it = []

    while elapsedTime(start_time) < time_limit
        # intensification
        if T < T_threshold
            sol = deepcopy(best_sol)
            temp_sol = deepcopy(sol)
            println("Intensified!")
            T = T_start
            # best_it = 1
        end

        # update probabilities
        if (it % 10 == 0)
            prob_destroy = setProb(rho_destroy)
            prob_repair = setProb(rho_repair)
        end

        # Choose destroy method
        selected_destroy = selectMethod(prob_destroy)
        destroy_time = time_ns()
        destroy_functions[selected_destroy](data, temp_sol, destroy_fracs[selected_destroy])
        elapsed_destroy = elapsedTime(destroy_time)

        # Update destroy time
        time_destroy[selected_destroy] += elapsed_destroy
        num_destroy[selected_destroy] += 1

        # Choose repair method
        selected_repair = selectMethod(prob_repair)
        repair_time = time_ns()
        repair_functions[selected_repair](data, temp_sol, type)
        elapsed_repair = elapsedTime(repair_time)
        valid = isValid(data, temp_sol, sol)

        if !valid
            continue
        end

        it += 1
        # best_it += 1

        # Update repair time
        time_repair[selected_repair] += elapsed_repair
        num_repair[selected_repair] += 1

        # Check acceptance criteria
        if type == "baseline"
            temp_obj = temp_sol.base_obj
            best_obj = best_sol.base_obj
            sol_obj = sol.base_obj
        elseif type == "expanded"
            temp_obj = temp_sol.exp_obj
            best_obj = best_sol.exp_obj
            sol_obj = sol.exp_obj
        else
            println("Enter valid model type")
            return
        end

        if temp_obj < best_obj
            best_sol = deepcopy(temp_sol)
            w = w1
            # best_it = 1
            println("New best")
            println(best_obj)
        elseif temp_obj < sol_obj
            sol = deepcopy(temp_sol)
            w = w2
        elseif rand() < exp(-(temp_obj-sol_obj)/T)
                sol = deepcopy(temp_sol)
                w = w3
        else
            w = w4
        end

        append!(repairs, selected_repair)
        append!(destroys, selected_destroy)
        append!(status, w)
        append!(prob_destroy_it, prob_destroy)
        append!(prob_repair_it, prob_repair)
        append!(T_it, T)
        if type == "baseline"
            append!(current_obj, temp_sol.base_obj)
            append!(current_best, best_sol.base_obj)
        elseif type == "expanded"
            append!(current_obj, temp_sol.exp_obj)
        append!(current_best, best_sol.exp_obj)
        else
            println("Enter valid model type")
        end
        
        rho_destroy[selected_destroy] = gamma*rho_destroy[selected_destroy] + (1-gamma)*w
        rho_repair[selected_repair] = gamma*rho_repair[selected_repair] + (1-gamma)*w
        T = alpha * T
     
    end
    prob_destroy_it = reshape(prob_destroy_it, length(num_destroy),:)
    prob_repair_it = reshape(prob_repair_it, length(num_repair),:)
    println("T: ", T)

    return best_sol, (prob_destroy=prob_destroy, prob_repair=prob_repair, destroys=destroys,  prob_destroy_it = prob_destroy_it,
    prob_repair_it = prob_repair_it, repairs=repairs, current_obj=current_obj, current_best=current_best, status=status, 
    time_repair=time_repair, time_destroy=time_destroy, num_repair=num_repair, num_destroy=num_destroy, destroy_names = destroy_names,
    repair_names = repair_names, iter = it, T_it = T_it)
end