# == Define Resource Type: haproxy::balancermember
#
# This type will setup a balancer member inside a listening service
#  configuration block in /etc/haproxy/haproxy.cfg on the load balancer.
#  currently it only has the ability to specify the instance name,
#  ip address, port, and whether or not it is a backup. More features
#  can be added as needed. The best way to implement this is to export
#  this resource for all haproxy balancer member servers, and then collect
#  them on the main haproxy load balancer.
#
# === Requirement/Dependencies:
#
# Currently requires the ripienaar/concat module on the Puppet Forge and
#  uses storeconfigs on the Puppet Master to export/collect resources
#  from all balancer members.
#
# === Parameters
#
# [*name*]
#   The title of the resource is arbitrary and only utilized in the concat
#    fragment name.
#
# [*listening_service*]
#    The haproxy service's instance name (or, the title of the
#     haproxy::config resource). This must match up with a declared
#     haproxy::config resource.
#
# [*balancer_port*]
#     A unique port for which the balancer member will accept connections
#     from the load balancer. Note that cookie values aren't yet supported,
#     but shouldn't be difficult to add to the configuration.
#     If you use an array in server_name and balancer_ip, the same port is
#     used for all balancermembers.
#
# [*order*]
#     The order, or numerical weight, of the fragment created by this defined
#      resource type. This is necessary to ensure the fragment is associated
#      with the correct listening service instance.
#
# [*server_name*]
#     The name of the balancer member server as known to haproxy in the
#      listening service's configuration block. This defaults to the
#      hostname. Can be an array of the same length as balancer_ip,
#      in which case a balancermember is created for each pair of
#      server_name and balancer_ip (in lockstep).
#
# [*balancer_ip*]
#      The ip address used to contact the balancer member server.
#      Can be an array, see documentation to server_name.
#
# [*balancermember_options*]
#      An array of options to be specified after the server declaration
#       in the listening service's configuration block.
#
#
# === Examples
#
#  Exporting the resource for a balancer member:
#
#  @@haproxy::balancermember { 'haproxy':
#    listening_service      => 'puppet00',
#    balancer_port          => '8140',
#    order                  => '21',
#    server_name            => $::hostname,
#    balancer_ip            => $::ipaddress,
#    balancermember_options => 'check',
#  }
#
#
#  Collecting the resource on a load balancer
#
#  Haproxy::Balancermember <<| listening_service == 'puppet00' |>>
#
#  Creating the resource for multiple balancer members at once
#  (for single-pass installation of haproxy without requiring a first
#  pass to export the resources if you know the members in advance):
# 
#  haproxy::balancermember { 'haproxy':
#    listening_service      => 'puppet00',
#    balancer_port          => '8140',
#    order                  => '21',
#    server_name            => ['server01', 'server02'],
#    balancer_ip            => ['192.168.56.200', '192.168.56.201'],
#    balancermember_options => 'check',
#  }
#  
#  (this resource can be declared anywhere)
#
# === Authors
#
# Gary Larizza <gary@puppetlabs.com>
#
define haproxy::balancermember (
  $listening_service,
  $balancer_port,
  $order                  = '20',
  $server_name            = $::hostname,
  $balancer_ip            = $::ipaddress,
  $balancermember_options = ''
) {
  concat::fragment { "${listening_service}_balancermember_${name}":
    order   => $order,
    target  => '/etc/haproxy/haproxy.cfg',
    content => template('haproxy/haproxy_balancermember.erb'),
  }
}
