using JuMP, GLPK

model = Model(GLPK.Optimizer)

P = [1,2,3,4,5,6] #two priorities, 3 channels #[DR1 kernen, DR1 perspektiv, DR2-K, DR2-P, DR3-K, DR3-P]
C = 3 #number of channels
M = 0

L = [-1,0,1]
Q = [-2,-1]

timeperiod = 10

time_start = abs(minimum(Q)) + 1
time_end = abs(minimum(Q)) + timeperiod
timesteps = abs(minimum(Q)) + timeperiod + maximum(L)

T = collect(1:timesteps)

I = zeros(length(T), C)
I[:,1] = ones(length(T)) * (120 * 7 + M)
I[:,2] = ones(length(T)) * (15 * 7 + M)
I[:,3] = ones(length(T)) * (7 * 7 + M)

S = [1,1,2,0,5,0] #zeros(6) #[1,1,0,1,1,1] 
w = [100,80,50,50,60,10]
H = ones(length(T)) * (100 + M)
u = zeros(length(L), length(P), C)
u[:,1,:] = [47 80 30; 0 0 0; 0 0 0]
u[:,2,:] = [0 64 85; 0 7 10; 0 0 0]
u[:,3,:] = [11 32 11; 17 48 17; 0 0 0]
u[:,4,:] = [0 38 44; 0 25 29; 0 0 0]
u[:,5,:] = [45 80 31; 0 0 0; 0 0 0]
u[:,6,:] = [0 0 0; 0 47 60; 0 0 0]

@variable(model, x[1:length(T), 1:length(P)] >= 0, Int)

@objective(model, Max, sum(x[t,p] for t = time_start:time_end for p = 1:length(P)))

@constraint(model, [t = 1:(time_start - 1)], sum(x[t,p] for p = 1:length(P)) == 0)
@constraint(model, [t = (time_end + 1):timesteps], sum(x[t,p] for p = 1:length(P)) == 0)

@constraint(model, [t=time_start:time_end, c = 1:C], sum(u[l,p,c] * x[t-L[l],p] for l = 1:length(L) for p = 1:length(P)) <= I[t,c])
@constraint(model, [p=1:length(P)], sum(x[t,p] for t = time_start:time_end) >= S[p])
@constraint(model, [t=time_start:time_end, q = 1:length(Q)], sum(w[p]*x[t,p] for p=1:length(P)) <= H[t+Q[q]]) #SHould be changed

JuMP.optimize!(model)
println("Objective: ", objective_value(model))
for t = 1:length(T)
    for p = 1:length(P)
        if JuMP.value(x[t,p]) > 0.5
            println("At time ", t, " we have prioritet ", p, " with value: ", JuMP.value(x[t,p]))
        end
    end
end
