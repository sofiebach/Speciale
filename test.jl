include("ReadWrite.jl")
include("MIPModels.jl")
include("BasicFunctions.jl")

data = readInstance("dataset/25_0_0.txt")

logging = 1
time_limit = 0
solution_limit = 0
spreading = 0

x = MIPExpansion(data, logging, time_limit, solution_limit, spreading)
sol = MIPtoSol(data, x)
X = collect(1.0:-0.1:0.1)*sol.base_obj

N = length(X)
Y = zeros(Float64, N)
gap = 0.05
spreading = 1

for i = 1:N
    x2 = MIPExpansion(data, logging, time_limit, gap, spreading, X[i])
    sol2 = MIPtoSol(data, x2)
    Y[i] = sol2.objective.g_penalty - sol2.objective.L_reward
end



