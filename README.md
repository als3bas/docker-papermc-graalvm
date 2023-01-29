# Docker Minecraft JAVA PaperMC Server 1.19
This is a fork from Marc Tönsing's repo. I just added & modify a few things to make it work with Graalvm OpenJDK.
Docker Minecraft PaperMC server for 1.19, 1.18, 1.17 for AMD64 and ARM64 platforms. 

The next steps are inherited from Marc Tönsing's repo.
Probably I will update the information in the future.

<details>

## Quick Start
```sh
docker run --rm --name mcserver -e MEMORYSIZE='1G' -v /home/joe/mcserver:/data:rw -p 25565:25565 -i marctv/minecraft-papermc-server:latest
```
The server will generate all data including the world and config files in ``/home/joe/mcserver``. Change that to an existing folder.

## How do I update the container? 

### On Synology DSM

* Re-download the image from the docker repository.
* Stop the container.
* Clear the container.
* Start the container.

### On Terminal

```sh
docker pull marctv/minecraft-papermc-server:latest
docker stop mcserver
```

Or just use https://containrrr.dev/watchtower/ 

## Run as non-root user

You can get the desired UID/GID (xxx) with the ID command (id username) then add the following to your docker run command:

```sh
-e PUID=xxx
-e PGID=xxx
```

## Docker Compose

If you prefer to use `docker-compose`, use the following commands:

Start the server:
```sh
docker-compose up
```
Stop the server:
```sh
docker-compose stop
```
Issue server commands after attaching to the container:
```sh
docker attach mcserver
# then you can type things like "list"
list
# which will show the current players online or
help
# to see all the commands available
```

## How to use the Makefile with Docker Compose 

Additionally, a `Makefile` is provided to easily start, stop, and attach to the container.

```sh
make start     # equivalent to `docker-compose up -d --build`
make stop      # equivalent to `docker-compose stop --rmi all --remove-orphans`
make attach    # equivalent to `docker attach mcserver`
make help      # prints a help message
```

## Environment variables

MEMORYSIZE = 1G

Not more than 70% of your RAM for your container. This is important. Because this is the RAM, your Minecraft Server will use within the container WITHOUT the operating system.

TZ = Europe/Berlin 

Sets the timezone for the container. A list of valid values can be found on Wikipedia: https://en.wikipedia.org/wiki/List_of_tz_database_time_zones

PAPERMC_FLAGS = --nojline

Sets the command-line flags for PaperMC. Remove `--nojline` if you want to enable color and tab-completion for the server console.

</details>

## Credits

* Based on the work of [Marc Tönsing](https://github.com/mtoensing/Docker-Minecraft-PaperMC-Server). Thanks for the repo
* Based on the work of [Felix Klauke](https://github.com/FelixKlauke/paperspigot-docker) Thanks for your help!
