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
  
  def system_chains
    catalog.resources.select {|res| res.class == Puppet::Type::Firewallchain}.select{|res|
      
      res.provider.properties[:name].match(Nameformat)
          chain = $1
          table = $2
          protocol = $3
          
      value(:regex) =~ chain
    }
  end
  
  autorequire(name) do
    self.system_chains
  end
  
  def generate
    self.system_chains.each {|r|
      r[:ensure] = :present
    }
  end
  
end
