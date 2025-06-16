# inst-jobs + inst_statsd

This gem adds [inst_statsd](https://github.com/instructure/inst_statsd) reporting to [inst-jobs](https://github.com/instructure/inst-jobs). Simply add reporting on `inst-jobs` activity by including this gem, and adding to your initializers:

```ruby
InstStatsd::DefaultTracking.track_jobs
```

## Stats

Implements the following stats:

- for each job:
  - `delayedjob.queue`: time spent in queue, prior to starting (timing)
  - `delayedjob.perform`: time to execute (timing)
  - `delayedjob.create`: Simple counter of created jobs (incremented in the job's `after create` lifecycle hook)
  - `delayedjob.run`: simple counter of executed jobs (incremented in the job's `before` lifecycle hook)
  - `delayedjob.complete`: Simple counter of completed jobs (incremented in the job's `after` lifecycle hook)

- for failed jobs:
  - `delayedjob.failed`: sent for each job failure (count)
  - `delayedjob.failed_after`: time to failure (timing)

- periodic gauges -- roughly every 60s:
  - `delayedjob.run_depth`: # of running jobs by queue
  - `delayedjob.run_depth.total`: # of running jobs
  - `delayedjob.run_age_max`: age in seconds of oldest running jobs by queue
  - `delayedjob.run_age_max.total`: age in seconds of oldest running jobs
  - `delayedjob.run_age_total`: total age in seconds of running jobs by queue
  - `delayedjob.run_age_total.total`: total age in seconds of running jobs
  - `delayedjob.queue_depth`: # of pending jobs, ready to run by queue
  - `delayedjob.queue_depth.total`: # of pending jobs, ready to run
  - `delayedjob.queue_age_max`: age in seconds of oldest job in the queue by queue
  - `delayedjob.queue_age_max.total`: age in seconds of oldest job in the queue
  - `delayedjob.queue_age_total`: total age in seconds of jobs in the queue by queue
  - `delayedjob.queue_age_total.total`: total age in seconds of jobs in the queue
  - `delayedjob.failed_depth`: # of jobs in the failed_jobs table by queue
  - `delayedjob.failed_depth.total`: # of jobs in the failed_jobs table

- other
  - `delayedjob.pop`: time for each :pop callback (timing)
  - `delayedjob.workqueuepop`: time for each :work_queue_pop callback (timing)

### Tagged stats

Each stat that is associated with a particular job will also use the job's tag
to create a tagged version of the stat. So, for a job with the tag `BatchProcessing#run`,
the `delayedjob.perform` stat would also generate `delayedjob.perform.tag.BatchProcessing.run`,
allowing stats to be tracked for unique job types.

An ENV variable, `INST_JOBS_STATSD_NAMESPACE`, can be defined to further segregate data
if necessary (for example, by region). Adding this namespace will maintain existing stats and
also create new namespaced stats
  - For an ENV var defined as `iad-prod`: `delayedjob.perform` would also generate `delayedjob.perform.iad-prod`

## Installation

First ensure that [inst-jobs](https://github.com/instructure/inst-jobs) and [inst_statsd](https://github.com/instructure/inst_statsd) are installed and configured appropriately.

Add this line to your application's Gemfile:

```ruby
gem 'inst-jobs-statsd'
```

And then execute:

```bash
bundle
```

Or install it yourself like so:

```bash
gem install inst-jobs-statsd
```

Add `track_jobs` to your `inst_statds` initialization:

```ruby
# config/initializers/inst_statsd.rb
InstStatsd::DefaultTracking.track_jobs
```

## Development

A simple docker environment has been provided for spinning up and testing this
gem with multiple versions of Ruby. This requires docker and docker-compose to
be installed. To get started, run the following:

```bash
./build.sh
```

This will install the gem in a docker image with all versions of Ruby installed,
and install all gem dependencies in the Ruby 2.7 set of gems. It will also
download and spin up a Graphite container for use with specs. Finally, it will
run [wwtd](https://github.com/grosser/wwtd), which runs all specs across all
supported version of Ruby and Rails, bundling gems for each combination along
the way.

The first build will take a long time, however, docker images and gems are
cached, making additional runs significantly faster.

Individual spec runs can be started like so:

```bash
docker-compose run --rm app /bin/bash -l -c \
  "BUNDLE_GEMFILE=spec/gemfiles/60.gemfile rvm-exec 2.7 bundle exec rspec"
```

If you'd like to mount your git checkout within the docker container running
tests so changes are easier to test, use the override provided:

```bash
cp docker-compose.override.example.yml docker-compose.override.yml
```


## Making a new Release

To install this gem onto your local machine, run `bundle exec rake install`. To
release a new version, update the version number in `version.rb`, and then just
run `bundle exec rake release`, which will create a git tag for the version,
push git commits and tags, and push the `.gem` file to
[rubygems.org](https://rubygems.org).


## Contributing

Bug reports and pull requests are welcome on GitHub at
https://github.com/instructure/inst-jobs-statsd.


## License

The gem is available as open source under the terms of the
[MIT License](http://opensource.org/licenses/MIT).
