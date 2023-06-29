# Project Title

Provide a short description of your project here.

## Table of Contents

- [Environment Setup](#environment-setup)
- [Activating the Environment](#activating-the-environment)
- [Installing Requirements](#installing-requirements)
- [Setting Up Environment Variables](#setting-up-environment-variables)
- [Starting the Server](#starting-the-server)
- [Starting the Watcher](#starting-the-watcher)

## Environment Setup

This project requires a Python virtual environment for isolating dependencies. Here's how you set it up:

```shell
python3 -m venv torch  # Creates a venv in a 'torch' directory
```


## Activating the environment

To activate the virtual environment, navigate to the directory where the venv folder is located and run:

```shell
source venv/bin/activate  # Activates the virtual environment
```

You should see the name of your venv before your shell prompt. Remember, you'll need to activate the venv in two separate terminals to run both the server and the watcher.

## Installing requirements

This project requires certain Python packages which are listed in the requirements.txt file. Install them with pip:

```shell
pip install -r requirements.txt
```

## Setting Up Environment Variables

Copy the .env.example file to a new file named .env and fill in the necessary environment variables:
    
```shell
cp .env.example .env
```

You'll likely only need to update the values for ABSOLUTE_SRC_DIR_PATH and ABSOLUTE_OUTPUT_DIR_PATH.

## Start the Server 

To start the server on port 8000, run:

```shell
python3 server/server.py
```

## Start the Watcher
 
In a second terminal, activate the venv and run the watcher:

```shell
python3 watcher/watcher.py
```

This will start the watcher on your src directory. Any changes to .sol files will trigger the watcher to compile the contracts, run the tests, and reload the server with the newly generated output HTML file.

