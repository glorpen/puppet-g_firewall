require 'spec_helper'

describe 'g_firewall_protect' do
  before :each do
    # rubocop:disable Layout/IndentHeredoc
    stub_return = <<PUPPETCODE
# Completed on Sun Jan  5 19:30:21 2014
# Generated by iptables-save v1.4.12 on Sun Jan  5 19:30:21 2014
*filter
:INPUT DROP [0:0]
:FORWARD DROP [0:0]
:OUTPUT ACCEPT [0:0]
:EXAMPLE - [0:0]
-A EXAMPLE -j RETURN -p all -m comment --comment "999 ex_rule1"
-A EXAMPLE -j RETURN -p all -m comment --comment "998 ex_rule2"
COMMIT
# Completed on Sun Jan  5 19:30:21 2014
PUPPETCODE
    allow(Puppet::Type.type(:firewall).provider(:iptables)).to receive(:iptables_save).and_return(stub_return)
    allow(Puppet::Type.type(:firewall).provider(:ip6tables)).to receive(:ip6tables_save).and_return(stub_return)
  end

  context 'with purgeable firewallchain' do
    it 'rule should be protected' do
      chain0 = Puppet::Type.type(:firewallchain).new(name: 'EXAMPLE:filter:IPv4', ensure: 'absent', purge: true)
      protect0 = Puppet::Type.type(:g_firewall_protect).new(name: 'test', regex: 'ex_rule1', chain: 'EXAMPLE:filter:IPv4')

      allow(Puppet::Type.type(:firewallchain)).to receive(:instances).and_return([chain0])

      catalog = Puppet::Resource::Catalog.new
      catalog.add_resource chain0
      catalog.add_resource protect0

      ret = chain0.generate

      expect(ret.select { |x| x[:name] == '998 ex_rule2' && x[:ensure] == :absent }.empty?).to eq(false)
      expect(ret.select { |x| x[:name] == '999 ex_rule1' }.empty?).to eq(true)
    end
  end
  context 'without firewallchain purging' do
    it 'protected rules should be overriden' do
      chain0 = Puppet::Type.type(:firewallchain).new(name: 'EXAMPLE:filter:IPv4', ensure: 'absent', purge: false)
      protect0 = Puppet::Type.type(:g_firewall_protect).new(name: 'test', regex: 'ex_rule1', chain: 'EXAMPLE:filter:IPv4')

      allow(Puppet::Type.type(:firewallchain)).to receive(:instances).and_return([chain0])

      catalog = Puppet::Resource::Catalog.new
      catalog.add_resource chain0
      catalog.add_resource protect0

      Puppet::Type.type(:firewall).instances.each { |x| catalog.add_resource x }

      ret = chain0.generate

      expect(ret.size).to eq(2)

      # puppet defaults to "tcp" proto, so check if it was properly overriden
      ret.each do |x|
        r = catalog.resources.select { |cr| cr[:name] == x[:name] }
        expect(r[0][:proto]).to eq(:all)
      end
    end
  end
end
