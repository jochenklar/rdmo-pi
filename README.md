# rdmo-pi

A setup for [pi](https://pi.dev/) to be used with [RDMO](https://rdmorganiser.github.io) ✨

## Setup

First create a `.env` file which contains the basic information about your RDMO instance and a token for authentication:

```
RDMO_URL=
RDMO_TOKEN=
```

### Docker

The Docker setup consists of a multi-target `Dockerfile` and a `compose.yml` for Docker Compose. The Compose service is named `agent`; the Docker build target selects which coding agent is installed.

Build and run the docker container using:

```bash
make run
```

This uses the `pi` agent by default. To build and run the `tau` agent instead:

```bash
make tau
```

The Docker build target is controlled by `CODING_AGENT`, which can be set to `pi` or `tau`:

```bash
CODING_AGENT=tau make build
```

The container user defaults to a neutral `agent` user for both tools. Agent-specific runtime state is still kept separate on the host in `./pi` and `./tau`:

```bash
./pi  -> /home/agent/.pi
./tau -> /home/agent/.tau
```

Tau OAuth browser callbacks use `http://localhost:1455/auth/callback`. The Docker image sets `TAU_OAUTH_CALLBACK_HOST=0.0.0.0`, and `make tau` publishes `127.0.0.1:1455:1455` so the host browser can reach the callback listener. If port `1455` is already in use, use Tau's paste fallback with the full redirect URL from the browser. The fallback input needs the final callback URL after provider login, for example `http://localhost:1455/auth/callback?code=...&state=...`, not the initial `https://auth.openai.com/oauth/authorize?...` login URL.

Stop containers without deleting runtime state:

```bash
make clean
```

Delete local Pi/Tau runtime state, including auth, cache, and sessions:

```bash
make clean-runtime
```

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
