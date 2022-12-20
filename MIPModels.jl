using JuMP, Gurobi
import HiGHS

genv = Gurobi.Env()

function MIPBaseline(data, solver, log=1, time_limit=60, gap=0)
    if solver == "Gurobi"
        model = Model(optimizer_with_attributes(() -> Gurobi.Optimizer(genv)))
    elseif solver == "HiGHS"
        model = Model(optimizer_with_attributes(() -> HiGHS.Optimizer()))
    else
        println("Input valid solver")
        return
    end
    
    if log  == 0
        set_silent(model)
    end

    if time_limit > 0
        if solver == "Gurobi"
            set_optimizer_attribute(model, "TimeLimit", time_limit)
            set_optimizer_attribute(model, "Threads", 4)
        else
            set_optimizer_attribute(model, "time_limit", time_limit*1.0)
        end
    elseif gap > 0
        set_optimizer_attribute(model,"MIPGap", gap)
    end

    @variable(model, x[1:data.T, 1:data.P] >= 0, Int)
    @variable(model, f[1:data.T,1:data.M] >= 0) 
    @variable(model, k[1:data.P] >= 0, Int)
    
    @objective(model, Min, sum(k[p]*data.penalty_S[p] for p = 1:data.P))

    # Nothing can be planned before start and after stop
    @constraint(model, [t = 1:(data.start - 1)], sum(x[t,p] for p = 1:data.P) == 0)
    @constraint(model, [t = (data.stop + 1):data.T], sum(x[t,p] for p = 1:data.P) == 0)

    # Inventory constraint
    @constraint(model, [t=1:data.T, c=1:data.C], sum(data.u[t-t2+data.L_zero,p,c]*x[t2,p] for p = 1:data.P for t2 = max(t-data.L_upper, data.start):min(data.stop,t-data.L_lower)) <= data.I[t,c])

    # Production constraint
    @constraint(model, [t=1:data.T, m=1:data.M], sum(data.w[p,m] * x[t2,p] for p=1:data.P for t2 = max(t-data.Q_upper, data.start):min(data.stop,t-data.Q_lower)) <= data.H[t,m] + f[t,m]) 

    # Maximum number of freelancers (four weeks per media)
    @constraint(model, [m = 1:data.M], sum(f[t,m] for t = 1:data.T) <= data.F[m]) 

    # Scope constraint
    @constraint(model, [p=1:data.P], sum(x[t,p] for t = data.start:data.stop) >= data.S[p] - k[p])

    # Do not plan more than in scope
    @constraint(model, [p=1:data.P], sum(x[t,p] for t = data.start:data.stop) <= data.S[p])

    JuMP.optimize!(model)

    if primal_status(model) != FEASIBLE_POINT
        return 0, 0 
    end

    x1 = zeros(Int64, data.T, data.P)
    for t = 1:data.T, p = 1:data.P
        if JuMP.value(x[t,p]) > 0.5
            x1[t,p] = Int64(round(JuMP.value(x[t,p])))
        end
    end
    return x1, dual_objective_value(model)
end


