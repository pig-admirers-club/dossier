FROM ruby:2.7.0-buster

RUN apt-get install -y libpq-dev
ADD [".","/app"]
WORKDIR /app

RUN bundle install

EXPOSE 4567

CMD ruby index.rb -o 0.0.0.0
ENTRYPOINT ["bundle", "exec"]
