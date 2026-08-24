#!/bin/sh
# CPack RPM %postun -- restores what the spec-built packages did.
#
# Every package up to 1.10.0 ran /sbin/ldconfig here. The 1.11.0-2.0.1 line lost it, leaving only a
# commented-out `#rm -rf /var/log/mesos /etc/mesos`, and the CPack build then dropped the scriptlet
# entirely. Log and config directories are still left alone.

/sbin/ldconfig
