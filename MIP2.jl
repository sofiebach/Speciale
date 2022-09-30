using JuMP, Gurobi
 
# Make a limit for how many campaigns of each type at each timestep
function MIP2(data, time_limit)
    if time_limit > 0
        model = Model(optimizer_with_attributes(Gurobi.Optimizer, "TimeLimit" => time_limit))
    else
        model = Model(optimizer_with_attributes(Gurobi.Optimizer))
    end

    @variable(model, x[1:data.T, 1:data.P] >= 0, Int)
    @variable(model, f[1:data.T,1:data.M] >= 0) # freelance hours
    @variable(model, k[1:data.P] >= 0, Int)
    @variable(model, x_max[1:data.P], Int)
    @variable(model, x_min[1:data.P], Int)

    @objective(model, Min, sum(k[p]*data.penalty_S[p] for p = 1:data.P))
    @constraint(model, [p = 1:data.P, t = 1:data.T], x_max[p] >= x[t,p])
    @constraint(model, [p = 1:data.P, t = 1:data.T], x_min[p] <= x[t,p])

    #It is not possible to slack on Flagskib DR1 and DR2 (p=1 and p=8)
    @constraint(model, [p in [1,8]], k[p] == 0)

    # Nothing can be planned before start and after stop
    @constraint(model, [t = 1:(data.start - 1)], sum(x[t,p] for p = 1:data.P) == 0)
    @constraint(model, [t = (data.stop + 1):data.T], sum(x[t,p] for p = 1:data.P) == 0)

    # Maximum number of campaigns for each timestep
    @constraint(model, [t = data.start:data.stop, p = 1:data.P], sum(x[t,p]) <= round(data.S[p]/data.timeperiod) + 1)

    # Inventory constraint
    @constraint(model, [t=1:data.T, c=1:data.C], sum(data.u[t-t2+data.L_zero,p,c]*x[t2,p] for p = 1:data.P for t2 = max(t-data.L_upper, data.start):min(data.stop,t-data.L_lower)) <= data.I[t,c])

    # Staff from t = start:stop
    @constraint(model, [t=1:data.T, m=1:data.M], sum(data.w[p,m] * x[t2,p] for p=1:data.P for t2 = max(t-data.Q_upper, data.start):min(data.stop,t-data.Q_lower)) <= data.H[t,m] + f[t,m]) 

    # Maximum number of freelancers
    @constraint(model, [m = 1:data.M], sum(f[t,m] for t = 1:data.T) <= data.F[m]) 

    # Scope constraint
    @constraint(model, [p=1:data.P], sum(x[t,p] for t = data.start:data.stop) >= data.S[p] - k[p])

    JuMP.optimize!(model)

    # Create solution object
    sol = Sol(data.T,data.P,data.M)
    sol.obj = objective_value(model)
    for p = 1:sol.P
        if JuMP.value(k[p]) > 0.5
            sol.k[p] = JuMP.value(k[p])
        end
        for t = 1:sol.T
            if JuMP.value(x[t,p]) > 0.5
                sol.x[t,p] = JuMP.value(x[t,p])
            end
        end
    end
    sol.num_campaigns = sum(sol.x)
    for t = 1:sol.T
        for m = 1:sol.M
            if JuMP.value(f[t,m]) > 0.5
                sol.f[t,m] = JuMP.value(f[t,m])
            end
        end
    end
    return sol
end