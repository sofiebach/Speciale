using JuMP, Gurobi

include("ReadWrite.jl")

filename = "simulated_data/data.txt"

P,C,timeperiod,L_lower,L_upper,L,L_zero,Q_lower,Q_upper,Q,start,stop,T,S,w,H,I,u = readInstance(filename)

model = Model(Gurobi.Optimizer)

@variable(model, x[1:T, 1:P] >= 0, Int)
@variable(model, f[1:P] >= 0, Int)

@objective(model, Max, sum(x[t,p] for t = start:stop for p = 1:P) - sum(f[p] for p = 1:P))

@constraint(model, [t = 1:(start - 1)], sum(x[t,p] for p = 1:P) == 0)
@constraint(model, [t = (stop + 1):T], sum(x[t,p] for p = 1:P) == 0)

# Inventory from t = start:stop
@constraint(model, [t=start:stop, c = 1:C], sum(u[l,p,c] * x[t-L[l],p] for l = 1:length(L) for p = 1:P) <= I[t,c])
# Inventory for boundaries
@constraint(model, [t=(stop+1):T, c = 1:C], sum(u[l,p,c] * x[t-L[l],p] for l = (L_zero + 1):length(L) for p = 1:P) <= I[t,c])
@constraint(model, [t=1:start-1, c = 1:C], sum(u[l,p,c] * x[t-L[l],p] for l = 1:(L_zero - 1) for p = 1:P) <= I[t,c])

# Staff from t = start:stop
@constraint(model, [t=1:(stop+Q_upper)], sum(w[p] * x[t-Q[q],p] for p=1:P for q = 1:length(Q)) <= H[t])

@constraint(model, [p=1:P], sum(x[t,p] for t = start:stop) >= S[p] - f[p])

JuMP.optimize!(model)

function print_solution(model)
    println("Objective: ", objective_value(model))
    sol = zeros(Int, T, P)
    for t = 1:T
        for p = 1:P
            if JuMP.value(x[t,p]) > 0.5
                println("At time ", t, " we have prioritet ", p, " with value: ", JuMP.value(x[t,p]))
                sol[t,p] = JuMP.value(x[t,p])
            end
        end
    end

    for p = 1:P
        if JuMP.value(f[p]) > 0
            println("Penalty for priority ", p , " with value: ", JuMP.value(f[p]))
        end
    end

    return sol
end

sol = print_solution(model)

writeSolution("output/solution.txt", sol, P, C, timeperiod,L_lower,L_upper,L_zero,Q_lower,Q_upper, start, stop, T)