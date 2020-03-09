Workarea.configure do |config|
  config.cache_expirations.taxjar_nexus = 1.hour

  config.taxjar ||= ActiveSupport::Configurable::Configuration.new

  # Config for how orders should post to taxjar
  # :none - no action happens
  # :post - a transaction is created
  config.taxjar.order_handling = :none
  config.taxjar.nexus_addresses ||= []

  config.taxjar.timeout = 2
  config.taxjar.test = Rails.env.production? ? true : false

  config.sandbox_enpoint = "https://api.sandbox.taxjar.com"
  config.production_enpoint = "https://api.taxjar.com"

  config.seeds.append("Workarea::TaxjarSeeds")
end

Workarea.config.pricing_calculators.swap(
  "Workarea::Pricing::Calculators::TaxCalculator",
  "Workarea::Pricing::Calculators::TaxjarTaxCalculator"
)
