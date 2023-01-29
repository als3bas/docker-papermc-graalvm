########################################################
## We want to use a Graalvm image bc it suppose to be ##
##          faster than the normal java image.         ##
########################################################

FROM ghcr.io/graalvm/graalvm-ce:ol9-java17-22.3.1 as build
RUN microdnf install -y curl jq

LABEL Marc Tönsing <marc@marc.tv>
LABEL Sebas Álvaro <https://asgg.cl>

# Set the minecraft version
ARG MCVERSION=1.19.3

########################################################
## Then Download papermc and build it with graalvm.   ##
##                 and Marc's script                  ##
########################################################
WORKDIR /opt/minecraft
COPY ./getpaperserver.sh /
RUN chmod +x /getpaperserver.sh

## clean posible jar to force update
RUN rm /opt/minecraft/paperclip.jar || true
RUN rm /opt/minecraft/paperspigot.jar || true

## download latest papermc 
RUN /getpaperserver.sh ${MCVERSION}

########################################################
## Then Download papermc and build it with graalvm.   ##
########################################################
FROM ghcr.io/graalvm/graalvm-ce:ol9-java17-22.3.1 as runtime
ARG TARGETARCH

# Install gosu since doesn't exist in oracle linux repos
ARG GOSUVERSION=1.16
RUN set -eux
RUN curl -fsSL "https://github.com/tianon/gosu/releases/download/${GOSUVERSION}/gosu-${TARGETARCH}" -o /usr/bin/gosu && \
    chmod +x /usr/bin/gosu && \
    gosu nobody true && \
    microdnf clean all && rm -rf /var/cache/yum

# Working directory
WORKDIR /data

# Obtain runable jar from build stage
COPY --from=build /opt/minecraft/paperclip.jar /opt/minecraft/paperspigot.jar

# Install and run rcon
ARG RCON_CLI_VER=1.6.0
ADD https://github.com/itzg/rcon-cli/releases/download/${RCON_CLI_VER}/rcon-cli_${RCON_CLI_VER}_linux_${TARGETARCH}.tar.gz /tmp/rcon-cli.tgz
RUN tar -x -C /usr/local/bin -f /tmp/rcon-cli.tgz rcon-cli && \
    rm /tmp/rcon-cli.tgz

# Volumes for the external data (Server, World, Config...)
VOLUME "/data"

# Expose minecraft port
EXPOSE 25565/tcp
EXPOSE 25565/udp

# Set memory size
ARG memory_size=1G
ENV MEMORYSIZE=$memory_size

# Set Java Flags
ARG java_flags="-Dlog4j2.formatMsgNoLookups=true -XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:MaxGCPauseMillis=200 -XX:+UnlockExperimentalVMOptions -XX:+DisableExplicitGC -XX:+AlwaysPreTouch -XX:G1NewSizePercent=30 -XX:G1MaxNewSizePercent=40 -XX:G1HeapRegionSize=8M -XX:G1ReservePercent=20 -XX:G1HeapWastePercent=5 -XX:G1MixedGCCountTarget=4 -XX:InitiatingHeapOccupancyPercent=15 -XX:G1MixedGCLiveThresholdPercent=90 -XX:G1RSetUpdatingPauseTimePercent=5 -XX:SurvivorRatio=32 -XX:+PerfDisableSharedMem -XX:MaxTenuringThreshold=1 -Dusing.aikars.flags=mcflags.emc.gs -Dcom.mojang.eula.agree=true"
ENV JAVAFLAGS=$java_flags

# Set PaperMC Flags
ARG papermc_flags="--nojline"
ENV PAPERMC_FLAGS=$papermc_flags

WORKDIR /data

COPY /docker-entrypoint.sh /opt/minecraft
RUN chmod +x /opt/minecraft/docker-entrypoint.sh

# Entrypoint
ENTRYPOINT ["/opt/minecraft/docker-entrypoint.sh"]
