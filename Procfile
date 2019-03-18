web: bundle exec puma -t 5:5 -p ${PORT:-3000} -e ${RACK_ENV:-development}
worker: LOG_LEVEL=info QUEUE=default rake jobs:work
feed_worker: QUEUE=feed rake jobs:work
