using Plots

gap = 0.02

f = open("results/trade-off")
readline(f) # X
X = parse.(Float64,split(readline(f)))
readline(f) # blank
readline(f) # Y
Y = parse.(Float64,split(readline(f)))
close(f)

Y_gap = -(gap .* abs.(Y) .- Y)

plot(X,[Y, Y_gap])
