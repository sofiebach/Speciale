include("ConstructionHeuristics.jl")


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

    # Check if p1 can be placed at time t2 instead of p2
    if !checkReplace(data, sol, t2, p2, p1)
        return false
    end

    # Check if p2 can be placed at time t1 instead of p1
    if !checkReplace(data, sol, t1, p1, p2)
        return false
    end

    return true
end

function swap(data, sol, t1, p1, t2, p2)
    remove(data, sol, t1, p1)
    remove(data, sol, t2, p2)
    insert(data, sol, t1, p2)
    insert(data, sol, t2, p1)
end

