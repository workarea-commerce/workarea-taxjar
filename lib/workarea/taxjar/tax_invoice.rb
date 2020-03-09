module Workarea
  module Taxjar
    class TaxInvoice
      include RequestHelpers

      attr_reader :order, :shippings, :options

      def initialize(order:, shippings: [], **options)
        @order = order
        @shippings = shippings
        @options = options.deep_symbolize_keys
      end

      def response
        @response ||= TaxRequest::Response.new(
          response: raw_response,
          request_order_line_items: order_line_items,
          request_shipping_line_items: shipping_line_items
        )
      end

      private

        def raw_response
          @raw_response ||=
            begin
              Taxjar.gateway.create_order(request_body)
            rescue ::Taxjar::Error => e
              TaxRequest::Error.new(e)
            end
        end

        def request_body
          {}
            .merge(order_info)
            .merge(addresses)
            .merge(order_totals)
            .merge(customer)
            .merge(line_items)
            .merge(request_options)
        end

        def order_totals
          super.merge(sales_tax: order.tax_total.to_f)
        end

        def order_total
          super + shipping_total
        end

        def lines
          order_line_items.map(&:invoice_hash)
        end
    end
  end
end
