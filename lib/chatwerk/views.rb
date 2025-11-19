# frozen_string_literal: true

module Chatwerk
  module Views
    autoload :NoPackagesView, 'chatwerk/views/no_packages_view'
    autoload :NoViolationsView, 'chatwerk/views/no_violations_view'
    autoload :PackageView, 'chatwerk/views/package_view'
    autoload :PackagesView, 'chatwerk/views/packages_view'
    autoload :ViolationsDetailsView, 'chatwerk/views/violations_details_view'
    autoload :ViolationsListView, 'chatwerk/views/violations_list_view'
  end
end
