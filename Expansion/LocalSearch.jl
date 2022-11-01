include("ConstructionHeuristics_expanded.jl")
include("HeuristicFunctions.jl")

function swapInsert(data, sol)
    best_sol = deepcopy(sol)
    temp_sol = deepcopy(sol)
    c = 1
    for t1 = data.start:(data.stop-1)
        P1 = findall(x->x>0, temp_sol.x[t1,:])
        if length(P1) == 0
            continue
        end
        for t2 = (t1+1):data.stop
            P2 = findall(x->x>0, temp_sol.x[t2,:])
            if length(P2) == 0
                continue
            end
            for p1 in P1
                for p2 in P2 
                    if checkSwap(data, temp_sol, t1, p1, t2, p2)
                        temp_obj = delta_swap(temp_sol, t1, p1, t2, p2)
                        # println("delta: ", delta_swap(temp_sol, t1, p1, t2, p2))
                        # swap!(data, temp_sol, t1, p1, t2, p2)
                        # println("swap: ", temp_sol.obj)
                        if temp_obj < best_sol.obj
                            swap!(data, temp_sol, t1, p1, t2, p2)
                            best_sol = deepcopy(temp_sol)
                            println("new obj: ", best_sol.obj)
                            println("campaigns: ", best_sol.num_campaigns)
                        else 
                            temp_sol = deepcopy(sol)
                        end
                    end
                end
            end
        end
    end
    return best_sol
end


