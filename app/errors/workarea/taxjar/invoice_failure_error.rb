module Workarea
  module Taxjar
    class InvoiceFailureError < StandardError
      attr_reader :order

      def initializer(order)
        @order = order
      end

      def message
        "Failed to invoice tax for order: #{order.id}"
      end
    end
  end
end
