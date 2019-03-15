def heroku_review_app?
  ENV['HEROKU_APP_NAME'] =~ /^hackney-repairs-.*-pr-\d+$/
end
