Workarea Taxjar
================================================================================

Taxjar integration for the Workarea ecomerce platform.


Taxjar provides a centralized service for tracking sales tax bills.
This plugin integrates that service into the Workarea platform. Instead of using
the Workarea platform's included sales tax calculation system, it uses Taxjar to
calculate sales tax. After an order is placed, that order's sales tax bill is
transmitted to Taxjar. Users may choose to commit (save them so that they are
reflected in tax liability) posted documents either via Workarea platform, or
via their own order management system.


Installation
--------------------------------------------------------------------------------

You will need a taxjar account to test your integration against. Development accounts can be obtained via the Taxjar.com signup process. You can find the API key for tax calculation in the adminstration console.


Add the Application gem to your gemfile in host application/
```ruby
  gem 'workarea-taxjar', '~> <version>'
```

Add the Taxjar API key to secrets:
```ruby
  taxjar:
    api_key: TAXJAR_API_KEY
```

Configuration
--------------------------------------------------------------------------------

Configure the taxjar plugin with the merchant's distribution center inside the host app's `config/initializers/workarea.rb` file.
```ruby
  Workarea.configure do |config|
    # Note that if a set of nexuses are passed in the API call,
    # they will override the set of nexuses defined in your TaxJar
    # account, rather than merging with them.  If nexuses are
    # defined on the taxjar side, leave this setting as an empty
    # array.
    config.taxjar.nexus_addresses = [
      {
        id: 'Main Warehouse',
        country: 'US',
        zip: '19106',
        state: 'PA',
        city: 'Philadelphia',
        street: '12 N. 3rd St.'
      }
    ]

    # Config for how orders should post to taxjar
    # :none - no action happens
    # :post - a transaction is created
    config.taxjar.order_handling = :none

    # Add the calculator in any desired environments
    unless Rails.env.test?
      config.pricing_calculators.swap(
        "Workarea::Pricing::Calculators::TaxCalculator",
        "Workarea::Pricing::Calculators::TaxjarTaxCalculator"
      )
    end
  end
```
Implementation Notes
--------------------------------------------------------------------------------

Tax calculations will only be performed when the customers state/region is located
in the same state as a taxable nexus. This will reduce the amount of extraneous API calls. See ***Configuration*** for setting up tax Nexus in either the host app or the Taxjar admin.

By default the sandbox API endpoint will be used in every non-production environment, with production uses the Taxjar production API endpoint.

This integration makes use of the ```workarea-circuit-breaker``` plugin which will disable tax calculation when the API service is unavailable.  The default Workarea Tax Calculator will be used when the Taxjar api service is not in use.
