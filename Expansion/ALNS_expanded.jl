include("HeuristicFunctions.jl")
include("ConstructionHeuristics_expanded.jl")

function setProb(rho, prob)
    for i = 1:length(prob)
        prob[i] = rho[i]/sum(rho[:])
    end
    return prob
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

function ALNS(data, time_limit, T=1000, alpha=0.999, frac_cluster=0.1, frac_random=0.1, thres_worst=10, frac_related=0.2)    
    it = 0
    sol = randomInitial(data)
    best_sol = deepcopy(sol)
    temp_sol = deepcopy(sol)
    start_time = time_ns()

    rho_destroy = ones(4)
    time_destroy = zeros(4)
    prob_destroy = zeros(4)
    num_destroy = zeros(4)
    destroy_names = Array{String}(undef,4)

    rho_repair = ones(4)
    prob_repair = zeros(4)
    time_repair = zeros(4)
    num_repair = zeros(4)
    repair_names = Array{String}(undef,4)
    

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
    prob_destroy_t = []
    prob_repair_t = []

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
            destroy_names[1] = "Cluster destroy"
            destroy_time = time_ns()
            clusterDestroy!(data,temp_sol,frac_cluster)
        elseif selected_destroy == 2
            destroy_names[2] = "Random destroy"
            destroy_time = time_ns()
            randomDestroy!(data,temp_sol,frac_random)
        elseif selected_destroy == 3
            destroy_names[3] = "Worst destroy"
            destroy_time = time_ns()
            worstDestroy!(data,temp_sol,thres_worst)
        else
            destroy_names[4] = "Related destroy"
            destroy_time = time_ns()
            relatedDestroy!(data, sol, frac_related)
        end

        # Update destroy time
        time_destroy[selected_destroy] += elapsed_time(destroy_time)
        num_destroy[selected_destroy] += 1

        # Choose repair method
        selected_repair = selectMethod(prob_repair)
        
        if selected_repair == 1
            repair_names[1] = "Greedy repair"
            repair_time = time_ns()
            greedyRepair!(data,temp_sol)
            elapsed_repair = elapsed_time(repair_time)
            # Check if P_bar constraint is exceeded
            for p_bar in data.P_bar 
                if temp_sol.k[p_bar] > 0
                    temp_sol = deepcopy(sol)
                    valid = false
                    break
                end
            end
        elseif selected_repair == 2
            repair_names[2] = "First repair"
            repair_time = time_ns()
            firstRepair!(data,temp_sol)
            elapsed_repair = elapsed_time(repair_time)
            # Check if P_bar constraint is exceeded
            for p_bar in data.P_bar 
                if temp_sol.k[p_bar] > 0
                    temp_sol = deepcopy(sol)
                    valid = false
                    break
                end
            end
        elseif selected_repair == 3
            repair_names[3] = "Regret repair" 
            repair_time = time_ns()
            regretRepair!(data,temp_sol)
            elapsed_repair = elapsed_time(repair_time)
            # Check if P_bar constraint is exceeded
            for p_bar in data.P_bar 
                if temp_sol.k[p_bar] > 0
                    temp_sol = deepcopy(sol)
                    valid = false
                    break
                end
            end
        else
            repair_names[4] = "Model repair"
            repair_time = time_ns()
            modelRepair!(data,temp_sol)
            elapsed_repair = elapsed_time(repair_time)
        end

        if !valid
            continue
        end

        # Update repair time
        time_repair[selected_repair] += elapsed_repair
        num_repair[selected_repair] += 1

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
        append!(prob_destroy_t, prob_destroy)
        append!(prob_repair_t, prob_repair)

        rho_destroy[selected_destroy] = gamma*rho_destroy[selected_destroy] + (1-gamma)*w
        rho_repair[selected_repair] = gamma*rho_repair[selected_repair] + (1-gamma)*w
        T = alpha * T
     
    end
    prob_destroy_t = reshape(prob_destroy_t, length(num_destroy),:)
    prob_repair_t = reshape(prob_repair_t, length(num_repair),:)
    return best_sol, (prob_destroy=prob_destroy, prob_repair=prob_repair, prob_destroy_t = prob_destroy_t, prob_repair_t = prob_repair_t, 
    destroys=destroys, repairs=repairs, current_obj=current_obj, current_best=current_best, status=status, time_repair=time_repair, 
    time_destroy=time_destroy, num_repair=num_repair, num_destroy=num_destroy, destroy_names = destroy_names, repair_names = repair_names)
end

