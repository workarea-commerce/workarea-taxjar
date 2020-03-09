module Workarea
  module Taxjar
    class TaxInvoiceWorker
      include Sidekiq::Worker
      include Sidekiq::CallbacksWorker

      sidekiq_options(
        enqueue_on: {
          Workarea::Order => :place,
          only_if: -> { Taxjar.commit? }
        }
      )

      def perform(order_id)
        order = Workarea::Order.find(order_id)
        shippings = Workarea::Shipping.where(order_id: order.id).to_a

        response = Taxjar::TaxInvoice.new(
          order: order,
          shippings: shippings
        ).response

        raise InvoiceFailureError, order unless response.success?

        order.set(tax_invoice_sent_at: Time.now)
      end
    end
  end
end
