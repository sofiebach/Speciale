include("ConstructionHeuristics_expanded.jl")
include("HeuristicFunctions.jl")

function ILS(data, time_limit)
    sol = randomInitial(data)
    localSearch!(data, sol)
    start_time = time_ns()

    while elapsed_time(start_time) < time_limit
        temp_sol = deepcopy(sol)
        pertubate!(data, temp_sol)
        localSearch!(data, temp_sol)
        if temp_sol.obj < sol.obj 
            sol = deepcopy(temp_sol)
            println("New best")
            println(sol.obj)
        end
    end

    return sol
end

function pertubate!(data, sol)
    init_sol = deepcopy(sol)
    while true
        valid = true
        randomDestroy!(data, sol, 0.2)
        greedyRepair!(data, sol)
        # Check if P_bar constraint is exceeded
        for p_bar in data.P_bar 
            if sol.k[p_bar] > 0
                sol = deepcopy(init_sol)
                valid = false
                break
            end
        end
        if valid 
            break
        end
    end
end

function localSearch!(data, sol)
    while true
        t1, p1, t2, p2 = firstImprovement(sol)
        if t1 != 0 && t2 != 0 && p1 != 0 && p2 != 0
            swap!(data, sol, t1, p1, t2, p2)
        else
            break
        end
    end
end

function firstImprovement(sol)
    for t1 = data.start:(data.stop-1)
        P1 = findall(x->x>0, sol.x[t1,:])
        if length(P1) == 0
            continue
        end
        for t2 = (t1+1):data.stop
            P2 = findall(x->x>0, sol.x[t2,:])
            if length(P2) == 0
                continue
            end
            for p1 in P1
                for p2 in P2 
                    if checkSwap(data, sol, t1, p1, t2, p2)
                        temp_obj = delta_swap(sol, t1, p1, t2, p2)
                        if temp_obj < sol.obj
                            return t1, p1, t2, p2
                        end
                    end
                end
            end
        end
    end
    return 0, 0, 0, 0
end

