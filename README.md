# rdmo-pi

A docker container setup for [pi](https://pi.dev/) ✨

## Setup

Download the OpenAPI specification from your RDMO instance, for example:
`https://rdmo.jochenklar.dev/main/api/v1/schema/`

Create the working directories:

```bash
mkdir -p workspace
```

Place the schema file in `workspace/`.

Create a `.env` file with:

```
RDMO_URL=
RDMO_TOKEN=
ANTHROPIC_API_KEY=
```

Build the image:

```bash
make build
```

Run the container:

```bash
make run
```

To pin the Pi package version, set `PI_VERSION` for the build:

```bash
PI_VERSION=1.2.3 make build
```

## Usage

Ask the chatbot:

1) Use the provided schema and the credentials in the env and display my projects.
2) Check the available catalogs.
3) Create a new project with the title "AI" and the description "Testing is fun" and the catalog RDMO.
4) What is the first question in the interview.
5) The main research question is "Testing tools and having fun." and you can make up 3 keywords.
