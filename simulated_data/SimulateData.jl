using Random

# Data file to write
data_file = open("simulated_data/data.txt", "w")

# Number of priorities
P = 6

# Number of channels
C = 3

# Number of medias
M = 4

# Time period excl prod and air
timeperiod = 10

# Min and max airing week
L_lower = -1
L_upper = 1

# Min and max production week
Q_lower = -3
Q_upper = -2

# Write parameters to file
write(data_file, "P, C, M, timeperiod" * "\n")
write(data_file, join([P, C, M, timeperiod]," ")*"\n\n")

# write(outFile,join(sol[t,:]," ")*"\n")
function sim_data(P, C, M, timeperiod, L_lower, L_upper, Q_lower, Q_upper)
    L = collect(L_lower:L_upper)
    L_zero = indexin(0,L)[] # MANGLER
    # Write to file
    write(data_file, "L_lower, L_upper, L0" * "\n")
    write(data_file, join([L_lower, L_upper, L_zero]," ")*"\n\n")
    write(data_file, "L-vector" * "\n")
    write(data_file, join(L, " ") * "\n\n")

    Q = collect(Q_lower:Q_upper)
    write(data_file, "Q_lower, Q_upper" * "\n")
    write(data_file, join([Q_lower, Q_upper]," ")*"\n\n")
    write(data_file, "Q-vector" * "\n")
    write(data_file, join(Q, " ") * "\n\n")

    # Time periods incl. prod and air
    start = abs(Q_lower) + 1
    stop = abs(Q_lower) + timeperiod
    T = abs(Q_lower) + timeperiod + L_upper
    write(data_file, "START, STOP, T" * "\n")
    write(data_file, join([start, stop, T]," ") * "\n\n")

    # Scope of each priority
    S = rand(0:5, P)*1.0 # skal vælges
    write(data_file, "SCOPE" * "\n")
    write(data_file, join(S, " ") * "\n\n")

    # Weekly cost of each priority
    w = rand(1:10, P)*10.0 # skal vælges
    write(data_file, "COST" * "\n")
    write(data_file, join(w, " ") * "\n\n")

    # Staffing in each time period
    H = rand(6:14, M)*10.0 # skal vælges
    H = transpose(repeat(H,1,T))
    write(data_file, "STAFFING" * "\n")
    for m = 1:M
        write(data_file, join(H[:,m], " ") * "\n")
    end
    write(data_file, "\n")

    # GRP inventory
    I = zeros(Float64, T, C)
    write(data_file, "INVENTORY" * "\n")
    for c = 1:C
        I[:, c] = rand(10:100, T)*7.0 # skal vælges
        write(data_file, join(I[:,c], " ") * "\n")
    end
    write(data_file, "\n")
    #I[:,1] = ones(length(T)) * (120 * 7 + M)
    #I[:,2] = ones(length(T)) * (15 * 7 + M)
    #I[:,3] = ones(length(T)) * (7 * 7 + M)
    
    # GRP consumption
    u = zeros(Float64, length(L), P, C)
    write(data_file, "CONSUMPTION" * "\n")
    #u[:,:,1] = [47 0 11 0 45 0; 80 64 32 38 80 0; 30 85 11 44 31 0]
    #u[:,:,2] = [0 0 17 0 0 0; 0 7 48 25 0 47; 0 10 17 29 0 60]
    #u[:,:,3] = [0 0 0 0 0 0; 0 0 0 0 0 0; 0 0 0 0 0 0]
    for c = 1:C
        u[:,:,c] = rand(1:5, length(L), P)*10.0
        write(data_file, join(u[:,:,c], " ") * "\n")
    end
    
end

sim_data(P, C, M, timeperiod, L_lower, L_upper, Q_lower, Q_upper)

close(data_file)