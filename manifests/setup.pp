class g_firewall::setup(
  $initialize = true
){
  include ::g_firewall::params

  if $initialize {

    $::g_firewall::params::chains.each | $protocol, $tables | {
      $tables.each | $table, $chains | {
        $chains.each | $chain | {
          firewallchain { "${chain}:${table}:${protocol}":
            ensure => present,
            purge  => true,
          }
        }
      }
    }

    resources { 'firewall':
      purge => false,
    }

    resources { 'firewallchain':
      purge => true,
    }

    Firewall {
      before  => Class['g_firewall::rules::post'],
      require => Class['g_firewall::rules::pre'],
    }

    class { ['g_firewall::rules::pre', 'g_firewall::rules::post']: }

    class { '::firewall': }

    # add internal chains to catalog, so no warnings and errors are printed
    g_firewall_syschain { 'default' :
      regex => '^(PREROUTING|POSTROUTING|BROUTING|INPUT|FORWARD|OUTPUT)$'
    }

  }

}
