# frozen_string_literal: true

module Chatwerk
  module Views
    class PackageView < BaseView
      def template(package:, package_path: nil)
        consumers = QueryPackwerk::Packages.all.to_a.select { |p| p.dependency_names.include?(package.name) }.map(&:name)
        consumers += package.consumer_names
        consumers.uniq.sort!

        say YAML.dump({
          name: package.name,
          enforce_dependencies: package.enforce_dependencies,
          enforce_privacy: package.enforce_privacy,
          owner: package.owner,
          metadata: package.metadata,
          dependencies: package.dependency_names,
          consumers:,
          todos_count: package.todos.count,
          violations_count: package.violations.count
        }.transform_keys(&:to_s))
      end
    end
  end
end
