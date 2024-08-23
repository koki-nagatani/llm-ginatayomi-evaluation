FROM node:20.10-bullseye-slim as node
FROM ubuntu:22.04 as base

EXPOSE 15500

COPY --from=node /usr/local/include/ /usr/local/include/
COPY --from=node /usr/local/lib/ /usr/local/lib/
COPY --from=node /usr/local/bin/ /usr/local/bin/

# reset symlinks
RUN corepack disable && corepack enable

# install git and other dependencies for gcloud
RUN apt-get update \
    && apt-get -y install --no-install-recommends \
        git \
        curl \
        sudo \
        gnupg \
        apt-transport-https \
        ca-certificates \
        software-properties-common \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# install gcloud
RUN echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list \
    && curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo gpg --dearmor -o /usr/share/keyrings/cloud.google.gpg \
    && apt-get update -y \
    && apt-get install google-cloud-sdk -y

# add node user
RUN groupadd --gid 1000 appuser \
    && useradd --uid 1000 --gid appuser --shell /bin/bash --create-home appuser \
    && mkdir /app \
    && chown -R appuser:appuser /app

WORKDIR /app

COPY --chown=appuser:appuser package.json ./

USER appuser

# install node dependencies
RUN npm install && npm cache clean --force

CMD ["bash"]

FROM base as dev

ARG PYTHON_VERSION=3.11.9
ENV TZ=Asia/Tokyo

USER root
# install pyenv dependencies
RUN add-apt-repository -y ppa:deadsnakes/ppa
RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get -y install --no-install-recommends \
        make \
        build-essential \
        libssl-dev \
        zlib1g-dev \
        libbz2-dev \
        libreadline-dev \
        libsqlite3-dev \
        wget \
        llvm \
        libncurses5-dev \
        libncursesw5-dev \
        xz-utils \
        tk-dev \
        libffi-dev \
        liblzma-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

COPY --chown=appuser:appuser poetry.lock pyproject.toml ./

USER appuser
# install pyenv
RUN curl https://pyenv.run | bash \
&& echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.bashrc \
&& echo 'export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.bashrc \
&& echo 'eval "$(pyenv init --path)"' >> ~/.bashrc

ENV PYENV_ROOT="/home/appuser/.pyenv" \
PATH="/home/appuser/.pyenv/bin:$PATH"

RUN eval "$(pyenv init --path)" \
&& pyenv install $PYTHON_VERSION

ENV PATH="/home/appuser/.pyenv/versions/$PYTHON_VERSION/bin:$PATH"

# install poetry
RUN pip install --upgrade pip \
&& pip install poetry==1.8.3

# install python dependencies
ENV POETRY_NO_INTERACTION=1 \
POETRY_VIRTUALENVS_IN_PROJECT=1 \
POETRY_VIRTUALENVS_CREATE=1 \
POETRY_CACHE_DIR=/tmp/poetry_cache

ENV VIRTUAL_ENV=/app/.venv \
PATH="/app/.venv/bin:$PATH"

RUN poetry install --no-root && rm -rf $POETRY_CACHE_DIR

CMD ["npx", "promptfoo", "view", "-y"]