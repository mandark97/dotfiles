FROM ubuntu:latest
ENV DEBIAN_FRONTEND=noninteractive

# Locales
RUN apt-get update && apt-get install -y locales
ENV LANG="en_US.UTF-8" LC_ALL="en_US.UTF-8" LANGUAGE="en_US.UTF-8"

RUN echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && \
  locale-gen --purge $LANG && \
    dpkg-reconfigure --frontend=noninteractive locales && \
    update-locale LANG=$LANG LC_ALL=$LC_ALL LANGUAGE=$LANGUAGE

# Common packages
RUN apt-get update && apt-get install -y \
      build-essential \
      software-properties-common \
      tzdata \
      psmisc \
      curl \
      git \
      wget \
      tmux \
      vim \
      zsh \
      ledger \
      mosh \
      ruby \
      ruby-dev \
      mosquitto \
      mosquitto-clients \
      postgresql-client \
      jq \
      rsync \
      lastpass-cli

# Install Node.js LTS
RUN curl -sL https://deb.nodesource.com/setup_10.x | bash -
RUN apt-get install -y nodejs

RUN curl -LO https://github.com/neovim/neovim/releases/download/stable/nvim.appimage
RUN chmod u+x nvim.appimage
# # install nvim
# WORKDIR /tmp
# RUN wget https://github.com/neovim/neovim/archive/stable.tar.gz
# RUN tar -xzvf stable.tar.gz
# WORKDIR /tmp/neovim-stable
# RUN make
# RUN make install

# Install Bundler
RUN gem install bundler --no-rdoc --no-ri

# Install oh-my-zsh
# RUN chsh -s /usr/bin/zsh
# RUN curl -L http://install.ohmyz.sh | sh || true

# Set up timezone
ENV TZ 'Europe/Bucharest'
RUN echo $TZ > /etc/timezone && \
    rm /etc/localtime && \
    ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && \
    dpkg-reconfigure -f noninteractive tzdata

# Set up dotfiles
# COPY ./zsh/* /root/
COPY dotfiles/vimrc /root/.vimrc
COPY dotfiles/vimrc.bundles /root/.vimrc.bundles
COPY dotfiles/vim /root/.vim
COPY dotfiles/tmux.conf /root/.tmux.conf
COPY dotfiles/init.nvim /root/.config/nvim/init.nvim
COPY dotfiles/vim/ /root/
# COPY ./git/* /root/
RUN vim +PlugInstall +qall > /dev/null
# Set up volumes
WORKDIR /projects
# VOLUME /projects
# VOLUME /keys

# Enable colors
ENV TERM=xterm-256color

# CMD ["tmux"]
