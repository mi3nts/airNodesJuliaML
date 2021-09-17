

import YAML
# import Pkg; Pkg.add("OrderedCollections")

# Pkg.add("YAML")

using OrderedCollections
using CSV
using DataFrames 
using Dates
using Query
using Statistics

# data = YAML.load_file("../mintsDefinitionsV2.yaml")

yamlFile = YAML.load_file("../mintsDefinitionsV2.yaml"; dicttype=OrderedDict{String,Any})      # loading yaml file and arrange in order
dirctory = yamlFile["dataFolder"]                            # taking the directory of data stored
sensorNames = yamlFile["liveStack"]                         # all the sensor names

# only 11th node data is saved
nodeIDs_array = yamlFile["nodeIDs"]                         # node's IDs array
node11 = nodeIDs_array[11]                                  # Taking 11th node 
nodeId = node11["nodeID"]                                   # taking 11th nodeID


#path1 = dirctory*"/"*nodeId*"/2019/07/20/"         # path of CSV data files stored
#path2 = dirctory*"/"*nodeId*"/2019/07/22/"

path = dirctory*"/"*nodeId

function g(dd, mm, yy)
    CSV_fileName_arry = readdir(path*"/"*yy*"/"*mm*"/"*dd*"/")       # taking all the file names from the folder
    num_files = length(CSV_fileName_arry)                            # number of files
    
    CSV_file = "MINTS_"*nodeId*"_"*sensorNames[1]*"_"*yy*"_"*mm*"_"*dd*".csv"
    if (CSV_file in CSV_fileName_arry)
        df = CSV.read(path*"/"*yy*"/"*mm*"/"*dd*"/"*CSV_file, DataFrame)
        df.dateTime =  SubString.(string.(df.dateTime), 1, 19)  
        df.dateTime = DateTime.(df.dateTime,"yyyy-mm-dd HH:MM:SS")   

        df.dateTime = map((x) -> round(x, Dates.Second(30)), df.dateTime)  
        gdf = groupby(df, :dateTime)                                                                                # making groups by same dateTime
        cgdf = combine(gdf, valuecols(gdf) .=> mean)    
        return cgdf
    end

end


k = 0
new_df = 0

years = readdir(path) 
for y in years
    months = readdir(path*"/"*y)

    for m in months
        days = readdir(path*"/"*y*"/"*m)
        
        for d in days
            va = g(d, m, y)

            df2 = va
             
            global k = k + 1
            global new_df

            if (k > 1)
                new_df = outerjoin(new_df, df2, on = intersect(names(new_df), names(df2)))
            else
                new_df = va

            end

            
            

        end

        
    end
end

CSV.write("/home/prabu/dfcom3.csv", new_df)



#println(sensorName)

#=

############ read each CSV file and take average
for i in 1:num_files-1
    df = CSV.read("/home/prabu/Research/mintsData/001e06305a6c/2019/07/20/"*CSV_fileName[i], DataFrame)         # Reading ith CSV data file
    df.dateTime =  SubString.(string.(df.dateTime), 1, 19)                                                      # Removing milisecond part of dateTime     
    df.dateTime = DateTime.(df.dateTime,"yyyy-mm-dd HH:MM:SS")                                                  # converting to dateTime

    df.dateTime = map((x) -> round(x, Dates.Second(30)), df.dateTime)                                           # rounding dateTime column for 30s
    gdf = groupby(df, :dateTime)                                                                                # making groups by same dateTime
    cgdf = combine(gdf, valuecols(gdf) .=> mean)                                                                # taking average of same group and combine
    push!(dfArray,cgdf)                                                                                         # put the DataFrame in the array

    sName =  SubString.(string.(CSV_fileName[i]), 20, 25)                                                       # taking sensor name from CSV file
    push!(sensorName,sName)                                                                                     # put sensor name in the array
end

=#



#=
arry = []
for (root, dirs, files) in walkdir(path)
    arr = joinpath.(root, files) # files is a Vector{String}, can be empty
    push!(arry, arr)
end
println(arry[4])
=#


#=
CSV_fileName1 = readdir(path1)       # taking all the file names from the folder
num_files1 = length(CSV_fileName1)                             # number of files
df1 = CSV.read(path1*CSV_fileName1[1], DataFrame)

CSV_fileName2 = readdir(path2)       # taking all the file names from the folder
num_files2 = length(CSV_fileName2)                             # number of files
df2 = CSV.read(path2*CSV_fileName2[1], DataFrame)
=#

#new_df = outerjoin(df1, df2, on = intersect(names(df1), names(df2)))

#CSV.write("/home/prabu/dfcom3.csv", new_df)
#println("Done")
