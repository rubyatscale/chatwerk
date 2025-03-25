module Chatwerk
  module Helpers
    def normalize_package_path(package_path)
      package_path = package_path.to_s.strip
      package_path = package_path.delete_prefix('/')
      package_path = package_path.delete_suffix('/package.yml')
      package_path = package_path.delete_suffix('/package_todo.yml')
      package_path.delete_suffix('/')
    end
    module_function :normalize_package_path

    def normalize_constant_name(constant_name)
      constant_name = constant_name.to_s.strip
      constant_name.sub(/^(::)?/, '::')
    end
    module_function :normalize_constant_name

    def all_packages(path_pattern = '')
      path_pattern = normalize_package_path(path_pattern)
      if path_pattern.empty?
        QueryPackwerk::Packages.all.to_a
      else
        QueryPackwerk::Packages.where(name: Regexp.new(Regexp.escape(path_pattern))).to_a
      end
    end
    module_function :all_packages

    def find_package(path_pattern)
      packages = all_packages(path_pattern)
      case packages.size
      when 0
        raise "Unable to find a package for #{path_pattern.inspect}."
      when 1
        packages.first
      else
        raise Chatwerk::Error, <<~ERROR
          Found multiple packages for #{path_pattern.inspect}. Please be more specific.
          #{packages.map(&:name).join("\n")}
        ERROR
      end
    end
    module_function :find_package
  end
end
