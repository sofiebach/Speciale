using Random

# Data file to write
data_file = open("simulated_data/data.txt", "w")

# Number of priorities
n_priorities = 6

# Number of channels
n_channels = 3

# Time period excl prod and air
n_weeks = 52

# Min and max airing week
min_air_week = -2
max_air_week = 5

# Min and max production week
min_prod_week = -4
max_prod_week = -3

# Write parameters to file
write(data_file, "N_PRIORITIES, N_CHANNELS, N_WEEKS" * "\n")
write(data_file, join([n_priorities, n_channels, n_weeks]," ")*"\n\n")

# write(outFile,join(sol[t,:]," ")*"\n")
function sim_data(n_priorities, n_channels, n_weeks, min_air_week, max_air_week, min_prod_week, max_prod_week)
    air_weeks = collect(min_air_week:max_air_week)
    air_zero = indexin(0,air_weeks)[] # MANGLER
    # Write to file
    write(data_file, "MIN_AIR_WEEK, MAX_AIR_WEEK, L0" * "\n")
    write(data_file, join([min_air_week, max_air_week, air_zero]," ")*"\n\n")
    write(data_file, "L-vector" * "\n")
    write(data_file, join(air_weeks, " ") * "\n\n")

    prod_weeks = collect(min_prod_week:max_prod_week)
    write(data_file, "MIN_PROD_WEEK, MAX_PROD_WEEK" * "\n")
    write(data_file, join([min_prod_week, max_prod_week]," ")*"\n\n")
    write(data_file, "Q-vector" * "\n")
    write(data_file, join(prod_weeks, " ") * "\n\n")

    # Time periods incl. prod and air
    start = abs(min_prod_week) + 1
    stop = abs(min_prod_week) + n_weeks
    T = abs(min_prod_week) + n_weeks + max_air_week
    write(data_file, "START, STOP, T" * "\n")
    write(data_file, join([start, stop, T]," ") * "\n\n")

    # Scope of each priority
    S = rand(0:5, n_priorities) # skal vælges
    write(data_file, "SCOPE" * "\n")
    write(data_file, join(S, " ") * "\n\n")

    # Weekly cost of each priority
    w = rand(1:10, n_priorities)*10 # skal vælges
    write(data_file, "COST" * "\n")
    write(data_file, join(w, " ") * "\n\n")

    # Staffing in each time period
    H = rand(6:14, T)*10 # skal vælges
    write(data_file, "STAFFING" * "\n")
    write(data_file, join(H, " ") * "\n\n")

    # GRP inventory
    I = zeros(Int, T, n_channels)
    write(data_file, "INVENTORY" * "\n")
    for c = 1:n_channels
        I[:, c] = rand(10:100, T)*7 # skal vælges
        write(data_file, join(I[:,c], " ") * "\n")
    end
    write(data_file, "\n")
    #I[:,1] = ones(length(T)) * (120 * 7 + M)
    #I[:,2] = ones(length(T)) * (15 * 7 + M)
    #I[:,3] = ones(length(T)) * (7 * 7 + M)
    
    # GRP consumption
    u = zeros(Int, length(air_weeks), n_priorities, n_channels)
    write(data_file, "CONSUMPTION" * "\n")
    #u[:,:,1] = [47 0 11 0 45 0; 80 64 32 38 80 0; 30 85 11 44 31 0]
    #u[:,:,2] = [0 0 17 0 0 0; 0 7 48 25 0 47; 0 10 17 29 0 60]
    #u[:,:,3] = [0 0 0 0 0 0; 0 0 0 0 0 0; 0 0 0 0 0 0]
    for c = 1:n_channels
        u[:,:,c] = rand(1:5, length(air_weeks), n_priorities)*10
        write(data_file, join(u[:,:,c], " ") * "\n")
    end
    
end

sim_data(n_priorities, n_channels, n_weeks, min_air_week, max_air_week, min_prod_week, max_prod_week)

close(data_file)