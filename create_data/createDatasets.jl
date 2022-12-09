include("../ReadWrite.jl")

data = read_DR_data(37)

writeInstance("original2.txt", data)


function createNewInstance(data, d, w, u)
    timeperiod = Int(ceil(data.timeperiod*d))
    stop = abs(data.Q_lower)+timeperiod
    T = timeperiod + data.start + abs(data.Q_lower) 
    S = Int64.(ceil.(data.S*d))
    
    outFile = open("dataset/"*string(Int(d*100))*"_"*string(Int(w*100))*"_"*string(Int(u*100))*".txt", "w")
    write(outFile, "timeperiod P M C T\n")
    write(outFile, join([timeperiod, data.P, data.M, data.C, T]," ")*"\n\n")

    write(outFile, "L_lower L_upper L_zero Q_lower Q_upper\n")
    write(outFile, join([data.L_lower, data.L_upper, data.L_zero, data.Q_lower, data.Q_upper]," ")*"\n\n")
    
    write(outFile, "start stop\n")
    write(outFile, join([data.start, stop]," ")*"\n\n")
    
    write(outFile, "P_bar\n")
    write(outFile,join(data.P_bar," ")*"\n\n")

    write(outFile, "S \n")
    write(outFile,join(S," ")*"\n\n")
    
    write(outFile, "w\n")
    for m = 1:data.M
        write(outFile,join(data.w[:,m]*(1-w)," ")*"\n")
    end
    write(outFile, "\n")

    write(outFile, "H\n")
    for m = 1:data.M
        write(outFile,join(data.H[1:T,m]," ")*"\n")
    end
    write(outFile, "\n")

    write(outFile, "I\n")
    for c = 1:data.C
        write(outFile,join(data.I[1:T,c]," ")*"\n")
    end
    write(outFile, "\n")

    write(outFile, "u\n")
    for c = 1:data.C
        for p=1:data.P
            write(outFile,join(data.u[:,p,c]*(1-u)," ")*"\n")
        end
    end
    write(outFile, "\n")

    write(outFile, "L_l\n")
    write(outFile,join(data.L_l," ")*"\n\n")

    write(outFile, "L_u\n")
    write(outFile,join(data.L_u," ")*"\n\n")

    write(outFile, "penalty_S\n")
    write(outFile,join(data.penalty_S," ")*"\n\n")

    write(outFile, "penalty_f\n")
    write(outFile,join(data.penalty_f," ")*"\n\n")

    write(outFile, "F\n")
    write(outFile,join(data.F*d," ")*"\n\n")

    write(outFile, "aimed\n")
    write(outFile,join(Int64.(ceil.(S/timeperiod))," ")*"\n\n")

    write(outFile, "P_names\n") 
    write(outFile,join(replace.(data.P_names, " " => "£")," ")*"\n\n")

    write(outFile, "C_names\n")
    write(outFile,join(data.C_names," ")*"\n\n")

    write(outFile, "M_names\n")
    write(outFile,join(data.M_names," ")*"\n\n")

    write(outFile, "BC_names\n") 
    write(outFile,join(replace.(data.BC_names, " " => "£")," ")*"\n\n")

    write(outFile, "campaign_type\n") #skal fikses
    write(outFile,join(replace.(data.campaign_type, " " => "£")," ")*"\n\n")

    close(outFile)
end

data = readInstance("create_data/original2.txt")

percent = [0.25,0.5,1]
U = [0, 0.05, 0.1, 0.15]
W = [0, 0.05, 0.1, 0.15]

for p in percent, u in U
    createNewInstance(data,p,0,u)
end

for p in percent, w in W
    createNewInstance(data,p,w,0)
end

