
# Module#prepend is not available in JRuby 1.9

# load classes
Puppet::Type.type(:firewallchain)

# Patch upstream method
class Puppet::Type::Firewallchain
  old_generate = instance_method(:generate)
  
  define_method(:generate) do
    if purge?
      rules_resources = old_generate.bind(self).()
      # Remove rules which match created g_firewall_protect types
      # and make them ensure=present again
      catalog.resources.select { |r| r.is_a?(Puppet::Type.type(:g_firewall_protect)) && r[:chain] == self[:name] }.each do |ignored_resource|
        rules_resources.delete_if do |res|
          v = ignored_resource[:regex].find_index { |f| res.provider.properties[:line].match(f) }
          if v
            res[:ensure] = :present
          end
          v
        end
      end
      
      rules_resources
    else
      rules_resources = Puppet::Type.type(:firewall).instances
      protection_rules = catalog.resources.select { |r| r.is_a?(Puppet::Type.type(:g_firewall_protect)) && r[:chain] == self[:name] }
      if !protection_rules.empty?
        protection_rules.each do |ignored_resource|
          # select only rules fetched from system
          rules_resources.delete_if do |res|
            ignored_resource[:regex].find_index { |f| res.provider.properties[:line].match(f) } === nil
          end
        end
        rules_resources.each do |r|
          res = catalog.resource('Firewall', r[:name])
          r.provider.properties.each do |k,v|
            res[k.to_s] = v
          end
          res[:ensure] = :present
        end
      else
        []
      end
    end
  end
end
