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


function ALNS(data,sol,time_limit,type="baseline",modelRepair=false,theta=0.05,alpha=0.99975,W=[10,5,1],gamma=0.9,destroy_frac=0.2,segment_size=10,long_term_update=5000)    
    it = 1
    best_it = 1
    best_sol = deepcopy(sol)
    temp_sol = deepcopy(sol)
    start_time = time_ns()

    if type == "baseline"
        T_start = -theta*temp_sol.base_obj/log(0.5)
        repair_functions = [greedyRepair!, firstRepair!, flexibilityRepair!, modelRepair!]
        destroy_functions = [clusterDestroy!, randomDestroy!, relatedDestroy!]
        n_d = length(destroy_functions)
        if modelRepair
            n_r = length(repair_functions)
        else
            n_r = length(repair_functions) - 1
        end
    elseif type == "expanded"
        T_start = -theta*temp_sol.exp_obj/log(0.5)
        repair_functions = [greedyRepair!, firstRepair!, flexibilityRepair!, regretRepair!, modelRepair!]
        repair_functions = [firstRepair!, flexibilityRepair!, regretRepair!, modelRepair!]
        destroy_functions = [clusterDestroy!, randomDestroy!, worstIdleDestroy!, stackDestroy!, relatedDestroy!]
        n_d = length(destroy_functions)
        if modelRepair
            n_r = length(repair_functions)
        else
            n_r = length(repair_functions) - 1
        end
    else
        println("Enter valid model type")
        return
    end

    T = T_start

    rho_destroy = ones(n_d)
    time_destroy = zeros(n_d)
    num_destroy = zeros(Int64, n_d)
    destroy_names = string.(destroy_functions)[1:n_d]

    rho_repair = ones(n_r)
    time_repair = zeros(n_r)
    num_repair = zeros(Int64, n_r)
    repair_names = string.(repair_functions)[1:n_r]
    
    prob_destroy = setProb(rho_destroy)
    prob_repair = setProb(rho_repair)

    destroys = Int64[]
    repairs = Int64[]
    current_obj = Float64[]
    current_best = Float64[]
    status = Int64[]
    prob_destroy_it = Float64[] 
    prob_repair_it = Float64[]
    T_it = Float64[]

    while elapsedTime(start_time) < time_limit
        # Intensification
        if best_it > long_term_update
            sol = deepcopy(best_sol)
            temp_sol = deepcopy(sol)
            #println("Intensified!")
            T = T_start
            best_it = 1

            # Reset probabilities
            rho_destroy = ones(n_d)
            rho_repair = ones(n_r)
            prob_destroy = setProb(rho_destroy)
            prob_repair = setProb(rho_repair)
        end

        # update probabilities
        if (it % segment_size == 0)
            prob_destroy = setProb(rho_destroy)
            prob_repair = setProb(rho_repair)
        end

        # Choose destroy method
        selected_destroy = selectMethod(prob_destroy)
        destroy_time = time_ns()
        destroy_functions[selected_destroy](data, temp_sol, destroy_frac)
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
        best_it += 1

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
            sol = deepcopy(temp_sol)
            w = W[1]
            println("New best")
            println(best_obj)
            best_it = 1
        elseif temp_obj < sol_obj
            sol = deepcopy(temp_sol)
            w = W[2]
        elseif rand() < exp(-(temp_obj-sol_obj)/T)
                sol = deepcopy(temp_sol)
                w = W[3]
        else
            temp_sol = deepcopy(sol)
            w = 0
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







