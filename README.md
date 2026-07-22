# Sandbox

Build a Docker image with Nix (Flake) installed, with Nix store persisted.

## Motivation

At first, I needed an isolated environment in which I can run agents such as OpenCode, without worrying about my files outside the workspace being accidentally deleteed by the agents. So I built a Docker image with OpenCode installed. For safty, users in the container should not have root permission. Then, I faced at the obstacle that everytime when I need to add new softwares for OpenCode to manipulate, I have to rebuild the image.

A solution is using [Nix](https://nixos.org/). It is a modern (and magic) package manager that can install packages without root permission, and even build up your development environment in one go. It then inspired me to consider a broader task. What I really need is a sandbox with Nix installed. And here it is.

## Howto

### Build

First of all, git clone this repository and go into the directly. In terminal, you can

```sh
git clone https://github.com/shuiruge/sandbox.git
cd sandbox/
```

Then set up your configuration. Copy `.env.example` to `.env`, by

```sh
cp .env.example .env
```

and edit the variables listed in `.env` in your favorite text editor. (I like vim/emacs. Yes, both!) We have employed mirror-URLs specifically for Chinese users to speed up the process.

Finally, build the Docker image in one go:

```sh
sh build.sh
```

It writes a `Dockerfile` and an `init.sh` script, which initializes the basic sandbox environment such as recover the Nix configurations (nix-profile). Then, it builds the Docker image with `docker build` command. Finally, it removes the intermediate artifacts (namely, the `Dockerfile` and `init.sh`) to keep the folder tidy.

### Run

To run the Docker image, we refer you to `example.sh`. You can just execute it as

```sh
sh run.sh
```

It mounts a folder that contains Nix (together with its store and profile) to your Docker image. Also mounted is your workspace folder. Or you can create your own shell script for your specific purpose based on `example.sh`. Such scripts are collected in the `examples/` folder.

## License

GPLv3

## Author

shuiruge@hotmail.com

