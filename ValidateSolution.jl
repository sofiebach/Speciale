include("ReadWrite.jl")

filename = "simulated_data/data.txt"

# Overview of inventory
function checkSolution(filename)
    x, _, P, C, M, _, L_lower, L_upper, Q_lower, Q_upper, _, _, T, _, I, H= readSolution(filename)
    inventory_check = zeros(C, T)
    inventory_used = zeros(C, T)
    for t = start:stop
        for p = 1:P
            if x[t,p] > 0
                l_idx = 1
                for l in (collect(L_lower:L_upper))
                    for c = 1:C
                        grp = u[l_idx,p,c] * x[t,p]
                        inventory_check[c, t+l] += grp
                        inventory_used[c, t+l] = 1 - (I[t+l,c] - inventory_check[c, t+l])/I[t+l,c]
                        if inventory_check[c, t+l] > I[t+l,c]
                            println("Inventory constraint exceeded!")
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
    staffing_check = zeros(T,M)
    staffing_used = zeros(T,M)
    for t = start:stop
        for p = 1:P
            if x[t,p] > 0
                q_idx = 1
                work = w[p]
                for q in Q
                    for m in 1:M
                        staffing_check[t+q,m] += work
                        staffing_used[t+q,m] = 1 - (H[t+q,m] - staffing_check[t+q,m])/H[t+q,m]
                        if staffing_check[t+q,m] > H[t+q,m]
                            println("Staff constraint exceeded!")
                            println("t: ", t)
                            println("p: ", p)
                            println("q: ", q)
                            println("m: ", m)
                        end
                    end
                    q_idx += 1
                end   
            end
        end
    end
    println("Inventory used (%):")
    display(inventory_used * 100)
    println("Staff used (%): ")
    println(staffing_used * 100)

    #println("Staff 50: ", staffing_check[50])
    #println("H 50: ", H)
    #println("Staff 50: ", staffing_used[50])
end

x, obj, P, C, M, timeperiod, L_lower, L_upper, Q_lower, Q_upper, start, stop, T, u, I, H = readSolution("output/solution.txt")
checkSolution("output/solution.txt")

