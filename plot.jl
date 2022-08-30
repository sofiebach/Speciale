#using VegaLite, DataFrames #for plotting
#
#function plot_time(start, stop, proc, job)
#    #put data inside dataframe for plotting using VegaLite
#    df = DataFrame(processor = proc, start = start, stop = stop, job = job)
#    
#    df |> @vlplot(
#    width=500,
#    :bar,
#    y="processor:n",
#    x=:start,
#    x2=:stop, 
#    color="job:n",
#    opacity={value = 0.5}
#    )
#end

P = [1,2,3,4,5,6] #two priorities, 3 channels #[DR1 kernen, DR1 perspektiv, DR2-K, DR2-P, DR3-K, DR3-P]
C = 3 #number of channels
M = 0
L = [-1,0,1]
Q = [-3,-2]

timeperiod = 10
start = abs(minimum(Q)) + 1
stop = abs(minimum(Q)) + timeperiod
timesteps = abs(minimum(Q)) + timeperiod + maximum(L)

T = collect(1:timesteps)

I = zeros(length(T), C)
I[:,1] = ones(length(T)) * (120 * 7 + M)
I[:,2] = ones(length(T)) * (15 * 7 + M)
I[:,3] = ones(length(T)) * (7 * 7 + M)

S = [1,5,2,0,3,0] #zeros(6) #[1,1,0,1,1,1] 
w = [100,80,50,50,60,10] #weekly cost
H = ones(length(T)) * (100 + M)
u = zeros(length(L), length(P), C)
u[:,:,1] = [47 0 11 0 45 0; 80 64 32 38 80 0; 30 85 11 44 31 0]
u[:,:,2] = [0 0 17 0 0 0; 0 7 48 25 0 47; 0 10 17 29 0 60]
u[:,:,3] = [0 0 0 0 0 0; 0 0 0 0 0 0; 0 0 0 0 0 0]

# Output
function readSolution(filename)
    x = zeros(Int, timesteps, length(P))
    f = open(filename)
    for i in 1:timesteps
        x[i,:] = parse.(Int,split(readline(f)))
    end
    return x
end
x = readSolution("output/solution.txt")

# Overview of inventory
inventory_check = zeros(C, timesteps)
for t = start:stop
    for p = 1:length(P)
        if x[t,p] > 0
            l_idx = 1
            for l in L
                for c = 1:C
                    grp = u[l_idx,p,c] * x[t,p]
                    inventory_check[c, t+l] += grp
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
staffing_check = zeros(timesteps)
for t = start:stop
    for p = 1:length(P)
        if x[t,p] > 0
            q_idx = 1
            work = w[p]
            for q in Q
                staffing_check[t+q] += work
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

