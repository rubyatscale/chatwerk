# frozen_string_literal: true

RSpec.describe Chatwerk::Error do
  context 'with a Chatwerk::Error' do
    it 'renders the error message' do
      error = instance_double('Error',
                              to_s: 'Custom error message',
                              backtrace: %w[line1 line2])

      expect(described_class.new(error).message).to eq(<<~OUTPUT)
        There was a problem accessing package information
        Error: Custom error message

        * Please ensure that the package path is correct.
        * Check that there is a package.yml file in the given directory.
        * Check that the path is a project root relative path that doesn't start with a slash.
        * Try calling the packages tool with the package_path to see if it is valid.
      OUTPUT
    end
  end

  context 'with a standard error and package_path' do
    it 'renders an error about package path access' do
      error = instance_double('StandardError',
                              to_s: 'Standard error message',
                              backtrace: %w[line1 line2])

      expect(described_class.new(error, package_path: 'app/packages/some_package').message).to eq(<<~OUTPUT)
        There was a problem finding or accessing "app/packages/some_package"
        Error: Standard error message

        * Please ensure that the package path is correct.
        * Check that there is a package.yml file in the given directory.
        * Check that the path is a project root relative path that doesn't start with a slash.
        * Try calling the packages tool with the package_path to see if it is valid.
      OUTPUT
    end
  end

  context 'with a standard error and no package_path' do
    it 'renders a generic error message' do
      error = instance_double('StandardError',
                              to_s: 'Standard error message',
                              backtrace: %w[line1 line2])

      expect(described_class.new(error).message).to eq(<<~OUTPUT)
        There was a problem accessing package information
        Error: Standard error message

        * Please ensure that the package path is correct.
        * Check that there is a package.yml file in the given directory.
        * Check that the path is a project root relative path that doesn't start with a slash.
        * Try calling the packages tool with the package_path to see if it is valid.
      OUTPUT
    end
  end
end
