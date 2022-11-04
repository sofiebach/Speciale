include("../ReadWrite.jl")
include("tuning.jl")

P = 37
data = read_DR_data(P)

temperatures = collect(500:100:1000)
alphas = collect(0.70:0.05:0.99)
gammas = collect(0.70:0.05:0.99)
T, alpha, gamma = tuneAcceptanceCriteria(data, temperatures, alphas, gammas)
