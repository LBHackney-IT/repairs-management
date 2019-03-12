namespace :deploy do
  desc "waits (only on review apps) for neo4j to boot and then run migrations"
  task :wait_and_migrate, [] => [:environment] do |_t, args|
    sleep 60 if heroku_review_app?
    Rake::Task["db:migrate"].invoke
  end
end
