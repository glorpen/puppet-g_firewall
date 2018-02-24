
# Module#prepend is not available in JRuby 1.9

# load classes
Puppet::Type.type(:firewallchain)

# Patch upstream method
class Puppet::Type::Firewallchain
  old_generate = instance_method(:generate)

  define_method(:generate) do
    if purge?
      rules_resources = old_generate.bind(self).call
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
      rules_all = Puppet::Type.type(:firewall).instances
      rules_matched = {}
      protection_rules = catalog.resources.select { |r| r.is_a?(Puppet::Type.type(:g_firewall_protect)) && r[:chain] == self[:name] }
      unless protection_rules.empty?
        protection_rules.each do |ignored_resource|
          # select only rules fetched from system
          rules_all.each do |res|
            next if rules_matched.include?(res[:name])
            unless ignored_resource[:regex].find_index { |f| res.provider.properties[:line].match(f) }.nil?
              rules_matched[res[:name]] = res
            end
          end
        end
        rules_matched.each do |_dummy, r|
          res = catalog.resource('Firewall', r[:name])
          r.provider.properties.each do |k, v|
            res[k.to_s] = v
          end
          res[:ensure] = :present
        end
      end
      rules_matched.values
    end
  end
end
