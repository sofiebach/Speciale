using JuMP, Gurobi
genv = Gurobi.Env()
function MIPExpansion(data, time_limit, logging)
    #if time_limit > 0
    #    model = Model(optimizer_with_attributes(() -> Gurobi.Optimizer(genv), "TimeLimit" => time_limit, "LogToConsole" => logging, "OutputFlag" => logging))
    #else
    #    model = Model(optimizer_with_attributes(Gurobi.Optimizer, "LogToConsole" => logging, "OutputFlag" => logging))
    #end
    model = Model(optimizer_with_attributes(Gurobi.Optimizer, "LogToConsole" => logging, "OutputFlag" => logging, "SolutionLimit" => 1))
    @variable(model, x[1:data.T, p = 1:data.P, 1:data.S[p]], Bin)
    @variable(model, f[1:data.T,1:data.M] >= 0) # freelance hours
    @variable(model, k[1:data.P] >= 0, Int)
    @variable(model, 0 <= L[p = 1:P] <= 100, Int) # Idle time for each priority
    

    @objective(model, Min, -sum(L[p] for p=1:data.P) -sum(data.reward[p]*sum(x[t,p,n] for n=1:data.S[p]) for t = data.start:data.stop for p = 1:data.P) + sum(k[p]*data.penalty_S[p] for p = 1:data.P) + sum(f[t,m]*data.penalty_f[m] for t = 1:data.T for m = 1:data.M))

    #It is not possible to slack on Flagskib DR1 and DR2 (p=1 and p=8)
    @constraint(model, [p in data.P_bar], k[p] == 0)

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

    # Uppder limit of x_priority
    @constraint(model, [p=1:data.P, n = 1:data.S[p]], sum(x[t,p,n] for t=1:data.T) <= 1)
    
    # Make order of n 
    @constraint(model, [p=1:data.P, n=1:(data.S[p]-1)], sum(x[t,p,n] * t for t=1:data.T) <= sum(x[t,p,n+1] * t for t=1:data.T))
>
    # Make idle time
    @constraint(model, [p=1:data.P, n=1:(data.S[p]-1)], sum(x[t,p,n+1] * t for t=1:data.T) - sum(x[t,p,n] * t for t=1:data.T) >= L[p] * sum(x[t,p,n] for t = 1:data.T))


    JuMP.optimize!(model)

    for p = 2:2
        for n = 1:data.S[p]
            println(p, " ", n)
            for t=1:data.T
                print(JuMP.value(x[t,p,n]))
                print(" ")
            end
            println("")
        end
    end 

    for p = 1:data.P
        if JuMP.value(L[p]) > 0.5
            println(p)
            println(JuMP.value(L[p]))
        end
    end


    # Create solution object
    sol = Sol(data.T,data.P,data.M)
    sol.obj = objective_value(model)
    for p = 1:sol.P
        if JuMP.value(k[p]) > 0.5
            sol.k[p] = Int64(round(JuMP.value(k[p])))
        end
        for t = 1:sol.T
            if JuMP.value(sum(x[t,p,n] for n=1:data.S[p])) > 0.5
                sol.x[t,p] = Int64(round(JuMP.value(sum(x[t,p,n] for n=1:data.S[p]))))
            end  
        end
    end
    sol.num_campaigns = sum(sol.x)
    for t = 1:sol.T
        for m = 1:sol.M
            sol.f[t,m] = JuMP.value(f[t,m])
        end
    end
    return sol
end