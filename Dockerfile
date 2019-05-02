FROM debian:stretch-slim
MAINTAINER devel@capside.com

RUN export DEBIAN_FRONTEND=noninteractive

# Install sys-level dependencies
 RUN apt-get update && apt-get install -y  \
  apt-transport-https \
  build-essential \
  cpanminus \
  libmodule-install-perl \
  libssl-dev \
  perl \
&& apt clean

# Install cpm
RUN cpanm -nq App::cpm && rm -rf $HOME/.cpanm

WORKDIR /code

# Install perl dependencies
RUN cpm install -g \
  HTTP::Tiny \
  HTTP::Request \
  HTTP::Date \
  LWP::UserAgent \
  Moose \
  Data::Dumper \
&& rm -rf ~/.perl-cpm
