#Read data instance
function readInstance(filename)
    f = open(filename)
    readline(f) # comment
    P, C, M, timeperiod = parse.(Int,split(readline(f)))
    readline(f) # blank
    readline(f) # comment
    L_lower, L_upper, L_zero = parse.(Int,split(readline(f)))
    readline(f) # blank
    readline(f) # comment
    L = parse.(Int,split(readline(f)))
    readline(f) # blank
    readline(f) # comment
    Q_lower, Q_upper = parse.(Int,split(readline(f)))
    readline(f) # blank
    readline(f) # comment
    Q = parse.(Int,split(readline(f)))
    readline(f) # blank
    readline(f) # comment
    start, stop, T = parse.(Int,split(readline(f)))
    readline(f) # blank
    readline(f) # comment
    S = parse.(Float64,split(readline(f)))
    readline(f) # blank
    readline(f) # comment
    w = parse.(Float64,split(readline(f)))
    readline(f) # blank
    readline(f) # comment
    H = zeros(Float64, T, M)
    for m = 1:M
        H[:,m] = parse.(Float64,split(readline(f)))
    end
    #H = parse.(Int,split(readline(f)))
    readline(f) # blank
    readline(f) # comment
    I = zeros(Float64, T, C)
    for c in 1:C
        I[:,c] = parse.(Float64,split(readline(f)))
    end
    readline(f) # blank
    readline(f) # comment
    L = collect(L_lower:L_upper)
    u = zeros(Float64, length(L), P, C)
    for c = 1:C
        line = parse.(Float64,split(readline(f)))
        u[:,:,c] = reshape(line, (length(L), P))
    end

    return P,C,M,timeperiod,L_lower,L_upper,L,L_zero,Q_lower,Q_upper,Q,start,stop,T,S,w,H,I,u
end
#filename = "simulated_data/data.txt"
#P,C,M,timeperiod,L_lower,L_upper,L,L_zero,Q_lower,Q_upper,Q,start,stop,T,S,w,H,I,u = readInstance(filename)

# Write solution
function writeSolution(filename, sol, k, f, P, C, M, timeperiod, L_lower, L_upper, L_zero, Q_lower,Q_upper, start, stop, T)
    outFile = open(filename, "w")
    write(outFile, "P, C, M, timeperiod" * "\n")
    write(outFile, join([P, C, M, timeperiod]," ")*"\n\n")

    write(outFile, "START, STOP, T" * "\n")
    write(outFile, join([start, stop, T]," ") * "\n\n")

    write(outFile, "Objective value \n")
    write(outFile, join(objective_value(model)," ")*"\n\n")
    write(outFile, "Solution \n")
    for p = 1:P
        write(outFile,join(sol[:,p]," ") * "\n")
    end
    write(outFile, "\n")

    write(outFile, "Penalty for undone jobs" * "\n")
    write(outFile,join(k," ")*"\n")
    write(outFile, "\n")

    write(outFile, "Freelancers hired" * "\n")
    for m = 1:M
        write(outFile,join(f[:,m]," ")*"\n")
    end
    write(outFile, "\n")

    write(outFile, "L_lower, L_upper, L0" * "\n")
    write(outFile, join([L_lower, L_upper, L_zero]," ")*"\n\n")

    write(outFile, "Q_lower, Q_upper" * "\n")
    write(outFile, join([Q_lower, Q_upper]," ")*"\n\n")

    # Time periods incl. prod and air
    start = abs(Q_lower) + 1
    stop = abs(Q_lower) + timeperiod

    write(outFile, "CONSUMPTION" * "\n")
    for c = 1:C
        write(outFile, join(u[:,:,c], " ") * "\n")
    end
    write(outFile, "\n")

    write(outFile, "INVENTORY" * "\n")
    for c = 1:C
        write(outFile, join(I[:,c], " ") * "\n")
    end
    write(outFile, "\n")

    write(outFile, "STAFFING" * "\n")
    for m = 1:M
        write(outFile, join(H[:,m], " ") * "\n")
    end
    write(outFile, "\n")

    close(outFile)
end


# Read solution
function readSolution(filename)
    f = open(filename)
    readline(f) # comment
    P, C, M, timeperiod = parse.(Int,split(readline(f)))
    readline(f) # blank
    readline(f) # comment
    start, stop, T = parse.(Int,split(readline(f)))
    readline(f) # blank
    readline(f) # comment
    obj = parse.(Float64, readline(f))
    readline(f) # blank
    readline(f) # comment
    x = zeros(Int, T, P)
    for p in 1:P
        x[:,p] = parse.(Int,split(readline(f)))
    end
    readline(f) # blank
    readline(f) # comment
    k = parse.(Int,split(readline(f)))
    readline(f) # blank
    readline(f) # comment
    f1 = zeros(Int, T, M)
    for m = 1:M
        f1[:,m] = parse.(Int,split(readline(f)))
    end
    readline(f) # blank
    readline(f) # comment
    L_lower, L_upper, L_zero = parse.(Int,split(readline(f)))
    readline(f) # blank
    readline(f) # comment
    Q_lower, Q_upper = parse.(Int,split(readline(f)))
    readline(f) # blank
    readline(f) # comment
    L = collect(L_lower:L_upper)
    
    u = zeros(Float64, length(L), P, C)
    for c = 1:C
        line = parse.(Float64,split(readline(f)))
        u[:,:,c] = reshape(line, (length(L), P))
    end
    readline(f) # blank
    readline(f) # comment
    I = zeros(Float64, T, C)
    for c in 1:C
        I[:,c] = parse.(Float64,split(readline(f)))
    end
    readline(f) # blank
    readline(f) # comment
    H = zeros(Float64, T, M)
    for m = 1:M
        H[:,m] = parse.(Float64,split(readline(f)))
    end
    return x, obj, f1, k, P, C, M, timeperiod, L_lower, L_upper, Q_lower, Q_upper, start, stop, T, u, I, H

end