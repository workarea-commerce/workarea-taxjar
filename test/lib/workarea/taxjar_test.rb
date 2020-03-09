require "test_helper"

module Workarea
  class TaxjarTest < Workarea::TestCase
    def test_auto_configure_gateway_creates_bogus_gateway_without_secrets
      assert_instance_of(Taxjar::BogusGateway, Taxjar.gateway)
    end

    def test_auto_configure_gateway_creates_real_gateway_with_secrets
      Rails.application.secrets.merge!(
        taxjar: {
          api_key: 'key',
          timeout: 3,
          endpoint: 'https://api.taxjar.com'
        }
      )

      assert_instance_of(::Taxjar::Client, Taxjar.gateway)

    ensure
      Rails.application.secrets.delete(:taxjar)
    end
  end
end
