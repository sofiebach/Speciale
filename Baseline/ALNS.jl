include("HeuristicFunctions.jl")
include("ConstructionHeuristics.jl")

using Statistics

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

function ALNS(data,time_limit,T=1000,alpha=0.99,gamma=0.9,frac_cluster=0.1,frac_random=0.1,thres_worst=10,frac_related=0.2)
    it = 1
    best_it = 1
    long_term_update = 1000

    sol = randomInitial(data)
    best_sol = deepcopy(sol)
    temp_sol = deepcopy(sol)
    start_time = time_ns()

    rho_destroy = ones(4)
    prob_destroy = zeros(4)

    rho_repair = ones(3)
    prob_repair = zeros(3)

    prob_destroy = setProb(rho_destroy, prob_destroy)
    prob_repair = setProb(rho_repair, prob_repair)

    w1 = 10
    w2 = 5
    w3 = 1
    w4 = 0

    destroys = []
    repairs = []
    current_obj = []
    current_best = []
    status = []

    while elapsed_time(start_time) < time_limit
        valid = true

        # intensification and diversification
        if best_it > long_term_update
            sol = deepcopy(best_sol)
            println("Intensified!")
            diversify!(data, sol)
            println("Diversified!")
            best_it = 1
        end

        # update probabilities
        if (it % 10 == 0)
            prob_destroy = setProb(rho_destroy, prob_destroy)
            prob_repair = setProb(rho_repair, prob_repair)
        end

        # Choose destroy method
        selected_destroy = selectMethod(prob_destroy)
        if selected_destroy == 1
            frac_cluster = 0.1
            clusterDestroy!(data,temp_sol,frac_cluster)
        elseif selected_destroy == 2
            frac_random = 0.1
            randomDestroy!(data,temp_sol,frac_random)
        elseif selected_destroy == 3
            thres_worst = 10
            worstDestroy!(data,temp_sol,thres_worst)
        else
            frac_related = 0.2
            relatedDestroy!(data, sol, frac_related)
        end
        
        # Choose repair method
        selected_repair = selectMethod(prob_repair)
        
        if selected_repair == 1
            greedyRepair!(data,temp_sol)
            # Check if P_bar constraint is exceeded
            for p_bar in data.P_bar 
                if temp_sol.k[p_bar] > 0
                    temp_sol = deepcopy(sol)
                    valid = false
                    break
                end
            end
        elseif selected_repair == 2
            firstRepair!(data,temp_sol)

            # Check if P_bar constraint is exceeded
            for p_bar in data.P_bar 
                if temp_sol.k[p_bar] > 0
                    temp_sol = deepcopy(sol)
                    valid = false
                    break
                end
            end
        else
            modelRepair!(data,temp_sol)
        end

        if !valid
            continue
        end
        it += 1
        best_it += 1

        append!(repairs, selected_repair)
        append!(destroys, selected_destroy)
        append!(current_obj, temp_sol.obj)

        # Check acceptance criteria
        w = w4
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

function ALNS_uden_modelRepair(data,time_limit,T=1000,alpha=0.99,gamma=0.9,frac_cluster=0.1,frac_random=0.1,thres_worst=10,frac_related=0.2)
    it = 0
    sol = randomInitial(data)
    best_sol = deepcopy(sol)
    temp_sol = deepcopy(sol)
    start_time = time_ns()

    rho_destroy = ones(4)
    rho_repair = ones(2)

    prob_destroy = zeros(4)
    prob_repair = zeros(2)

    prob_destroy = setProb(rho_destroy, prob_destroy)
    prob_repair = setProb(rho_repair, prob_repair)

    w1 = 10
    w2 = 5
    w3 = 1
    w4 = 0

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
            frac_cluster = 0.1
            clusterDestroy!(data,temp_sol,frac_cluster)
        elseif selected_destroy == 2
            frac_random = 0.1
            randomDestroy!(data,temp_sol,frac_random)
        elseif selected_destroy == 3
            thres_worst = 10
            worstDestroy!(data,temp_sol,thres_worst)
        else
            frac_related = 0.2
            relatedDestroy!(data, sol, frac_related)
        end
        
        # Choose repair method
        selected_repair = selectMethod(prob_repair)
        
        if selected_repair == 1
            greedyRepair!(data,temp_sol)
            # Check if P_bar constraint is exceeded
            for p_bar in data.P_bar 
                if temp_sol.k[p_bar] > 0
                    temp_sol = deepcopy(sol)
                    valid = false
                    break
                end
            end
        else
            firstRepair!(data,temp_sol)

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