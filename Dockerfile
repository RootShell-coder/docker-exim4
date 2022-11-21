FROM debian:stable

LABEL authors="darkman"
LABEL maintainer="RootShell-coder <Root.Shelling@gmail.com>"
LABEL build_date="2022/11/21"

ARG USERNAME=notroot
ARG USER_UID=1000
ARG USER_GID=${USER_UID}

RUN groupadd --gid ${USER_GID} ${USERNAME} \
    && useradd --uid ${USER_UID} --gid ${USER_GID} -m ${USERNAME} \
    && apt update && apt upgrade -y \
    && apt install exim4-daemon-heavy -y \
    && rm -rf /var/lib/apt/lists /tmp/ \
    && usermod -aG Debian-exim ${USERNAME}

COPY exim4 /etc/exim4
COPY docker-entrypoint.sh /usr/local/bin

RUN chown -R Debian-exim:Debian-exim /etc/exim4 /var/spool/exim4 /var/log/exim4 \
    && update-exim4.conf \
    && chmod +x /usr/local/bin/docker-entrypoint.sh

USER ${USERNAME}
WORKDIR /etc/exim4/
VOLUME ["/var/spool/exim4", "/etc/exim4", "/var/log/exim4"]
EXPOSE 25 587 465

# SMTP on port 25 (IPv6 and IPv4) port 587 (IPv6 and IPv4)
# SMTPS on port 465 (IPv6 and IPv4)

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["/usr/sbin/exim", "-bd", "-v"]
