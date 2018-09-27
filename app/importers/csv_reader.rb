require 'csv'

class CsvReader
  def initialize(kind)
    @kind
  end

  def read_csv
    count = 0
    time = Time.current
    CSV.parse(STDIN, headers: true) do |row|
      yield row
      count += 1
      if count % 100 == 0
        puts "count = %d, %0.5f s per %s" % [count, (Time.current - time) / 100, @kind]
        time = Time.current
      end
    end
  end
end
