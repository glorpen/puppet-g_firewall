==========
g-firewall
==========

Puppet module to ease firewall rule management, wraps *puppetlabs/firewall*.


Default firewall rules
======================

Including ``g_firewall::setup`` will setup default firewall rules and resource purging.

IPv4 or IPv6
============

To create rule for *ipv4* stack, use ``g_firewall::ipv4``. For ipv6, as you guessed, use ``g_firewall::ipv6``.

All parameters used in *puppetlabs/firewall* should be available in ``g_firewall`` and its ipv4/ipv6 counterparts,
for guide and documentation see upstream module.

.. sourcecode:: puppet

    g_firewall::ipv4 { "200 example rule for network eth0:ipv6":
      iniface => 'eth0',
      action => 'accept',
      dport => '9101-9103'
    }
    
    g_firewall::ipv6 { "200 example rule for network eth0:ipv4":
      iniface => 'eth0',
      action => 'accept',
      dport => '9101-9103'
    }

And to create rules for both ip stacks:

.. sourcecode:: puppet

   g_firewall { "200 example rule":
     iniface => 'eth0',
     action => 'accept',
     dport => '9101-9103'
   }

Resource name prefixing
-----------------------

This behavior relies on resource naming convention from *puppetlabs/firewall* - ``<number> <description>``.
When generating ipv4/ipv6 rules it is extended to ``<number>.<stack> <description>``, so rule from previous section would create resources named:

.. sourcecode::

   200.IPv4 example rule
   200.IPv6 example rule

Proto icmp and ipv6
-------------------

When using *icmp* as *proto* parameter in ipv6 scope it is automatically transated to *icmp-ipv6*. 


Protecting unmanaged rules
==========================

Example for *docker* (you will need more protect rules):

.. sourcecode:: puppet

   g_firewall::protect { 'docker ipv4 filter rules':
     regex => [' -j DOCKER'],
     chain => 'FORWARD:filter:IPv4'
   }
   g_firewall::protect { 'docker ipv4 nat rules':
     regex => ['-j DOCKER'],
     chain => 'PREROUTING:nat:IPv4'
   }
   g_firewall::protect { 'docker ipv4 output rules':
     regex => ['-j DOCKER'],
     chain => 'OUTPUT:nat:IPv4'
   }

Example for *fail2ban*:

.. sourcecode:: puppet

   g_firewall::protect { 'f2b ipv4 rules':
      regex => [' -j f2b-'],
      chain => 'INPUT:filter:IPv4'
    }
    
    g_firewall::protect { 'f2b ipv6 rules':
     regex => [' -j f2b-'],
     chain => 'INPUT:filter:IPv6'
   }


Builtin chains
==============

By default, not managed builtin chains are tried for deletion when purging.
As builtin chain cannot be removed it results in error. 

By using ``g_firewall_syschain`` type you can skip removal of builting system chains.

Example usage, from ``setup.pp``:

.. sourcecode:: puppet

    g_firewall_syschain { 'default' :
      regex => '^(PREROUTING|POSTROUTING|BROUTING|INPUT|FORWARD|OUTPUT)$'
    }
