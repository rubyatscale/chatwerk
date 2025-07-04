# frozen_string_literal: true

module Chatwerk
  module Views
    class BaseView
      def self.render(**data)
        new(**data).render
      end

      attr_reader :data, :output

      def initialize(**data)
        @data = data
        @output = nil
      end

      def render
        @output = nil
        temp = template(**data)
        return temp if @output.nil? # allow templates to return a string instead

        @output
      end

      private

      def template(**data)
        raise NotImplementedError, 'Subclasses must implement the #template method'
      end

      def say(message = '')
        @output ||= +''
        @output << message << "\n"
      end

      def method_missing(name, *args, **kwargs, &block)
        @data[name]
      end

      def respond_to_missing?(name, include_private = false)
        data.key?(name) || super
      end

      def format_count(count, singular, plural = nil)
        if count == 1
          "1 #{singular}"
        else
          plural ||= "#{singular}s"
          "#{count} #{plural}"
        end
      end
    end
  end
end
