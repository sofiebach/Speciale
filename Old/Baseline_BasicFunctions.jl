using Random
using Statistics
include("MIPModel.jl")

function insert!(data, sol, t, p)
    sol.x[t,p] += 1
    sol.num_campaigns += 1

    # update inventory
    l_idx = 1
    for t_hat = (t+data.L_lower):(t+data.L_upper)
        for c = 1:data.C
            sol.I_cap[t_hat, c] -= data.u[l_idx,p,c]
        end
        l_idx += 1
    end

    # update production
    for m = 1:data.M
        for t_hat = (t+data.Q_lower):(t+data.Q_upper)
            sol.H_cap[t_hat, m] -= data.w[p, m]
            if sol.H_cap[t_hat, m] < 0
                sol.f[t_hat, m] = -sol.H_cap[t_hat, m]
            end
        end
    end

    # update scope
    if sol.k[p] > 0
        sol.k[p] -= 1
    end

    findObjective!(data, sol)
end

function MIPtoSol(data, x)
    sol = Sol(data)
    for t = 1:data.T, p = 1:data.P
        for n = 1:x[t,p]
            insert!(data, sol, t, p)
        end
    end
    return sol
end

function remove!(data, sol, t, p)
    sol.x[t,p] -= 1
    sol.num_campaigns -= 1
    
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
                sol.f[t_hat, m] = -sol.H_cap[t_hat, m]
            else
                sol.f[t_hat,m] = 0
            end
        end
    end

    # update scope
    if sum(sol.x[:,p]) < data.S[p]
        sol.k[p] += 1
    else 
        sol.k[p] = 0
    end

    # update objective
    findObjective!(data, sol)
end

function fits(data, sol, t, p)
    if t < data.start || t > data.stop
        println("Select t between start and stop.")
        return false
    end

    l_idx = 1
    for t_hat = (t+data.L_lower):(t+data.L_upper)
        for c = 1:data.C
            grp = data.u[l_idx,p,c]
            if sol.I_cap[t_hat, c] - grp < 0
                return false
            end
        end
        l_idx += 1
    end

    for m = 1:data.M
        freelancers_needed = 0
        for t_hat = (t+data.Q_lower):(t+data.Q_upper) 
            if sol.H_cap[t_hat, m] - data.w[p, m] < 0
                freelancers_needed += -(sol.H_cap[t_hat, m] - data.w[p, m])
                if sum(sol.f[:,m]) + freelancers_needed > data.F[m] 
                    return false
                end
            end
        end
    end    
    
    return true
end

function findObjective!(data, sol)
    num_campaigns = sum(sum(sol.x, dims=1) .* transpose(data.reward))
    scope = sum(data.penalty_S .* sol.k)
    # freelance = sum(sum(sol.f, dims=1) .* data.penalty_f)
    sol.obj =  scope - num_campaigns
end

function randomInsert!(data, sol, priorities)
    for p in priorities
        r_times = shuffle(collect(data.start:data.stop))
        for n = 1:data.S[p], t in r_times
            if sol.k[p] == 0
                break
            end
            if fits(data, sol, t, p)
                insert!(data, sol, t, p)
            end
        end
    end
end

function delta_insert(data, sol, p)
    if sol.k[p] > 0
        return sol.obj - data.penalty_S[p] - data.reward[p]
    else
        return sol.obj - data.reward[p]
    end
end

function delta_remove(data, sol, p)
    if sum(sol.x[:,p])-1 < data.S[p]
        return sol.obj + data.penalty_S[p] + data.reward[p]
    else
        return sol.obj + data.reward[p]
    end
end

function elapsed_time(start_time)
    return round((time_ns()-start_time)/1e9, digits = 3)
end

function findSimilarity(data)
    sim = zeros(data.P, data.P)
    for p1 = 1:(data.P-1)
        for p2 = (p1+1):data.P
            sim_u = PearsonSimilarity(data.u[:,p1,:], data.u[:,p2,:])
            sim_w = PearsonSimilarity(data.w[p1,:], data.w[p2,:])

            sim[p1,p2] = mean([sim_u, sim_w])
            sim[p2,p1] = mean([sim_u, sim_w])
        end 
    end
    return sim
end

function PearsonSimilarity(a, b)
    mu_a =  mean(a)
    mu_b = mean(b)
    t = (sum((a.-mu_a).*(b.-mu_b)))
    n = sqrt(sum((a.-mu_a).^2))*sqrt(sum((b.-mu_b).^2))
    return t/n
end
