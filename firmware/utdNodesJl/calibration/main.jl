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

#import YAML

# using JLD
#using OrderedCollections
using CSV
using DataFrames 
using Dates
#using Query
using Statistics
#using JuMP
#using Missings
#using Serialization
using JDF

println("Started")

nodeId = "001e0610c0e4"
path = "/mnt/3fbf694d-d8e0-46c0-903d-69d994241206/mintsData/reference"*"/"*nodeId

files = readdir(path)
year = []

for x in files
    ex = findlast(isequal('.'),x)
    if ex == nothing
        push!(year,x)
    end
end

#files = map((files) -> findlast(isequal('.'),files), files) 
#println(files)

sensor_names = ["GPGGA", "GPVTG", "HCHDT", "WIMDA", "WIMWV", "YXXDR"]
#sensor_names = ["GPVTG"]

function average(yy, mm, dd, ss)
    csv_arry = readdir(path*"/"*yy*"/"*mm*"/"*dd)
    CSV_file = "MINTS_"*nodeId*"_"*ss*"_"*yy*"_"*mm*"_"*dd*".csv"

    if (CSV_file in csv_arry)
        df = CSV.read(path*"/"*yy*"/"*mm*"/"*dd*"/"*CSV_file, DataFrame)

        if ss == "GPGGA"
            df = select!(df, Not(:latDirection))
            df = select!(df, Not(:lonDirection))
            df = select!(df, Not(:AUnits))
            df = select!(df, Not(:GSUnits))
            df = select!(df, Not(:ageOfDifferential))
            df = select!(df, Not(:stationID))
            df = select!(df, Not(:checkSum))
        end

        if ss == "GPVTG"
            df = select!(df, Not(:relativeToTN))
            df = select!(df, Not(:relativeToMN))
            df = select!(df, Not(:SOGKUnits))
            df = select!(df, Not(:SOGKMPHUnits))
            df = select!(df, Not(:mode))
            df = select!(df, Not(:checkSum))
        end

        if ss == "HCHDT"
            df = select!(df, Not(:HID))
            df = select!(df, Not(:checkSum))
        end

        if ss == "WIMDA"
            df = select!(df, Not(:BPMUnits))
            df = select!(df, Not(:BPBUnits))
            df = select!(df, Not(:ATUnits))
            df = select!(df, Not(:waterTemperature))
            df = select!(df, Not(:WTUnits))
            df = select!(df, Not(:absoluteHumidity))
            df = select!(df, Not(:DPUnits))
            df = select!(df, Not(:WDTUnits))
            df = select!(df, Not(:WDMUnits))
            df = select!(df, Not(:WSKUnits))
            df = select!(df, Not(:WSMPSUnits))
            df = select!(df, Not(:checkSum))
        end

        if ss == "WIMWV"
            df = select!(df, Not(:WAReference))
            df = select!(df, Not(:WSUnits))
            df = select!(df, Not(:status))
            df = select!(df, Not(:checkSum))
        end

        if ss == "YXXDR"
            df = select!(df, Not(:temperature))
            df = select!(df, Not(:relativeWindChillTemperature))
            df = select!(df, Not(:TUnits))
            df = select!(df, Not(:RWCTID))
            df = select!(df, Not(:RWCTUnits))
            df = select!(df, Not(:theoreticalWindChillTemperature))
            df = select!(df, Not(:TUnits2))
            df = select!(df, Not(:TWCTID))
            df = select!(df, Not(:TWCTUnits))
            df = select!(df, Not(:heatIndex))
            df = select!(df, Not(:HIUnits))
            df = select!(df, Not(:HIID))
            df = select!(df, Not(:pressureUnits))
            df = select!(df, Not(:BPBUnits))
            df = select!(df, Not(:BPBID))
            df = select!(df, Not(:checkSum))
        end

        try
            df.dateTime =  SubString.(string.(df.dateTime), 1, 19)
            df.dateTime = DateTime.(df.dateTime,"yyyy-mm-dd HH:MM:SS") 

            df.dateTime = map((x) -> round(x, Dates.Second(30)), df.dateTime)       # Rounding dateTime for 30 seconds 
            gdf = groupby(df, :dateTime)                                            # making groups by same dateTime
            cgdf = combine(gdf, valuecols(gdf) .=> mean) 

            cgdf = dropmissing(cgdf)

            colFullName = names(cgdf)                                               # Take the column names of dataFrame into a array
            for x in 2:length(colFullName)                                          # Starting from 2nd column and go through all the columns                                
                num_let = length(colFullName[x])                                    # taking number of characters in one column name
                colName = SubString.(string.(colFullName[x]), 1, num_let-5)         # removing last five characters of each column name (that is _mean)
                rename!(cgdf,colFullName[x] => ss*"_"*colName)                   # adding sensor name to the column name
            end

            return cgdf

        catch e
            println(e)

            colFullName = names(df)                                               # Take the column names of dataFrame into a array
            for x in 2:length(colFullName)                                          # Starting from 2nd column and go through all the columns    
                rename!(df,colFullName[x] => ss*"_"*colFullName[x])                   # adding sensor name to the column name
            end

            cgdf = empty(df::AbstractDataFrame)
            println("pass empty_____"*yy*"_"*mm*"_"*dd)
            return cgdf
        end   
    end
end


n = 0

for s in sensor_names
    k = 0
    for y in year
        month = readdir(path*"/"*y)
        for m in month
           day = readdir(path*"/"*y*"/"*m)
           for d in day
               csv_files = readdir(path*"/"*y*"/"*m*"/"*d)
               csv = "MINTS_"*nodeId*"_"*s*"_"*y*"_"*m*"_"*d*".csv" 
               

               if (csv in csv_files)
                    df_average = average(y, m, d, s)
                    df2 = df_average
                    k = k + 1

                    global sensr_exist = true

                    if (k > 1)
                        global new_df = outerjoin(new_df, df2, on = intersect(names(new_df), names(df2)))
                    else
                        new_df = df_average
                    end

                    empty_col_arry = names(new_df, any.(ismissing, eachcol(new_df)))
                    for u in 1:length(empty_col_arry)
                        empty_col_name = empty_col_arry[u]
                        new_df = select!(new_df, Not(empty_col_name))
                    end
                    
    
                else
                    println(s*"_doesnt exist")
                    sensr_exist = false
                end

                println(s*"_"*y*"_"*m*"_"*d*" - Done")
           end
        end
    end

    global n = n + 1

    if sensr_exist
        if (n > 1)
            println("******************************************************")
            global final_df = outerjoin(final_df, new_df, on = :dateTime, makeunique=true) 
        else
            final_df = new_df
        end
    end

end

final_df2 = sort!(final_df) 
JDF.save("/mnt/3fbf694d-d8e0-46c0-903d-69d994241206/mintsData/avJlData/"*nodeId*"_df_ref.jdf", final_df2)
println("Data saved")

#CSV.write("/mnt/3fbf694d-d8e0-46c0-903d-69d994241206/mintsData/avJlData/"*nodeId*"_df_ref2.csv", final_df2)
