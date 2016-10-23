define g_firewall::protect (
  $chain,
  $regex
){
  g_firewall_protect { $title:
    chain => $chain,
    regex => $regex
  }
}
