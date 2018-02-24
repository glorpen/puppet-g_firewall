require 'spec_helper'

describe 'g_firewall_syschain' do
  context 'with system chain marked as absent' do
    it 'chain should be ensured to be present' do
      res = Puppet::Type.type(:firewallchain).new(name: 'EXAMPLE:filter:IPv4', ensure: 'absent')
      allow(Puppet::Type.type(:firewallchain)).to receive(:instances).and_return([res])
      r1 = Puppet::Type.type(:g_firewall_syschain).new(name: 'default', regex: '^EXAMPLE$')

      catalog = Puppet::Resource::Catalog.new
      catalog.add_resource res
      catalog.add_resource r1

      r1.generate

      expect(res['ensure']).to be :present
    end
  end
end
