## [1.3.7](https://github.com/bauer-group/IAC-Ansible/compare/v1.3.6...v1.3.7) (2026-04-12)

### 🐛 Bug Fixes

* **ansible-pull:** prevented duplicate Ansible PPA registration ([5fe9708](https://github.com/bauer-group/IAC-Ansible/commit/5fe9708278f35b2618cdbecb68f6187501ee0466))

## [1.3.6](https://github.com/bauer-group/IAC-Ansible/compare/v1.3.5...v1.3.6) (2026-04-12)

### 🐛 Bug Fixes

* **config:** removed community.general.timer callback ([83b4827](https://github.com/bauer-group/IAC-Ansible/commit/83b48272983cadd1ae2e6b1bbe26b1c784ef7a13))

## [1.3.5](https://github.com/bauer-group/IAC-Ansible/compare/v1.3.4...v1.3.5) (2026-04-12)

### 🐛 Bug Fixes

* **netplan:** changed IPv6 test target from Cloudflare to Google ([332e254](https://github.com/bauer-group/IAC-Ansible/commit/332e2547cd5fee4cff459df72de72bad78056958))

## [1.3.4](https://github.com/bauer-group/IAC-Ansible/compare/v1.3.3...v1.3.4) (2026-04-12)

### 🐛 Bug Fixes

* **netplan:** increased settle time after netplan apply to 15s ([6d870ea](https://github.com/bauer-group/IAC-Ansible/commit/6d870eaed4e10356e6e1c7a2df8f6db3f05c12de))

## [1.3.3](https://github.com/bauer-group/IAC-Ansible/compare/v1.3.2...v1.3.3) (2026-04-12)

### 🐛 Bug Fixes

* **inventory:** disabled IPv6 connectivity test for 0047-20 ([886074c](https://github.com/bauer-group/IAC-Ansible/commit/886074c36ae248ffba9ed111b794b3448c7147e9))

## [1.3.2](https://github.com/bauer-group/IAC-Ansible/compare/v1.3.1...v1.3.2) (2026-04-12)

### 🐛 Bug Fixes

* **config:** replaced removed community.general.yaml callback ([1e0f3a8](https://github.com/bauer-group/IAC-Ansible/commit/1e0f3a89bbda33dfcfe305a0120ff87c7a24f171))

## [1.3.1](https://github.com/bauer-group/IAC-Ansible/compare/v1.3.0...v1.3.1) (2026-04-11)

### 🐛 Bug Fixes

* **lint:** fixed 26 ansible-lint violations ([0122f19](https://github.com/bauer-group/IAC-Ansible/commit/0122f1967cd6b475328559d15b497852f888add8))

## [1.3.0](https://github.com/bauer-group/IAC-Ansible/compare/v1.2.0...v1.3.0) (2026-04-11)

### 🚀 Features

* **bootstrap:** added IAC_HOSTNAME inventory hostname support ([dc383fb](https://github.com/bauer-group/IAC-Ansible/commit/dc383fb46fcc236c3a031e22a43276f07c5f329b))
* **common:** added hostname and firewall management ([ed86dda](https://github.com/bauer-group/IAC-Ansible/commit/ed86ddaf66b5917a55efbff65e48b341f94030d0))
* **coolify:** added Coolify platform support ([7adb6f1](https://github.com/bauer-group/IAC-Ansible/commit/7adb6f18fca3104e0de2e04e54ffdbcc2a81ad59))
* **inventory:** provisioned Docker host 0047-20 ([4106663](https://github.com/bauer-group/IAC-Ansible/commit/41066631f7c06d61fd40db65ca8917045d65edb8))

## [1.2.0](https://github.com/bauer-group/IAC-Ansible/compare/v1.1.0...v1.2.0) (2026-03-20)

### 🚀 Features

* **monitoring:** added SMART disk monitoring ([6ec2ff0](https://github.com/bauer-group/IAC-Ansible/commit/6ec2ff0bba29cd6165590dce1ac1ca13b100ec45))

## [1.1.0](https://github.com/bauer-group/IAC-Ansible/compare/v1.0.2...v1.1.0) (2026-03-20)

### 🚀 Features

* **common:** added DNS server configuration for systemd-resolved ([e025c83](https://github.com/bauer-group/IAC-Ansible/commit/e025c83900ad74a027ff917714240ff8ffec2d5e))
* **common:** added system hardening and resource limits ([d474a69](https://github.com/bauer-group/IAC-Ansible/commit/d474a6971ec007af227ddac1bf438c921a8e3545))
* **docker:** added Docker deployment phase ([5936981](https://github.com/bauer-group/IAC-Ansible/commit/593698181c4801ea68d344c2f04f9973ced26076))

## [1.0.2](https://github.com/bauer-group/IAC-Ansible/compare/v1.0.1...v1.0.2) (2026-03-20)

### 🐛 Bug Fixes

* **ansible-pull:** removed restrictive security options ([4fcc9d5](https://github.com/bauer-group/IAC-Ansible/commit/4fcc9d5d83719bed1e5dc7c86f080b1922fb75ba))

## [1.0.1](https://github.com/bauer-group/IAC-Ansible/compare/v1.0.0...v1.0.1) (2026-03-20)

### 🐛 Bug Fixes

* **ansible_pull:** fixed extra args handling in ansible-pull service ([4042175](https://github.com/bauer-group/IAC-Ansible/commit/4042175e1dfa0724ab67abd46c64180770a9bbb0))

## [1.0.0](https://github.com/bauer-group/IAC-Ansible/compare/v0.7.0...v1.0.0) (2026-03-20)

### ⚠ BREAKING CHANGES

* **common:** motd.j2 template no longer used; MOTD now handled via platform-specific dynamic scripts.

### 🚀 Features

* **common:** added platform-specific dynamic MOTD scripts ([2742c14](https://github.com/bauer-group/IAC-Ansible/commit/2742c14632332f28947a4786fff719629cc2f6ec))

## [0.7.0](https://github.com/bauer-group/IAC-Ansible/compare/v0.6.0...v0.7.0) (2026-03-20)

### 🚀 Features

* **common:** separated Ubuntu-specific packages ([62c4d35](https://github.com/bauer-group/IAC-Ansible/commit/62c4d35e3d1ea41f53d61b2b77c633f2f846503e))

## [0.6.0](https://github.com/bauer-group/IAC-Ansible/compare/v0.5.2...v0.6.0) (2026-03-20)

### 🚀 Features

* **staging:** added staging host with inventory groups ([b615452](https://github.com/bauer-group/IAC-Ansible/commit/b615452c618a9fb9a9497cd6fdc96845c93624f3))

## [0.5.2](https://github.com/bauer-group/IAC-Ansible/compare/v0.5.1...v0.5.2) (2026-03-20)

### 🐛 Bug Fixes

* **security:** hardened security posture and reliability ([fc6729c](https://github.com/bauer-group/IAC-Ansible/commit/fc6729c2dd961000f12f5bfdd9053548a07a353e))

## [0.5.1](https://github.com/bauer-group/IAC-Ansible/compare/v0.5.0...v0.5.1) (2026-03-20)

### ♻️ Refactoring

* **ansible:** moved software-properties-common to Ubuntu-only ([b8af008](https://github.com/bauer-group/IAC-Ansible/commit/b8af0084037d1a95ad98d61364817986c8dc4ad8))

## [0.5.0](https://github.com/bauer-group/IAC-Ansible/compare/v0.4.0...v0.5.0) (2026-02-09)

### 🚀 Features

* Add SSH hardening documentation with automatic key deployment instructions ([c9bcb21](https://github.com/bauer-group/IAC-Ansible/commit/c9bcb21a187ba8534799fb7241903923913b3905))
* Update Debian auto-update configuration and disable unnecessary timers ([dcfd63c](https://github.com/bauer-group/IAC-Ansible/commit/dcfd63cfc114d85a0d3cffcbdd13e18d4854942a))
* Update maintenance chain schedule to 03:00 and disable unnecessary timers for RedHat ([dbe09af](https://github.com/bauer-group/IAC-Ansible/commit/dbe09afb0c344e6b83d77cf0536139ceff6b5d54))

## [0.4.0](https://github.com/bauer-group/IAC-Ansible/compare/v0.3.0...v0.4.0) (2026-02-09)

### 🚀 Features

* Enhance SSH key deployment and hardening with GitHub integration ([9a15d41](https://github.com/bauer-group/IAC-Ansible/commit/9a15d4189667ced1cee619d8d929dabcbf0c4ea8))

## [0.3.0](https://github.com/bauer-group/IAC-Ansible/compare/v0.2.3...v0.3.0) (2026-02-09)

### 🚀 Features

* Implement SSH hardening configuration with conditional checks and templates ([7dc959c](https://github.com/bauer-group/IAC-Ansible/commit/7dc959c7f72c9cd1559e5a06b360167e760b02f4))

### 🐛 Bug Fixes

* Remove SSH hardening settings and restart handler from main.yml ([01c2418](https://github.com/bauer-group/IAC-Ansible/commit/01c241878760d59ff27f904baf7b1e683e003d8a))

## [0.2.3](https://github.com/bauer-group/IAC-Ansible/compare/v0.2.2...v0.2.3) (2026-02-08)

### 🐛 Bug Fixes

* Remove linear strategy and run_once from pre_tasks in site.yml ([7ba48a4](https://github.com/bauer-group/IAC-Ansible/commit/7ba48a40a0ac69644c031d8c0d0870ac95ee726b))

## [0.2.2](https://github.com/bauer-group/IAC-Ansible/compare/v0.2.1...v0.2.2) (2026-02-08)

### 🐛 Bug Fixes

* Replace shell command with service facts for NTP detection and set active state fact ([cd1e514](https://github.com/bauer-group/IAC-Ansible/commit/cd1e5146ac7c329d08a4d2d77979edeb91c8f30b))

## [0.2.1](https://github.com/bauer-group/IAC-Ansible/compare/v0.2.0...v0.2.1) (2026-02-08)

### 🐛 Bug Fixes

* Correct formatting in ansible-deploy.yml for Python setup step ([1c6a5fe](https://github.com/bauer-group/IAC-Ansible/commit/1c6a5fe6393c76f6973fd4dd2a12d60f1ddba8f0))
* Update playbooks and roles with improved error handling and consistent variable naming ([bb86674](https://github.com/bauer-group/IAC-Ansible/commit/bb86674200a9b0de6becc021d519c3333d65aefe))

## [0.2.0](https://github.com/bauer-group/IAC-Ansible/compare/v0.1.1...v0.2.0) (2026-02-08)

### 🚀 Features

* Enhance Uptime Kuma integration for automated maintenance window management ([e1fd19a](https://github.com/bauer-group/IAC-Ansible/commit/e1fd19a49dd63457ff5d41076766bb0b6c225671))
* Integrate Uptime Kuma for automated maintenance window management during updates ([b47a88c](https://github.com/bauer-group/IAC-Ansible/commit/b47a88c609f39fb29cfad54a36d43f23d964a885))

## [0.1.1](https://github.com/bauer-group/IAC-Ansible/compare/v0.1.0...v0.1.1) (2026-02-08)

### 🐛 Bug Fixes

* Refactor dependency installation and update Ansible Galaxy requirements for consistency ([dacc948](https://github.com/bauer-group/IAC-Ansible/commit/dacc948d556f81d20cfc745ef1b54d193836cc94))
* Standardize repository naming and enhance NTP configuration checks ([e0d08c8](https://github.com/bauer-group/IAC-Ansible/commit/e0d08c894f34349e926626bca82510c10bd1f80f))
* Update maintenance chain for auto-update process and adjust schedules ([8648e05](https://github.com/bauer-group/IAC-Ansible/commit/8648e050273f265f40ee93786a5602b27330ef9d))
* Update minimum Ansible version to 2.18 and adjust related configurations ([8b96184](https://github.com/bauer-group/IAC-Ansible/commit/8b96184c3d3b5d7660de5928d638949da468a8d2))
* Update Python setup action to version 6 in workflows for consistency ([fd57c94](https://github.com/bauer-group/IAC-Ansible/commit/fd57c948bc6ed001d4b1d6aa9c5da4f9b65dba98))

## [0.1.0](https://github.com/bauer-group/IAC-Ansible/compare/v0.0.0...v0.1.0) (2026-02-08)

### 🚀 Features

* Add GitHub workflows for deployment, linting, release, and notifications ([bb83893](https://github.com/bauer-group/IAC-Ansible/commit/bb838930c2970ed34bc80f79ae83b104653f1e6b))
* Add workflows for deployment and linting to enhance automation and code quality ([326945d](https://github.com/bauer-group/IAC-Ansible/commit/326945d3598dea7d69e5301dacd0e603646d15ac))
* Enhance deployment workflows and scripts for improved functionality and security ([07677f4](https://github.com/bauer-group/IAC-Ansible/commit/07677f4b9377e657bab9ae64670da647c99c87bb))
* Remove obsolete workflows and enhance documentation for asset management ([9b2d265](https://github.com/bauer-group/IAC-Ansible/commit/9b2d265ee5137d9272bb1f734f38f76e4a41a595))
* Update supported OS versions in documentation and role metadata for accuracy ([bd8e15b](https://github.com/bauer-group/IAC-Ansible/commit/bd8e15b8ee9c0e2c9e72a49ac11a958e145205b5))

### 🐛 Bug Fixes

* Prefix, Timezone, Naming ([d26d7a4](https://github.com/bauer-group/IAC-Ansible/commit/d26d7a4b6204d7ecd407bdbcb300e14510c9885a))
* Update actions versions in workflows for consistency and improved functionality ([eefb95b](https://github.com/bauer-group/IAC-Ansible/commit/eefb95b1541c88c4f7c845614dc0cf2e6024289f))
