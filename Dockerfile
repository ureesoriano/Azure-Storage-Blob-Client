FROM debian:stretch-slim
MAINTAINER devel@capside.com

RUN export DEBIAN_FRONTEND=noninteractive

# Install sys-level dependencies
 RUN apt-get update && apt-get install -y  \
  apt-transport-https \
  build-essential \
  perl \
  cpanminus \
  libmodule-install-perl \
  libssl-dev \
  libxml2-dev \
  git \
&& apt clean

# Install cpm
RUN cpanm -nq App::cpm && rm -rf $HOME/.cpanm

COPY cpanfile /code/cpanfile
WORKDIR /code

# Install perl dependencies
RUN cpm install -g \
  --cpanfile=./cpanfile \
  --with-develop \
&& rm -rf ~/.perl-cpm
