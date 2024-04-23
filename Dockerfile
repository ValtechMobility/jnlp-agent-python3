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
    git \
    curl \
    rsync \
    python3-full \
    python3-pip \
    python3-venv

RUN pip3 install mkdocs --break-system-packages

ENV HOME="/root"
WORKDIR ${HOME}

RUN git clone --depth=1 https://github.com/pyenv/pyenv.git .pyenv

RUN chown -R jenkins:jenkins /root/.pyenv

ENV PYENV_ROOT="${HOME}/.pyenv"
ENV PATH="${PYENV_ROOT}/shims:${PYENV_ROOT}/bin:${PATH}"

RUN ln -s "${PYENV_ROOT}/bin/pyenv" /usr/local/bin/pyenv

RUN eval "$(pyenv init -)"

USER ${user}

RUN pyenv version

ENTRYPOINT ["/usr/local/bin/jenkins-agent"]
