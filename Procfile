web: bundle exec puma -t 3:3 -p ${PORT:-3000} -e ${RACK_ENV:-development}
worker: QUEUE=default rake jobs:work
feed_worker: QUEUE=feed rake jobs:work
