#!/bin/bash
asn_int="65534"
asn_ext="65533"
prefixes="fc00::/7 2001:2::/48 2001:20::/28 2001:db8::/32 100::/64"
grpname_ibgp="iBGP"
grpname_ebgp_full="eBGP_full"
grpname_ebgp_part="eBGP_partial"

echo "router bgp ${asn_int}"
echo " bgp log-neighbor-changes"
echo " no bgp default ipv4-unicast"
echo " bgp graceful-restart"
for target in ${grpname_ibgp} ${grpname_ebgp_full} ${grpname_ebgp_part}; do
	echo " neighbor ${target} peer-group"
	if [ "${target}" != "${grpname_ibgp}" ]; then
		if [ "${asn_ext}" != "${asn_int}" ]; then
			echo "!neighbor <${target} Peer IPv6> remote-as <${target} Peer ASN>"
			echo "!neighbor <${target} Peer IPv6> local-as ${asn_ext}"
		fi
	else
		echo "!neighbor <${target} Peer IPv6> remote-as ${asn_int}"
	fi
done
echo " address-family ipv6"
for target in ${prefixes}; do
	echo "  network ${target}"
done
for target in ${grpname_ibgp} ${grpname_ebgp_full} ${grpname_ebgp_part}; do
	echo "  neighbor ${target} activate"
	echo "  neighbor ${target} soft-reconfiguration inbound"
	echo "  neighbor ${target} distribute-list ${target}-in in"
	echo "  neighbor ${target} distribute-list ${target}-out out"
	echo "! neighbor <${target} Peer IPv6> peer-group ${target}"
done
echo " exit-address-family"
for target in ${prefixes}; do
	echo "ipv6 route ${target} ::1 lo0 blackhole"
done
echo "no ipv6 access-list ${grpname_ebgp_full}-in"
echo "ipv6 access-list ${grpname_ebgp_full}-in deny ::/0 exact-match"
echo "ipv6 access-list ${grpname_ebgp_full}-in permit any"
echo "no ipv6 access-list ${grpname_ebgp_full}-out"
echo "ipv6 access-list ${grpname_ebgp_full}-out deny ::/0 exact-match"
for target in ${prefixes}; do
	echo "ipv6 access-list ${grpname_ebgp_full}-out permit ${target} exact-match"
done
echo "ipv6 access-list ${grpname_ebgp_full}-out deny any"
echo "no ipv6 access-list ${grpname_ebgp_part}-in"
echo "ipv6 access-list ${grpname_ebgp_part}-in deny ::/0 exact-match"
for target in ${prefixes}; do
	echo "ipv6 access-list ${grpname_ebgp_part}-in deny ${target}"
done
echo "ipv6 access-list ${grpname_ebgp_part}-in permit any"
echo "no ipv6 access-list ${grpname_ebgp_part}-out"
echo "ipv6 access-list ${grpname_ebgp_part}-out deny ::/0 exact-match"
for target in ${prefixes}; do
	echo "ipv6 access-list ${grpname_ebgp_part}-out permit ${target} exact-match"
done
echo "ipv6 access-list ${grpname_ebgp_part}-out deny any"
echo "no ipv6 access-list ${grpname_ibgp}-in"
echo "ipv6 access-list ${grpname_ibgp}-in deny ::/0 exact-match"
echo "ipv6 access-list ${grpname_ibgp}-in permit any"
echo "no ipv6 access-list ${grpname_ibgp}-out"
echo "ipv6 access-list ${grpname_ibgp}-out permit any"
