require 'spec_helper'

describe 'g_firewall' do
  let(:title) { '200 example' }

  context 'with auto rules' do
    let(:facts) { { 'iptables_version' => '1' } }

    it { is_expected.to contain_firewall('200.IPv4 example') }
    it { is_expected.to contain_firewall('200.IPv6 example') }
  end

  context 'with overrided ip protocols' do
    let(:facts) do
      {
        'iptables_version' => '1',
        'ip6tables_version' => '1',
      }
    end
    let :params do
      {
        'protocol' => ['IPv4'],
      }
    end

    it { is_expected.to contain_firewall('200.IPv4 example') }
    it { is_expected.not_to contain_firewall('200.IPv6 example') }
  end

  context 'with unknown ip protocol' do
    let :params do
      {
        'protocol' => ['IPv7'],
      }
    end

    it { is_expected.to compile.and_raise_error(%r{Protocol IPv7 is not known}) }
  end

  [4, '4', 'ip4', 'ipv4'].each do |ip|
    context "with different ip protocol names: #{ip}" do
      let(:facts) do
        {
          'iptables_version' => '1',
        }
      end
      let :params do
        {
          'protocol' => [ip],
        }
      end

      it { is_expected.to contain_firewall('200.IPv4 example') }
    end
  end

  context 'with auto detected IPv4 protocol' do
    let :params do
      {
        'proto_from_ip' => '127.0.0.1/32',
      }
    end

    it { is_expected.to contain_firewall('200.IPv4 example') }
    it { is_expected.not_to contain_firewall('200.IPv6 example') }
  end

  context 'with auto detected IPv6 protocol' do
    let :params do
      {
        'proto_from_ip' => '2004:fe::',
      }
    end

    it { is_expected.not_to contain_firewall('200.IPv4 example') }
    it { is_expected.to contain_firewall('200.IPv6 example') }
  end
end
