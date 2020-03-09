module Workarea
  class TaxjarSeeds
    def perform
      puts "Adding Taxjar Usage Types..."

      formatted_names.keys.each do |code|
        Workarea::Taxjar::UsageType.find_or_create_by(
          code: code,
          name: formatted_names.fetch(code, code),
          country_codes: ['US']
        )
      end
    end

    private

      def formatted_names
        {
          "wholesale"  => "Resale",
          "government" => "Government",
          "other"      => "Other or custom",
          "non_exempt" => "Non-excempt taxable customer"
        }
      end
  end
end
