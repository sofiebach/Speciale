using JuMP, Gurobi

include("ReadWrite.jl")

# filename = "simulated_data/data.txt"
# data = readInstance(filename)
data = read_DR_data()

GRP_matrix = zeros(Float64, data.T, data.T, data.P, data.C)
for t_col = data.start:data.stop
    row_start = t_col + data.L_lower
    row_stop = min(data.T, row_start + length(data.L) - 1)
    for t_row = row_start:row_stop
        for c = 1:data.C
            for p = 1:data.P
                l = data.L_zero + t_row-t_col
                GRP_matrix[t_row, t_col, p, c] = data.u[l,p,c]
            end
        end
    end
end

model = Model(optimizer_with_attributes(Gurobi.Optimizer, "TimeLimit" => 60))

@variable(model, x[1:data.T, 1:data.P] >= 0, Int)
@variable(model, f[1:data.T,1:data.M] >= 0, Int)
@variable(model, k[1:data.P] >= 0, Int)
penalty_scope = 50
penalty_freelancer = 10
@objective(model, Max, sum(x[t,p] for t = data.start:data.stop for p = 1:data.P) - penalty_scope*sum(k[p] for p = 1:data.P) - penalty_freelancer*sum(f[t,m] for t = 1:data.T for m = 1:data.M))

@constraint(model, [t = 1:(data.start - 1)], sum(x[t,p] for p = 1:data.P) == 0)
@constraint(model, [t = (data.stop + 1):data.T], sum(x[t,p] for p = 1:data.P) == 0)

# Inventory from t = start:stop
@constraint(model, [t=1:data.T, c=1:data.C], sum(GRP_matrix[t,t2,p,c]*x[t2,p] for t2=1:data.T for p=1:data.P) <= data.I[t,c])
# @constraint(model, [t=(start+1):(stop-1), c = 1:C], sum(u[l,p,c] * x[t-L[l],p] for l = 1:length(L) for p = 1:P) <= I[t,c])
# Inventory for boundaries
# @constraint(model, [t=stop:T, c = 1:C], sum(u[l,p,c] * x[t-L[l],p] for l = (t - stop + L_zero):length(L) for p = 1:P) <= I[t,c])
# @constraint(model, [t=1:start, c = 1:C], sum(u[l,p,c] * x[t-L[l],p] for l = 1:(t - 1 + L_zero) for p = 1:P) <= I[t,c])

# Staff from t = start:stop
@constraint(model, [t=1:(data.stop+data.Q_upper), m=1:data.M], sum(data.w[p,m] * x[t-data.Q[q],p] for p=1:data.P for q = 1:length(data.Q)) <= data.H[t,m] + 7*3.5*f[t,m]) # freelancer * 7 hours * 3,5 days (avg days per week) 

# Scope constraint
@constraint(model, [p=1:data.P], sum(x[t,p] for t = data.start:data.stop) >= data.S[p] - k[p])

JuMP.optimize!(model)

sol = Sol(data.T,data.P,data.M)

function print_solution(model, sol)
    println("Objective: ", objective_value(model))
    sol.obj = objective_value(model)
    for p = 1:sol.P
        for t = 1:sol.T
            if JuMP.value(x[t,p]) > 0.5
                #println("At time ", t, " we have priority ", p, " with value: ", JuMP.value(x[t,p]))
                sol.x[t,p] = JuMP.value(x[t,p])
            end
        end
        println("Priority ", p, " is scheduled ", sum(sol.x[:,p]), " times")
    end

    for p = 1:sol.P
        if JuMP.value(k[p]) > 0.5
            sol.k[p] = JuMP.value(k[p])
            println("Penalty for priority ", p , " with value: ", sol.k[p])
        end
    end
    for t = 1:sol.T
        for m = 1:sol.M
            if JuMP.value(f[t,m]) > 0.5
                sol.f[t,m] = JuMP.value(f[t,m])
                #println("Number of freelance for media ", m , " at time ", t, ": ", sol.f[t,m])
            end
        end
    end
    println("Number of freelancers: ", sum(sol.f))
    println("Number of campaigns: ", sum(sol.x))
    return sol
end

sol = print_solution(model,sol)

writeSolution("output/solution.txt", data, sol)

#data1, sol1 = readSolution("output/solution.txt")