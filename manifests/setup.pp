class g_firewall::setup(
  $initialize = true
){
  include ::g_firewall::params

  if $initialize {

    resources { 'firewall':
      purge => true,
    }

    resources { 'firewallchain':
      purge => true,
    }

    Firewall {
      before  => Class['g_firewall::rules::post'],
      require => Class['g_firewall::rules::pre'],
    }
    Firewallchain {
      purge => true
    }

    class { ['g_firewall::rules::pre', 'g_firewall::rules::post']: }

    class { '::firewall': }

    # add internal chains to catalog, so no warnings and errors are printed
    g_firewall_syschain { 'default' :
      regex => '^(PREROUTING|POSTROUTING|BROUTING|INPUT|FORWARD|OUTPUT)$'
    }
  }
}
