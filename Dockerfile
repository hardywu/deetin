FROM ruby:2.5.3

# Set the TZ variable to avoid perpetual system calls to stat(/etc/localtime)
ENV TZ=UTC

WORKDIR /app

ADD Gemfile Gemfile.lock /app/
RUN bundle install

# Copy application sources.
COPY . /app/

# The main command to run when the container starts.
CMD ["bundle", "exec", "puma", "--config", "config/puma.rb"]
