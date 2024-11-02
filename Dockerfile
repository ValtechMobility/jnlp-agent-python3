FROM jenkins/inbound-agent:alpine as jnlp

FROM jenkins/agent:latest-jdk17

ARG version
LABEL Description="This is a base image, which allows connecting Jenkins agents via JNLP protocols" Vendor="Jenkins project" Version="$version"

ARG user=jenkins

USER root

COPY --from=jnlp /usr/local/bin/jenkins-agent /usr/local/bin/jenkins-agent

RUN chmod +x /usr/local/bin/jenkins-agent && \
    ln -s /usr/local/bin/jenkins-agent /usr/local/bin/jenkins-slave

RUN apt-get update && apt-get install -y \
    git \
    curl \
    rsync \
    python3-full \
    python3-pip \
    python3-venv

RUN pip3 install mkdocs --break-system-packages

RUN ln -s "/home/jenkins/.pyenv/bin/pyenv" /usr/local/bin/pyenv

USER ${user}

ENV HOME="/home/jenkins"
WORKDIR ${HOME}

SHELL ["/bin/bash", "-c"]

RUN git clone --depth=1 https://github.com/pyenv/pyenv.git .pyenv

ENV PYENV_ROOT="${HOME}/.pyenv"
ENV PATH="${PYENV_ROOT}/shims:${PYENV_ROOT}/bin:${PATH}"
RUN eval "$(pyenv init -)"

RUN pyenv version

ENTRYPOINT ["/usr/local/bin/jenkins-agent"]
