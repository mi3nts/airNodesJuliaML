# import Pkg; 
# Pkg.add("Dash")
# Pkg.add("DashHtmlComponents")
# Pkg.add("DashCoreComponents")
# Pkg.add("PlotlyJS")
# Pkg.add("JSON")


using Dash, DashHtmlComponents, DashCoreComponents
using PlotlyJS
using JSON
using Dates


#=
function plotPM()
    # NOTE: we must use the semicolon in beginning of plotly commands as everything works via kwargs

    pm1 = scatter(;
                  x = [1, 2, 3, 4, 5],
                  y = [5, 10, 15, 10, 8],
                  mode = "lines+markers",
                  name = "PM 1",
                  marker_color = :red,
                  marker_size = 5,
                  )


    layout = Layout(;
                    title = "PM Levels",
                    xaxis_title = "time",
                    yaxis_title = "PM [μg/m³]",
                    plot_bgcolor = :transparent,
                    paper_bgcolor = :transparent,
                    )
    plot([pm1], layout)
end
=#



#=

function plotContour()


    data = contour(;
                   x = sensors[:OPCN3][:dt],
                   y = binCenters,
                   z = log10.(hcat(sensors[:OPCN3][:bins]...) .+ 1.0 ),  # add 1 to each count so we don't have issues with log(0)
                   colorscale = "Jet",
                   ncontours = 100,
                   contours_showlines = false,
                   )

    layout = Layout(;
                    title = "Particle Size Distribution",
                    xaxis_title = "time",
                    yaxis_title = "Particle Radius [μm]",
                    yaxis_type = "log",
                    plot_bgcolor = :transparent,
                    paper_bgcolor = :transparent,
                    )
    plot(data, layout)
end

=#

#=

function update_pm()
    # load in some test data to play with
    APDS9002()
    BME280()
    GUV001()
    MGS001()
    OPCN3()
    SI114X()

    plotPM()
end


function update_contour()
    plotContour()
end

=#

pm1 = scatter(;
x = [1, 2, 3, 4, 5],
y = [5, 10, 15, 10, 8],
mode = "lines+markers",
name = "PM 1",
marker_color = :red,
marker_size = 5,
);

layout = Layout(;
title = "Particle Size Distribution",
xaxis_title = "time",
yaxis_title = "Particle Radius [μm]",
yaxis_type = "log",
plot_bgcolor = :transparent,
paper_bgcolor = :transparent,
)

app = dash()

app.layout = html_div() do
    html_h1(
        "MINTS Dashboards: UTD Nodes",
        style=Dict("color"=>:black, "textAlign"=>"center"),
    ),
    html_div(
        children = [
            dcc_graph(
                id="pm-graph",
                #figure = plotPM()

                figure = plot([pm1], layout)
            ),
            #dcc_graph(
             #   id="size-contour",
              #  figure = plotContour()
            #),

            dcc_interval(
                id="interval-component",
                interval = 250, # 250 miliseconds
                n_intervals=0
            ),
        ],
#        className = "two-thirds column wind__speed__container",
    )
end

#=
callback!(app,
          Output("pm-graph", "figure"),
          Input("interval-component", "n_intervals")) do n
    update_pm()
end

callback!(app, Output("size-contour", "figure"), Input("interval-component", "n_intervals")) do n
    update_contour()
end
=#




run_server(app, "0.0.0.0", debug=true)
