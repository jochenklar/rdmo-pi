# rdmo-pi

A setup for [pi](https://pi.dev/) to be used with [RDMO](https://rdmorganiser.github.io) ✨

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
make pi
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
