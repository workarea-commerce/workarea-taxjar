module Workarea
  module Taxjar
    class TaxRequest::Addresses
      attr_reader :tax_request

      def initialize(tax_request:)
        @tax_request = tax_request
      end

      def hash
        {}
          .merge(ship_from)
          .merge(ship_to)
      end

      private

        def ship_from
          return {} if from_address.blank?
          {
            from_country: from_address[:country],
            from_zip:     from_address[:zip],
            from_state:   from_address[:state],
            from_city:    from_address[:city],
            from_street:  from_address[:street]
          }
        end

        def ship_to
          return {} if to_address.blank?
          {
            to_country: to_address.country.alpha2,
            to_zip:     to_address.postal_code,
            to_state:   to_address.region,
            to_city:    to_address.city,
            to_street:  to_address.street
          }
        end

        def to_address
          return @to_address if defined?(@to_address)
          @to_address = tax_request.shippings.first.try(:address)
        end

        def from_address
          return @to_address if defined?(@to_address)
          @from_address = Taxjar.config.nexus_addresses.first
        end
    end
  end
end
