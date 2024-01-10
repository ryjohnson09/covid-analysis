from shiny import App, render, ui
import os
import vetiver
import pandas as pd

# Define endpoint for API and key
endpoint = vetiver.vetiver_endpoint("https://hopping-armadillo.staging.eval.posit.co/cnct/content/36b225c4-8c07-4194-8763-e16ad138537f/predict")
api_key = os.getenv("CONNECT_API_KEY") 

# User Interface
app_ui = ui.page_fluid(
    ui.input_date("day", "Select Date:", value="2021-01-01"),
    ui.output_text_verbatim("txt")
)

# Server Function
def server(input, output, session):
    @render.text
    def txt():
       
        # Parameters to be included in the query string
        #  Convert date to number of year
        params = pd.DataFrame({
            'DayOfYear': [input.day().strftime("%j")]
        })

        # If needed, add authorization
        h = {"Authorization": f"Key {api_key}"}

        # Make a prediction
        response = vetiver.predict(endpoint=endpoint, data=params, headers=h).at[0, "predict"].round()

        # Return message
        return f"Predicted number of COVID cases: {response}"

# Create Shiny App
app = App(app_ui, server)