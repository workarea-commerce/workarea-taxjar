module Workarea
  module TaxjarApiConfig
    def self.included(test)
      super
      test.setup :set_key
      test.teardown :reset_key
    end

    def set_key
      Rails.application.secrets.merge!(
        taxjar: {
          api_key: '0b025b123017608d76593f4da3467083'
        }
      )
    end

    def reset_key
      Rails.application.secrets.delete(:taxjar)
    end
  end
end
