function g_firewall::normalize_name(String $name, String $protocol){
  $matches = $name.match(/^(.*?)(.IPv[0-9])?\s+(.*?)$/)

  "${matches[1]}.${protocol} ${matches[3]}"
}
