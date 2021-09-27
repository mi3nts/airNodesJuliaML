using CSV, DataFrames, Dates



df1 = CSV.read("/mnt/3fbf694d-d8e0-46c0-903d-69d994241206/mintsData/raw/001e06305a6c/2019/11/09/MINTS_001e06305a6c_AS7262_2019_11_09.csv", DataFrame)         # Reading ith CSV data file
df2 = CSV.read("/mnt/3fbf694d-d8e0-46c0-903d-69d994241206/mintsData/raw/001e06305a6c/2019/11/08/MINTS_001e06305a6c_AS7262_2019_11_08.csv", DataFrame) 
#dfn = df[1:3,:]
#df.dateTime =  SubString.(string.(df.dateTime), 1, 19)  
#df.dateTime = DateTime.(df.dateTime,"yyyy-mm-dd HH:MM:SS") 
#DateTime.(df.dateTime[2],"yyyy-mm-dd HH:MM:SS") 
#skipmissing(df)
#df1 = df[1, :]
#df2 = df[2, :]

#println(dfn)
println(names(df1))
println(names(df2))

  #=                                          # Removing milisecond part of dateTime  
for i in 1:length(df.dateTime)   
    # println("========")
    # println(i)
    # print(df[i,:])
    # println("---------")
    # println(df.dateTime[i])
    try
        DateTime.(df.dateTime[i],"yyyy-mm-dd HH:MM:SS") 
    catch e
        println("========")
        println(i)
        println(e)
    end
   

end


    #println(df)
    #println(typeof(df.dateTime[7914]))

    =#