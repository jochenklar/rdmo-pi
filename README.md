# rdmo-pi

A docker container setup for [pi](https://pi.dev/) ✨

## Setup

Download the OpenAPI specification from, e.g. https://rdmo.jochenklar.dev/main/api/v1/schema/.

Create a `workspace` directory and place the schema inside.

Create a `.env` file with:

```
RDMO_URL=
RDMO_TOKEN=
ANTHROPIC_API_KEY=
```

Build and run the docker container:

```bash
make
```

## Usage

Ask the chatbot:

1) Use the provided schema and the credentials in the env and display my projects.
2) Check the available catalogs.
3) Create a new project with the title "AI" and the description "Testing is fun" and the catalog RDMO.
4) What is the first question in the interview.
5) The main research question is "Testing tools and having fun." and you can make up 3 keywords.

