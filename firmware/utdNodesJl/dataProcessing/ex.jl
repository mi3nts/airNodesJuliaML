#import Pkg; 

#Pkg.add("HDF5")
#Pkg.add("FeatherFiles")
#Pkg.add("JLD")
#Pkg.add("FileIO")
#Pkg.add("JLD2")


using CSV, DataFrames, Dates
using Statistics
using HDF5
using Serialization
using FeatherFiles
using JLD
using FileIO
using JLD2


path1 = "/mnt/3fbf694d-d8e0-46c0-903d-69d994241206/mintsData/raw/001e06305a6c/2019/07/22/"
path2 = "/mnt/3fbf694d-d8e0-46c0-903d-69d994241206/mintsData/raw/001e06305a6c/2019/07/23/"

csv_file1  = "MINTS_001e06305a6c_AS7262_2019_07_22.csv"
csv_file2  = "MINTS_001e06305a6c_AS7262_2019_07_23.csv"

df1 = CSV.read(path1 * csv_file1, DataFrame)      
df2 = CSV.read(path1 * csv_file1, DataFrame) 

df = [df1, df2]


df1.dateTime = SubString.(string.(df1.dateTime), 1, 19) 
df1.dateTime = DateTime.(df1.dateTime,"yyyy-mm-dd HH:MM:SS") 

#aa = df1[1,:]
#=
df1.dateTime[2] = round(df1[2,:].dateTime, Dates.Second(30))
println(df1)

serialize("/mnt/3fbf694d-d8e0-46c0-903d-69d994241206/mintsData/avJlData/"*nodeId*"_dataF.jls", df1)
df2 = deserialize("/mnt/3fbf694d-d8e0-46c0-903d-69d994241206/mintsData/avJlData/"*nodeId*"_dataF.jls")
println(df2)
=#


#df_csv = CSV.read("/mnt/3fbf694d-d8e0-46c0-903d-69d994241206/mintsData/avJlData/001e06305a6c_df.csv", DataFrame)
#println(df_csv)





df2 = deserialize("/mnt/3fbf694d-d8e0-46c0-903d-69d994241206/mintsData/avJlData/001e06305a6c_df2.jls")
#println(df2)




#save("/mnt/3fbf694d-d8e0-46c0-903d-69d994241206/mintsData/avJlData/output.feather", df1)



#df3 = DataFrame(load("/mnt/3fbf694d-d8e0-46c0-903d-69d994241206/mintsData/avJlData/output.feather"))
#println(df3[1,:])#Pkg.add("JLD")

#println(df1)

#h5write("/mnt/3fbf694d-d8e0-46c0-903d-69d994241206/mintsData/avJlData/test.h5", "mygroup2/A", df1)

#h5write("/mnt/3fbf694d-d8e0-46c0-903d-69d994241206/mintsData/avJlData/test.h5","abc",DateTime.(df1))

#h5write("/mnt/3fbf694d-d8e0-46c0-903d-69d994241206/mintsData/avJlData/test.h5", "mygroup/myDf", convert(Array, df1[:,]))

#=
h5open("/mnt/3fbf694d-d8e0-46c0-903d-69d994241206/mintsData/avJlData/test.h5", "w") do file
    write(file, "A", df1)  # alternatively, say "@write file A"
end



A = collect(reshape(1:120, 15, 8))
println(A)
h5write("/mnt/3fbf694d-d8e0-46c0-903d-69d994241206/mintsData/avJlData/test2.h5", "mygroup2/A", A)
=#

#gdf = []
#println(df1)
#println(df2)

#=
for i in 1:2
    df[i].dateTime = SubString.(string.(df[i].dateTime), 1, 19) 
    df[i].dateTime = DateTime.(df[i].dateTime,"yyyy-mm-dd HH:MM:SS") 

    df[i].dateTime = map((x) -> round(x, Dates.Second(30)), df[i].dateTime)
end


gdf1 = groupby(df1, :dateTime) 
gdf2 = groupby(df2, :dateTime) 

cgdf1 = combine(gdf1, valuecols(gdf1) .=> mean)  
cgdf2 = combine(gdf2, valuecols(gdf2) .=> mean)  


empty_df = empty(cgdf1::AbstractDataFrame)
#empty(df::AbstractDataFrame)

new_df = outerjoin(cgdf1, cgdf2, on = intersect(names(cgdf1), names(cgdf2)))
new_df2 = outerjoin(new_df, empty_df, on = intersect(names(new_df), names(empty_df)))

println(new_df2)

#df = df[1:5,:]
#println(names(df))
clName = names(df)
    df.dateTime =  SubString.(string.(df.dateTime), 1, 19)                                                      # Removing milisecond part of dateTime     
    df.dateTime = DateTime.(df.dateTime,"yyyy-mm-dd HH:MM:SS") 


    #if sensr == "GPSGPGGA2"
        df = select!(df, Not(:timestamp))
        df = select!(df, Not(:latitudeDirection))
        df = select!(df, Not(:longitudeDirection))
        df = select!(df, Not(:altitudeUnits))
        df = select!(df, Not(:undulationUnits))
        df = select!(df, Not(:age))
        df = select!(df, Not(:stationID))
    #end

    if "Column18" in clName
        df = select!(df, Not(:Column18))
    end

    if "Column19" in clName
        df = select!(df, Not(:Column19))
    end

    #df.latitudeCoordinate = Float64.(df.latitudeCoordinate)
    try
        df.latitudeCoordinate = parse.(Float64, df.latitudeCoordinate)
        df.longitudeCoordinate = parse.(Float64, df.longitudeCoordinate)
        df.numberOfSatellites = parse.(Float64, df.numberOfSatellites)
    catch e
        println(e)
    end
    
    #println(names(df))
    #=
    for i in 1:length(df.dateTime)
        println(i)  
        DateTime.(df.dateTime[i],"yyyy-mm-dd HH:MM:SS")  
    end 
    #println(df)
    =#

    #=
    try
        df.dateTime = map((x) -> round(x, Dates.Second(30)), df.dateTime)       # Rounding dateTime for 30 seconds 
        gdf = groupby(df, :dateTime)                                            # making groups by same dateTime
        cgdf = combine(gdf, valuecols(gdf) .=> mean)   
    catch e
        df = df[1:10,:]
        df.dateTime = map((x) -> round(x, Dates.Second(30)), df.dateTime)       # Rounding dateTime for 30 seconds 
        gdf = groupby(df, :dateTime)                                            # making groups by same dateTime
        cgdf = combine(gdf, valuecols(gdf) .=> mean)  
    end
    =#

    
    println(df)
    df.dateTime = map((x) -> round(x, Dates.Second(30)), df.dateTime)
    gdf = groupby(df, :dateTime)                                            # making groups by same dateTime
    cgdf = combine(gdf, valuecols(gdf) .=> mean)  




    println(cgdf)

    =#