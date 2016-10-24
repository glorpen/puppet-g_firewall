# This is a workaround for bug: #4248 whereby ruby files outside of the normal
# provider/type path do not load until pluginsync has occured on the puppetmaster
#
# In this case I'm trying the relative path first, then falling back to normal
# mechanisms. This should be fixed in future versions of puppet but it looks
# like we'll need to maintain this for some time perhaps.
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__),"..",".."))

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
      unless value.is_a?(Array) or value.is_a?(String) or value == false
        self.devfail "Regex must be a string or an Array"
      end
    end
    munge do |patterns| # convert into an array of {Regex}es
      patterns = [patterns] if patterns.is_a?(String)
      patterns.map{|p| Regexp.new(p)}
    end
  end
  
  def protected_instances
    value(:chain).match(Nameformat)
    chain = $1
    table = $2
    protocol = $3
    
    provider = case protocol
       when 'IPv4'
         :iptables
       when 'IPv6'
         :ip6tables
       end
    
    catalog.resources.select {|res| res.class == Puppet::Type::Firewall}.select{|res|
      # has to be read from system, not freshly created by puppet
      # has to have matching provider, table and chain name
      # has to have matching code
      res.provider.properties[:line] \
      and res[:provider] == provider and res.provider.properties[:table].to_s == table and res.provider.properties[:chain] == chain \
      and value(:regex).find_index{|f| res.provider.properties[:line].match(f)}
    }
  end
  
  autorequire(name) do
    self.protected_instances
  end
  
  def generate
    self.protected_instances.each {|r|
      r[:ensure] = :present
    }
  end
  
end