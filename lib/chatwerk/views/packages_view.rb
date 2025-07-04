# frozen_string_literal: true

module Chatwerk
  module Views
    class PackagesView < BaseView
      def template(packages:, package_path: nil)
        if packages.empty?
          "No packages found matching #{package_path.inspect}\n"
        else
          packages.map { |p| "#{p.name}\n" }.sort.join
        end
      end
    end
  end
end
