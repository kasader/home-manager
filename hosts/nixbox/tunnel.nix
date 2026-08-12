# The private network every service on this box hangs off. A plain attrset, NOT a
# module — the files under ./services read it with `import`, so it must never
# appear in an `imports` list.
#
# It exists because these facts are shared: wireguard defines the interface,
# dnsmasq binds addr and opens ports on iface, and a tunnel-only service orders
# itself after unit. Defaulting them per service is how you end up renaming the
# interface in two places out of three and leaving a unit ordered after a
# wireguard unit that no longer exists.
{
  iface = "wg0";
  addr = "10.100.0.1";
  prefixLength = 24;

  # networking.wireguard.interfaces.<n> generates this unit name. Encoded once
  # here because the convention is not something you can infer from the option.
  unit = "wireguard-wg0.service";
}
