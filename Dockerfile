FROM ruby:2.6.3-alpine

LABEL "org.gusrub.vendor"="Gustavo Adolfo Rubio Casillas"
LABEL "com.saecri.maintainer"="Gustavo Rubio <mail@gustavorub.io>"
LABEL "com.saecri.product"="Chiquito"
LABEL "version"="1.0"
LABEL "description"="A simple URL shortener"

ARG RAILS_ENV="development"
ENV RAILS_ENV=$RAILS_ENV
ENV RACK_ENV=$RAILS_ENV

RUN apk update && apk add --no-cache build-base libxml2-dev libxslt-dev wget openjdk8 bash tzdata postgresql-dev libpq nodejs npm openssh git tar file
RUN mkdir /app
WORKDIR /app

COPY Gemfile ./Gemfile
COPY Gemfile.lock ./Gemfile.lock

RUN gem install bundler -v 1.17.1
RUN bundle install -j 4
RUN bundle exec rails db:drop db:create db:migrate
COPY . .

EXPOSE 3000

HEALTHCHECK --interval=1m --timeout=5s CMD wget -S --spider -q localhost:3000 || exit 1

COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh

CMD ["bundle", "exec", "puma", "-C", "/app/config/puma.rb"]
ENTRYPOINT ["entrypoint.sh"]
