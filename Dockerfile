FROM instructure/rvm

WORKDIR /app
USER root
RUN apt-get update \
 && apt-get install -y git \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*
RUN chown -R docker:docker /app
USER docker

COPY --chown=docker:docker inst-jobs-statsd.gemspec Gemfile Gemfile.lock /app/
COPY --chown=docker:docker lib/inst_jobs_statsd/version.rb /app/lib/inst_jobs_statsd/version.rb

RUN mkdir -p /app/coverage \
             /app/log \
             /app/spec/gemfiles/.bundle \
             /app/spec/dummy/log \
             /app/spec/dummy/tmp

RUN /bin/bash -lc "cd /app && rvm-exec 2.7 gem install bundler -v 2.4.20 && rvm-exec 2.7 bundle install --jobs 5"
COPY --chown=docker:docker . /app

ENV TEST_DB_USERNAME postgres

CMD /bin/bash -l -c "rvm-exec 2.7 bundle exec wwtd --parallel"
