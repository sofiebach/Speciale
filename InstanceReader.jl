
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