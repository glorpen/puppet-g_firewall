class g_firewall::rules::post {
  include ::g_firewall::params

  $::g_firewall::params::protocols.each |$p| {
    $provider = $p?{
      'IPv4' => 'iptables',
      'IPv6' => 'ip6tables'
    }

    firewall { "999.${p} drop all":
      proto    => 'all',
      action   => 'drop',
      before   => undef,
      provider => $provider
    }
  }
}
