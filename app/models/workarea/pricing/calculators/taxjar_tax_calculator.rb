module Workarea
  module Pricing
    module Calculators
      # calculates order/shipping sales tax via the Taxjar API
      class TaxjarTaxCalculator < TaxCalculator
        def adjust
          return super unless Workarea.config.taxjar.enabled
          return unless in_taxable_region?

          Workarea::CircuitBreaker[:taxjar_service].wrap(fallback: :fallback) do
            return unless response.success?

            shippings.each do |shipping|
              next unless shipping.address.present?

              price_adjustments_for(shipping).each do |adjustment|
                tax_line = response.tax_line_for_adjustment adjustment
                next unless tax_line.present?

                adjust_pricing(
                  shipping,
                  tax_line,
                  "order_item_id" => adjustment._parent.id,
                  "adjustment" => adjustment.id
                 )
              end

              shipping_tax_line = response.tax_line_for_shipping(shipping)
              adjust_pricing(shipping, shipping_tax_line, "shipping_service_tax" => true)
            end
          end
        end

        private

          def response
            @response ||= tax_request.response
          end

          def tax_request
            @tax_request ||= Taxjar::TaxRequest.new(
              order: order,
              shippings: shippings,
              **request_options
            )
          end

          def request_options
            { timeout: Taxjar.config.timeout }
          end

          def fallback
            Pricing::Calculators::TaxCalculator.new(request).adjust
          end
          alias_method :handle_timeout_error, :fallback

          def adjust_pricing(shipping, tax_line, data = {})
            return if tax_line.fetch(:tax_collectable, nil).to_m.zero?

            line_details = tax_line.each_with_object({}) do |(k, v), memo|
              memo[k] = v
            end

            shipping.adjust_pricing(
              price: "tax",
              calculator: self.class.name,
              description: "Sales Tax",
              amount: tax_line.fetch(:tax_collectable).to_m,
              data: data.merge(line_details)
            )
          end

          def in_taxable_region?
            return unless address.present?

            regions = (remote_nexus_regions + app_nexus_regions).uniq

            return true if regions.empty?

            regions.include?(address.region)
          end

          # nexus regions defined in the Taxjar admin
          def remote_nexus_regions
            md5 = Digest::MD5.hexdigest(Workarea::Taxjar.api_key)

            key = "taxjar_regions/#{md5}"

            Rails.cache.fetch(key, expires_in: Workarea.config.cache_expirations.taxjar_nexus) do
              Workarea::Taxjar.gateway.nexus_regions.map(&:region_code)
            end
          rescue
            []
          end

          # nexus regions defiend in the host app
          def app_nexus_regions
            return [] unless Workarea::Taxjar.config[:nexus_addresses]
            Workarea::Taxjar.config[:nexus_addresses].map { |a| a[:state] }
          rescue
            []
          end

          def address
            shipping = shippings.first

            # try to use the shipping address from the shimpment.
            # if its not there then fall back to the billing address
            return shipping.address if (shipping.present? && shipping.address.present?)

            payment_address
          end

          def payment_address
            payment = Workarea::Payment.where(id: order.id).first
            return unless payment.present?

            payment.address
          end
      end
    end
  end
end
