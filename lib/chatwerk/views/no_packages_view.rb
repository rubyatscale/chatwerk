# frozen_string_literal: true

module Chatwerk
  module Views
    class NoPackagesView < BaseView
      def template(has_packwerk_yml: false)
        if has_packwerk_yml
          <<~MESSAGE
            0 packages found.
            `packwerk.yml` file exists in project root: #{Chatwerk::Helpers.pwd}

            * Check that the project root is correct.
            * Make sure that packwerk is initialized correctly.
            * Make sure at least one package is defined.
          MESSAGE
        else
          <<~MESSAGE
            This project does not appear to be using packwerk.
            `packwerk.yml` file does not exist in project root: #{Chatwerk::Helpers.pwd}

            * Check that the project root is correct.
            * Check to make sure that packwerk is installed and initialized correctly.
          MESSAGE
        end
      end
    end
  end
end
