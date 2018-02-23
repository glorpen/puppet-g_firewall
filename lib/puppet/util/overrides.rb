
# Module#prepend is not available in JRuby 1.9

# Patch upstream method
class Puppet::Type::Firewallchain
  def generate
    return [] unless purge?

    value(:name).match(Nameformat)
    chain = Regexp.last_match(1)
    table = Regexp.last_match(2)
    protocol = Regexp.last_match(3)

    provider = case protocol
               when 'IPv4'
                 :iptables
               when 'IPv6'
                 :ip6tables
               end

    # gather a list of all rules present on the system
    rules_resources = Puppet::Type.type(:firewall).instances

    # Keep only rules in this chain
    rules_resources.delete_if { |res| (res[:provider] != provider || res.provider.properties[:table].to_s != table || res.provider.properties[:chain] != chain) }

    # Remove rules which match our ignore filter
    rules_resources.delete_if { |res| value(:ignore).find_index { |f| res.provider.properties[:line].match(f) } } if value(:ignore)

    # Remove rules which match created g_firewall_protect types
    catalog.resources.select { |r| r.is_a?(Puppet::Type.type(:g_firewall_protect)) && r[:chain] == self[:name] }.each do |ignored_resource|
      rules_resources.delete_if { |res| ignored_resource[:regex].find_index { |f| res.provider.properties[:line].match(f) } }
    end

    # We mark all remaining rules for deletion, and then let the catalog override us on rules which should be present
    rules_resources.each { |res| res[:ensure] = :absent }

    rules_resources
  end
end
