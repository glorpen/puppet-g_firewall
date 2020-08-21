
# Module#prepend is not available in JRuby 1.9

# load classes
Puppet::Type.type(:firewallchain)

# Patch upstream method
class Puppet::Type::Firewallchain
  old_generate = instance_method(:generate)

  def nameformat
    if defined? Nameformat
      return Nameformat
    end
    NAME_FORMAT
  end

  def contained_rules
    # from https://github.com/puppetlabs/puppetlabs-firewall/pull/333/files
    if not self.class.class_variable_defined?(:@@firewall_rule_resources)
      self.class.send(:class_variable_set,:@@firewall_rule_resources,Puppet::Type.type(:firewall).instances)
    end
    rules_resources = self.class.send(:class_variable_get,:@@firewall_rule_resources).dup

    value(:name).match(nameformat)
    chain = Regexp.last_match(1)
    table = Regexp.last_match(2)
    protocol = Regexp.last_match(3)

    provider = case protocol
               when 'IPv4'
                 :iptables
               when 'IPv6'
                 :ip6tables
               end

    rules_resources.reject { |res| (res[:provider] != provider || res.provider.properties[:table].to_s != table || res.provider.properties[:chain] != chain) }
  end

  def do_generate_smart
    rules_all = contained_rules

    rules_matched = []

    if self[:purge] == :false && !Puppet::Type.type(:firewallchain).instances.select { |x| x[:name] == self[:name] }.empty?
      # only if this chain is set to purge=false and is managed by puppet
      rules_matched = rules_all
    else
      protection_rules = catalog.resources.select { |r| r.is_a?(Puppet::Type.type(:g_firewall_protect)) && r[:chain] == self[:name] }
      rules_cache = {}
      unless protection_rules.empty?
        protection_rules.each do |ignored_resource|
          # select only rules fetched from system
          rules_all.each do |res|
            next if rules_cache.include?(res[:name])
            unless ignored_resource[:regex].find_index { |f| res.provider.properties[:line].match(f) }.nil?
              rules_cache[res[:name]] = res
            end
          end
        end
      end
      rules_matched = rules_cache.values
    end

    rules_matched.each do |r|
      res = catalog.resource('Firewall', r[:name])
      next if res.nil?
      debug("g_firewall: protecting (smart) #{r[:name]}")
      r.provider.properties.each do |k, v|
        res[k.to_s] = v.is_a?(Puppet::Util::Execution::ProcessOutput) ? v.to_s : v
      end
      res[:ensure] = :present
    end
    rules_matched
  end

  define_method(:generate) do
    if purge?
      rules_resources = old_generate.bind(self).call
      # Remove rules which match created g_firewall_protect types
      # and make them ensure=present again
      catalog.resources.select { |r| r.is_a?(Puppet::Type.type(:g_firewall_protect)) && r[:chain] == self[:name] }.each do |ignored_resource|
        rules_resources.delete_if do |res|
          v = ignored_resource[:regex].find_index { |f| res.provider.properties[:line].match(f) }
          if v
            debug("g_firewall: protecting (normal) #{res[:name]} with #{ignored_resource[:name]}")
            res[:ensure] = :present
          end
          v
        end
      end

      rules_resources
    else
      do_generate_smart
    end
  end
end
