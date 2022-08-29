using JuMP, GLPK

model = Model(GLPK.Optimizer)

T = collect(1:52)
P = [1,2,3,4,5,6] #two priorities, 3 channels #[DR1 kernen, DR1 perspektiv, DR2-K, DR2-P, DR3-K, DR3-P]
C = 3 #number of channels
M = 0

L = [-1,0,1]
Q = [-2,-1]

I = zeros(length(T), C)
I[:,1] = ones(length(T))*(120*7 + M)
I[:,2] = ones(length(T))*(15*7 + M)
I[:,3] = ones(length(T))*(7*7 + M)

S = [12,13,2,29,0,0]
w = [100,80,50,50,60,10]
H = ones(length(T))*(100 + M)
u = zeros(length(L),length(P), C)
u[:,1,:] = [47 110 30; 0 0 0; 0 0 0]
u[:,2,:] = [0 64 85; 0 7 10; 0 0 0]
u[:,3,:] = [11 32 11; 17 48 17; 0 0 0]
u[:,4,:] = [0 38 44; 0 25 29; 0 0 0]
u[:,5,:] = [45 80 31; 0 0 0; 0 0 0]
u[:,6,:] = [0 0 0; 0 47 118; 0 0 0]

@variable(model, x[1:length(T), 1:length(P)] >= 0, Int)

@objective(model, Max, sum(x[t,p] for t = 2:length(T) for p = 1:length(P)))

@constraint(model, [t=2:(length(T)-1), l in 1:length(L), c = 1:C], sum(u[l,p,c] * x[t,p] for p = 1:length(P)) <= I[t+L[l],c])
@constraint(model, [p=1:length(P)], sum(x[t,p] for t = 1:length(T)) >= S[p])
@constraint(model, [t=3:length(T), q = 1:length(Q)], sum(w[p]*x[t,p] for p=1:length(P)) <= H[t+Q[q]])

JuMP.optimize!(model)
println("Objective: ", objective_value(model))
for t=1:length(T)
    for p=1:length(P)
        if JuMP.value(x[t,p])>0.5
            println("At time ", t, " we have prioritet ", p, " with value: ", JuMP.value(x[t,p]))
        end
    end
end
