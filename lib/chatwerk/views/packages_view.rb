require_relative 'base_view'

module Chatwerk
  module Views
    class PackagesView < BaseView
      def render
        if packages.empty?
          "No packages found matching #{package_path.inspect}"
        else
          packages.map(&:name).sort.join("\n")
        end
      end
    end
  end
end
