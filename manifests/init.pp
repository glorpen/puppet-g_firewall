# Class: g_firewall
#
# This module manages g_firewall
#
# Parameters: none
#
# Actions:
#
# Requires: see Modulefile
#
# Sample Usage:
#
define g_firewall (
  $ensure = present,
  $protocol = undef,
  Optional[Stdlib::IP::Address] $proto_from_ip = undef,

  $action = undef,
  $source = undef,
  $src_range = undef,
  $destination = undef,
  $dst_range = undef,
  $sport = undef,
  $dport = undef,
  $port = undef,
  $dst_type = undef,
  $src_type = undef,
  $proto = undef,
  $mss = undef,
  $tcp_flags = undef,
  $chain = undef,
  $table = undef,
  $jump = undef,
  $goto = undef,
  $iniface = undef,
  $outiface = undef,
  $tosource = undef,
  $todest = undef,
  $toports = undef,
  $to = undef,
  $random = undef,
  $reject = undef,
  $log_level = undef,
  $log_prefix = undef,
  $log_uid = undef,
  $icmp = undef,
  $state = undef,
  $ctstate = undef,
  $connmark = undef,
  $connlimit_above = undef,
  $connlimit_mask = undef,
  $hop_limit = undef,
  $limit = undef,
  $burst = undef,
  $uid = undef,
  $gid = undef,
  $match_mark = undef,
  $set_mark = undef,
  $clamp_mss_to_pmtu = undef,
  $set_dscp = undef,
  $set_dscp_class = undef,
  $set_mss = undef,
  $pkttype = undef,
  $isfragment = undef,
  $recent = undef,
  $rdest = undef,
  $rsource = undef,
  $rname = undef,
  $rseconds = undef,
  $reap = undef,
  $rhitcount = undef,
  $rttl = undef,
  $socket = undef,
  $ishasmorefrags = undef,
  $islastfrag = undef,
  $isfirstfrag = undef,
  $ipsec_policy = undef,
  $ipsec_dir = undef,
  $stat_mode = undef,
  $stat_every = undef,
  $stat_packet = undef,
  $stat_probability = undef,
  $mask = undef,
  $gateway = undef,
  $ipset = undef,
  $checksum_fill = undef,
  $mac_source = undef,
  $physdev_in = undef,
  $physdev_out = undef,
  $physdev_is_bridged = undef,
  $date_start = undef,
  $date_stop = undef,
  $time_start = undef,
  $time_stop = undef,
  $month_days = undef,
  $week_days = undef,
  $time_contiguous = undef,
  $kernel_timezone = undef,
  $clusterip_new = undef,
  $clusterip_hashmode = undef,
  $clusterip_clustermac = undef,
  $clusterip_total_nodes = undef,
  $clusterip_local_node = undef,
  $clusterip_hash_init = undef,
  $length = undef,
  $string = undef,
  $string_algo = undef,
  $string_from = undef,
  $string_to = undef,
){

  include ::stdlib

  $opts = {
    'ensure' => $ensure,
    'action' => $action,
    'source' => $source,
    'src_range' => $src_range,
    'destination' => $destination,
    'dst_range' => $dst_range,
    'sport' => $sport,
    'dport' => $dport,
    'port' => $port,
    'dst_type' => $dst_type,
    'src_type' => $src_type,
    'mss' => $mss,
    'tcp_flags' => $tcp_flags,
    'chain' => $chain,
    'table' => $table,
    'jump' => $jump,
    'goto' => $goto,
    'iniface' => $iniface,
    'outiface' => $outiface,
    'tosource' => $tosource,
    'todest' => $todest,
    'toports' => $toports,
    'to' => $to,
    'random' => $random,
    'reject' => $reject,
    'log_level' => $log_level,
    'log_prefix' => $log_prefix,
    'log_uid' => $log_uid,
    'icmp' => $icmp,
    'state' => $state,
    'ctstate' => $ctstate,
    'connmark' => $connmark,
    'connlimit_above' => $connlimit_above,
    'connlimit_mask' => $connlimit_mask,
    'hop_limit' => $hop_limit,
    'limit' => $limit,
    'burst' => $burst,
    'uid' => $uid,
    'gid' => $gid,
    'match_mark' => $match_mark,
    'set_mark' => $set_mark,
    'clamp_mss_to_pmtu' => $clamp_mss_to_pmtu,
    'set_dscp' => $set_dscp,
    'set_dscp_class' => $set_dscp_class,
    'set_mss' => $set_mss,
    'pkttype' => $pkttype,
    'isfragment' => $isfragment,
    'recent' => $recent,
    'rdest' => $rdest,
    'rsource' => $rsource,
    'rname' => $rname,
    'rseconds' => $rseconds,
    'reap' => $reap,
    'rhitcount' => $rhitcount,
    'rttl' => $rttl,
    'socket' => $socket,
    'ishasmorefrags' => $ishasmorefrags,
    'islastfrag' => $islastfrag,
    'isfirstfrag' => $isfirstfrag,
    'ipsec_policy' => $ipsec_policy,
    'ipsec_dir' => $ipsec_dir,
    'stat_mode' => $stat_mode,
    'stat_every' => $stat_every,
    'stat_packet' => $stat_packet,
    'stat_probability' => $stat_probability,
    'mask' => $mask,
    'gateway' => $gateway,
    'ipset' => $ipset,
    'checksum_fill' => $checksum_fill,
    'mac_source' => $mac_source,
    'physdev_in' => $physdev_in,
    'physdev_out' => $physdev_out,
    'physdev_is_bridged' => $physdev_is_bridged,
    'date_start' => $date_start,
    'date_stop' => $date_stop,
    'time_start' => $time_start,
    'time_stop' => $time_stop,
    'month_days' => $month_days,
    'week_days' => $week_days,
    'time_contiguous' => $time_contiguous,
    'kernel_timezone' => $kernel_timezone,
    'clusterip_new' => $clusterip_new,
    'clusterip_hashmode' => $clusterip_hashmode,
    'clusterip_clustermac' => $clusterip_clustermac,
    'clusterip_total_nodes' => $clusterip_total_nodes,
    'clusterip_local_node' => $clusterip_local_node,
    'clusterip_hash_init' => $clusterip_hash_init,
    'length' => $length,
    'string' => $string,
    'string_algo' => $string_algo,
    'string_from' => $string_from,
    'string_to' => $string_to,
  }.filter |$key, $value| { $value != undef }

  include ::g_firewall::params

  if $proto_from_ip == undef {
    if $protocol == undef {
      $_protocols = $::g_firewall::params::protocols
    } else {
      $_protocols = g_firewall::normalize_protocol(flatten([$protocol]))
      $_diff = difference($_protocols,$::g_firewall::params::protocols)
      if !empty($_diff) {
        fail("Protocols ${_diff} are not enabled")
      }
    }
  } else {
    $_protocols = $proto_from_ip?{
      Stdlib::IP::Address::V4 => ['IPv4'],
      Stdlib::IP::Address::V6 => ['IPv6']
    }
  }

  $_protocols.each |$p| {
    $_title = ::g_firewall::normalize_name($title, $p)
    $_provider = $p?{
      'IPv4' => 'iptables',
      'IPv6' => 'ip6tables'
    }

    if $p == 'IPv6' {
      # fix icmp for ipv6
      $fixed_proto = $proto?{
        'icmp' => 'ipv6-icmp',
        default => $proto
      }
    } else {
      $fixed_proto = $proto
    }

    $fixes = {
      'proto' => $fixed_proto
    }.filter |$key, $value| { $value != undef }

    create_resources(firewall, {$_title => merge($opts, $fixes, {'provider' => $_provider })})
  }
}
