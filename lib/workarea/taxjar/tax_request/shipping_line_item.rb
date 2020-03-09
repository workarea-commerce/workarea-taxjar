module Workarea
  module Taxjar
    class TaxRequest::ShippingLineItem < TaxRequest::LineItem
      attr_reader :shipping

      def initialize(shipping:)
        super
        @shipping = shipping
      end

      def quantity
        1
      end

      def amount
        shipping.price_adjustments.adjusting("shipping").sum(&:amount)
      end

      def unit_price
        amount
      end

      def item_code
        "SHIPPING"
      end

      def tax_code
        shipping.shipping_service.try(:tax_code)
      end

      def discount
        0
      end
    end
  end
end
