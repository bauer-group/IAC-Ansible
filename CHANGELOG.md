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
