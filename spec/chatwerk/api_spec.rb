# typed: false
# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Chatwerk::API do
  let(:pwd) { '/test/workspace' }
  let(:package_path) { 'packs/test_package' }
  let(:constant_name) { '::TestPackage::TestClass' }
  let(:package) { instance_double('Packwerk::Package', name: 'packs/test_package') }
  let(:violations) { instance_double('QueryPackwerk::Violations') }
  let(:anonymous_sources_with_locations) { { '::TestPackage::TestClass' => { 'example usage' => ['app/models/test.rb:1'] } } }

  before do
    allow(Chatwerk::Helpers).to receive(:chdir)
  end

  describe '.packages' do
    context 'when packages exist' do
      before do
        allow(File).to receive(:exist?).with('packwerk.yml').and_return(true)
        allow(Chatwerk::Helpers).to receive(:all_packages).and_return([package])
      end

      it 'returns the packages view' do
        expect(described_class.packages).to eq("packs/test_package\n")
      end

      it 'accepts an optional package path filter' do
        expect(Chatwerk::Helpers).to receive(:all_packages).with(package_path).and_return([package])
        described_class.packages(package_path: package_path)
      end
    end

    context 'when no packages exist' do
      before do
        allow(File).to receive(:exist?).with('packwerk.yml').and_return(true)
        allow(Chatwerk::Helpers).to receive(:all_packages).and_return([])
        allow(Chatwerk::Helpers).to receive(:pwd).and_return('/test/workspace')
      end

      it 'returns the no packages view' do
        expect(described_class.packages).to eq(<<~STRING)
          0 packages found.
          `packwerk.yml` file exists in project root: /test/workspace

          * Check that the project root is correct.
          * Make sure that packwerk is initialized correctly.
          * Make sure at least one package is defined.
        STRING
      end
    end

    context 'when an error occurs' do
      before do
        allow(Chatwerk::Helpers).to receive(:all_packages).and_raise(StandardError.new('test error'))
      end

      it 'returns the error view' do
        expect { described_class.packages }.to raise_error(Chatwerk::Error)
      end
    end
  end

  describe '.package' do
    before do
      allow(Chatwerk::Helpers).to receive(:all_packages).and_return([package])
      # this view is tested well in the views/package_view_spec.rb and it's complicated to render
      allow(Chatwerk::Views::PackageView).to receive(:render).with(package:).and_return('package view')
    end

    it 'returns the package view' do
      expect(described_class.package(package_path: package_path)).to eq('package view')
    end

    context 'when an error occurs' do
      before do
        allow(Chatwerk::Helpers).to receive(:all_packages).and_raise(StandardError.new('test error'))
      end

      it 'returns the error view' do
        expect { described_class.package(package_path: package_path) }.to raise_error(Chatwerk::Error)
      end
    end
  end

  describe '.package_todos' do
    let(:expected_output) { 'test output' }

    before do
      allow(Chatwerk::Helpers).to receive(:all_packages).and_return([package])
      allow(package).to receive(:todos).and_return(violations)
      allow(violations).to receive(:anonymous_sources_with_locations).and_return(anonymous_sources_with_locations)
    end

    context 'without constant name' do
      let(:constant_name) { '' }

      it 'returns the violations list view' do
        expect(described_class.package_todos(package_path: package_path)).to eq(<<~STRING)
          app/models/test.rb
          1:   example usage
        STRING
      end
    end

    context 'with constant name' do
      it 'returns the violations details view' do
        expect(described_class.package_todos(package_path: package_path, constant_name: constant_name)).to eq(<<~STRING)
          app/models/test.rb
          1:   example usage
        STRING
      end

      context 'when no violations found' do
        let(:anonymous_sources_with_locations) { {} }

        it 'returns the no violations view' do
          expect(described_class.package_todos(package_path: package_path, constant_name: constant_name).strip).to eq(<<~STRING.strip)
            No violations found in "packs/test_package" for "::TestPackage::TestClass".
            Ensure that constant_name is given in the format of "::ConstantName" or "::ConstantName::NestedConstant".
          STRING
        end
      end
    end

    context 'when an error occurs' do
      before do
        allow(Chatwerk::Helpers).to receive(:all_packages).and_raise(StandardError.new('test error'))
      end

      it 'returns the error view' do
        expect { described_class.package_todos(package_path: package_path) }.to raise_error(Chatwerk::Error)
      end
    end
  end

  describe '.package_violations' do
    let(:expected_output) { 'test output' }

    before do
      allow(Chatwerk::Helpers).to receive(:all_packages).and_return([package])
      allow(package).to receive(:violations).and_return(violations)
      allow(violations).to receive(:anonymous_sources_with_locations).and_return(anonymous_sources_with_locations)
    end

    context 'without constant name' do
      let(:constant_name) { '' }

      it 'returns the violations list view' do
        expect(described_class.package_violations(package_path: package_path)).to eq(<<~STRING)
          app/models/test.rb
          1:   example usage
        STRING
      end
    end

    context 'with constant name' do
      it 'returns the violations details view' do
        expect(described_class.package_violations(package_path: package_path, constant_name: constant_name)).to eq(<<~STRING)
          app/models/test.rb
          1:   example usage
        STRING
      end

      context 'when no violations found' do
        let(:anonymous_sources_with_locations) { {} }

        it 'returns the no violations view' do
          expect(described_class.package_violations(package_path: package_path, constant_name: constant_name)).to eq(<<~STRING)
            No violations found in "packs/test_package" for "::TestPackage::TestClass".
            Ensure that constant_name is given in the format of "::ConstantName" or "::ConstantName::NestedConstant".
          STRING
        end
      end
    end

    context 'when an error occurs' do
      before do
        allow(Chatwerk::Helpers).to receive(:all_packages).and_raise(StandardError.new('test error'))
      end

      it 'returns the error view' do
        expect { described_class.package_violations(package_path: package_path) }.to raise_error(Chatwerk::Error)
      end
    end
  end
end
