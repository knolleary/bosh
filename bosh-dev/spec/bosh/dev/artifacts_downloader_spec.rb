require 'logger'
require 'spec_helper'
require 'bosh/dev/build'
require 'bosh/dev/download_adapter'
require 'bosh/dev/artifacts_downloader'

module Bosh::Dev
  describe ArtifactsDownloader do
    subject(:artifacts_downloader) { ArtifactsDownloader.new(download_adapter, logger) }
    let(:download_adapter) { DownloadAdapter.new(logger) }
    let(:logger) { Logger.new('/dev/null') }

    describe '#download_release' do
      it 'downloads a release and returns path' do
        download_adapter
          .should_receive(:download)
          .with('http://s3.amazonaws.com/bosh-jenkins-artifacts/release/bosh-123.tgz', 'bosh-123.tgz')
          .and_return(File.join(Dir.pwd, 'where-it-was-written-to'))
        expect(artifacts_downloader.download_release('123')).to eq File.join(Dir.pwd, 'where-it-was-written-to')
      end
    end

    describe '#download_stemcell' do
      let(:infrastructure) do
        instance_double(
          'Bosh::Stemcell::Infrastructure',
          name: 'fake-infrastructure-name',
          hypervisor: 'fake-infrastructure-hypervisor',
        )
      end

      let(:operating_system) do
        instance_double(
          'Bosh::Stemcell::OperatingSystem',
          name: 'fake-os-name',
        )
      end

      it 'downloads a stemcell and returns path' do
        expected_name = [
          'light',
          'bosh-stemcell',
          'fake-number',
          'fake-infrastructure-name',
          'fake-infrastructure-hypervisor',
          'fake-os-name.tgz',
        ].join('-')

        expected_remote_path = [
          'http://s3.amazonaws.com',
          'bosh-jenkins-artifacts',
          'bosh-stemcell',
          'fake-infrastructure-name',
          expected_name,
        ].join('/')

        expected_local_path = "fake-output-dir/#{expected_name}"

        download_adapter
          .should_receive(:download)
          .with(expected_remote_path, expected_local_path)
          .and_return('returned-path')

        returned_path = artifacts_downloader.download_stemcell(
          'fake-number', infrastructure, operating_system, true, 'fake-output-dir')

        expect(returned_path).to eq('returned-path')
      end
    end
  end
end
