include("InstanceReader.jl")

filename = "simulated_data/data.txt"

P,C,timeperiod,L_lower,L_upper,L,L_zero,Q_lower,Q_upper,Q,start,stop,T,S,w,H,I,u = readInstance(filename)

# Output
function readSolution(filename)
    x = zeros(Int, T, P)
    f = open(filename)
    obj = parse.(Float64, readline(f))
    for i in 1:T
        x[i,:] = parse.(Int,split(readline(f)))
    end
    return x, obj
end
x, obj = readSolution("output/solution.txt")

# Overview of inventory
inventory_check = zeros(C, T)
inventory_dif = zeros(C, T)
for t = start:stop
    for p = 1:P
        if x[t,p] > 0
            l_idx = 1
            for l in L
                for c = 1:C
                    grp = u[l_idx,p,c] * x[t,p]
                    inventory_check[c, t+l] += grp
                    inventory_dif[c, t+l] = I[t+l,c] - inventory_check[c, t+l]
                    if inventory_check[c, t+l] > I[t+l,c]
                        println("p: ", p)
                        println("c: ", c)
                        println("t: ", t)
                        println("l: ", l)
                    end
                end
                l_idx += 1
            end   
        end
    end
end

# Overview of staffing
staffing_check = zeros(T)
staffing_dif = zeros(T)
for t = start:stop
    for p = 1:P
        if x[t,p] > 0
            q_idx = 1
            work = w[p]
            for q in Q
                staffing_check[t+q] += work
                staffing_dif[t+q] = H[t+q] - staffing_check[t+q]
                if staffing_check[t+q] > H[t+q]
                    println("t: ", t)
                    println("p: ", p)
                    println("q: ", q)
                end
                q_idx += 1
            end   
        end
    end
end

print("hej")
