import Pkg
using Pkg

# Pkg.add("CSV")
# Pkg.add("DataFrames")
# Pkg.add("Query")
# Pkg.add("Plots")

using CSV
using DataFrames 
using Dates
using Query
using Statistics
using Plots

CSV_fileName = readdir("/home/prabu/Research/mintsData/001e06305a6c/2019/07/20/")       # taking all the file names from the folder
num_files = length(CSV_fileName)                                                        # number of files

dfArray = []            # Define an array of DataFrames (all CSV files)
sensorName = []         # Define an array for abstract sensor names from CSV file.

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

########### change the column name of each DataFrames
for j in 1:length(sensorName)
    colFullName = names(dfArray[j])                                             # taking all the column name of one DataFrame

    for x in 2:length(colFullName)                                              
        num_let = length(colFullName[x])                                        # taking number of characters in one column name
        colName = SubString.(string.(colFullName[x]), 1, num_let-5)             # removing last five characters of each column name
        rename!(dfArray[j],colFullName[x] => sensorName[j]*"_"*colName)         # adding sensor name to the column name
    end

end

########### combine all the DataFrames
new_df = dfArray[1]                                                                             # first DataFrame
for x in 1:length(dfArray)-1
    global new_df = outerjoin(new_df, dfArray[x+1], on = :dateTime, makeunique=true)            # combine all the DataFrames together
end

final_df = sort!(new_df)                                # arranging raws of total DataFrame in ascending order by dateTime

println(final_df)
CSV.write("/home/prabu/dfcom3.csv", final_df)


plot(final_df.dateTime, final_df.AS7262_temperature)