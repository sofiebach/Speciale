include("ConstructionHeuristics.jl")
include("ALNS.jl")

function checkReplace(data, sol, t1, p1, p2)
    # checks if p2 can be placed at t1 INSTEAD of p1
    if t1 < data.start || t1 > data.stop 
        println("Select t between start and stop.")
        return false
    end

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
    for t_hat = (t1+data.Q_lower):(t1+data.Q_upper) 
        for m = 1:data.M
            work_p1 = data.w[p1, m]
            work_p2 = data.w[p2, m]
            extra_work = work_p2 - work_p1
            if extra_work > 0
                if sol.H_cap[t_hat, m] + extra_work < 0 # then we need freelancers
                    if sum(sol.f[:,m]) + extra_work > data.F[m] 
                        return false
                    end
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


    # if (t1+data.L_upper) < (t2+data.L_lower)
    #     # checkReplace
    # end
    l_idx1 = 0
    l_idx2 = 0
    for t_hat = (t1+data.L_lower):(t2+data.L_upper)
        if t_hat > t1+data.L_upper
            l_idx1 = 0
        else
            l_idx1 += 1
        end
        if t_hat < t2+data.L_lower
            l_idx2 = 0
        else
            l_idx2 += 1
        end

        for c = 1:data.C
            if l_idx1 > 0
                old_grp_p1 = data.u[l_idx1,p1,c]
                new_grp_p2 = data.u[l_idx1,p2,c]
            else
                old_grp_p1 = 0
                new_grp_p2 = 0
            end
            if l_idx2 > 0
                old_grp_p2 = data.u[l_idx2,p2,c]
                new_grp_p1 = data.u[l_idx2,p1,c]
            else
                old_grp_p2 = 0
                new_grp_p1 = 0
            end

            if sol.I_cap[t_hat, c] + old_grp_p1 + old_grp_p2 - new_grp_p2 - new_grp_p1 < 0 
                return false
            end
        end  
    end
 
    return true
end

function swap(data, sol, t1, p1, t2, p2)
    remove(data, sol, t1, p1)
    remove(data, sol, t2, p2)
    insert(data, sol, t1, p2)
    insert(data, sol, t2, p1)
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
                        greedyInsert(data, temp_sol)
                        if temp_sol.obj < sol.obj
                            swap(data, sol, t1, p1, t2, p2)
                            greedyInsert(data, sol)
                            #println("new obj: ", sol.obj)
                            println("campaigns: ", sol.num_campaigns)
                        else 
                            temp_sol = deepcopy(sol)
                        end
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

swapInsert(data, sol)
checkSolution(data,sol)
