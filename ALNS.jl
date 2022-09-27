include("ConstructionHeuristics.jl")
include("ValidateSolution.jl")

function destroy(data, sol, frac)
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
end


function remove(data, sol, t, p)
    sol.x[t,p] -= 1
    sol.num_campaigns -= 1
    
    # update k
    if sum(sol.x[:,p]) < data.S[p]
        sol.k[p] += 1
    end
    
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
                sol.f[t_hat, m] = Int(ceil(-sol.H_cap[t_hat, m])) 
            else
                sol.f[t_hat,m] = 0
            end
        end
    end

    # update objective
    findObjective(data, sol)
end


function firstFits(data, sol) 
    # prioritize priorities with highest penalty
    sorted_idx = sortperm(-data.penalty_S)
    for p in sorted_idx
        for n = 1:sol.k[p]
            inserted = false
            r_times = shuffle(collect(data.start:data.stop))
            for t in r_times
                if fits(data,sol,t,p)
                    insert(data,sol,t,p)
                    inserted = true
                    break
                end
            end
            if !inserted
                break
            end
        end
    end
end



function LNS(data)
    sol = randomInitial(data)
    
    frac = 0.2
    destroy(data,sol,frac)
    
    firstFits(data,sol)
    
end

P = 37
data = read_DR_data(P)

sol = randomInitial(data)

checkSolution(data,sol)

LNS(data)

checkSolution(data,sol)