function MIPExtended(data, solver, log=1, time_limit=60, solution_limit=0, destroyed_sol=0)
    if solver == "Gurobi"
        model = Model(optimizer_with_attributes(() -> Gurobi.Optimizer(genv)))
    elseif solver == "HiGHS"
        model = Model(optimizer_with_attributes(() -> HiGHS.Optimizer()))
    else
        println("Input valid solver")
        return
    end
    
    if log  == 0
        set_silent(model)
    end

    if time_limit > 0
        if solver == "Gurobi"
            set_optimizer_attribute(model, "TimeLimit", time_limit)
            set_optimizer_attribute(model, "Threads", 4)
        else
            set_optimizer_attribute(model, "time_limit", time_limit*1.0)
        end
    elseif solution_limit > 0
        set_optimizer_attribute(model,"SolutionLimit", solution_limit)
    end

    @variable(model, x[1:data.T, p = 1:data.P, 1:data.S[p]], Bin)   # We can't have more than scope of each priority for now
    @variable(model, f[1:data.T,1:data.M] >= 0)                     # Freelance hours
    @variable(model, k[1:data.P] >= 0, Int)                         # Slack for scope
    @variable(model, L[1:data.P] >= 0, Int)                         # Idle time for each priority
    @variable(model, z[1:data.P], Bin)                              # Constraining min idle time
    @variable(model, g[1:data.T, 1:data.P] >= 0, Int)               # Slack for maximum campaigns per week
    @variable(model, y[1:data.P] >= 0)                              # Slack for too large idle time

    M_T = data.timeperiod
    M_S = 2
    epsilon = 0.5

    @objective(model, Min, 
        data.lambda * sum(data.penalty_S[p] * k[p] for p = 1:data.P) +                     # Penalty for not fulfilled Scope
        (1-data.lambda) * (sum(data.penalty_g[p] * g[t,p] for t=1:data.T, p=1:data.P) +    # Penalty for stacking
        sum(data.weight_idle[p] * (-L[p]+y[p]) + 1 for p=1:data.P))                        # Penalty for no spreading
    )

    # Nothing can be planned before start and after stop
    @constraint(model, [t = 1:(data.start - 1)], sum(sum(x[t,p,n] for n=1:data.S[p]) for p = 1:data.P) == 0)
    @constraint(model, [t = (data.stop + 1):data.T], sum(sum(x[t,p,n] for n=1:data.S[p]) for p = 1:data.P) == 0)

    # Inventory constraint
    @constraint(model, [t=1:data.T, c=1:data.C], sum(data.u[t-t2+data.L_zero,p,c]*sum(x[t2,p,n] for n=1:data.S[p]) for p = 1:data.P for t2 = max(t-data.L_upper, data.start):min(data.stop,t-data.L_lower)) <= data.I[t,c])

    # Production constraint
    @constraint(model, [t=1:data.T, m=1:data.M], sum(data.w[p,m] * sum(x[t2,p,n] for n=1:data.S[p]) for p=1:data.P for t2 = max(t-data.Q_upper, data.start):min(data.stop,t-data.Q_lower)) <= data.H[t,m] + f[t,m]) 

    # Maximum number of freelancers (four weeks per media)
    @constraint(model, [m = 1:data.M], sum(f[t,m] for t = 1:data.T) <= data.F[m]) 

    # Scope constraint
    @constraint(model, [p=1:data.P], sum(sum(x[t,p,n] for n=1:data.S[p]) for t = data.start:data.stop) >= data.S[p] - k[p])

    # Upper limit of x_priority
    @constraint(model, [p=1:data.P, n = 1:data.S[p]], sum(x[t,p,n] for t=1:data.T) <= 1)
    
    # Make order of n 
    @constraint(model, [p=1:data.P, n=1:(data.S[p]-1)], sum(x[t,p,n] * t for t=1:data.T) <= sum(x[t,p,n+1] * t for t=1:data.T))

    # Make idle time
    @constraint(model, [p=1:data.P, n=1:(data.S[p]-1)], sum(x[t,p,n+1] * t for t=1:data.T) - sum(x[t,p,n] * t for t=1:data.T) + M_T*(1 - sum(x[t,p,n] for t=1:data.T)) >= L[p] )

    # Activate z
    @constraint(model, [p=1:data.P], 1-sum(x[t,p,n] for t=1:data.T, n=1:data.S[p]) <= M_S * z[p] - epsilon * (1-z[p]))

    # Constraint L 
    @constraint(model, [p=1:data.P], (1 - z[p]) * M_T >= L[p])

    # Number of campaigns per week
    @constraint(model, [p=1:data.P, t=1:data.T], sum(x[t,p,n] for n=1:data.S[p]) <= data.aimed_g[p] + g[t,p])

    # Activate y
    @constraint(model, [p=1:data.P], L[p] <= data.aimed_L[p] + y[p])

    JuMP.optimize!(model)

    if primal_status(model) != FEASIBLE_POINT
        return 0, 0
    end
    primal_status(model)

    x1 = zeros(Int64, data.T, data.P)
    for t = 1:data.T, p = 1:data.P
        if JuMP.value(sum(x[t,p,:])) > 0.5
            x1[t,p] = Int64(round(JuMP.value(sum(x[t,p,n] for n=1:data.S[p]))))
        end
    end

    return x1, dual_objective_value(model)
end

