require "test_helper"

module Workarea
  module Taxjar
    class TaxInvoiceWorkerTest < Workarea::TestCase
      def test_worker_sets_invoice_time_stamp
        Workarea.with_config do |config|
          config.taxjar.order_handling = :post

          order = create_placed_order

          Workarea::Taxjar::TaxInvoiceWorker.new.perform(order.id)

          order.reload

          assert(order.tax_invoice_sent_at.present?)
        end
      end
    end
  end
end
