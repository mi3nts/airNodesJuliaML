# import Pkg; 

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


yamlFile = YAML.load_file("../mintsDefinitionsV2.yaml"; dicttype=OrderedDict{String,Any})      # loading yaml file and arrange in order
dirctory = yamlFile["dataFolder"]                            # taking the directory of data stored
sensorNames = yamlFile["liveStack"]                         # all the sensor names
#sensorNames = ["PPD42NSDuo"]

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
        #df.dateTime =  SubString.(string.(df.dateTime), 1, 19)                  # Removing last three decimal numbers in dateTime column

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

        df1 = df
        df2 = df[1:2,:]

        try
            #df1 = df
            df1.dateTime =  SubString.(string.(df1.dateTime), 1, 19)
            df1.dateTime = DateTime.(df1.dateTime,"yyyy-mm-dd HH:MM:SS")  

            df1.dateTime = map((x) -> round(x, Dates.Second(30)), df1.dateTime)       # Rounding dateTime for 30 seconds 
            gdf1 = groupby(df1, :dateTime)                                            # making groups by same dateTime
            cgdf1 = combine(gdf1, valuecols(gdf1) .=> mean)                            # Calculate the mean of each group and then combine the groups 
        
            colFullName = names(cgdf1)                                               # Take the column names of dataFrame into a array
            for x in 2:length(colFullName)                                          # Starting from 2nd column and go through all the columns                                
                num_let = length(colFullName[x])                                    # taking number of characters in one column name
                colName = SubString.(string.(colFullName[x]), 1, num_let-5)         # removing last five characters of each column name (that is _mean)
                rename!(cgdf1,colFullName[x] => sensr*"_"*colName)                   # adding sensor name to the column name
            end
        
            return cgdf1                             # return the dataFrame to for loop

        catch e
            println("Error on "*CSV_file)
            #df2 = df[1:10,:]

            if sensr == "GPSGPGGA2"
                clName = names(df2)
                if "Column18" in clName
                    df2 = select!(df2, Not(:Column18))
                end
                if "Column19" in clName
                    df2 = select!(df2, Not(:Column19))
                end
                
                try
                    df2.latitudeCoordinate = parse.(Float64, df2.latitudeCoordinate)
                    df2.longitudeCoordinate = parse.(Float64, df2.longitudeCoordinate)
                    df2.numberOfSatellites = parse.(Float64, df2.numberOfSatellites)
                catch e
                end
            end

            if sensr == "GPSGPRMC2"
                clName = names(df2)
                if "Column15" in clName
                    df2 = select!(df2, Not(:Column15))
                end
                if "Column16" in clName
                    df2 = select!(df2, Not(:Column16))
                end
                if "Column17" in clName
                    df2 = select!(df2, Not(:Column17))
                end
                if "Column18" in clName
                    df2 = select!(df2, Not(:Column18))
                end
                if "Column19" in clName
                    df2 = select!(df2, Not(:Column19))
                end
                if "Column20" in clName
                    df2 = select!(df2, Not(:Column20))
                end
                if "Column21" in clName
                    df2 = select!(df2, Not(:Column21))
                end
                
                try
                    #df2.latitudeCoordinate = parse.(Float64, df2.latitudeCoordinate)
                    #df2.longitudeCoordinate = parse.(Float64, df2.longitudeCoordinate)
                    df2.speedOverGround = parse.(Float64, df2.speedOverGround)
                    df2.longitude = parse.(Float64, df2.longitude)
                catch e
                end
            end

            if sensr == "PPD42NSDuo"
                clName = names(df2)
                if "Column10" in clName
                    df2 = select!(df2, Not(:Column10))
                end
                if "Column11" in clName
                    df2 = select!(df2, Not(:Column11))
                end
                
                try
                    df2.LPOPmMid = parse.(Float64, df2.LPOPmMid)
                catch e
                end
            end
            
            println(df2)
            df2.dateTime =  SubString.(string.(df2.dateTime), 1, 19)
            df2.dateTime = DateTime.(df2.dateTime,"yyyy-mm-dd HH:MM:SS") 

            df2.dateTime = map((x) -> round(x, Dates.Second(30)), df2.dateTime)       # Rounding dateTime for 30 seconds 
            gdf2 = groupby(df2, :dateTime)                                            # making groups by same dateTime
            cgdf2 = combine(gdf2, valuecols(gdf2) .=> mean)                            # Calculate the mean of each group and then combine the groups 

            colFullName = names(cgdf2)                                               # Take the column names of dataFrame into a array
            for x in 2:length(colFullName)                                          # Starting from 2nd column and go through all the columns                                
                num_let = length(colFullName[x])                                    # taking number of characters in one column name
                colName = SubString.(string.(colFullName[x]), 1, num_let-5)         # removing last five characters of each column name (that is _mean)
                rename!(cgdf2,colFullName[x] => sensr*"_"*colName)                   # adding sensor name to the column name
            end

            return cgdf2
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
                    println("Date: "*y*"_"*m*"_"*d)
                    println(sensr)
                    averaged_df = ss(d, m, y, sensr)
                    df2 = averaged_df
                    k = k + 1
                    
                    println("done")
                    global sensr_exsist = true
                    
                    if (k > 1)

                        #try
                        global new_df = outerjoin(new_df, df2, on = intersect(names(new_df), names(df2)))
                        #catch e
                            #println("Error of adding: "*"MINTS_"*nodeId*"_"*sensr*"_"*y*"_"*m*"_"*d*".csv")
                        #end

                    else
                        new_df = averaged_df
                    end

                else
                    println("No data of "*sensr)
                    sensr_exsist = false
                    #continue
                end                
            end
        end
    end       
    

    global n = n + 1

    if sensr_exsist

        if (n > 1)
            println("******************************************************")
            global final_df = outerjoin(final_df, new_df, on = :dateTime, makeunique=true) 
        else
            final_df = new_df
        end
 
    end

end


final_df2 = sort!(final_df)  
CSV.write("/mnt/3fbf694d-d8e0-46c0-903d-69d994241206/mintsData/avJlData/"*nodeId*"_df.csv", final_df2)

