module InstJobsStatsd
  module Naming
    BASENAME = 'delayedjob'.freeze

    # The root prefix for all stat names
    # TODO: Make this configurable
    def self.basename
      BASENAME
    end

    def self.qualified_names(stat_name, job)
      names = ["#{basename}.#{stat_name}"]
      tagged = tagged_stat(names[0], job)
      names << tagged if tagged.present?
      names << region_tags(names)
      names.flatten.compact
    end

    # Given a stat name, add a suffix to it to make it
    # unique per job type -- using the job's class name
    # and method name as appropriate
    def self.tagged_stat(stat_name, job)
      return unless job

      obj_tag, method_tag = job_tags(job)
      return if obj_tag.blank?

      tagged = "#{stat_name}.tag.#{obj_tag}"
      tagged += ".#{method_tag}" if method_tag.present?
      tagged
    end

    def self.dd_job_tags(job)
      return {} unless job
      return {} unless job.tag
      return {} if job.tag =~ /Class:0x/

      method_tag, obj_tag = split_to_tag(job)
      tag = obj_tag
      tag = [obj_tag, method_tag].join('.') if method_tag.present?
      {tag: tag}
    end

    # this converts Foo#bar" or "Foo.bar" into "Foo and "bar",
    # and makes sure the values are valid to be used for statsd names
    def self.job_tags(job)
      return unless job
      return unless job.tag
      return if job.tag =~ /Class:0x/

      method_tag, obj_tag = split_to_tag(job)
      tags = [obj_tag]
      tags << method_tag if method_tag.present?
      tags
    end

    # We are using all existing stat names here because we do not want
    # to break existing dependencies on the non-regioned data
    def self.region_tags(stat_names)
      return unless ENV['INST_JOBS_STATSD_NAMESPACE']

      stat_names.map do |name|
        name
          .split('.')
          .insert(2, ENV['INST_JOBS_STATSD_NAMESPACE'])
          .join('.')
      end
    end

    private

    def self.split_to_tag(job)
      obj_tag, method_tag = job.tag.split(/[\.#]/, 2).map do |v|
        InstStatsd::Statsd.escape(v).gsub('::', '-')
      end
      return method_tag, obj_tag
    end
  end
end
