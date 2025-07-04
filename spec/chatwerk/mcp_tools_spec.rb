# typed: false
# frozen_string_literal: true

require 'spec_helper'
require 'chatwerk/mcp'

RSpec.describe 'MCP Tools' do
  let(:server_context) { double('server_context') }

  describe Chatwerk::PrintEnvTool do
    it 'responds with environment information' do
      response = described_class.call(server_context: server_context)

      expect(response).to be_a(MCP::Tool::Response)
      expect(response.content).to be_an(Array)
      expect(response.content.first[:type]).to eq('text')
      expect(response.content.first[:text]).to include('Current Directory:')
      expect(response.content.first[:text]).to include('Environment:')
    end

    it 'has correct description' do
      expect(described_class.description).to include('current working directory')
    end

    it 'has no required arguments' do
      schema = described_class.input_schema
      expect(schema.required).to be_empty
    end
  end

  describe Chatwerk::PackagesTool do
    it 'responds with package list when no package_path provided' do
      allow(Chatwerk::API).to receive(:packages).with(package_path: nil).and_return('package list')

      response = described_class.call(server_context: server_context)

      expect(response).to be_a(MCP::Tool::Response)
      expect(response.content.first[:text]).to eq('package list')
    end

    it 'responds with filtered packages when package_path provided' do
      allow(Chatwerk::API).to receive(:packages).with(package_path: 'packs/payments').and_return('filtered packages')

      response = described_class.call(package_path: 'packs/payments', server_context: server_context)

      expect(response.content.first[:text]).to eq('filtered packages')
    end

    it 'has correct description' do
      expect(described_class.description).to include('List all valid packwerk packages')
    end

    it 'has package_path as optional argument' do
      schema = described_class.input_schema
      expect(schema.properties).to have_key(:package_path)
      expect(schema.required).not_to include(:package_path)
    end
  end

  describe Chatwerk::PackageTool do
    it 'responds with package details' do
      allow(Chatwerk::API).to receive(:package).with(package_path: 'packs/payments').and_return('package details')

      response = described_class.call(package_path: 'packs/payments', server_context: server_context)

      expect(response).to be_a(MCP::Tool::Response)
      expect(response.content.first[:text]).to eq('package details')
    end

    it 'has correct description' do
      expect(described_class.description).to include('Show the details for a specific package')
    end

    it 'has package_path as required argument' do
      schema = described_class.input_schema
      expect(schema.properties).to have_key(:package_path)
      expect(schema.required).to include(:package_path)
    end
  end

  describe Chatwerk::PackageTodosTool do
    it 'responds with todos list when no constant_name provided' do
      allow(Chatwerk::API).to receive(:package_todos)
        .with(package_path: 'packs/payments', constant_name: nil)
        .and_return('todos list')

      response = described_class.call(package_path: 'packs/payments', server_context: server_context)

      expect(response).to be_a(MCP::Tool::Response)
      expect(response.content.first[:text]).to eq('todos list')
    end

    it 'responds with detailed todos when constant_name provided' do
      allow(Chatwerk::API).to receive(:package_todos)
        .with(package_path: 'packs/payments', constant_name: '::OtherPackage::SomeClass')
        .and_return('detailed todos')

      response = described_class.call(
        package_path: 'packs/payments',
        constant_name: '::OtherPackage::SomeClass',
        server_context: server_context
      )

      expect(response.content.first[:text]).to eq('detailed todos')
    end

    it 'has correct description' do
      expect(described_class.description).to include('Find code that violates dependency boundaries FROM this package')
    end

    it 'has correct argument requirements' do
      schema = described_class.input_schema
      expect(schema.properties).to have_key(:package_path)
      expect(schema.properties).to have_key(:constant_name)
      expect(schema.required).to include(:package_path)
      expect(schema.required).not_to include(:constant_name)
    end
  end

  describe Chatwerk::PackageViolationsTool do
    it 'responds with violations list when no constant_name provided' do
      allow(Chatwerk::API).to receive(:package_violations)
        .with(package_path: 'packs/payments', constant_name: nil)
        .and_return('violations list')

      response = described_class.call(package_path: 'packs/payments', server_context: server_context)

      expect(response).to be_a(MCP::Tool::Response)
      expect(response.content.first[:text]).to eq('violations list')
    end

    it 'responds with detailed violations when constant_name provided' do
      allow(Chatwerk::API).to receive(:package_violations)
        .with(package_path: 'packs/payments', constant_name: '::ThisPackage::SomeClass')
        .and_return('detailed violations')

      response = described_class.call(
        package_path: 'packs/payments',
        constant_name: '::ThisPackage::SomeClass',
        server_context: server_context
      )

      expect(response.content.first[:text]).to eq('detailed violations')
    end

    it 'has correct description' do
      expect(described_class.description).to include('Find code that violates dependency boundaries TO this package')
    end

    it 'has correct argument requirements' do
      schema = described_class.input_schema
      expect(schema.properties).to have_key(:package_path)
      expect(schema.properties).to have_key(:constant_name)
      expect(schema.required).to include(:package_path)
      expect(schema.required).not_to include(:constant_name)
    end
  end
end
