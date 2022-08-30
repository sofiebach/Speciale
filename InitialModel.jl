using JuMP, GLPK

model = Model(GLPK.Optimizer)

P = [1,2,3,4,5,6] #two priorities, 3 channels #[DR1 kernen, DR1 perspektiv, DR2-K, DR2-P, DR3-K, DR3-P]
C = 3 #number of channels
M = 0

L = [-1,0,1]
Q = [-3,-2]

timeperiod = 10

time_start = abs(minimum(Q)) + 1
time_end = abs(minimum(Q)) + timeperiod
timesteps = abs(minimum(Q)) + timeperiod + maximum(L)

T = collect(1:timesteps)

I = zeros(length(T), C)
I[:,1] = ones(length(T)) * (120 * 7 + M)
I[:,2] = ones(length(T)) * (15 * 7 + M)
I[:,3] = ones(length(T)) * (7 * 7 + M)

S = [1,5,2,0,3,0] #zeros(6) #[1,1,0,1,1,1] 
w = [100,80,50,50,60,10] #weekly cost
H = ones(length(T)) * (100 + M)
u = zeros(length(L), length(P), C)

u[:,:,1] = [47 0 11 0 45 0; 80 64 32 38 80 0; 30 85 11 44 31 0]
u[:,:,2] = [0 0 17 0 0 0; 0 7 48 25 0 47; 0 10 17 29 0 60]
u[:,:,3] = [0 0 0 0 0 0; 0 0 0 0 0 0; 0 0 0 0 0 0]

@variable(model, x[1:length(T), 1:length(P)] >= 0, Int)
@variable(model, f[1:length(P)] >= 0, Int)

@objective(model, Max, sum(x[t,p] for t = time_start:time_end for p = 1:length(P)) - sum(f[p] for p = 1:length(P)))

@constraint(model, [t = 1:(time_start - 1)], sum(x[t,p] for p = 1:length(P)) == 0)
@constraint(model, [t = (time_end + 1):timesteps], sum(x[t,p] for p = 1:length(P)) == 0)

@constraint(model, [t=time_start:time_end, c = 1:C], sum(u[l,p,c] * x[t-L[l],p] for l = 1:length(L) for p = 1:length(P)) <= I[t,c])
@constraint(model, [t=1:(time_end - time_start)], sum(w[p] * x[t-Q[q],p] for p=1:length(P) for q = 1:length(Q)) <= H[t])


@constraint(model, [p=1:length(P)], sum(x[t,p] for t = time_start:time_end) >= S[p] - f[p])


JuMP.optimize!(model)
println("Objective: ", objective_value(model))
for t = 1:length(T)
    for p = 1:length(P)
        if JuMP.value(x[t,p]) > 0.5
            println("At time ", t, " we have prioritet ", p, " with value: ", JuMP.value(x[t,p]))
        end
    end
end

for p = 1:length(P)
    if JuMP.value(f[p]) > 0.5
        println("Penalty for priority ", p , " with value: ", JuMP.value(f[p]))
    end
end