module Chatwerk
  module Helpers
    def chdir(&)
      Dir.chdir(env_pwd, &)
    end
    module_function :chdir

    def env_pwd
      path = ENV.fetch('PWD', pwd)
      # Use realpath if the path exists, otherwise fall back to expand_path
      File.directory?(path) ? File.realpath(path) : File.expand_path(path)
    end
    module_function :env_pwd

    def pwd
      File.realpath(Dir.pwd)
    end
    module_function :pwd

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
      return '' if constant_name.empty?

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

      if packages.empty?
        raise "Unable to find a package for #{path_pattern.inspect}."
      elsif packages.size == 1
        packages.first
      else
        # Return an exact match even if it's a subset of another match
        # e.g. packs/payments and packs/payments_api
        exact_match = packages.find { |package| package.name == path_pattern }
        return exact_match if exact_match

        raise Chatwerk::Error, <<~ERROR
          Found multiple packages for #{path_pattern.inspect}:

          #{packages.map(&:name).join("\n")}

          Please use full path to specify the correct package.
        ERROR
      end
    end
    module_function :find_package
  end
end
