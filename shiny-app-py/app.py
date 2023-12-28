from shiny import App, render, ui
import requests
import json

api_url = "https://woodoo-orangutan.staging.eval.posit.co/cnct/content/316fd4e0-2375-44e1-8fe4-7e0b943da00b/predict" 

app_ui = ui.page_fluid(
    ui.input_slider("n", "N", 0, 365, 20),
    ui.output_text_verbatim("txt"),
)


def server(input, output, session):
    @render.text
    def txt():
       
        # Parameters to be included in the query string
        params = [{
            'DayOfYear': input.n()
        }]

        # Make a GET request with parameters
        response = requests.post(api_url, json=params)
        json_data = response.json()
        return f"n*2 is {json_data}"


app = App(app_ui, server)


