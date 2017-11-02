# This is a workaround for bug: #4248 whereby ruby files outside of the normal
# provider/type path do not load until pluginsync has occured on the puppetmaster
#
# In this case I'm trying the relative path first, then falling back to normal
# mechanisms. This should be fixed in future versions of puppet but it looks
# like we'll need to maintain this for some time perhaps.
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__),"..",".."))

Puppet::Type.newtype(:g_firewall_syschain) do
  @doc = <<-EOS
    This type allows to disable purging of built-in chains.
  EOS
  
  newparam(:name) do
    desc <<-EOS
      The name of chain.
    EOS
    isnamevar
  end
  
  newparam(:regex) do
    desc <<-EOS
      Regex to find internal chains.
    EOS
    munge do |pattern| # convert into an array of {Regex}es
      Regexp.new(pattern)
    end
  end
  
  autorequire(:firewallchain) do
    catalog.resources.collect do |r|
      if r.is_a?(Puppet::Type.type(:firewallchain))
        r[:name].match(Nameformat)
            chain = $1
            table = $2
            protocol = $3
        if chain == self[:name]
          r.name
        end
      end
    end.compact
  end
  
  def generate
    chain_resources = Puppet::Type.type(:firewallchain).instances
    
    chain_resources.delete_if {|res|
      res.provider.properties[:name].match(Nameformat)
          chain = $1
          table = $2
          protocol = $3
          
      value(:regex) !~ chain
    }
    
    chain_resources.each {|res|
      res[:ensure] = :present
    }
    
    # override catalog
    catalog.resources.select {|res|
      res.class == Puppet::Type::Firewallchain
    }.select{ |res|
      not chain_resources.select {|r|
        res[:name] == r[:name]
      }.empty?
    }.each {|res|
      res[:ensure] = :present
    }
    
    chain_resources
  end
end
