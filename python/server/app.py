import os
from flask import Flask, send_from_directory
from dotenv import load_dotenv

load_dotenv() 

ABSOLUTE_OUTPUT_DIR_PATH = os.getenv('ABSOLUTE_OUTPUT_DIR_PATH')
HTML_OUTPUT_FILE = os.getenv('HTML_OUTPUT_FILE')

#use absolute path to avoid issues with running from different directories
app = Flask(__name__, static_folder=ABSOLUTE_OUTPUT_DIR_PATH)

@app.route('/')
def home():
    return send_from_directory(app.static_folder, 'renderedSite.html')

if __name__ == "__main__":
    app.run(port=8000, debug=True)