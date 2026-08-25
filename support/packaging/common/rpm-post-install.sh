#!/bin/sh
# CPack RPM post-install scriptlet -- restores what the spec-built packages did,
# which the CPack build dropped.
#
# Up to 1.10.0 (and 1.11.0-0.el8) this was the standard systemd_post macro expansion:
#
# NOTE: do not write that macro name with its leading percent sign anywhere in this file.
# CPack embeds the file verbatim into the generated spec and rpmbuild expands any macro it
# recognises -- including inside comments. Doing so once injected a live
# `systemctl preset expansion:` block into the built package's post-install scriptlet.
#
#     /sbin/ldconfig
#     if [ $1 -eq 1 ] ; then
#             systemctl preset mesos-slave.service mesos-master.service >/dev/null 2>&1 || :
#     fi
#
# The 1.11.0-2.0.1 line replaced it with a bare `systemctl enable mesos-master; systemctl enable
# mesos-slave` -- no first-install guard, no preset. That put a master on hosts that only wanted an
# agent, where it joined the cluster's ZooKeeper leader election unnoticed (mesos elects the lowest
# sequence number, so it only surfaces once the real masters restart), and it undid any
# `systemctl disable` on the next upgrade.
#
# preset, not enable: it honours the vendor preset, which ships both units disabled.

/sbin/ldconfig

if [ "$1" -eq 1 ] ; then
        # Initial installation
        systemctl preset mesos-agent.service mesos-master.service >/dev/null 2>&1 || :
fi
