module Workarea
  module Taxjar
    class TaxRequest::LineItem
      def initialize(**)
      end

      def hash
        {
          id:               item_code,
          quantity:         quantity,
          product_tax_code: tax_code,
          unit_price:       unit_price.to_s,
          discount:         discount
        }
      end

      def item_code
        raise NotImplementedError, "#{self.class.name} must implement #item_code"
      end

      def quantity
        raise NotImplementedError, "#{self.class.name} must implement #quantity"
      end

      def amount
        raise NotImplementedError, "#{self.class.name} must implement #amount"
      end

      def unit_price
        raise NotImplementedError, "#{self.class.name} must implement #unit_price"
      end

      def tax_code
        raise NotImplementedError, "#{self.class.name} must implement #tax_code"
      end

      def discount
        raise NotImplementedError, "#{self.class.name} must implement #discount"
      end
    end
  end
end
