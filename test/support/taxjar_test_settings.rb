Workarea::Taxjar.configure do |config|
  config.nexus_addresses = [
    {
      id: 'Main Warehouse',
      country: 'US',
      zip: '19106',
      state: 'PA',
      city: 'Philadelphia',
      street: '12 N. 3rd St.'
    }
  ]
end
