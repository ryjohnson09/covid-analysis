from shiny import App, render, ui
import requests
import json
from datetime import datetime

# Define URL for API
api_url = "https://woodoo-orangutan.staging.eval.posit.co/cnct/covid-predict/predict" 

# User Interfact
app_ui = ui.page_fluid(
    ui.input_date("day", "Select Date:", value="2021-01-01"),
    ui.output_text_verbatim("txt"),
)

# Server Function
def server(input, output, session):
    @render.text
    def txt():
       
        # Parameters to be included in the query string
        #  Convert date to number of year
        params = [{
            'DayOfYear': input.day().strftime("%j")
        }]

        # Make a POST request with parameters
        response = requests.post(api_url, json=params)

        # Parse API response
        json_data = round(response.json()['predict'][0])

        # Return message
        return f"Predicted number of COVID cases: {json_data}"


app = App(app_ui, server)