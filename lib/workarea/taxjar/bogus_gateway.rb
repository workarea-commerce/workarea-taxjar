module Workarea
  module Taxjar
    class BogusGateway
      def tax_for_order(body)
        BogusTaxForOrder.new(body).response
      end

      def create_order(body)
        BogusTaxForOrder.new(body).response
      end
    end
  end
end
