FROM node:12.4.0-jdk

RUN apt-get update
RUN apt-get install -y python3-pip

# add requirements.txt, written this way to gracefully ignore a missing file
COPY . .
RUN ([ -f requirements.txt ] \
    && pip3 install --no-cache-dir -r requirements.txt) \
    || pip3 install --no-cache-dir jupyter jupyterlab

USER root

# Download the pstate-jupyter artifact
RUN curl -L https://gitlab.cas.mcmaster.ca/lime/pstate-jupyter/-/jobs/2420/artifacts/download > pstate-jupyter.zip

# Unpack and install the pstate-jupyter artifact
RUN unzip pstate-jupyter.zip \
    && python3 -m pip install dist/pstate-0.1.0-py3-none-any.whl[ipy] --force-reinstall
RUN python3 -m jupyter nbextension install --py pstate
RUN python3 -m jupyter nbextension enable --py pstate

# Set up the user environment

ENV NB_USER jovyan
ENV NB_UID 1000
ENV HOME /home/$NB_USER

RUN adduser --disabled-password \
    --gecos "Default user" \
    --uid $NB_UID \
    $NB_USER

COPY . $HOME
RUN chown -R $NB_UID $HOME

USER $NB_USER

# Launch the notebook server
WORKDIR $HOME
CMD ["jupyter", "notebook", "--ip", "0.0.0.0"]