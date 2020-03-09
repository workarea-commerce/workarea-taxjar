module Workarea
  module Taxjar
    class TaxRequest::Error
      attr_reader :error
      delegate :code, :message, to: :error

      def initialize(error)
        @error = error
      end

      def to_h
        {}
      end
    end
  end
end
