module Workarea
  module Taxjar
    class BogusGateway::BogusTaxForOrder
      attr_reader :request_body

      def initialize(request_body)
        @request_body = request_body
      end

      def response
        ::Taxjar::Tax.new(response_body)
      end

      private

        def state_rate
          0.01
        end

        def county_rate
          0.0075
        end

        def city_rate
          0.0025
        end

        def combined_rate
          state_rate + county_rate + city_rate
        end

        def response_body
          {
            order_total_amount: request_body[:amount] + request_body[:shipping],
            shipping:           request_body[:shipping],
            taxable_amount:     request_body[:amount],
            amount_to_collect:  sum_lines(:tax_collectable),
            rate:               combined_rate,
            has_nexus:          true,
            freight_taxable:    false,
            tax_source:         "destination",
            jurisdictions: {
              country: request_body[:to_country],
              state:   request_body[:to_state],
              county:  "County",
              city:    request_body[:to_city]
            },
            breakdown: {
              taxable_amount:         sum_lines(:taxable_amount),
              tax_collectable:        sum_lines(:tax_collectable),
              combined_tax_rate:      sum_lines(:combined_tax_rate),
              state_taxable_amount:   sum_lines(:state_taxable_amount),
              state_tax_rate:         state_rate,
              state_tax_collectable:  sum_lines(:state_amount),
              county_taxable_amount:  sum_lines(:county_taxable_amount),
              county_tax_rate:        county_rate,
              county_tax_collectable: sum_lines(:county_amount),
              city_taxable_amount:    sum_lines(:city_taxable_amount),
              city_tax_rate:          city_rate,
              city_tax_collectable:   sum_lines(:city_amount),
              special_district_taxable_amount:
                                      sum_lines(:special_district_taxable_amount),
              special_tax_rate:       0.0,
              special_district_tax_collectable:
                                      0.0,
              shipping: shipping,
              line_items: lines
            }
          }
        end

        def sum_lines(field)
          lines.map { |line| line[field].to_f }.sum
        end

        def shipping
          line_from_request(
            quantity: 1,
            unit_price: request_body[:shipping].to_f
          )
        end

        def lines
          @lines ||= request_body[:line_items].map do |line|
            line_from_request(line)
          end.compact
        end

        def line_from_request(line)
          qty = line[:quantity]
          unit = line[:unit_price].to_f
          code = line[:product_tax_code]
          discount = line[:discount].to_f

          taxable = (unit * qty).round(2) - discount

          {
            id:                      line[:id],
            taxable_amount:          taxable,
            combined_tax_rate:       combined_rate,
            tax_collectable:         (combined_rate * taxable).round(2),
            state_taxable_amount:    taxable,
            state_sales_tax_rate:    state_rate,
            state_amount:            (state_rate * taxable).round(2),
            county_taxable_amount:   taxable,
            county_tax_rate:         county_rate,
            county_amount:           (county_rate * taxable).round(2),
            city_taxable_amount:     taxable,
            city_tax_rate:           city_rate,
            city_amount:             (city_rate * taxable).round(2),
            special_district_taxable_amount: taxable,
            special_tax_rate:        0.0,
            special_district_amount: 0.0
          }
        end
    end
  end
end
