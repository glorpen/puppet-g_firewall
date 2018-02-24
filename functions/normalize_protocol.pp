function g_firewall::normalize_protocol( Variant[String, Integer, Tuple] $v){
  if $v =~ Tuple {
    $v.flatten.map | $i | {
      g_firewall::normalize_protocol($i)
    }
  } else {
    if $v =~ Integer {
      if $v in [4,6] {
        "IPv${v}"
      } else {
        fail("Protocol IPv${v} is not known")
      }
    } elsif $v =~ String {
      $matches = $v.match(/^[a-zA-Z]*([0-9])/)
      if $matches {
        g_firewall::normalize_protocol(Integer($matches[1]))
      } else {
        fail("Protocol ${v} is not known")
      }
    } else {
      fail("Unsupported type for ${v}")
    }
  }
}
