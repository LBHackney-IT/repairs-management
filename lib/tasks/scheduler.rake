# This file is used by Heroku Scheduler

namespace :hackney do
  desc "Import work orders"
  task :import_work_orders => :environment do
    WorkOrdersImporter.new.import
  end
end