function MIPpriority(data, p, xp, log=0, time_limit=10)
    model = Model(optimizer_with_attributes(() -> HiGHS.Optimizer()))
    set_optimizer_attribute(model, "time_limit", time_limit*1.0)
    if log  == 0
        set_silent(model)
    end

    @variable(model, x[1:data.T, 1:data.S[p]], Bin)     # We can't have more than scope of each priority for now
    @variable(model, f[1:data.T,1:data.M] >= 0)         # Freelance hours
    @variable(model, k >= 0, Int)                       # Slack for scope
    @variable(model, L >= 0, Int)                       # Idle time for each priority
    @variable(model, z, Bin)                            # Constraining min idle time
    @variable(model, g[1:data.T] >= 0, Int)             # Slack for maximum campaigns per week
    @variable(model, y >= 0)                            # Slack for too large idle time

    M_T = data.T + 1
    M_S = data.S[p] + 1
    epsilon = 0.5
    lambda = 3/4

    @objective(model, Min, 
        lambda * (data.penalty_S[p]*k +                  # Penalty for not fulfilled Scope
        data.penalty_g[p] * sum(g[t] for t=1:data.T)) -  # Penalty for stacking
        (1-lambda) * (data.weight_idle[p] * L +          # Reward for spreading
        data.weight_idle[p] * y)                         # Penalty for spreading too much
    )

    for t = data.start:data.stop
        if xp[t] > 0
            @constraint(model, sum(x[t,n] for n=1:data.S[p]) >= xp[t])
        end
    end

    # Nothing can be planned before start and after stop
    @constraint(model, [t = 1:(data.start - 1)], sum(x[t,n] for n=1:data.S[p]) == 0)
    @constraint(model, [t = (data.stop + 1):data.T], sum(x[t,n] for n=1:data.S[p]) == 0)

    # Inventory constraint
    @constraint(model, [t=1:data.T, c=1:data.C], sum(data.u[t-t2+data.L_zero,p,c]*sum(x[t2,n] for n=1:data.S[p]) for t2 = max(t-data.L_upper, data.start):min(data.stop,t-data.L_lower)) <= data.I[t,c])

    # Production constraint
    @constraint(model, [t=1:data.T, m=1:data.M], sum(data.w[p,m] * sum(x[t2,n] for n=1:data.S[p]) for t2 = max(t-data.Q_upper, data.start):min(data.stop,t-data.Q_lower)) <= data.H[t,m] + f[t,m]) 

    # Maximum number of freelancers (four weeks per media)
    @constraint(model, [m = 1:data.M], sum(f[t,m] for t = 1:data.T) <= data.F[m]) 

    # Scope constraint
    @constraint(model, sum(x[t,n] for n=1:data.S[p] for t = data.start:data.stop) >= data.S[p] - k)

    # Upper limit of x_priority
    @constraint(model, [n = 1:data.S[p]], sum(x[t,n] for t=1:data.T) <= 1)
    
    # Make order of n 
    @constraint(model, [n=1:(data.S[p]-1)], sum(x[t,n] * t for t=1:data.T) <= sum(x[t,n+1] * t for t=1:data.T))

    # Make idle time
    @constraint(model, [n=1:(data.S[p]-1)], sum(x[t,n+1] * t for t=1:data.T) - sum(x[t,n] * t for t=1:data.T) + M_T*(1 - sum(x[t,n] for t=1:data.T)) >= L)

    # Activate z
    @constraint(model, 1-sum(x[t,n] for t=1:data.T, n=1:data.S[p]) <= M_S * z - epsilon * (1-z))

    # Constraint L 
    @constraint(model, (1 - z) * M_T >= L)

    # Number of campaigns per week
    @constraint(model, [t=1:data.T], sum(x[t,n] for n=1:data.S[p]) <= data.aimed_g[p] + g[t])

    # Activate y
    @constraint(model, L <= data.aimed_L[p] + y)

    JuMP.optimize!(model)

    if primal_status(model) != FEASIBLE_POINT
        return 0
    end

    x1 = zeros(Int64, data.T)
    for t = 1:data.T
        if JuMP.value(sum(x[t,:])) > 0.5
            x1[t] = Int64(round(JuMP.value(sum(x[t,n] for n=1:data.S[p]))))
        end
    end

    return x1

end