#import Pkg; 

# Pkg.add("JLD")
# Pkg.add("PlotlyJS")
# Pkg.add("JSON")
# Pkg.add("JuMP")
# Pkg.add("YAML")
# Pkg.add("CSV")
# Pkg.add("DataFrames")
# Pkg.add("Query")
# Pkg.add("OrderedCollections")
# Pkg.add("Missings")
#Pkg.add("JDF")

import YAML

# using JLD
using OrderedCollections
using CSV
using DataFrames 
using Dates
using Query
using Statistics
using JuMP
using Missings
# using JDF
#using Serialization

println("Started")

yamlFile = YAML.load_file("/mnt/861c9f85-a9ba-440b-8815-065043e41e1a/gitHubRepos/airNodesJuliaML/firmware/utdNodesJl/mintsDefinitionsV2.yaml"; dicttype=OrderedDict{String,Any})  
#yamlFile = YAML.load_file("../mintsDefinitionsV2.yaml"; dicttype=OrderedDict{String,Any})      # loading yaml file and arrange in order
dirctory = yamlFile["dataFolder"]                            # taking the directory of data stored
sensorNames = yamlFile["liveStack"]                         # all the sensor names
#sensorNames = ["TSL2591"]

# only 11th node data is saved
nodeIDs_array = yamlFile["nodeIDs"]                         # node's IDs array
node11 = nodeIDs_array[11]                                  # Taking 11th node 
nodeId = node11["nodeID"]                                   # taking 11th nodeID

path = dirctory*"/"*nodeId


############# anaylzing and averaging data
function ss(dd, mm, yy, sensr)
    CSV_fileName_arry = readdir(path*"/"*yy*"/"*mm*"/"*dd*"/")       # taking all the file names from the folder
    num_files = length(CSV_fileName_arry)                            # number of files
    
    CSV_file = "MINTS_"*nodeId*"_"*sensr*"_"*yy*"_"*mm*"_"*dd*".csv"            # CSV file name
    if (CSV_file in CSV_fileName_arry)                                          # check CSV fime exist or not
        df = CSV.read(path*"/"*yy*"/"*mm*"/"*dd*"/"*CSV_file, DataFrame)        # If the CSV file exist then take the data into a dataframe
        
        if sensr == "GPSGPGGA2"
            df = select!(df, Not(:timestamp))
            df = select!(df, Not(:latitudeDirection))
            df = select!(df, Not(:longitudeDirection))
            df = select!(df, Not(:altitudeUnits))
            df = select!(df, Not(:undulationUnits))
            df = select!(df, Not(:age))
            df = select!(df, Not(:stationID))
        end

        if sensr == "GPSGPRMC2"
            df = select!(df, Not(:timestamp))
            df = select!(df, Not(:status))
            df = select!(df, Not(:latitudeDirection))
            df = select!(df, Not(:longitudeDirection))
            df = select!(df, Not(:dateStamp))
            df = select!(df, Not(:magVariation))
            df = select!(df, Not(:magVariationDirection))
            df = select!(df, Not(:trueCourse))
        end

        try
            df.dateTime =  SubString.(string.(df.dateTime), 1, 19)
            df.dateTime = DateTime.(df.dateTime,"yyyy-mm-dd HH:MM:SS")  

            df.dateTime = map((x) -> round(x, Dates.Second(30)), df.dateTime)       # Rounding dateTime for 30 seconds 
            gdf = groupby(df, :dateTime)                                            # making groups by same dateTime
            cgdf = combine(gdf, valuecols(gdf) .=> mean)                            # Calculate the mean of each group and then combine the groups 
        
            colFullName = names(cgdf)                                               # Take the column names of dataFrame into a array
            for x in 2:length(colFullName)                                          # Starting from 2nd column and go through all the columns                                
                num_let = length(colFullName[x])                                    # taking number of characters in one column name
                colName = SubString.(string.(colFullName[x]), 1, num_let-5)         # removing last five characters of each column name (that is _mean)
                rename!(cgdf,colFullName[x] => sensr*"_"*colName)                   # adding sensor name to the column name
            end
        
            return cgdf                             # return the dataFrame to for loop

        catch e
            println("Error on "*CSV_file)

            colFullName = names(df)                                               # Take the column names of dataFrame into a array
            for x in 2:length(colFullName)                                          # Starting from 2nd column and go through all the columns
                rename!(df,colFullName[x] => sensr*"_"*colFullName[x])                   # adding sensor name to the column name
            end

            cgdf = empty(df::AbstractDataFrame)
            return cgdf
        end
    end
end


#global sensr_exsist = false
n = 0

for sensr in sensorNames                                                # Go through all the sensor names
    k = 0
    years = readdir(path)                                               # taking all the year folder names 

    for y in years                                                      # 
        months = readdir(path*"/"*y)

        for m in months
            days = readdir(path*"/"*y*"/"*m)

            for d in days
                filess = readdir(path*"/"*y*"/"*m*"/"*d)
                CSV_file = "MINTS_"*nodeId*"_"*sensr*"_"*y*"_"*m*"_"*d*".csv"

                if (CSV_file in filess)
                    averaged_df = ss(d, m, y, sensr)
                    df2 = averaged_df
                    k = k + 1
                    
                    mapcols(col -> replace!(col, NaN=>0), df2)

                    println(y*"_"*m*"_"*d*"_"*sensr*" - done")
                    global sensr_exist = true
                    
                    if (k > 1)
                        global new_df = outerjoin(new_df, df2, on = intersect(names(new_df), names(df2)))
                    else
                        new_df = averaged_df
                    end

                else
                    println("No data of "*sensr)
                    sensr_exist = false
                end                
            end
        end
    end       

    global n = n + 1

    if sensr_exist
        if (n > 1)
            global final_df = outerjoin(final_df, new_df, on = :dateTime, makeunique=true) 
        else
            final_df = new_df
        end
    end
end

final_df2 = sort!(final_df)  

println("Anaylzing done")
JDF.save("/mnt/3fbf694d-d8e0-46c0-903d-69d994241206/mintsData/avJlData/"*nodeId*"_df.jdf", final_df2)

println("Data saved")

#CSV.write("/mnt/3fbf694d-d8e0-46c0-903d-69d994241206/mintsData/avJlData/"*nodeId*"_df.csv", final_df2)
#serialize("/mnt/3fbf694d-d8e0-46c0-903d-69d994241206/mintsData/avJlData/"*nodeId*"_df2.jls", final_df2)



