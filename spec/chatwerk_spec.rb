# frozen_string_literal: true

RSpec.describe Chatwerk do
  it 'has a version number' do
    expect(Chatwerk::VERSION).not_to be nil
  end

  describe Chatwerk::Mcp do
    it 'is defined' do
      expect(Chatwerk::Mcp.name).to eq('chatwerk')
    end
  end
end
