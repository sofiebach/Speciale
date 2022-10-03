include("ConstructionHeuristics.jl")
include("ALNS.jl")

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

function swap(data, sol, t1, p1, t2, p2)
    remove(data, sol, t1, p1)
    
    # if !checkSolution(data, sol)
    #     println("Insert: ", p2, " at ", t1)
    # end
    
    remove(data, sol, t2, p2)
    insert(data, sol, t2, p1)
    insert(data, sol, t1, p2)
    # if !checkSolution(data, sol)
    #     println("Insert: ", p1, " at ", t2)
    # end
    
end


function greedyInsert(data, sol)
    # loops through all timesteps and checks if it is possible to insert another priority
    for t = data.start:data.stop
        sorted_idx = sortperm(-data.penalty_S)
        for p in sorted_idx
            if sol.k[p] > 0
                if fits(data,sol,t,p) 
                    insert(data,sol,t,p)
                end
            end
        end
    end
end


function swapInsert(data, sol)
    best_sol = deepcopy(sol)
    temp_sol = deepcopy(sol)
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
                        swap(data, temp_sol, t1, p1, t2, p2)
                        if !checkSolution(data, temp_sol)
                            return
                        end
                        # greedyInsert(data, temp_sol)
                        if temp_sol.obj < best_sol.obj
                            best_sol = deepcopy(temp_sol)
                            #println("new obj: ", best_sol.obj)
                            #println("campaigns: ", best_sol.num_campaigns)
                        else 
                            temp_sol = deepcopy(sol)
                        end
                    end
                end
            end
        end
    end
end

function test(data, sol)
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
                        println("swapped")
                        swap(data, sol, t1, p1, t2, p2)
                        if !checkSolution(data,sol)
                            return
                        end
                        greedyInsert(data, sol)
                    end
                end
            end
        end
    end
end


P = 37
data = read_DR_data(P)

sol = randomInitial(data)
checkSolution(data,sol)

test(data,sol)
# checkSolution(data,sol)

# swapInsert(data, sol)
# inventory_used, staffing_used = checkSolution(data,sol)
sol = randomInitial(data)
println(sum(sol.f,dims=1))
swap(data, sol, 10, 1, 20, 2)
println(sum(sol.f,dims=1))
swap(data, sol, 10, 2, 20, 1)
println(sum(sol.f,dims=1))