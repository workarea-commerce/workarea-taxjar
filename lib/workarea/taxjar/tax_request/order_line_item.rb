module Workarea
  module Taxjar
    class TaxRequest::OrderLineItem < TaxRequest::LineItem
      attr_reader :order_item, :adjustment, :adjustment_set

      def initialize(order_item:, adjustment:, adjustment_set:)
        @order_item = order_item
        @adjustment = adjustment
        @adjustment_set = adjustment_set
      end

      def invoice_hash
        hash.merge(
          product_identifier: order_item.product_id,
          description: product_name,
          sales_tax: 0.0
        )
      end

      def item_code
        order_item.id.to_s
      end

      def quantity
        adjustment.quantity
      end

      def amount
        adjustment.amount.to_f
      end

      def unit_price
        amount / adjustment.quantity
      end

      def tax_code
        adjustment.data["tax_code"]
      end

      def discount
        adjustment_set.discounts.sum.to_f.abs
      end

      def product_name
        name = order_item.product_attributes[:name]
        case name
        when String
          name
        when Hash
          name[:en]
        else
          order_item.sku
        end
      end
    end
  end
end
