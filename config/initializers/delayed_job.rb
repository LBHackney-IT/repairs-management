Delayed::Worker.raise_signal_exceptions = :term
Delayed::Worker.max_attempts = ENV.fetch('DELAYED_JOB_MAX_ATTEMPTS', Delayed::Worker::DEFAULT_MAX_ATTEMPTS).to_i
