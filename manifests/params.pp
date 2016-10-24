class g_firewall::params {
  
  $_mangle_chain = {'mangle' => ['PREROUTING', 'INPUT', 'FORWARD', 'OUTPUT', 'POSTROUTING']}
  $_filter_chain = {'filter' => ['INPUT', 'FORWARD', 'OUTPUT']}
  $_raw_chain = {'raw' => ['PREROUTING', 'OUTPUT']}
  
  $_nat_chain = {'nat' => ['PREROUTING', 'INPUT', 'OUTPUT', 'POSTROUTING']}
  
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
  
  $chains = {
    'IPv4' => merge($_mangle_chain, $_filter_chain, $_raw_chain, $_nat_chain),
    'IPv6' => merge($_mangle_chain, $_filter_chain, $_raw_chain)
  }
}
