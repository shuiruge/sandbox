This is a example workspace folder that build up an OpenCode environment.

First, you have to build and run the Docker image. After coming into the container (sandbox), run

```sh
cd workspace
nix develop
```

in terminal to build the OpenCode environment using Flake (an modern feature of Nix). Then, try `opencode` in terminal to execute OpenCode.

Have fun :)

