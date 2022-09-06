#P = [1,2,3,4,5,6] #two priorities, 3 channels #[DR1 kernen, DR1 perspektiv, DR2-K, DR2-P, DR3-K, DR3-P]
#C = 3 #number of channels
#M = 0
#
#L_lower = -1
#L_upper = 1
#L = collect(L_lower:L_upper)
#L_zero = indexin(0,L)[]
#
#
#Q_lower = -3
#Q_upper = -2
#Q = collect(Q_lower:Q_upper)
#
#timeperiod = 10
#
#start = abs(minimum(Q)) + 1
#stop = abs(minimum(Q)) + timeperiod
#timesteps = abs(minimum(Q)) + timeperiod + maximum(L)
#
#T = collect(1:timesteps)
#
#I = zeros(length(T), C)
#I[:,1] = ones(length(T)) * (120 * 7 + M)
#I[:,2] = ones(length(T)) * (15 * 7 + M)
#I[:,3] = ones(length(T)) * (7 * 7 + M)
#
#S = [1,2,2,0,3,0] #zeros(6) #[1,1,0,1,1,1] 
#w = [100,80,50,50,60,10] #weekly cost
#H = ones(length(T)) * (100 + M)
#u = zeros(length(L), length(P), C)
#
#u[:,:,1] = [47 0 11 0 45 0; 80 64 32 38 80 0; 30 85 11 44 31 0]
#u[:,:,2] = [0 0 17 0 0 0; 0 7 48 25 0 47; 0 10 17 29 0 60]
#u[:,:,3] = [0 0 0 0 0 0; 0 0 0 0 0 0; 0 0 0 0 0 0]