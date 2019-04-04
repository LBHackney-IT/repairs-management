module Profiling
  extend ActiveSupport::Concern

  class Profiler
    def initialize(target_class)
      @target_class = target_class
    end

    def method_missing(m, *args, &block)
      caller = caller_locations.first.label
      Appsignal.instrument("#{caller}->#{@target_class.name}##{m}") do
        @target_class.send(m, *args, &block)
      end
    end
  end

  class_methods do
    def profile
      Profiler.new(self)
    end
  end
end
