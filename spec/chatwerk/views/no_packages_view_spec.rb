# frozen_string_literal: true

RSpec.describe Chatwerk::Views::NoPackagesView do
  context 'when packwerk.yml exists' do
    it 'renders a message indicating 0 packages found' do
      expect(described_class.render(has_packwerk_yml: true)).to eq(<<~MESSAGE)
        0 packages found.
        `packwerk.yml` file exists in project root: #{Chatwerk::Helpers.pwd}

        * Check that the project root is correct.
        * Make sure that packwerk is initialized correctly.
        * Make sure at least one package is defined.
      MESSAGE
    end
  end

  context 'when packwerk.yml does not exist' do
    it 'renders a message indicating packwerk is not being used' do
      expect(described_class.render(has_packwerk_yml: false)).to eq(<<~MESSAGE)
        This project does not appear to be using packwerk.
        `packwerk.yml` file does not exist in project root: #{Chatwerk::Helpers.pwd}

        * Check that the project root is correct.
        * Check to make sure that packwerk is installed and initialized correctly.
      MESSAGE
    end
  end
end
