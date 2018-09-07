class ExampleJob < ApplicationJob
  queue_as :default

  def perform(*args)
    raise 'BANG!' if args.length > 0
    puts "BOOOOOOOOM!"
  end
end
