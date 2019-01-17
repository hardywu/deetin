FROM ruby:2.5.3

WORKDIR /app
ADD Gemfile Gemfile.lock /app/
RUN gem sources --add https://gems.ruby-china.com/ --remove https://rubygems.org/
RUN bundle install
