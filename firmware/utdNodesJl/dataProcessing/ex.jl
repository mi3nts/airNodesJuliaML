using CSV, DataFrames, Dates



df = CSV.read("/mnt/3fbf694d-d8e0-46c0-903d-69d994241206/mintsData/2019 11/08/MINTS_001e06305a6c_AS7262_2019_11_08.csv", DataFrame)         # Reading ith CSV data file
    df.dateTime =  SubString.(string.(df.dateTime), 1, 19)                                                      # Removing milisecond part of dateTime     
    df.dateTime = DateTime.(df.dateTime,"yyyy-mm-dd HH:MM:SS")     
    println(df)