using Dash, DashHtmlComponents, DashCoreComponents
using PlotlyJS
using JSON
using Dates

using CSV
using DataFrames


df = CSV.read("/home/prabu/Research/mintsData/rawJld/001e06305a6c_df.csv", DataFrame)


function plotPM()

    OPCN2_pm1 = scatter(x = df.dateTime, y = df.OPCN2_pm1,
                        mode = "lines+markers", name = "OPCN2 PM1",
                        marker_color = :red, marker_size = 4)

    OPCN2_pm2_5 = scatter(x = df.dateTime, y = df.OPCN2_pm2_5,
                        mode = "lines+markers", name = "OPCN2 PM2.5",
                        marker_color = :blue, marker_size = 4)

    OPCN2_pm10 = scatter(x = df.dateTime, y = df.OPCN2_pm10,
                        mode = "lines+markers", name = "OPCN2 PM10",
                        marker_color = :black, marker_size = 4)

    layout = Layout(title = "PM1", xaxis_title = "DateTime", yaxis_title = "PM1",
                  plot_bgcolor = :transparent, paper_bgcolor = :transparent)

  plot([OPCN2_pm1, OPCN2_pm2_5, OPCN2_pm10], layout)
end


function plotCO2()

    SCD30_c02 = scatter(x = df.dateTime, y = df.SCD30_c02,
                        mode = "lines+markers", name = "SCD30",
                        marker_color = :red, marker_size = 4)

    layout = Layout(title = "CO2", xaxis_title = "DateTime", yaxis_title = "CO2",
                  plot_bgcolor = :transparent, paper_bgcolor = :transparent)

  plot([SCD30_c02], layout)
end



function plotTemp()

    AS7262_temp = scatter(x = df.dateTime, y = df.AS7262_temperature,
                  mode = "lines+markers",name = "AS7262",
                  marker_color = :red,marker_size = 4)

    BME280_temp = scatter(x = df.dateTime, y = df.BME280_temperature,
                  mode = "lines+markers", name = "BME280",
                  marker_color = :blue, marker_size = 4)

    SCD30_temp = scatter(x = df.dateTime, y = df.SCD30_temperature,
                 mode = "lines+markers", name = "SCD30",
                 marker_color = :black, marker_size = 4)

    layout = Layout(title = "Temperature", xaxis_title = "DateTime", yaxis_title = "Temperature",
                    plot_bgcolor = :transparent, paper_bgcolor = :transparent)

    plot([AS7262_temp, BME280_temp, SCD30_temp], layout)
end


function plotPressure()

    BME280_pressure = scatter(x = df.dateTime, y = df.BME280_pressure,
                        mode = "lines+markers", name = "BME280",
                        marker_color = :red, marker_size = 4)

    layout = Layout(title = "Pressure", xaxis_title = "DateTime", yaxis_title = "Pressure",
                  plot_bgcolor = :transparent, paper_bgcolor = :transparent)

  plot([BME280_pressure], layout)
end


function plotHumidity()

    BME280_humidity = scatter(x = df.dateTime, y = df.BME280_humidity,
                        mode = "lines+markers", name = "BME280",
                        marker_color = :red, marker_size = 4)

    SCD30_humidity = scatter(x = df.dateTime, y = df.SCD30_humidity,
                        mode = "lines+markers", name = "SCD30",
                        marker_color = :blue, marker_size = 4)

    layout = Layout(title = "Humidity", xaxis_title = "DateTime", yaxis_title = "Humidity",
                  plot_bgcolor = :transparent, paper_bgcolor = :transparent)

  plot([BME280_humidity, SCD30_humidity], layout)
end




app = dash()

app.layout = html_div() do
    html_h1(
        "MINTS Dashboards: UTD Nodes", style=Dict("color"=>:black, "textAlign"=>"center")),

    html_div(
        children = [
            dcc_graph(id="pm1-graph", figure = plotPM()),
            dcc_graph(id="CO2-graph", figure = plotCO2()),
            dcc_graph(id="temp-graph", figure = plotTemp()),
            dcc_graph(id="pressure-graph", figure = plotPressure()),
            dcc_graph(id="humidity-graph", figure = plotHumidity()),

            dcc_interval(id="interval-component", interval = 250, n_intervals=0),
        ],
    )
end

run_server(app, "0.0.0.0", debug=true)
