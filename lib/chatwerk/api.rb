# typed: strict
# frozen_string_literal: true

module Chatwerk
  # The API module provides a structured interface for accessing QueryPackwerk functionality.
  # It's designed to be used by the MCP (Machine Control Protocol) server.
  # All methods are designed to return structured data that can be easily serialized to JSON.
  module API
    extend T::Sig
    extend self # rubocop:disable Style/ModuleFunction

    # Get detailed information about a single package
    sig { params(pack_name: String).returns(T::Hash[String, T.untyped]) }
    def package_info(pack_name)
      pack = QueryPackwerk.package(pack_name)
      { error: "Package '#{pack_name}' not found" } unless pack
    end

    # Get all dependencies of a package, including information about ignored dependencies and violations
    sig { params(pack_name: String).returns(T::Hash[String, T.untyped]) }
    def package_dependencies(pack_name)
      pack = QueryPackwerk.package(pack_name)
      return { error: "Package '#{pack_name}' not found" } unless pack

      violations = QueryPackwerk::Violations.where(consuming_pack: pack.name)
      # Group violations by the package they reference
      violation_by_package = {}
      violations.each do |v|
        package_name = v.to_package_name
        violation_by_package[package_name] ||= []
        violation_by_package[package_name] << v
      end

      # Get declared dependencies
      declared_dependencies = pack.dependency_names.map do |dep_name|
        dep_pack = QueryPackwerk.package(dep_name)
        next { name: dep_name, status: 'unknown' } unless dep_pack

        {
          name: dep_name,
          status: 'declared',
          owner: dep_pack.owner,
          enforce_dependencies: dep_pack.enforce_dependencies,
          enforce_privacy: dep_pack.enforce_privacy
        }
      end

      # Get ignored dependencies from package.yml if available
      ignored_dependencies = []
      if pack.metadata['ignored_dependencies'].is_a?(Array)
        ignored_dependencies = pack.metadata['ignored_dependencies'].map do |dep_name|
          dep_pack = QueryPackwerk.package(dep_name)
          next { name: dep_name, status: 'ignored' } unless dep_pack

          {
            name: dep_name,
            status: 'ignored',
            owner: dep_pack.owner
          }
        end
      end

      # Get violation dependencies (undeclared dependencies)
      violation_dependencies = violation_by_package.keys.reject do |dep|
        pack.dependency_names.include?(dep)
      end.map do |dep_name|
        dep_pack = QueryPackwerk.package(dep_name)
        vcount = violation_by_package[dep_name]&.size || 0

        next { name: dep_name, status: 'violation', violation_count: vcount } unless dep_pack

        {
          name: dep_name,
          status: 'violation',
          owner: dep_pack.owner,
          enforce_dependencies: dep_pack.enforce_dependencies,
          enforce_privacy: dep_pack.enforce_privacy,
          violation_count: vcount
        }
      end

      {
        package: pack.name,
        dependencies: {
          declared: declared_dependencies,
          ignored: ignored_dependencies,
          violations: violation_dependencies
        },
        total_declared: declared_dependencies.size,
        total_ignored: ignored_dependencies.size,
        total_violations: violation_dependencies.size
      }
    end

    # Get all consumers of a package
    sig { params(pack_name: String, threshold: Integer).returns(T::Hash[String, T.untyped]) }
    def package_consumers(pack_name, threshold: 0)
      pack = QueryPackwerk.package(pack_name)
      return { error: "Package '#{pack_name}' not found" } unless pack

      consumer_counts = QueryPackwerk.consumers(pack_name, threshold: threshold)

      consumers = consumer_counts.map do |consumer_name, count|
        consumer_pack = QueryPackwerk.package(consumer_name)
        next { name: consumer_name, count: count } unless consumer_pack

        {
          name: consumer_name,
          owner: consumer_pack.owner,
          count: count,
          is_declared_dependency: consumer_pack.dependency_names.include?(pack_name)
        }
      end

      {
        package: pack_name,
        consumers: consumers,
        total_consumers: consumers.size
      }
    end

    # Get all usage patterns for a package
    sig { params(pack_name: String, threshold: Integer).returns(T::Hash[String, T.untyped]) }
    def package_usage_patterns(pack_name, threshold: 0)
      pack = QueryPackwerk.package(pack_name)
      return { error: "Package '#{pack_name}' not found" } unless pack

      patterns = QueryPackwerk.anonymous_violation_counts_for(pack_name, threshold: threshold)

      result = {
        package: pack_name,
        patterns: {},
        total_patterns: 0
      }

      patterns.each do |pattern_type, pattern_counts|
        result[:patterns][pattern_type] = pattern_counts.map do |pattern, count|
          {
            pattern: pattern,
            count: count
          }
        end.sort_by { |p| -p[:count] }

        result[:total_patterns] += pattern_counts.size
      end

      result
    end

    # Get all code patterns that access a specific package
    sig { params(pack_name: String).returns(T::Hash[String, T.untyped]) }
    def package_access_patterns(pack_name)
      violations = QueryPackwerk::Violations.where(producing_pack: QueryPackwerk.full_name(pack_name))
      return { error: "No access patterns found for package '#{pack_name}'" } if violations.count.zero?

      # Group violations by type and class name
      patterns = {}
      violations.each do |violation|
        type = violation.type
        class_name = violation.class_name
        patterns[type] ||= {}
        patterns[type][class_name] ||= []

        # Get first sample file for example
        next unless violation.sources_with_locations.any?

        patterns[type][class_name] << {
          from_package: violation.consuming_pack.name,
          location: violation.sources_with_locations.first,
          file: violation.sources.first
        }
      end

      # Format the response
      formatted_patterns = {}
      patterns.each do |type, class_patterns|
        formatted_patterns[type] = class_patterns.map do |class_name, examples|
          {
            constant: class_name,
            count: examples.size,
            examples: examples.uniq { |e| e[:from_package] }.first(3) # Limit to 3 examples
          }
        end
      end

      {
        package: pack_name,
        access_patterns: formatted_patterns,
        total_constants: patterns.values.flat_map(&:keys).uniq.size
      }
    end

    # Find all the places in the code where a package is used from other packages
    sig { params(pack_name: String).returns(T::Hash[String, T.untyped]) }
    def find_usage_locations(pack_name)
      violations = QueryPackwerk::Violations.where(producing_pack: QueryPackwerk.full_name(pack_name))
      return { error: "No usage found for package '#{pack_name}'" } if violations.count.zero?

      locations = violations.sources_with_locations

      # Group by consuming package for better organization
      usage_by_consumer = {}
      violations.each do |violation|
        consumer = violation.consuming_pack.name
        usage_by_consumer[consumer] ||= []

        violation.sources_with_locations.each do |loc|
          usage_by_consumer[consumer] << {
            constant: violation.class_name,
            location: loc,
            type: violation.type
          }
        end
      end

      {
        package: pack_name,
        usage_locations: usage_by_consumer,
        total_consumers: usage_by_consumer.keys.size,
        total_locations: locations.values.flatten.size
      }
    end
  end
end
