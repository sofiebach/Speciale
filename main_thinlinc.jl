include("ReadWrite.jl")
include("MIPModel.jl")

function print_solution(sol)
    println("Objective: ", sol.obj)
    for p = 1:sol.P
        println("Priority ", p, " is scheduled ", sum(sol.x[:,p]), " times")
    end

    for p = 1:sol.P
        if sol.k[p] > 0.5
            println("Penalty for priority ", p , " with value: ", sol.k[p])
        end
    end
    for m = 1:sol.M
        for t = 1:sol.T 
            if sol.f[t,m] > 0.5
                #println("Number of freelance for media ", m , " at time ", t, ": ", sol.f[t,m])
            end
        end
        println("Number of freelance hours for media ", m, " is: ", sum(sol.f[:,m]))
    end
    
    println("Total number of campaigns: ", sum(sol.x))
end

P = 37
data = read_DR_data(P)

sol = MIP(data, 2, 0)

println("Objective to compare with meta:")
println(-sum(data.reward.*transpose(sol.x))+sum(sol.k.*data.penalty_S))

print_solution(sol)



