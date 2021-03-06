# This is a workaround for bug: #4248 whereby ruby files outside of the normal
# provider/type path do not load until pluginsync has occured on the puppetmaster
#
# In this case I'm trying the relative path first, then falling back to normal
# mechanisms. This should be fixed in future versions of puppet but it looks
# like we'll need to maintain this for some time perhaps.
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', '..'))

require 'puppet/util/g_firewall_overrides'

Puppet::Type.newtype(:g_firewall_protect) do
  @doc = <<-EOS
    This type provides the capability to manage purging rules in firewall chains.
  EOS

  newparam(:name) do
    desc <<-EOS
      The name of ignore filter.
    EOS
    isnamevar
  end

  newparam(:chain) do
    desc <<-EOS
      The canonical name of the chain.

      For iptables the format must be {chain}:{table}:{protocol}.
    EOS
  end

  newparam(:regex) do
    desc <<-EOS
      Regex to perform on firewall rules to exempt existing rules from purging.
      This is matched against the output of `iptables-save`.

      This can be a single regex, or an array of them.
      For more explanation see `firewallchain`.

      Full example:
      g_firewall_protect { 'my ignore rules':
        chain => 'INPUT:filter:IPv4',
        regex => [
          '-j fail2ban-ssh', # ignore the fail2ban jump rule
          '--comment "[^"]*(?i:ignore)[^"]*"', # ignore any rules with "ignore" (case insensitive) in the comment in the rule
        ],
      }
    EOS

    validate do |value|
      unless value.is_a?(Array) || value.is_a?(String) || value == false
        devfail 'Regex must be a string or an Array'
      end
    end
    munge do |patterns| # convert into an array of {Regex}es
      patterns = [patterns] if patterns.is_a?(String)
      patterns.map { |p| Regexp.new(p) }
    end
  end

  autorequire(:firewallchain) do
    res = catalog.resource('Firewallchain', self[:chain])
    unless res
      warning "Target Firewallchain with name of #{self[:chain]} not found in the catalog"
    end
    [res]
  end
end
