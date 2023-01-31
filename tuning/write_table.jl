include("../ReadWrite.jl")


parameter = "alpha"

filepath = joinpath.("tuning/results/" * parameter *"/", readdir("tuning/results/" * parameter * "/"))

outFile = open("tuning/" * parameter * "_table", "w")

avg_sum = zeros(Float64, 5)
std_sum = zeros(Float64, 5)
idx = 1
rounddigitsavg = 4
rounddigitsstd = 2

file = filepath[1]
f = open(file)
readline(f)
readline(f)
readline(f)
if parameter == "theta"
    tuning_param = parse.(Float64, split(readline(f)))
else
    readline(f)
end
readline(f)
readline(f)
if parameter == "alpha"
    tuning_param = parse.(Float64, split(readline(f)))
else
    readline(f)
end
readline(f)
readline(f)
if parameter == "W"
    tuning_param = []
    for i = 1:5
        push!(tuning_param, parse.(Int64, split(readline(f), " ")))
    end
else
    readline(f)
end
readline(f)
readline(f)
if parameter == "gamma"
    tuning_param = parse.(Float64, split(readline(f)))
else
    readline(f)
end
readline(f)
readline(f)
if parameter == "frac"
    tuning_param = parse.(Float64, split(readline(f)))
else
    readline(f)
end
readline(f)
readline(f)
if parameter == "segment"
    tuning_param = parse.(Float64, split(readline(f)))
else
    readline(f)
end
readline(f)
readline(f)
if parameter == "LTU"
    tuning_param = parse.(Float64, split(readline(f)))
else
    readline(f)
end
write(outFile, " Values ")
for i = 1:5
    write(outFile, " & ")
    write(outFile, "\\multicolumn{2}{c}{")
    write(outFile, join(tuning_param[i]," "))
    write(outFile, "}")
end
write(outFile, "\\\\")
write(outFile, "\n")
write(outFile, "\\cmidrule(r){2-3}\\cmidrule(r){4-5}\\cmidrule(r){6-7}\\cmidrule(r){8-9}\\cmidrule(r){10-11}
Instance & \\begin{tabular}[c]{@{}c@{}}Avg. imp. \\\\  (\\%)\\end{tabular} & Std & \\begin{tabular}[c]{@{}c@{}}Avg. imp. \\\\  (\\%)\\end{tabular} & Std & \\begin{tabular}[c]{@{}c@{}}Avg. imp. \\\\  (\\%)\\end{tabular} & Std & \\begin{tabular}[c]{@{}c@{}}Avg. imp. \\\\  (\\%)\\end{tabular} & Std & \\begin{tabular}[c]{@{}c@{}}Avg. imp. \\\\  (\\%)\\end{tabular} & Std \\\\
\\midrule ")
write(outFile, "\n")

for file in filepath
    f = open(file)
    readline(f)
    readline(f)
    readline(f)
    readline(f)
    readline(f)
    readline(f)
    readline(f)
    readline(f)
    readline(f)
    if parameter == "W"
        for i = 1:5
            readline(f)
        end
    else
        readline(f)
    end
    readline(f)
    readline(f)
    readline(f)
    readline(f)
    readline(f)
    readline(f)
    readline(f)
    readline(f)
    readline(f)
    readline(f)
    readline(f)
    readline(f)
    readline(f)
    readline(f)
    std = parse.(Float64, split(readline(f)))
    readline(f)
    readline(f)
    avg = parse.(Float64, split(readline(f)))

   
    nameandtype = rsplit(split(file, "/")[4], "_",limit = 2)
        write(outFile, "\$" * string(\) * "texttt{")
        write(outFile, replace(nameandtype[1], "_" => "\\_") * "} \$")
        for i = 1:5
            write(outFile, " & ")
            write(outFile, join(round(avg[i]*100,sigdigits = rounddigitsavg)," "))
            write(outFile, " &  ")
            write(outFile, join(round(std[i],sigdigits = rounddigitsstd)," "))
            avg_sum[i] += avg[i]*100
            std_sum[i] += std[i]
        end
            write(outFile, "\\\\")
            write(outFile, "\n")
end
write(outFile, "\\midrule ")
write(outFile, "Average")
for i = 1:5
    write(outFile, " &  ")
    write(outFile, join(round(avg_sum[i]/6,sigdigits = rounddigitsavg)," "))
    write(outFile, " &  ")
    write(outFile, join(round(std_sum[i]/6,sigdigits = rounddigitsstd)," "))
end
write(outFile, "\\\\")

close(outFile)