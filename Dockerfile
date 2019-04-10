FROM ruby:2.5.3-alpine

RUN bundle config --global build.nokogiri --use-system-libraries
RUN apk --no-cache --update add make libxml2 libxslt-dev g++ tzdata
RUN apk --no-cache add mysql-dev

ENV APP_HOME /app
WORKDIR $APP_HOME
ENV LANG C.UTF-8 # <---- This is the important part
RUN echo "gem: --no-ri --no-rdoc" > ~/.gemrc

ADD Gemfile Gemfile.lock $APP_HOME/
RUN gem install bundler
RUN bundle install

# Copy application sources.
COPY . /app/
RUN bundle exec rails app:update:bin

# The main command to run when the container starts.
CMD ["bundle", "exec", "puma", "--config", "config/puma.rb"]
