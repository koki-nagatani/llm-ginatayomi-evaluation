# llm-ginatayomi-evaluation

## Overview
This project evaluates the ability of Large Language Models (LLMs) to handle 'ginatayomi', a Japanese language phenomenon where different interpretations arise based on how text is segmented or punctuated.

## Prerequisites
- Docker 20.10+
- Docker Compose 1.29+

## Quickstart Setup
### 1. Clone repo
```
git clone https://github.com/koki-nagatani/llm-ginatayomi-evaluation
```

### 2. Set API Keys for LLM evaluation
- Copy `.env.sample` to `.env`:
```
cp .env.sample .env
```
- Edit the `.env` file to include your API keys.
- See [here](https://www.promptfoo.dev/docs/providers/) for instructions on obtaining API keys and setting environment variables for each LLM model.

To evaluate current ginatayomi evaluation, set all of OpenAI, Anthropic, and Google Vertex AI API Keys.  
For Google Vertex AI, ensure that your GCP credentials are stored in the `.gcloud` folder.


### 3. Launch a container using docker compose
```
docker-compose up --build -d
```

### 4. Run eval
Execute the below command in container.
```
npx promptfoo eval
```

### 5. Viewing Results
- Open your web browser and navigate to [http://localhost:15500](http://localhost:15500).
- The promptfoo viewer will display the evaluation results, where you can explore detailed outputs, comparisons, and metrics.

## For Developers
This project supports development using Visual Studio Code with DevContainers. You can start developing in a consistent environment without worrying about dependencies. To begin:

1. Ensure you have the [Dev Containers extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers) installed in VSCode.
2. Open the project in VSCode.
3. When prompted, choose "Reopen in Container" to automatically set up the development environment.

This will allow you to work within a Docker container that has all necessary dependencies pre-installed.