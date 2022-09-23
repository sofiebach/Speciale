using JuMP, Gurobi


function Baseline(data, time_limit)
    if time_limit > 0
        model = Model(optimizer_with_attributes(Gurobi.Optimizer, "TimeLimit" => time_limit))
    else
        model = Model(optimizer_with_attributes(Gurobi.Optimizer))
    end

    @variable(model, x[1:data.T, 1:data.P] >= 0, Int)
    @variable(model, f[1:data.T,1:data.M] >= 0, Int)
    @variable(model, k[1:data.P] >= 0, Int)

    b = vcat(1:10,12)
    penalty_scope = round.(sum(sum(data.u[:,:,b], dims=1),dims=3)) # 1:10 to not include SOME and Banner

    @objective(model, Max, sum(x[t,p] for t = data.start:data.stop for p = 1:data.P) - sum(k[p]*penalty_scope[p] for p = 1:data.P))

    # Nothing can be planned before start and after stop
    @constraint(model, [t = 1:(data.start - 1)], sum(x[t,p] for p = 1:data.P) == 0)
    @constraint(model, [t = (data.stop + 1):data.T], sum(x[t,p] for p = 1:data.P) == 0)

    # Force freelance hours to be 0
    @constraint(model, [t = 1:data.T, m = 1:data.M], f[t,m] == 0)

    # Inventory constraint
    @constraint(model, [t=1:data.T, c=1:data.C], sum(data.u[t-t2+data.L_zero,p,c]*x[t2,p] for p = 1:data.P for t2 = max(t-data.L_upper, data.start):min(data.stop,t-data.L_lower)) <= data.I[t,c])

    # Staff from t = start:stop
    @constraint(model, [t=1:data.T, m=1:data.M], sum(data.w[p,m] * x[t2,p] for p=1:data.P for t2 = max(t-data.Q_upper, data.start):min(data.stop,t-data.Q_lower)) <= data.H[t,m]) 

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
    for t = 1:sol.T
        for m = 1:sol.M
            if JuMP.value(f[t,m]) > 0.5
                sol.f[t,m] = JuMP.value(f[t,m])
            end
        end
    end
    return sol
end


include("ReadWrite.jl")
include("MIPModel.jl")
include("ValidateSolution.jl")
include("PlotSolution.jl")

P = 37
data = read_DR_data(P)

sol = Baseline(data, 60)

print_solution(sol)

checkSolution(data,sol)

drawSolution(data, sol, "baseline")

drawHeatmap(data,sol, "baseline")