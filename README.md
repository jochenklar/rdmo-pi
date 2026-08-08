# rdmo-pi

A setup for [pi](https://pi.dev/) and other coding harnesses to be used with [RDMO](https://rdmorganiser.github.io) ✨

## Setup

First create a `.env` file which contains the basic information about your RDMO instance and a token for authentication:

```
RDMO_URL=
RDMO_TOKEN=
```

### Docker

The docker setup consists of a `Dockerfile` and a `compose.yml` for docker compose.

Build and run the docker container using:

```bash
make
make bash   # open a shell in the container (for debugging)
make build  # (re-)build the docker image
make clean  # remove the container and the home volume
```

Other agents / coding harnesses use:

```bash
make AGENT=claude
make AGENT=codex
make AGENT=tau
```

`AGENT` can also be put in the `.env` file.

With `pi` you can create a [`model.json`](https://pi.dev/docs/latest/models), e.g. for a local Ollama installation:

```json
{
  "providers": {
    "ollama": {
      "baseUrl": "http://host.docker.internal:11434/v1",
      "api": "openai-completions",
      "apiKey": "ollama",
      "compat": {
        "supportsDeveloperRole": false,
        "supportsReasoningEffort": false
      },
      "models": [
        {
          "id": "qwen3.6:35b-a3b"
        },
      ]
    },
  }
}
```

This file is mounted in the container when including: `MODELS_JSON=./models.json` in `.env`.


With `tau` a similar [`catalog.toml`](https://twotimespi.dev/guides/providers-and-models/) can be created:

```toml
schema_version = 1

[[providers]]
name = "ollama"
display_name = "Ollama"
kind = "openai-compatible"
base_url = "http://host.docker.internal:11434/v1"
api_key_env = "OLLAMA_API_KEY"
credential_name = "ollama"
models = [
    "qwen3.6:35b-a3b",
]
default_model = "qwen3.6:35b-a3b"
docs_url = "https://example.test/local-gateway"
thinking_levels = [
    "low",
    "medium",
    "high"
]
```

This file is mounted in the container when including: `CATALOG_TOML=./catalog.toml` in `.env`.

API keys like `OPENAI_API_KEY`, `ANTHROPIC_API_KEY` can also be set in `.env`.

### Ansible

Install `ansible`:

```bash
pip install ansible
```

Create an inventory file `hosts.yml`:

```yaml
all:
  hosts:
    pi:
      ansible_host: 
      ansible_user: 
  vars:
    ansible_python_interpreter: auto_silent
    node_version: v24.16.0

    users:
    - name: jochen
      hash: $6$...  # use `openssl passwd -6` to create the hash
      ssh_keys:
      - "ssh-ed25519 AAA... jochen@example.com"
      ...
```

Run the playbook:

```bash
ansible-playbook playbook.yml -i hosts.yml
```

## Usage

Ask the chatbot:

1) Display my projects.
2) Check the available catalogs.
3) Create a new project with the title "AI" and the description "Testing is fun" and the catalog RDMO.
4) What is the first question in the interview.
5) The main research question is "Testing tools and having fun." and you can make up 3 keywords.
