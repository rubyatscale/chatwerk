# frozen_string_literal: true

RSpec.describe Chatwerk::Helpers do
  describe '.chdir' do
    it 'changes directory temporarily and executes the block' do
      original_dir = Dir.pwd
      File.expand_path('..', original_dir)

      described_class.chdir do
        expect(Dir.pwd).to eq(described_class.env_pwd)
      end

      expect(Dir.pwd).to eq(original_dir)
    end
  end

  describe '.env_pwd' do
    it 'returns ENV["PWD"] when set' do
      allow(ENV).to receive(:fetch).with('PWD', anything).and_return('/custom/path')
      expect(described_class.env_pwd).to eq('/custom/path')
    end

    it 'falls back to pwd when ENV["PWD"] is not set' do
      allow(ENV).to receive(:fetch).with('PWD', anything).and_call_original
      expect(described_class.env_pwd).to eq(described_class.pwd)
    end
  end

  describe '.normalize_package_path' do
    it 'normalizes package paths correctly' do
      examples = {
        '/path/to/package/' => 'path/to/package',
        'path/to/package/package.yml' => 'path/to/package',
        'path/to/package/package_todo.yml' => 'path/to/package',
        '  path/to/package  ' => 'path/to/package',
        nil => ''
      }

      examples.each do |input, expected|
        expect(described_class.normalize_package_path(input)).to eq(expected)
      end
    end
  end

  describe '.normalize_constant_name' do
    it 'normalizes constant names correctly' do
      examples = {
        'MyConstant' => '::MyConstant',
        '::MyConstant' => '::MyConstant',
        '  MyConstant  ' => '::MyConstant',
        nil => ''
      }

      examples.each do |input, expected|
        expect(described_class.normalize_constant_name(input)).to eq(expected)
      end
    end
  end

  describe '.all_packages' do
    let(:package1) { instance_double('QueryPackwerk::Package', name: 'package1') }
    let(:package2) { instance_double('QueryPackwerk::Package', name: 'package2') }
    let(:all_packages) { [package1, package2] }

    before do
      allow(QueryPackwerk::Packages).to receive(:all).and_return(all_packages)
      allow(QueryPackwerk::Packages).to receive(:where).and_return([package1])
    end

    it 'returns all packages when no pattern is given' do
      expect(described_class.all_packages).to eq(all_packages)
    end

    it 'returns filtered packages when pattern is given' do
      expect(described_class.all_packages('package1')).to eq([package1])
    end
  end

  describe '.find_package' do
    let(:package) { instance_double('QueryPackwerk::Package', name: 'test_package') }

    context 'when one package is found' do
      before do
        allow(described_class).to receive(:all_packages).with('test_package').and_return([package])
      end

      it 'returns the package' do
        expect(described_class.find_package('test_package')).to eq(package)
      end
    end

    context 'when no packages are found' do
      before do
        allow(described_class).to receive(:all_packages).with('nonexistent').and_return([])
      end

      it 'raises an error' do
        expect do
          described_class.find_package('nonexistent')
        end.to raise_error(/Unable to find a package/)
      end
    end

    context 'when multiple packages are found' do
      let(:package2) { instance_double('QueryPackwerk::Package', name: 'test_package2') }

      before do
        allow(described_class).to receive(:all_packages).with('test').and_return([package, package2])
      end

      it 'raises an error' do
        expect do
          described_class.find_package('test')
        end.to raise_error(Chatwerk::Error, /Found multiple packages/)
      end
    end
  end
end
