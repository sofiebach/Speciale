function checkSolution(data, sol)
    # Overview of inventory
    eps = 1e-6
    inventory_check = zeros(data.T, data.C)
    for t = 1:data.T
        for p = 1:data.P
            if sol.x[t,p] > 0
                l_idx = 1
                for l = data.L_lower:data.L_upper
                    for c = 1:data.C
                        grp = data.u[l_idx,p,c] * sol.x[t,p]
                        inventory_check[t+l,c] += grp
                        if inventory_check[t+l, c] > data.I[t+l,c] + eps
                            println("Inventory constraint exceeded!")
                            #println("p: ", p)
                            #println("c: ", c)
                            #println("t: ", t)
                            #println("l: ", l)
                        end
                    end
                    l_idx += 1
                end   
            end
        end
    end
    inventory_used = inventory_check ./ data.I

    # Overview of staffing
    staffing_check = zeros(Float64, data.T,data.M)
    staff_incl_freelancer = data.H + sol.f 
    for t = 1:data.T
        for p = 1:data.P
            if sol.x[t,p] > 0
                for q = data.Q_lower:data.Q_upper
                    for m in 1:data.M
                        #println(data.w[p,m])
                        work = data.w[p,m] * sol.x[t,p]
                        staffing_check[t+q,m] += work
                        if staffing_check[t+q,m] > staff_incl_freelancer[t+q,m] + eps
                            println("Staff constraint exceeded!")
                            println("t: ", t+q)
                            println("m: ", m)
                            println("used: ", staffing_check[t+q,m])
                            println("cap: ", staff_incl_freelancer[t+q,m])
                            #println("t: ", t)
                            #println("p: ", p)
                            #println("q: ", q)
                            #println("m: ", m)
                            return false
                            break
                        end
                    end
                end   
            end
        end
    end
    staffing_used = staffing_check ./ staff_incl_freelancer

    for m = 1:data.M
        if sum(sol.f[:,m]) > data.F[m]
            println("Too many freelance hours!")
        end
    end
    return true

    #println("Inventory used (%):")
    #display(inventory_used * 100)
    max_inventory = maximum(inventory_used)
    max_inventory_idx = findfirst(x -> x == maximum(inventory_used), inventory_used)
    #println("Maximum inventory used is ", max_inventory, " on channel ", max_inventory_idx[2], " at time ", max_inventory_idx[1], "\n\n")

    #println("Staffing used (%):")
    #display(staffing_used * 100)
    max_staff = maximum(staffing_used)
    max_staff_idx = findfirst(x -> x == maximum(staffing_used), staffing_used)
    #println("Maximum staffing used is ", max_staff, " on media ", max_staff_idx[2], " at time ", max_staff_idx[1])
    return inventory_used, staffing_used
end



function checkSolution2(data, sol)
    # Only production check

    used_inv = zeros(Float64,data.T, data.C)
    cap_inv = zeros(Float64, data.T, data.C)

    used_prod = zeros(Float64, data.T, data.M)
    cap_prod = zeros(Float64, data.T, data.M)
    for t = data.start:data.stop
    #    for l_idx = (t-data.L_upper):(t-data.L_lower)
    #        println("t ", t, " l_idx: ", l_idx,)
    #        used_inv[t,:] += transpose(sum(sol.x[l_idx,:].*data.u[l_idx-t+data.L_zero+1,:,:],dims=1))
    #    end
    #end


        # production check
        for q_idx = (t-data.Q_upper):(t-data.Q_lower)
            used_prod[t,:] += transpose(sum(sol.x[q_idx,:].*data.w,dims=1))
        end
        cap_prod[t,:] = data.H[t,:] + sol.f[t,:]
        for m = 1:data.M
            if(used_prod[t,m] > cap_prod[t,m])
                print("Staff exceeded at time ", t, " media ", m)
            end
        end 
    end

    for m = 1:data.M
        if sum(sol.f[:,m]) > data.F[m]
            println("Too many freelance hours!")
        end
    end
    return used_prod, cap_prod
end

