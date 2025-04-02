# typed: strict
# frozen_string_literal: true

require 'yaml'
require_relative 'views'

module Chatwerk
  module API
    class << self
      def packages(package_path: nil)
        packages = Helpers.all_packages(package_path)

        if packages.empty?
          has_packwerk_yml = File.exist?('packwerk.yml')
          Views::NoPackagesView.render(has_packwerk_yml:)
        else
          Views::PackagesView.render(packages:)
        end
      rescue StandardError => e
        raise Chatwerk::Error.new(e, package_path:)
      end

      def package(package_path:)
        package = Helpers.find_package(package_path)

        Views::PackageView.render(package:)
      rescue StandardError => e
        raise Chatwerk::Error.new(e, package_path:)
      end

      def package_todos(package_path:, constant_name: nil)
        package = Helpers.find_package(package_path)
        constant_name = Helpers.normalize_constant_name(constant_name)
        violations = package.todos

        if constant_name.empty?
          Views::ViolationsListView.render(package:, violations:)
        else
          Views::ViolationsDetailsView.render(package:, violations:, constant_name:)
        end
      rescue StandardError => e
        raise Chatwerk::Error.new(e, package_path:, constant_name:)
      end

      def package_violations(package_path:, constant_name: nil)
        package = Helpers.find_package(package_path)
        constant_name = Helpers.normalize_constant_name(constant_name)
        violations = package.violations

        if constant_name.empty?
          Views::ViolationsListView.render(package:, violations:)
        else
          Views::ViolationsDetailsView.render(package:, violations:, constant_name:)
        end
      rescue StandardError => e
        raise Chatwerk::Error.new(e, package_path:, constant_name:)
      end
    end
  end
end
