class g_firewall::rules::pre {
  Firewall {
    require => undef,
  }

  # Default firewall rules
  g_firewall { '000 accept all icmp':
    proto  => 'icmp',
    action => 'accept',
  }
  ->g_firewall { '001 accept all to lo interface':
    proto   => 'all',
    iniface => 'lo',
    action  => 'accept',
  }

  g_firewall::ipv4 { '002 reject local traffic not on loopback interface':
    iniface     => '! lo',
    proto       => 'all',
    destination => '127.0.0.1/8',
    action      => 'reject',
    require     => G_firewall['001 accept all to lo interface'],
    before      => G_firewall['003 accept related established rules']
  }

  g_firewall::ipv6 { '002 reject local traffic not on loopback interface':
    iniface     => '! lo',
    proto       => 'all',
    destination => '::1',
    action      => 'reject',
    require     => G_firewall['001 accept all to lo interface'],
    before      => G_firewall['003 accept related established rules']
  }

  g_firewall { '003 accept related established rules':
    proto  => 'all',
    state  => ['RELATED', 'ESTABLISHED'],
    action => 'accept',
  }
  # for TOR but looks good for others too
  ->g_firewall { '004 drop invalid packets':
    proto  => 'all',
    state  => ['INVALID'],
    action => 'drop',
  }

}
