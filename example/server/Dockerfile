FROM ruby:2.5.3

WORKDIR /app

COPY Gemfile Gemfile.lock /app/
RUN bundle install

COPY . /app/

CMD ["bundle", "exec", "ruby", "server.rb"]
