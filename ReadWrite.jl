#Read data instance
function readInstance(filename)
    f = open(filename)
    readline(f) # comment
    P, C, timeperiod = parse.(Int,split(readline(f)))
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
    S = parse.(Int,split(readline(f)))
    readline(f) # blank
    readline(f) # comment
    w = parse.(Int,split(readline(f)))
    readline(f) # blank
    readline(f) # comment
    H = parse.(Int,split(readline(f)))
    readline(f) # blank
    readline(f) # comment
    I = zeros(Int, T, C)
    for c in 1:C
        I[:,c] = parse.(Int,split(readline(f)))
    end
    readline(f) # blank
    readline(f) # comment
    air_weeks = collect(L_lower:L_upper)
    u = zeros(Int, length(air_weeks), P, C)
    for c = 1:C
        line = parse.(Int,split(readline(f)))
        u[:,:,c] = reshape(line, (length(air_weeks), P))
    end

    return P,C,timeperiod,L_lower,L_upper,L,L_zero,Q_lower,Q_upper,Q,start,stop,T,S,w,H,I,u
end

#P,C,timeperiod,L_lower,L_upper,L,Q_lower,Q_upper,Q,start,stop,T,S,w,H,I,u = readInstance(filename)

# Write solution
function writeSolution(filename, sol, n_priorities, n_channels, n_weeks, min_air_week, max_air_week, air_zero, min_prod_week,max_prod_week, start, stop, T)
    outFile = open(filename, "w")
    write(outFile, "N_PRIORITIES, N_CHANNELS, N_WEEKS" * "\n")
    write(outFile, join([n_priorities, n_channels, n_weeks]," ")*"\n\n")

    write(outFile, "START, STOP, T" * "\n")
    write(outFile, join([start, stop, T]," ") * "\n\n")

    write(outFile, join(objective_value(model)," ")*"\n")
    for t = 1:T
        write(outFile,join(sol[t,:]," ")*"\n")
    end
    write(outFile, "\n")

    write(outFile, "MIN_AIR_WEEK, MAX_AIR_WEEK, L0" * "\n")
    write(outFile, join([min_air_week, max_air_week, air_zero]," ")*"\n\n")

    write(outFile, "MIN_PROD_WEEK, MAX_PROD_WEEK" * "\n")
    write(outFile, join([min_prod_week, max_prod_week]," ")*"\n\n")

    # Time periods incl. prod and air
    start = abs(min_prod_week) + 1
    stop = abs(min_prod_week) + n_weeks

    write(outFile, "CONSUMPTION" * "\n")
    for c = 1:C
        write(outFile, join(u[:,:,c], " ") * "\n")
    end
    close(outFile)
end

# Read solution
function readSolution(filename)
    f = open(filename)
    readline(f) # comment
    P, C, timeperiod = parse.(Int,split(readline(f)))
    readline(f) # blank
    readline(f) # comment
    start, stop, T = parse.(Int,split(readline(f)))
    readline(f) # blank
    obj = parse.(Float64, readline(f))
    x = zeros(Int, T, P)
    for i in 1:T
        x[i,:] = parse.(Int,split(readline(f)))
    end
    readline(f) # blank
    readline(f) # comment
    L_lower, L_upper, L_zero = parse.(Int,split(readline(f)))
    readline(f) # blank
    readline(f) # comment
    Q_lower, Q_upper = parse.(Int,split(readline(f)))
    readline(f) # blank
    readline(f) # comment
    air_weeks = collect(L_lower:L_upper)
    u = zeros(Float64, length(air_weeks), P, C)
    for c = 1:C
        line = parse.(Float64,split(readline(f)))
        u[:,:,c] = reshape(line, (length(air_weeks), P))
    end
    return x, obj, P, C, timeperiod, L_lower, L_upper, Q_lower, Q_upper, start, stop, T, u

end