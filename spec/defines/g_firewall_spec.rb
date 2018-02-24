require 'spec_helper'

describe 'g_firewall' do
  let(:title) { '200 example' }

  context 'with auto rules for detected iptables' do
    let(:facts) { { 'iptables_version' => '1' } }

    it { is_expected.to contain_firewall('200.IPv4 example') }
    it { is_expected.not_to contain_firewall('200.IPv6 example') }
  end
  context 'with auto rules for detected ip6tables' do
    let(:facts) { { 'ip6tables_version' => '1' } }

    it { is_expected.to contain_firewall('200.IPv6 example') }
    it { is_expected.not_to contain_firewall('200.IPv4 example') }
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

  context 'with unsupported ip protocol' do
    let(:facts) do
      {
        'iptables_version' => '1',
      }
    end
    let :params do
      {
        'protocol' => ['IPv6'],
      }
    end

    it { is_expected.to compile.and_raise_error(%r{Protocols \[IPv6\] are not enabled}) }
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
end
