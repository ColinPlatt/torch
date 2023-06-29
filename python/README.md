Setting up the environment

First, you'll need to create a virtual environment (venv) for this project. This will help isolate the Python environment for this specific project. Assuming you have venv installed, create a new venv by running the following command in the terminal either in your venv storage folder or in this projects python folder:

Unix or MacOS
python3 -m venv torch

This creates a virtual environment in a folder named "torch" in the current directory. Name it as you wish. 

Activating the environment

Next, activate the venv by running the following command in the terminal:

From the directory where the venv folder is located:

Unix or MacOS
source venv/bin/activate

If successful, you should see (name of your venv) before your shell prompt.

While you are at it open another terminal and activate the venv there as well. You will need two terminals to run the server and watcher. 

Installing requirements

This project has a requirements.txt file which lists all necessary Python packages. You can install them using pip:

pip install -r requirements.txt


Environment Variables

Copy the .env.example file to .env and fill in the values for the environment variables. You can use the following command in the terminal:

cp .env.example .env

You should really only need to change,
ABSOLUTE_SRC_DIR_PATH and ABSOLUTE_OUTPUT_DIR_PATH


Start the Server 

In the terminal, run: 
python3 server/app.py

This will start the server on port 8000 

Start the Watcher
 
In your second terminal, run:
python3 server/watchDog.py

This will start the watcher on your src directory. Any changes to any .sol files on save will trigger the watcher to compile to compile the contracts, run the tests, and reload the server with the new output HTML file generated in the test. 



