module Workarea
  module Taxjar
    class TaxRequest::Response
      attr_reader :response, :request_order_line_items, :request_shipping_line_items

      def initialize(response:, request_order_line_items:, request_shipping_line_items:)
        @response = response
        @request_order_line_items = request_order_line_items
        @request_shipping_line_items = request_shipping_line_items
      end

      def success?
        !response.kind_of?(TaxRequest::Error)
      end

      def tax_line_for_adjustment(price_adjustment)
        return unless success?

        order_item = request_order_line_items
          .detect { |line_item| line_item.adjustment == price_adjustment }
          .try(:order_item)

        return unless order_item

        line_items.detect { |line| line[:id] == order_item.id.to_s }
      end

      def tax_line_for_shipping(shipping)
        shipping_items
      end

      def line_items
        @line_items ||=
          body
            .fetch(:breakdown, {})
            .fetch(:line_items, [])
      end

      def shipping_items
        @shipping_items ||=
          body
            .fetch(:breakdown, {})
            .fetch(:shipping, {})
      end

      def body
        @body ||= response.to_h
      end

    end
  end
end
