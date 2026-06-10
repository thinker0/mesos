// Licensed to the Apache Software Foundation (ASF) under one
// or more contributor license agreements.  See the NOTICE file
// distributed with this work for additional information
// regarding copyright ownership.  The ASF licenses this file
// to you under the Apache License, Version 2.0 (the
// "License"); you may not use this file except in compliance
// with the License.  You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

#ifndef __LINUX_BPF_COMPAT_HPP__
#define __LINUX_BPF_COMPAT_HPP__

#include <linux/bpf.h>

namespace ebpf {

// Vendored, kernel-header-version-independent definitions for the BPF
// cgroup-device interface (added upstream in Linux 4.15; atomic program
// replace added in Linux 5.0).
//
// The kernel UAPI exposes these as anonymous-enum constants and a struct, none
// of which are preprocessor macros, so their presence cannot be detected with
// #ifdef/#ifndef. Older kernel UAPI headers (e.g. RHEL/CentOS 7 x86_64,
// kernel-headers 3.10.0-*.el7) omit them entirely. Rather than trying to probe
// for the kernel symbols, we mirror the stable kernel ABI here under our own
// names and reference these from our code. This lets a single source compile
// against any kernel-header version with no build-time feature detection, and
// support is determined at runtime: on a kernel that does not implement BPF
// cgroup-device programs the bpf() syscalls fail and the error is surfaced to
// the caller.
namespace cgroup_device {

// enum bpf_attach_type::BPF_CGROUP_DEVICE. Only ever assigned to the `__u32`
// attach-type fields of the bpf() attributes, so a plain integer is enough.
constexpr __u32 ATTACH_TYPE = 6;

// enum bpf_prog_type::BPF_PROG_TYPE_CGROUP_DEVICE.
constexpr __u32 PROG_TYPE = 15;

// Device access bits encoded in the high 16 bits of `Context::access_type`.
constexpr __u32 ACC_MKNOD = 1u << 0;
constexpr __u32 ACC_READ = 1u << 1;
constexpr __u32 ACC_WRITE = 1u << 2;

// Device type bits encoded in the low 16 bits of `Context::access_type`.
constexpr __u32 DEV_BLOCK = 1u << 0;
constexpr __u32 DEV_CHAR = 1u << 1;

// Program attach flags (BPF_F_ALLOW_MULTI, BPF_F_REPLACE).
constexpr __u32 F_ALLOW_MULTI = 1u << 1;
constexpr __u32 F_REPLACE = 1u << 2;

// Layout-compatible mirror of the kernel's `struct bpf_cgroup_dev_ctx`, the
// context passed to a cgroup-device program. The device type is encoded in the
// low 16 bits of `access_type` and the access type in the high 16 bits.
struct Context
{
  __u32 access_type;
  __u32 major;
  __u32 minor;
};

// Layout-compatible mirror of the BPF_PROG_ATTACH variant of `union bpf_attr`,
// including `replace_bpf_fd` (Linux >= 5.0) which older kernel UAPI headers
// omit from `union bpf_attr`. Using our own type lets us request an atomic
// program replace regardless of the build's kernel-header age; the kernel
// reads `sizeof(AttachAttr)` bytes and validates the trailing field.
struct AttachAttr
{
  __u32 target_fd;
  __u32 attach_bpf_fd;
  __u32 attach_type;
  __u32 attach_flags;
  __u32 replace_bpf_fd;
};

} // namespace cgroup_device {

} // namespace ebpf {

#endif // __LINUX_BPF_COMPAT_HPP__
