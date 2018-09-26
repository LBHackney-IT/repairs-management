module Hackney
  module WorkOrders
    class ReferenceFinder
      def initialize(work_order_reference)
        @work_order_reference = work_order_reference
      end

      def find(text)
        text.scan(/\d+/).select { |n| n.size == 8 && n != @work_order_reference }
      end
    end
  end
end
