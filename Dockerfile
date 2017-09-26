FROM instructure/rvm

WORKDIR /app

COPY inst-jobs-statsd.gemspec Gemfile /app/
COPY lib/inst_jobs_statsd/version.rb /app/lib/inst_jobs_statsd/version.rb

USER root
RUN mkdir -p /app/coverage \
             /app/log \
             /app/spec/gemfiles/.bundle \
             /app/spec/dummy/log \
             /app/spec/dummy/tmp \
 && chown -R docker:docker /app

USER docker
RUN /bin/bash -l -c "cd /app && rvm-exec 2.4 bundle install"
COPY . /app

USER root
RUN chown -R docker:docker /app
USER docker

ENV TEST_DB_USERNAME postgres

CMD /bin/bash -l -c "rvm-exec 2.4 bundle exec wwtd --parallel"
