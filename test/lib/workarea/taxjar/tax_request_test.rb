require "test_helper"

module Workarea
  module Taxjar
    class TaxRequestTest < Workarea::TestCase
      include TaxjarApiConfig

      def test_successful_response
        response = VCR.use_cassette :succesful_taxjar_create_transaction, allow_playback_repeats: true do
          request = TaxRequest.new(order: order, shippings: shippings)
          request.response
        end

        assert response.success?
      end

      private

        def order
          @order ||= create_checkout_order(email: "epigeon@weblinc.com")
        end

        def shippings
          @shippings ||= Shipping.where(order_id: order.id)
        end
    end
  end
end
