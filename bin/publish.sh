#!/bin/bash
# shellcheck shell=bash

set -e

current_version=$(ruby -e "require '$(pwd)/lib/inst_jobs_statsd/version.rb'; puts InstJobsStatsd::VERSION;")
existing_versions=$(gem list --exact inst-jobs-statsd --remote --all | grep -o '\((.*)\)$' | tr -d '() ')

if [[ $existing_versions == *$current_version* ]]; then
  echo "Gem has already been published ... skipping ..."
else
  gem build ./inst-jobs-statsd.gemspec
  find inst-jobs-statsd-*.gem | xargs gem push
fi
