#import Pkg; 

#Pkg.add("JDF")

using CSV
using DataFrames 
using Dates
using HDF5
using JLD
using JDF

println("started")
path1 = "/mnt/3fbf694d-d8e0-46c0-903d-69d994241206/mintsData/reference/001e0610c0e4/2019/05/01"

df1 = CSV.read(path1*"/MINTS_001e0610c0e4_GPGGA_2019_05_01.csv", DataFrame)
df1.dateTime =  SubString.(string.(df1.dateTime), 1, 19)
df1.dateTime = DateTime.(df1.dateTime,"yyyy-mm-dd HH:MM:SS") 

#col = names(df1)
#col_type = typeof(df1[:,1])
#println(col_type)

#ty = eltype.(eachcol(df1))
#println(ty)

#h5write("/mnt/3fbf694d-d8e0-46c0-903d-69d994241206/mintsData/avJlData/text8.h5", "top", df1[:,1])

#data = h5read("/mnt/3fbf694d-d8e0-46c0-903d-69d994241206/mintsData/avJlData/text8.h5", "top")

#h5write("/mnt/3fbf694d-d8e0-46c0-903d-69d994241206/mintsData/avJlData/text8.h5", "top", df1[:,1])

#=
h5open("/mnt/3fbf694d-d8e0-46c0-903d-69d994241206/mintsData/avJlData/text8.h5", "w") do file
    write(file, "top3", float.(df1[:,3]), "top4", string.(df1[:,4]))  # alternatively, say "@write file A"
end
=#

dd = h5read("/mnt/3fbf694d-d8e0-46c0-903d-69d994241206/mintsData/avJlData/text10.h5", "mygroup/myDf8")
println(dd)

#h5write("/mnt/3fbf694d-d8e0-46c0-903d-69d994241206/mintsData/avJlData/text10.h5", "mygroup/myDf10", string.(df1[:,1]))


#data = h5read(file, "/mnt/3fbf694d-d8e0-46c0-903d-69d994241206/mintsData/avJlData/text8.h5")
#println(data)


#JDF.save("/mnt/3fbf694d-d8e0-46c0-903d-69d994241206/mintsData/avJlData/text8.jdf", df1)
#a2 = DataFrame(JDF.load("/mnt/3fbf694d-d8e0-46c0-903d-69d994241206/mintsData/avJlData/001e06305a6c_df.jdf"))
#println(a2)

#=
df1.dateTime =  SubString.(string.(df1.dateTime), 1, 19)
df1.dateTime = DateTime.(df1.dateTime,"yyyy-mm-dd HH:MM:SS") 
df1.dateTime = map((x) -> round(x, Dates.Second(30)), df1.dateTime)       # Rounding dateTime for 30 seconds 
gdf1 = groupby(df1, :dateTime)                                            # making groups by same dateTime
cgdf1 = combine(gdf1, valuecols(gdf1) .=> mean) 
=#

#aa = mapcols(x -> any(ismissing.(x)), cgdf2)


println("done")


