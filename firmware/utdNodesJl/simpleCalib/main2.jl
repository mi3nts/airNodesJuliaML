

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
#sensorNames = yamlFile["liveStack"]                         # all the sensor names
sensorNames = ["AS7262","BME280","MGS001",]


# only 11th node data is saved
nodeIDs_array = yamlFile["nodeIDs"]                         # node's IDs array
node11 = nodeIDs_array[11]                                  # Taking 11th node 
nodeId = node11["nodeID"]                                   # taking 11th nodeID

path = dirctory*"/"*nodeId






############# anaylzing and averaging data of AS7262 sensor
function ss(dd, mm, yy, sensr)
    CSV_fileName_arry = readdir(path*"/"*yy*"/"*mm*"/"*dd*"/")       # taking all the file names from the folder
    num_files = length(CSV_fileName_arry)                            # number of files
    
    CSV_file = "MINTS_"*nodeId*"_"*sensr*"_"*yy*"_"*mm*"_"*dd*".csv"
    if (CSV_file in CSV_fileName_arry)
        df = CSV.read(path*"/"*yy*"/"*mm*"/"*dd*"/"*CSV_file, DataFrame)
        df.dateTime =  SubString.(string.(df.dateTime), 1, 19)  
        df.dateTime = DateTime.(df.dateTime,"yyyy-mm-dd HH:MM:SS")   

        df.dateTime = map((x) -> round(x, Dates.Second(30)), df.dateTime)  
        gdf = groupby(df, :dateTime)                                                                                # making groups by same dateTime
        cgdf = combine(gdf, valuecols(gdf) .=> mean)    
        


        colFullName = names(cgdf)  
        for x in 2:length(colFullName)                                              
            num_let = length(colFullName[x])                                        # taking number of characters in one column name
            colName = SubString.(string.(colFullName[x]), 1, num_let-5)             # removing last five characters of each column name
            rename!(cgdf,colFullName[x] => sensr*"_"*colName)                       # adding sensor name to the column name
        end
        
        return cgdf
    end


end





n = 0

for sensr in sensorNames
    k = 0

    years = readdir(path) 

    for y in years
        months = readdir(path*"/"*y)

        for m in months
            days = readdir(path*"/"*y*"/"*m)

            for d in days

                filess = readdir(path*"/"*y*"/"*m*"/"*d)
                CSV_file = "MINTS_"*nodeId*"_"*sensr*"_"*y*"_"*m*"_"*d*".csv"

                if (CSV_file in filess)
                    println("Date: "*y*"_"*m*"_"*d)
                    averaged_df = ss(d, m, y, sensr)
                    df2 = averaged_df
                    k = k + 1
                    
                    if (k > 1)
                        global new_df = outerjoin(new_df, df2, on = intersect(names(new_df), names(df2)))
                    else
                        new_df = averaged_df
                    end
                else
                    println("No data of "*sensr)
                    continue
                end
                #=

                    averaged_df = ss(d, m, y, sensr)
                    df2 = averaged_df

                    k = k + 1

                    

                    if (k > 1)
                        global new_df = outerjoin(new_df, df2, on = intersect(names(new_df), names(df2)))
                    else
                        new_df = averaged_df
                    end

                    =#
                
            end

        end

    end       
    
    
    global n = n + 1

    if (n > 1)
        global final_df = outerjoin(final_df, new_df, on = :dateTime, makeunique=true) 
    else
        final_df = new_df
    end
    

    

end


final_df2 = sort!(final_df)  
CSV.write("/home/prabu/dfcomfff.csv", final_df2)


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
