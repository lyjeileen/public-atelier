# atelier

Atelier integrates Rustic AI projects, providing a platform for users to explore and experiment with conversational agentic applications.
Apps from [rustic-showcase](https://pypi.org/project/rusticai-showcase/) are available to try out.

## Getting started

### Prerequisites

- Docker: Please ensure [Docker](https://docs.docker.com/desktop/) is installed and running

### Configuring

The supported integrations require the following API Keys to be configured:

- OPENAI_API_KEY is for accessing [Open AI](https://platform.openai.com/docs/overview) APIs
- HUGGINGFACE_API_KEY is for using models from [HuggingFace](https://huggingface.co/)
- SERP_API_KEY is for [SerpApi](https://serpapi.com/dashboard)

Copy the `.env.template` to `.env` and set the required values.

```shell
cp .env.template .env
```

Edit the `.env` file and provide the desired keys.
This file is provided at runtime using docker secrets. 
**Your API Keys are not stored anywhere and are not shared with any other service**


### Running

**Starting the application without Authentication**

Execute the command below in the terminal:

```shell
./start.sh
```

The application will be accessible locally at [http://localhost:3000](http://localhost:3000).

**Stopping the application**

```shell
docker compose down
```