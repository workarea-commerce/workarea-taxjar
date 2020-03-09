require "taxjar"
require "workarea/core"
require "workarea/storefront"
require "workarea/admin"
require "workarea/circuit_breaker"

module Workarea
  module Taxjar
    include ActiveSupport::Configurable

    def self.config
      Workarea.config.taxjar
    end

    def self.credentials
      (Rails.application.secrets.taxjar || {}).deep_symbolize_keys
    end

    def self.api_key
      credentials[:api_key]
    end

    def self.test?
      config.test
    end

    def self.commit?
      config.order_handling == :post
    end

    def self.gateway
      if credentials.present?
        attrs = {
          api_key: api_key,
          timeout: config.timeout,
          endpoint: test? ? config.sandbox_enpoint : config.production_endpoint
        }

        ::Taxjar::Client.new(attrs)

      else
        Taxjar::BogusGateway.new
      end
    end
  end
end

require "workarea/taxjar/engine"
require "workarea/taxjar/version"
require "workarea/taxjar/request_helpers"
require "workarea/taxjar/tax_request"
require "workarea/taxjar/tax_invoice"
require "workarea/taxjar/tax_request/error"
require "workarea/taxjar/tax_request/line_item"
require "workarea/taxjar/tax_request/order_line_item"
require "workarea/taxjar/tax_request/shipping_line_item"
require "workarea/taxjar/tax_request/addresses"
require "workarea/taxjar/tax_request/response"
require "workarea/taxjar/bogus_gateway"
require "workarea/taxjar/bogus_gateway/bogus_tax_for_order"
