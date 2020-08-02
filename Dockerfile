FROM ruby

RUN apt-get update && apt-get install -y \
    python3-pip \
    libzmq3-dev libczmq-dev \
    && \
    apt-get clean && rm -rf /var/lib/apt/lists/* # clean up

RUN apt-get update && \
    curl -sL https://deb.nodesource.com/setup_12.x | bash - && \
    apt-get install -y nodejs && \
    apt-get clean && rm -rf /var/lib/apt/lists/* # clean up

RUN gem install ffi-rzmq && \
    gem install iruby --pre && \
    iruby register --force

RUN pip3 install \
    jupyter \
    jupyterlab \
    jupytext \
    ipywidgets \
    jupyter-contrib-nbextensions \
    jupyter-nbextensions-configurator \
    jupyterlab_code_formatter

RUN jupyter notebook --generate-config && echo "\
c.ContentsManager.default_jupytext_formats = 'ipynb,rb'\n\
c.NotebookApp.contents_manager_class = 'jupytext.TextFileContentsManager'\n\
c.NotebookApp.open_browser = False\n\
" >> ${HOME}/.jupyter/jupyter_notebook_config.py

# Install/enable extension for JupyterLab users
RUN jupyter labextension install @lckr/jupyterlab_variableinspector --no-build && \
    jupyter labextension install @jupyterlab/toc --no-build && \
    jupyter nbextension enable --py widgetsnbextension && \
    jupyter labextension install @jupyter-widgets/jupyterlab-manager --no-build && \
    jupyter labextension install @z-m-k/jupyterlab_sublime --no-build && \
    jupyter labextension install @ryantam626/jupyterlab_code_formatter --no-build && \
    jupyter serverextension enable --py jupyterlab_code_formatter && \
    jupyter labextension install @hokyjack/jupyterlab-monokai-plus --no-build && \
    jupyter lab build -y && \
    jupyter lab clean -y && \
    npm cache clean --force && \
    rm -rf /home/$NB_USER/.cache/yarn && \
    rm -rf /home/$NB_USER/.node-gyp && \
    echo Done

# Setup default formatter (For Python Users only)
RUN mkdir -p ${HOME}/.jupyter/lab/user-settings/@ryantam626/jupyterlab_code_formatter && echo '\
{\n\
    "preferences": {\n\
        "default_formatter": {\n\
            "python": "black",\n\
        }\n\
    }\n\
}\n\
\
'>> ${HOME}/.jupyter/lab/user-settings/@ryantam626/jupyterlab_code_formatter/settings.jupyterlab-settings

# Set color theme Monokai++ by default (The selection is due to my hobby)
RUN mkdir -p ${HOME}/.jupyter/lab/user-settings/@jupyterlab/apputils-extension && echo '\
{\n\
    "theme": "Monokai++"\n\
}\n\
\
' >> ${HOME}/.jupyter/lab/user-settings/@jupyterlab/apputils-extension/themes.jupyterlab-settings

# Show line numbers by default
RUN mkdir -p ${HOME}/.jupyter/lab/user-settings/@jupyterlab/notebook-extension && echo '\
{\n\
    "codeCellConfig": {\n\
        "lineNumbers": true,\n\
    },\n\
}\n\
\
' >> ${HOME}/.jupyter/lab/user-settings/@jupyterlab/notebook-extension/tracker.jupyterlab-settings

# exposing default port for streamlit
EXPOSE 8888