FROM ruby:2.5

# Update node.js package distribution from 4.8.2 to 10.x
RUN curl -sL https://deb.nodesource.com/setup_10.x | bash -

# Install apt based dependencies required to run Rails as
# well as RubyGems. As the Ruby image itself is based on a
# Debian image, we use apt-get to install those.
RUN apt-get update && apt-get install -y \
  libpq-dev \
  build-essential \
  nodejs

# Install yarn
ENV PATH=/root/.yarn/bin:$PATH
RUN curl -o- -L https://yarnpkg.com/install.sh | bash

# Configure the main working directory. This is the base
# directory used in any further RUN, COPY, and ENTRYPOINT
# commands.
WORKDIR /app

# Pre-install nokogiri so we don't have to recompile when adding gems
RUN gem install nokogiri --version 1.8.3

# Copy the Gemfile as well as the Gemfile.lock and install
# the RubyGems. This is a separate step so the dependencies
# will be cached unless changes to one of those two files
# are made.
COPY Gemfile Gemfile.lock ./
RUN bundle install