function ALNS_uden_modelrepair(data, time_limit, T=1000, alpha=0.999, frac_cluster=0.1, frac_random=0.1, thres_worst=10, frac_related=0.2)    
    it = 0
    best_it = 1
    long_term_update = 1000
    sol = randomInitial(data)
    best_sol = deepcopy(sol)
    temp_sol = deepcopy(sol)
    start_time = time_ns()

    rho_destroy = ones(4)
    time_destroy = zeros(4)
    prob_destroy = zeros(4)
    num_destroy = zeros(4)
    destroy_names = Array{String}(undef,4)

    rho_repair = ones(3)
    prob_repair = zeros(3)
    time_repair = zeros(3)
    num_repair = zeros(3)
    repair_names = Array{String}(undef,3)

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
    prob_destroy_t = [] 
    prob_repair_t = []

    while elapsed_time(start_time) < time_limit
    #while it < 100
        # diversification
        if best_it > long_term_update
            diversify!(data, sol)
            best_it = 1
            println("Diversified!")
        end

        valid = true

        # update probabilities
        if (it % 10 == 0)
            prob_destroy = setProb(rho_destroy, prob_destroy)
            prob_repair = setProb(rho_repair, prob_repair)
        end

        # Choose destroy method
        selected_destroy = selectMethod(prob_destroy)
        if selected_destroy == 1
            destroy_names[1] = "Cluster destroy"
            destroy_time = time_ns()
            clusterDestroy!(data,temp_sol,frac_cluster)
        elseif selected_destroy == 2
            destroy_names[2] = "Random destroy"
            destroy_time = time_ns()
            randomDestroy!(data,temp_sol,frac_random)
        elseif selected_destroy == 3
            destroy_names[3] = "Worst destroy"
            destroy_time = time_ns()
            worstDestroy!(data,temp_sol,thres_worst)
        else
            destroy_names[4] = "Related destroy"
            destroy_time = time_ns()
            relatedDestroy!(data, sol, frac_related)
        end

        # Update destroy time
        time_destroy[selected_destroy] += elapsed_time(destroy_time)
        num_destroy[selected_destroy] += 1

        # Choose repair method
        selected_repair = selectMethod(prob_repair)
        
        if selected_repair == 1
            repair_names[1] = "Greedy repair"
            repair_time = time_ns()
            greedyRepair!(data,temp_sol)
            elapsed_repair = elapsed_time(repair_time)
            # Check if P_bar constraint is exceeded
            for p_bar in data.P_bar 
                if temp_sol.k[p_bar] > 0
                    temp_sol = deepcopy(sol)
                    valid = false
                    break
                end
            end
        elseif selected_repair == 2
            repair_names[2] = "First repair"
            repair_time = time_ns()
            firstRepair!(data,temp_sol)
            elapsed_repair = elapsed_time(repair_time)
            # Check if P_bar constraint is exceeded
            for p_bar in data.P_bar 
                if temp_sol.k[p_bar] > 0
                    temp_sol = deepcopy(sol)
                    valid = false
                    break
                end
            end
        else
            repair_names[3] = "Regret repair"
            repair_time = time_ns()
            regretRepair!(data,temp_sol)
            elapsed_repair = elapsed_time(repair_time)
            # Check if P_bar constraint is exceeded
            for p_bar in data.P_bar 
                if temp_sol.k[p_bar] > 0
                    temp_sol = deepcopy(sol)
                    valid = false
                    break
                end
            end
        end

        if !valid
            continue
        end

        it += 1
        best_it += 1

        # Update repair time
        time_repair[selected_repair] += elapsed_repair
        num_repair[selected_repair] += 1

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
        append!(prob_destroy_t, prob_destroy)
        append!(prob_repair_t, prob_repair)

        rho_destroy[selected_destroy] = gamma*rho_destroy[selected_destroy] + (1-gamma)*w
        rho_repair[selected_repair] = gamma*rho_repair[selected_repair] + (1-gamma)*w
        T = alpha * T
     
    end
    prob_destroy_t = reshape(prob_destroy_t, length(num_destroy),:)
    prob_repair_t = reshape(prob_repair_t, length(num_repair),:)
    return best_sol, (prob_destroy=prob_destroy, prob_repair=prob_repair, destroys=destroys,  prob_destroy_t = prob_destroy_t,
    prob_repair_t = prob_repair_t, repairs=repairs, current_obj=current_obj, current_best=current_best, status=status, 
    time_repair=time_repair, time_destroy=time_destroy, num_repair=num_repair, num_destroy=num_destroy, destroy_names = destroy_names, repair_names = repair_names)
end