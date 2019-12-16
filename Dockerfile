FROM ruby:2.5.7
ENV DEBIAN_FRONTEND=noninteractive

ARG USER=mateimelinte
ARG UID=1000
ARG GID=1000
ARG PW=docker

# Locales
RUN apt-get update && apt-get install -y locales
ENV LANG="en_US.UTF-8" LC_ALL="en_US.UTF-8" LANGUAGE="en_US.UTF-8"

RUN echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && \
  locale-gen --purge $LANG && \
    dpkg-reconfigure --frontend=noninteractive locales && \
    update-locale LANG=$LANG LC_ALL=$LC_ALL LANGUAGE=$LANGUAGE
# Set up timezone
ENV TZ 'Europe/Bucharest'
RUN echo $TZ > /etc/timezone && \
    rm /etc/localtime && \
    ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && \
    dpkg-reconfigure -f noninteractive tzdata
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
      neovim \
      fish \
      postgresql-client \
      rsync \
      sudo

RUN  useradd mateimelinte && echo "mateimelinte:mateimelinte" | chpasswd && adduser --disabled-password mateimelinte sudo

# Install bundler 2
RUN gem install bundler -v 2
# # Ruby/Chruby Setup
# WORKDIR /tmp
# RUN wget -O ruby-install-0.7.0.tar.gz https://github.com/postmodern/ruby-install/archive/v0.7.0.tar.gz
# RUN tar -xzvf ruby-install-0.7.0.tar.gz
# WORKDIR ruby-install-0.7.0/
# RUN make install
#
# RUN wget -O chruby-0.3.9.tar.gz https://github.com/postmodern/chruby/archive/v0.3.9.tar.gz
# RUN tar -xzvf chruby-0.3.9.tar.gz
# WORKDIR chruby-0.3.9/
# RUN make install
#
# RUN echo 'source /usr/local/share/chruby/chruby.sh \n\
# source /usr/local/share/chruby/auto.sh\n' >> ~/.bashrc
#
# RUN ruby-install ruby 2.5.6
# RUN echo ruby-2.5.6 > ~/.ruby-version
# RUN ruby -v

# Install Node.js LTS and yarn
RUN curl -sL https://deb.nodesource.com/setup_10.x | bash -
RUN apt-get install -y nodejs
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
  && echo 'deb http://dl.yarnpkg.com/debian/ stable main' > /etc/apt/sources.list.d/yarn.list

# RUN add-apt-repository ppa:neovim-ppa/stable
RUN apt-get update && apt-get install -y neovim
# # Install oh-my-zsh
# RUN chsh -s /usr/bin/zsh
# RUN curl -L http://install.ohmyz.sh | sh || true

# USER ${USER}
WORKDIR /home/${USER}
# Set up dotfiles
# COPY zsh .
COPY vimrc .vimrc
COPY vimrc.bundles .vimrc.bundles
COPY vim .vim
COPY tmux.conf .tmux.conf
COPY init.vim .config/nvim/init.vim
RUN chown -R ${USER} /home/${USER}
# COPY ./git/* ${HOME}/
USER ${USER}
RUN nvim +PlugInstall +qall > /dev/null
# Set up volumes
# WORKDIR /projects
# VOLUME /projects
# VOLUME /keys
# Enable colors
ENV TERM=xterm-256color


ENTRYPOINT ["fish"]
