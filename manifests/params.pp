class g_firewall::params {
  include ::stdlib

  $protocols = [
    $facts['iptables_version']?{
      undef => undef,
      default => 'IPv4'
    },
    $facts['ip6tables_version']?{
      undef => undef,
      default => 'IPv6'
    },
  ].filter |$v| { $v != undef }
}
