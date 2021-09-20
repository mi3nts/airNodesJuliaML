import YAML

using OrderedCollections
using CSV
using DataFrames 
using Dates
using Query
using Statistics


yamlFile = YAML.load_file("../mintsDefinitionsV2.yaml"; dicttype=OrderedDict{String,Any})      # loading yaml file and arrange in order
dirctory = yamlFile["dataFolder"]                            # taking the directory of data stored
#sensorNames = yamlFile["liveStack"]                         # all the sensor names
sensorNames = ["AS7262","BME280","MGS001",]

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
        df.dateTime =  SubString.(string.(df.dateTime), 1, 19)                  # Removing last three decimal numbers in dateTime column
        df.dateTime = DateTime.(df.dateTime,"yyyy-mm-dd HH:MM:SS")              # Converting to dataTime format

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
    end

end





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
CSV.write("/home/prabu/dfcomfff2.csv", final_df2)

