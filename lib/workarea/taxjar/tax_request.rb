module Workarea
  module Taxjar
    class TaxRequest
      include RequestHelpers

      attr_reader :order, :shippings, :options

      def initialize(order:, shippings: [], **options)
        @order = order
        @shippings = shippings
        @options = options.deep_symbolize_keys
      end

      def response
        @response ||= Response.new(
          response: cached_response,
          request_order_line_items: order_line_items,
          request_shipping_line_items: shipping_line_items
        )
      end

      private

        def cached_response
          Rails.cache.fetch(cache_key, expires_in: 15.minutes) do
            raw_response
          end
        end

        def cache_key
          'taxjar-' <<
          Digest::MD5.hexdigest(
            request_body
              .to_a
              .map { |a| a.join(':') }
              .join(',')
          )
        end

        def raw_response
          @raw_response ||=
            begin
              Taxjar.gateway.tax_for_order(request_body)
            rescue ::Taxjar::Error => e
              Error.new(e)
            end
        end

        def request_body
          {}
            .merge(addresses)
            .merge(order_totals)
            .merge(customer)
            .merge(nexus_addresses)
            .merge(line_items)
            .merge(request_options)
        end

        def lines
          order_line_items.map(&:hash)
        end

    end
  end
end
