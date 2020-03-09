module Workarea
  module Taxjar
    class Engine < ::Rails::Engine
      include Workarea::Plugin

      isolate_namespace Workarea::Taxjar
    end
  end
end
