include("../../ReadWrite.jl")

parameter = "horizontalDestroy"

filepath = joinpath.("tuning/new_destroy_tune/results/" * parameter *"/", readdir("tuning/new_destroy_tune/results/" * parameter * "/"))
if length(filepath) > 6
    filepath = filepath[2:end]
end

outFile = open("tuning/new_destroy_tune/" * parameter * "_table", "w")

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
readline(f)
tuning_param = parse.(Float64, split(readline(f)))

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
stds=0
avgs=0
for file in filepath
    f = open(file)
    count = 0
    while count <= 6
        readline(f)
        count += 1
    end
    stds = parse.(Float64, split(readline(f)))
    readline(f)
    readline(f)
    avgs = parse.(Float64, split(readline(f)))

    name = split(split(file, "/")[5],".")[1]
    write(outFile, "\$" * string(\) * "texttt{")
    write(outFile, replace(name, "_" => "\\_") * "} \$")
    for i = 1:5
        write(outFile, " & ")
        write(outFile, join(round(avgs[i]*100,sigdigits = rounddigitsavg)," "))
        write(outFile, " &  ")
        write(outFile, join(round(stds[i],sigdigits = rounddigitsstd)," "))
        avg_sum[i] += avgs[i]*100
        std_sum[i] += stds[i]
    end
    write(outFile, "\\\\")
    write(outFile, "\n")
end
write(outFile, "\\midrule ")
write(outFile, "Average")
for i = 1:5
    write(outFile, " &  ")
    write(outFile, join(round(avg_sum[i]/length(filepath),sigdigits = rounddigitsavg)," "))
    write(outFile, " &  ")
    write(outFile, join(round(std_sum[i]/length(filepath),sigdigits = rounddigitsstd)," "))
end
write(outFile, "\\\\")

close(outFile)
