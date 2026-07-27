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

Then edit the configurations part in `build.sh` in your favorite text editor. (I like vim/emacs. Yes, both!) We have employed mirror-URLs specifically for Chinese users to speed up the process.

Finally, build the Docker image in one go:

```sh
sh build.sh
```

It writes a temporal `Dockerfile` and a temporal `init.sh` script, which initializes the basic sandbox environment such as recover the Nix configurations (nix-profile). Then, it builds the Docker image with `docker build` command.

### Run

To run the Docker image, we refer you to scripts in `examples/`, for example `basic.sh`. You can just execute it as

```sh
sh examples/basic.sh
```

It mounts a folder that contains Nix (together with its store and profile) to your Docker image. Also mounted is your workspace folder. Or you can create your own shell script for your specific purpose based on it. More examples are in the `examples/` folder.

### Examples

In `examples` folder:

- basic.sh: The basic example. You can build your own based on this.
- opencode.sh: Container with OpenCode (with TUI and web modes) installed.

## License

GPLv3

## Author

shuiruge@hotmail.com

