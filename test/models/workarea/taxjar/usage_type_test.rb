require "test_helper"

module Workarea
  module Taxjar
    class UsageTypeTest < Workarea::TestCase
      def test_countries_returns_array_of_cuntries
        ussage_type = UsageType.new(country_codes: ["US"])

        assert_equal [Country["US"]], ussage_type.countries
      end
    end
  end
end
