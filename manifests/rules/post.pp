class g_firewall::rules::post {
  g_firewall { "999 drop all":
    proto  => 'all',
    action => 'drop',
    before => undef,
    is_post_rule => true
  }
}
