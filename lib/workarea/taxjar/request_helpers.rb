# Assumes methods that reference the +order+ and +shippings+
module Workarea
  module Taxjar
    module RequestHelpers
      private

      def request_options
        options.slice(:timeout)
      end

      def order_info
        {
          transaction_id: order.id.to_s,
          transaction_date: order.placed_at.to_s
        }
      end

      def addresses
        TaxRequest::Addresses.new(tax_request: self).hash
      end

      def order_totals
        {
          amount:   order_total,
          shipping: shipping_total
        }
      end

      def customer
        return {} if user.blank?
        { customer_id: user.id.to_s }
      end

      def nexus_addresses
        return {} unless Taxjar.config.nexus_addresses.any?
        { nexus_addresses: Taxjar.config.nexus_addresses }
      end

      def line_items
        { line_items: lines }
      end

      def user
        return @user if defined?(@user)
        @user = if order.email.present?
          User.find_by_email(order.email)
        else
          nil
        end
      end

      def order_total
        order.subtotal_price.to_f
      end

      def shipping_total
        shippings
          .flat_map { |s| s.price_adjustments.adjusting('shipping') }
          .map(&:amount)
          .sum
          .to_f
      end

      def order_line_items
        @order_line_items ||=
          order.price_adjustments.grouped_by_parent.flat_map do |item, set|
            set.map do |adjustment|
              next unless adjustment.data["tax_code"].present?

              TaxRequest::OrderLineItem.new(
                order_item: item,
                adjustment: adjustment,
                adjustment_set: set
              )
            end
          end.compact
      end

      def shipping_line_items
        @shipping_line_item ||= shippings.map { |shipping|
          TaxRequest::ShippingLineItem.new(shipping: shipping)
        }
      end
    end
  end
end
