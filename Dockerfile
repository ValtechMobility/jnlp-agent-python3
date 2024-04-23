FROM jenkins/inbound-agent:alpine as jnlp

FROM jenkins/agent:latest-jdk11

ARG version
LABEL Description="This is a base image, which allows connecting Jenkins agents via JNLP protocols" Vendor="Jenkins project" Version="$version"

ARG user=jenkins

USER root

COPY --from=jnlp /usr/local/bin/jenkins-agent /usr/local/bin/jenkins-agent

RUN chmod +x /usr/local/bin/jenkins-agent && \
    ln -s /usr/local/bin/jenkins-agent /usr/local/bin/jenkins-slave

RUN apt-get update && apt-get install -y \
    rsync \
    python3-full \
    python3-pip \
    python3-venv

RUN pip3 install mkdocs --break-system-packages

RUN curl https://pyenv.run | bash

RUN export PYENV_ROOT="$HOME/.pyenv"
RUN export PATH="$PYENV_ROOT/bin:$PATH"
RUN eval "$(pyenv init -)"

RUN pyenv version

USER ${user}

RUN pyenv version

ENTRYPOINT ["/usr/local/bin/jenkins-agent"]
