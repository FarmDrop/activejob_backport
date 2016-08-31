require 'sidekiq'

module ActiveJob
  module QueueAdapters
    class SidekiqAdapter
      class << self
        def enqueue(job)
          #Sidekiq::Client does not support symbols as keys
          Sidekiq::Client.push \
            'class' => JobWrapper,
            'wrapped' => job.class.to_s,
            'queue' => job.queue_name,
            'args'  => [ job.serialize ],
            'retry' => JobWrapper.sidekiq_options['retry']
        end

        def enqueue_at(job, timestamp)
          Sidekiq::Client.push \
            'class' => JobWrapper,
            'wrapped' => job.class.to_s,
            'queue' => job.queue_name,
            'args'  => [ job.serialize ],
            'retry' => JobWrapper.sidekiq_options['retry'],
            'at'    => timestamp
        end
      end

      class JobWrapper
        include Sidekiq::Worker

        def perform(job_data)
          Base.execute job_data
        end
      end
    end
  end
end
