## [2.14.0](https://github.com/bauer-group/IAC-Ansible/compare/v2.13.0...v2.14.0) (2026-06-27)

### 🚀 Features

* **portainer:** added role for Portainer management UI ([66141b5](https://github.com/bauer-group/IAC-Ansible/commit/66141b501c838d1c210a065ecaf4f72940335ca1))

## [2.13.0](https://github.com/bauer-group/IAC-Ansible/compare/v2.12.0...v2.13.0) (2026-06-26)

### 🚀 Features

* **inventory:** added traefik labels and auto-update for storage host ([09f9d4d](https://github.com/bauer-group/IAC-Ansible/commit/09f9d4d41847f748e443f54058ecf0e3c860c99d))

## [2.12.0](https://github.com/bauer-group/IAC-Ansible/compare/v2.11.0...v2.12.0) (2026-06-26)

### 🚀 Features

* **inventory:** added physical storage host 0001-45 ([051354f](https://github.com/bauer-group/IAC-Ansible/commit/051354f56e9bfc83a05fa805e9dd8525978b72cc))

## [2.11.0](https://github.com/bauer-group/IAC-Ansible/compare/v2.10.0...v2.11.0) (2026-06-26)

### 🚀 Features

* **inventory:** rolled out Traefik on 0048-20, 0049-00, 0050-00 ([1d809a1](https://github.com/bauer-group/IAC-Ansible/commit/1d809a1c43818d57f6f7d28cf73f0034a8bccc7e))

## [2.10.0](https://github.com/bauer-group/IAC-Ansible/compare/v2.9.0...v2.10.0) (2026-06-23)

### 🚀 Features

* **inventory:** added Azure host 0001-21 and group code 21 ([ea9acbc](https://github.com/bauer-group/IAC-Ansible/commit/ea9acbc1601d399df906003be04c3ebf9277fd5c))

## [2.9.0](https://github.com/bauer-group/IAC-Ansible/compare/v2.8.0...v2.9.0) (2026-06-17)

### 🚀 Features

* **traefik:** added Traefik edge-proxy role (core mode) ([47aeba6](https://github.com/bauer-group/IAC-Ansible/commit/47aeba6a51547ecf2ccc2fc584a7e7857c4aae86))

## [2.8.0](https://github.com/bauer-group/IAC-Ansible/compare/v2.7.4...v2.8.0) (2026-06-17)

### 🚀 Features

* **inventory:** added three production hosts (0048-20, 0049-00, 0050-00) ([e648d9b](https://github.com/bauer-group/IAC-Ansible/commit/e648d9ba6d4ea8cc78d6a84e870ca5a82a521370))

## [2.7.4](https://github.com/bauer-group/IAC-Ansible/compare/v2.7.3...v2.7.4) (2026-06-17)

### 🐛 Bug Fixes

* **cloud-init:** update purpose to include Docker application host ([de3586f](https://github.com/bauer-group/IAC-Ansible/commit/de3586fe7d4511cc0afb1803563909d6712e7e2e))

## [2.7.3](https://github.com/bauer-group/IAC-Ansible/compare/v2.7.2...v2.7.3) (2026-06-16)

### 🐛 Bug Fixes

* **platform:** completed Ubuntu 26.04 LTS support for fresh hosts ([a0cf60c](https://github.com/bauer-group/IAC-Ansible/commit/a0cf60c115010a183c5dbbb5cfe45aa42e1a906b))

## [2.7.2](https://github.com/bauer-group/IAC-Ansible/compare/v2.7.1...v2.7.2) (2026-05-07)

### ⏪ Reverts

* **docker:** removed subnet migration drain logic ([69b27cc](https://github.com/bauer-group/IAC-Ansible/commit/69b27cc6308374b5158ba6029b6b47f55145c5cc))

## [2.7.1](https://github.com/bauer-group/IAC-Ansible/compare/v2.7.0...v2.7.1) (2026-05-07)

### 🐛 Bug Fixes

* **docker:** made subnet migration idempotent via docker0 prefix check ([fe5de68](https://github.com/bauer-group/IAC-Ansible/commit/fe5de68bc2151f0625283be596974cbf55695c61))

## [2.7.0](https://github.com/bauer-group/IAC-Ansible/compare/v2.6.0...v2.7.0) (2026-05-07)

### 🚀 Features

* **docker:** migrated to fd10::/48 IPv6 layout with opt-in drain ([66ae86c](https://github.com/bauer-group/IAC-Ansible/commit/66ae86cfb6cb1e428cd6ab713ce6f5e377ec0d2b))

## [2.6.0](https://github.com/bauer-group/IAC-Ansible/compare/v2.5.12...v2.6.0) (2026-05-07)

### 🚀 Features

* **cloud-init:** added per-host bootstrap scripts for prod and staging ([351ec5e](https://github.com/bauer-group/IAC-Ansible/commit/351ec5e70e4277252339623daf951525633527fd))

### 🐛 Bug Fixes

* **installer:** passed INVENTORY to initial ansible-pull invocation ([b4f6002](https://github.com/bauer-group/IAC-Ansible/commit/b4f6002622e79c3f83a18e9941959467f5859a1d))

## [2.5.12](https://github.com/bauer-group/IAC-Ansible/compare/v2.5.11...v2.5.12) (2026-05-03)

### 🐛 Bug Fixes

* **secondary_dns:** moved raw-block explainer outside the raw block ([53f471b](https://github.com/bauer-group/IAC-Ansible/commit/53f471b237ef7a9b0d8a5ddf19903b5e7746a8dc))

## [2.5.11](https://github.com/bauer-group/IAC-Ansible/compare/v2.5.10...v2.5.11) (2026-05-03)

### 🐛 Bug Fixes

* **secondary_dns:** wrapped dns-admin bash body in jinja raw block ([306ea2b](https://github.com/bauer-group/IAC-Ansible/commit/306ea2b67090044d7205d6e9d9e0ec9c57c18dfa))

## [2.5.10](https://github.com/bauer-group/IAC-Ansible/compare/v2.5.9...v2.5.10) (2026-05-03)

### 🐛 Bug Fixes

* **secondary_dns:** satisfied var-naming role-prefix lint rule ([9c543a4](https://github.com/bauer-group/IAC-Ansible/commit/9c543a44a925333e15bdb7b2cd053a7d6becafae))

## [2.5.9](https://github.com/bauer-group/IAC-Ansible/compare/v2.5.8...v2.5.9) (2026-05-03)

### 🐛 Bug Fixes

* **secondary_dns:** used unsafe_writes for /etc/resolv.conf rewrite ([d5fb970](https://github.com/bauer-group/IAC-Ansible/commit/d5fb9701fd39c2a9b751e08c3a7f1729f7c6adbb))

## [2.5.8](https://github.com/bauer-group/IAC-Ansible/compare/v2.5.7...v2.5.8) (2026-05-03)

### 🐛 Bug Fixes

* **secondary_dns:** corrected molecule ANSIBLE_ROLES_PATH off-by-one ([c4b6dda](https://github.com/bauer-group/IAC-Ansible/commit/c4b6dda5f832d1d96fb5dd7268d13c44b4a7ba5f))

## [2.5.7](https://github.com/bauer-group/IAC-Ansible/compare/v2.5.6...v2.5.7) (2026-05-03)

### ⏪ Reverts

* **ci:** rolled molecule back to github-hosted runners + restored rocky ([2163b00](https://github.com/bauer-group/IAC-Ansible/commit/2163b00f98dbf76425dec584da18db0d9eb84804))

## [2.5.6](https://github.com/bauer-group/IAC-Ansible/compare/v2.5.5...v2.5.6) (2026-05-03)

### 🐛 Bug Fixes

* **workflow:** moved ANSIBLE_REMOTE_TMP to /var/tmp to bypass tmpfs pressure ([9e0a586](https://github.com/bauer-group/IAC-Ansible/commit/9e0a58657322b6f786ddb0e60c9cf57f565faf74))
* **workflow:** pinned ANSIBLE_REMOTE_TMP to /tmp for self-hosted runner ([5c04725](https://github.com/bauer-group/IAC-Ansible/commit/5c047253c1b77e5c13defb9efc1a3843b759d0be))
* **workflow:** update ANSIBLE_REMOTE_TMP path to /tmp/.ansible ([d293d2e](https://github.com/bauer-group/IAC-Ansible/commit/d293d2e127c7b846e8dea151216a8b1637e8e9e5))

## [2.5.5](https://github.com/bauer-group/IAC-Ansible/compare/v2.5.4...v2.5.5) (2026-05-03)

### 🐛 Bug Fixes

* **molecule-test:** correct syntax for runs-on attribute in workflow ([5f37265](https://github.com/bauer-group/IAC-Ansible/commit/5f37265b55d2a26aeaf42d4a29261083d8a4c998))
* **workflow:** update Python version from 3.12 to 3.14 in molecule test setup ([ebcf833](https://github.com/bauer-group/IAC-Ansible/commit/ebcf83387e5835d9143592e914cb4c6d05377f32))
* **workflow:** update Python version from 3.14 to 3.12 in molecule test setup ([91d5fd1](https://github.com/bauer-group/IAC-Ansible/commit/91d5fd194ba40fba891ef5d760f19e96bd4ab201))

## [2.5.4](https://github.com/bauer-group/IAC-Ansible/compare/v2.5.3...v2.5.4) (2026-05-03)

### 🐛 Bug Fixes

* **common:** added apt retry to fail2ban install for archive resilience ([59758ef](https://github.com/bauer-group/IAC-Ansible/commit/59758ef7cd76e66672797da3b386fe95249df504))
* **molecule-test:** update runner to self-hosted Linux environment ([c8147ef](https://github.com/bauer-group/IAC-Ansible/commit/c8147ef957b2c3fd42d4b89e692c7fc288d61bef))

## [2.5.3](https://github.com/bauer-group/IAC-Ansible/compare/v2.5.2...v2.5.3) (2026-05-02)

### 🐛 Bug Fixes

* **ansible_pull:** hardened apt cache retries against launchpad mirror flakes ([5bd82be](https://github.com/bauer-group/IAC-Ansible/commit/5bd82beff486d11211ad94a466a5ac3f4e268522))

## [2.5.2](https://github.com/bauer-group/IAC-Ansible/compare/v2.5.1...v2.5.2) (2026-05-02)

### 🐛 Bug Fixes

* **common:** pinned recidive jail to systemd backend for cross-platform reliability ([5339ca0](https://github.com/bauer-group/IAC-Ansible/commit/5339ca072349a6ec33281fff894cb93249d68e94))

## [2.5.1](https://github.com/bauer-group/IAC-Ansible/compare/v2.5.0...v2.5.1) (2026-05-02)

### 🐛 Bug Fixes

* **secondary_dns:** satisfied ansible-lint no-changed-when in strict mode ([2006e97](https://github.com/bauer-group/IAC-Ansible/commit/2006e97b44dded017dcaea470fff02bd2a95febc))

## [2.5.0](https://github.com/bauer-group/IAC-Ansible/compare/v2.4.2...v2.5.0) (2026-05-02)

### 🚀 Features

* **common:** added fail2ban recidive jail to baseline ([ebfde3b](https://github.com/bauer-group/IAC-Ansible/commit/ebfde3b47a50a7cc213959b0d73d2d5f1e8efcbd))
* **secondary_dns:** added PowerDNS authoritative secondary role ([df1f6ea](https://github.com/bauer-group/IAC-Ansible/commit/df1f6eabd9821554f487544ceb33c3c51c60bb55))

## [2.4.2](https://github.com/bauer-group/IAC-Ansible/compare/v2.4.1...v2.4.2) (2026-04-19)

### 🐛 Bug Fixes

* **common:** moved legacy PPA purge before first apt cache update ([b821372](https://github.com/bauer-group/IAC-Ansible/commit/b82137211d166340ad67d3092ca83e671a919300))

## [2.4.1](https://github.com/bauer-group/IAC-Ansible/compare/v2.4.0...v2.4.1) (2026-04-19)

### 🐛 Bug Fixes

* **ansible_pull:** resolved apt Signed-By conflict on Ubuntu PPA ([6250a88](https://github.com/bauer-group/IAC-Ansible/commit/6250a88d1c7b637ff96640ae0e3d6d9c8558ea91))

## [2.4.0](https://github.com/bauer-group/IAC-Ansible/compare/v2.3.1...v2.4.0) (2026-04-19)

### 🚀 Features

* **inventory:** added 5-node staging k0s cluster (overlay mode) ([a950325](https://github.com/bauer-group/IAC-Ansible/commit/a9503259b1a88e839f79883ac7bd2807193aec54))
* **k0s:** added k0s role with vlan and overlay network modes ([c6d254b](https://github.com/bauer-group/IAC-Ansible/commit/c6d254b41338db8c86cacaf76d17ff918bcddc99))
* **playbooks:** integrated k0s as Phase 7 with multi-cluster topology ([5f053e8](https://github.com/bauer-group/IAC-Ansible/commit/5f053e80ff21773a35a3772764217827c2f8f4bd))

### 🐛 Bug Fixes

* **k0s:** added pipefail to WireGuard keypair shell task ([b02afe0](https://github.com/bauer-group/IAC-Ansible/commit/b02afe0319510cae4904c1d59156716220333531))
* **k0s:** bash-executable for pipefail, test-mode-safe handlers ([2c0028f](https://github.com/bauer-group/IAC-Ansible/commit/2c0028fad19501da01a74df287401e626a1521c5))
* **k0s:** pre-create /etc/modules-load.d and /etc/sysctl.d ([f5823b1](https://github.com/bauer-group/IAC-Ansible/commit/f5823b1adba09e4fd3308b107b507a39834f2df9))
* **k0s:** refresh apt cache before installing preflight packages ([82e0b19](https://github.com/bauer-group/IAC-Ansible/commit/82e0b19ccf863604eb112b37f6c23bdcc4237561))
* **k0s:** removed meta-deps on common and secrets roles ([26311f9](https://github.com/bauer-group/IAC-Ansible/commit/26311f9dc3efaccd8687b61c7f1593b9e50df8e8))
* **k0s:** skipped cross-host bootstrap uniqueness assert in test mode ([666297e](https://github.com/bauer-group/IAC-Ansible/commit/666297e033816ece84e08ad49a72f0971d249b20))
* **k0s:** three molecule blockers (fstab, netplan dir, alternatives idempotency) ([dadbb84](https://github.com/bauer-group/IAC-Ansible/commit/dadbb847ef534d93c58ce67bbc0635ff37d85764))
* **roles:** shortened apt cache_valid_time to recover from stale-cache images ([4b6d3ba](https://github.com/bauer-group/IAC-Ansible/commit/4b6d3ba38f7bbb7a3065c0cda6b291b10230dfa4))

### ♻️ Refactoring

* **staging:** switched k0s test cluster to Ubuntu 24.04 LTS (HWE) ([48e5378](https://github.com/bauer-group/IAC-Ansible/commit/48e5378712a43b89290e4c9b6082d3d7d937a383))

## [2.3.1](https://github.com/bauer-group/IAC-Ansible/compare/v2.3.0...v2.3.1) (2026-04-18)

### 🐛 Bug Fixes

* **common:** added tzdata to Debian/Ubuntu common_packages ([c897c13](https://github.com/bauer-group/IAC-Ansible/commit/c897c13bba93a97681b53d86530df5515f58e063))

## [2.3.0](https://github.com/bauer-group/IAC-Ansible/compare/v2.2.8...v2.3.0) (2026-04-18)

### 🚀 Features

* **platform:** added Ubuntu 22.04 Molecule coverage + legacy-var pre-flight ([834e438](https://github.com/bauer-group/IAC-Ansible/commit/834e438682c1a77b09e63fd671fdbec0136cc4eb))

## [2.2.8](https://github.com/bauer-group/IAC-Ansible/compare/v2.2.7...v2.2.8) (2026-04-18)

### 🐛 Bug Fixes

* **molecule:** unified docker-ce presence check via package_facts ([7639771](https://github.com/bauer-group/IAC-Ansible/commit/763977101d6b2d7950bf76816b2a53ccf38f7663))

## [2.2.7](https://github.com/bauer-group/IAC-Ansible/compare/v2.2.6...v2.2.7) (2026-04-18)

### 🐛 Bug Fixes

* **molecule:** OS-family-aware docker package verification ([60136b8](https://github.com/bauer-group/IAC-Ansible/commit/60136b860a9de9e76b69f544137151afbe07cc03))

## [2.2.6](https://github.com/bauer-group/IAC-Ansible/compare/v2.2.5...v2.2.6) (2026-04-18)

### 🐛 Bug Fixes

* **docker:** silenced Rocky 10 RPM idempotence false-positive ([3fb9cbe](https://github.com/bauer-group/IAC-Ansible/commit/3fb9cbe92339d12ed98e0d23ba78f9c48ea127ed))

## [2.2.5](https://github.com/bauer-group/IAC-Ansible/compare/v2.2.4...v2.2.5) (2026-04-18)

### 🐛 Bug Fixes

* **docker:** idempotent RHEL Docker install via package_facts gate ([603c8a9](https://github.com/bauer-group/IAC-Ansible/commit/603c8a9ffab26d688279c6b3ed7acce7866439c2))

## [2.2.4](https://github.com/bauer-group/IAC-Ansible/compare/v2.2.3...v2.2.4) (2026-04-18)

### 🐛 Bug Fixes

* **roles:** resolved RHEL docker idempotence + PPA-key download idempotence ([84a995c](https://github.com/bauer-group/IAC-Ansible/commit/84a995c31db4dad681805d3b718479d7686d941a))

## [2.2.3](https://github.com/bauer-group/IAC-Ansible/compare/v2.2.2...v2.2.3) (2026-04-18)

### 🐛 Bug Fixes

* **roles:** EL-aware sysctl.d + MOTD path in verify ([5bf0887](https://github.com/bauer-group/IAC-Ansible/commit/5bf08879f7592a7795f7500ca87840daa46b14e5))

## [2.2.2](https://github.com/bauer-group/IAC-Ansible/compare/v2.2.1...v2.2.2) (2026-04-18)

### 🐛 Bug Fixes

* **roles:** addressed EL 9/10 package-management specifics ([130810a](https://github.com/bauer-group/IAC-Ansible/commit/130810adf0ce330e508c47285f14d0594ec92297))

## [2.2.1](https://github.com/bauer-group/IAC-Ansible/compare/v2.2.0...v2.2.1) (2026-04-18)

### 🐛 Bug Fixes

* **molecule:** switched become_method to su for Rocky/RHEL containers ([1728058](https://github.com/bauer-group/IAC-Ansible/commit/17280584d50016cf7b098e70d0945fa40036d6e8))

## [2.2.0](https://github.com/bauer-group/IAC-Ansible/compare/v2.1.2...v2.2.0) (2026-04-18)

### 🚀 Features

* **platform:** dropped EL 8 (EOL), added Molecule + path-aware chrony for EL 9+10 ([9ede37d](https://github.com/bauer-group/IAC-Ansible/commit/9ede37d3c48fe51e104a1989a5f073b7d85cb36d))

## [2.1.2](https://github.com/bauer-group/IAC-Ansible/compare/v2.1.1...v2.1.2) (2026-04-17)

### ♻️ Refactoring

* **common:** migrated NTP config to drop-in pattern (chrony + timesyncd) ([234dd33](https://github.com/bauer-group/IAC-Ansible/commit/234dd33cdb1c9868a04c5ebc90d87469ddc591aa))

## [2.1.1](https://github.com/bauer-group/IAC-Ansible/compare/v2.1.0...v2.1.1) (2026-04-17)

### 🐛 Bug Fixes

* **common:** added locales package to Debian/Ubuntu common_packages ([a6328c0](https://github.com/bauer-group/IAC-Ansible/commit/a6328c0a9aa12725b09f600f0943c91b5fe51247))

## [2.1.0](https://github.com/bauer-group/IAC-Ansible/compare/v2.0.11...v2.1.0) (2026-04-17)

### 🚀 Features

* **platform:** dropped Debian 12, added Debian 13 Molecule coverage ([201733b](https://github.com/bauer-group/IAC-Ansible/commit/201733b0bff1d788ae5545a4d3dcb4a486da2280))

## [2.0.11](https://github.com/bauer-group/IAC-Ansible/compare/v2.0.10...v2.0.11) (2026-04-17)

### 🐛 Bug Fixes

* **ansible_pull:** extended PPA usage to Ubuntu 24.04 (noble) ([c3b93cc](https://github.com/bauer-group/IAC-Ansible/commit/c3b93cc5b4cead3a4d5e6c0e0e3dd290e28de350))

## [2.0.10](https://github.com/bauer-group/IAC-Ansible/compare/v2.0.9...v2.0.10) (2026-04-17)

### 🐛 Bug Fixes

* **molecule:** removed stale auto_update statusmon-dir verify check ([bd6485a](https://github.com/bauer-group/IAC-Ansible/commit/bd6485af5d4492d1c3c4802ca1898215e3fcff83))

## [2.0.9](https://github.com/bauer-group/IAC-Ansible/compare/v2.0.8...v2.0.9) (2026-04-17)

### 🐛 Bug Fixes

* **molecule:** corrected auto_update verify paths ([d80676c](https://github.com/bauer-group/IAC-Ansible/commit/d80676c47ff7c74ed2e50b4564eead5b22f8e66c))

## [2.0.8](https://github.com/bauer-group/IAC-Ansible/compare/v2.0.7...v2.0.8) (2026-04-17)

### 🐛 Bug Fixes

* **molecule:** disabled NTP in common/auto_update converge tests ([426c5bf](https://github.com/bauer-group/IAC-Ansible/commit/426c5bff642343140e984590e7a449ad5aa970b7))

## [2.0.7](https://github.com/bauer-group/IAC-Ansible/compare/v2.0.6...v2.0.7) (2026-04-17)

### 🐛 Bug Fixes

* **common:** guarded resolved.conf deploy + handler on service presence ([50c2e58](https://github.com/bauer-group/IAC-Ansible/commit/50c2e58ccd3ec61540b73c6bc3ed7fcbed1285a0))

## [2.0.6](https://github.com/bauer-group/IAC-Ansible/compare/v2.0.5...v2.0.6) (2026-04-16)

### 🐛 Bug Fixes

* **roles:** resolved MOTD template + docker cron prereq ([75ca555](https://github.com/bauer-group/IAC-Ansible/commit/75ca5558b755e83fa4dee0fd3d801d33f6fbc6ef))

## [2.0.5](https://github.com/bauer-group/IAC-Ansible/compare/v2.0.4...v2.0.5) (2026-04-16)

### 🐛 Bug Fixes

* **molecule:** addressed remaining container-test failures ([e6c6ffc](https://github.com/bauer-group/IAC-Ansible/commit/e6c6ffcd017c8031eda1414826cbd27afbf374a2))

## [2.0.4](https://github.com/bauer-group/IAC-Ansible/compare/v2.0.3...v2.0.4) (2026-04-16)

### 🐛 Bug Fixes

* **ci:** resolved molecule container-specific test failures ([4baf576](https://github.com/bauer-group/IAC-Ansible/commit/4baf57666fab61735e0e84c8596175dbf099189c))

## [2.0.3](https://github.com/bauer-group/IAC-Ansible/compare/v2.0.2...v2.0.3) (2026-04-16)

### 🐛 Bug Fixes

* **molecule:** resolved local roles via ANSIBLE_ROLES_PATH ([aa42ca1](https://github.com/bauer-group/IAC-Ansible/commit/aa42ca1f45b2eeb954a9e60e8265cec43e4176ac))

## [2.0.2](https://github.com/bauer-group/IAC-Ansible/compare/v2.0.1...v2.0.2) (2026-04-16)

### 🐛 Bug Fixes

* **molecule:** used fully-qualified role names in converge playbooks ([5fde7b9](https://github.com/bauer-group/IAC-Ansible/commit/5fde7b981ffc055bc9f444ea39b4675ee93c7142))

## [2.0.1](https://github.com/bauer-group/IAC-Ansible/compare/v2.0.0...v2.0.1) (2026-04-16)

### 🐛 Bug Fixes

* **deps:** upgraded molecule-plugins to 25.x for ansible-core 2.20 compat ([730d826](https://github.com/bauer-group/IAC-Ansible/commit/730d826d7b2947d62bf5b22bae5d7e1266b436ba))

## [2.0.0](https://github.com/bauer-group/IAC-Ansible/compare/v1.4.0...v2.0.0) (2026-04-16)

### ⚠ BREAKING CHANGES

* **secrets:** Users mit vault_* in ihrer secrets.yml oder
hashicorp_vault_* in secrets_config.yml müssen migrieren — siehe
Migration-Schritte oben.

### 🐛 Bug Fixes

* **ci:** resolved accumulated molecule and lint errors ([8c62c08](https://github.com/bauer-group/IAC-Ansible/commit/8c62c083371c422c7e0efa752cd742da4957115e))

### ♻️ Refactoring

* **secrets:** renamed public API vars to use secrets_ prefix ([44ad1f8](https://github.com/bauer-group/IAC-Ansible/commit/44ad1f8b9c4590b2cd9e867e49071cea04e3c300))

## [1.4.0](https://github.com/bauer-group/IAC-Ansible/compare/v1.3.12...v1.4.0) (2026-04-16)

### 🚀 Features

* **platform:** added Ubuntu 26.04 LTS (Resolute) support ([7dda958](https://github.com/bauer-group/IAC-Ansible/commit/7dda958f51bee0db280c63a522c258e1c4748791))
* **secrets:** added switchable secrets backend (Ansible Vault / HashiCorp Vault) ([bfda69a](https://github.com/bauer-group/IAC-Ansible/commit/bfda69a379ee835f0605667af0de5f4c81bd5297))

### 🐛 Bug Fixes

* **common:** improved IPv6 detection in MOTD banner ([7a93c1c](https://github.com/bauer-group/IAC-Ansible/commit/7a93c1c75b1de9649b1baf486494f0bbd917cc86))

## [1.3.12](https://github.com/bauer-group/IAC-Ansible/compare/v1.3.11...v1.3.12) (2026-04-12)

### 🐛 Bug Fixes

* **common:** added fallback defaults for renamed global variables ([ef1dba3](https://github.com/bauer-group/IAC-Ansible/commit/ef1dba3698bbd262da06e405bb29b9ccf8a19d38))

## [1.3.11](https://github.com/bauer-group/IAC-Ansible/compare/v1.3.10...v1.3.11) (2026-04-12)

### 🐛 Bug Fixes

* **lint:** renamed variable to use role prefix ([5dd592c](https://github.com/bauer-group/IAC-Ansible/commit/5dd592c9d9093d87f7452bcca4a4788b56fdb06d))

### ♻️ Refactoring

* **common:** resolved 16 audit findings (H1-H4, M1-M7, L2-L3) ([4b4dc33](https://github.com/bauer-group/IAC-Ansible/commit/4b4dc33cbb6be63efd26a19cb0bfa7718e5afc13))

## [1.3.10](https://github.com/bauer-group/IAC-Ansible/compare/v1.3.9...v1.3.10) (2026-04-12)

### 🐛 Bug Fixes

* **docker:** replaced ip6tables with iptables package ([2696a29](https://github.com/bauer-group/IAC-Ansible/commit/2696a297259e329995a445a15eb0dafc22992867))

## [1.3.9](https://github.com/bauer-group/IAC-Ansible/compare/v1.3.8...v1.3.9) (2026-04-12)

### 🐛 Bug Fixes

* **config:** separated production and staging inventory loading ([ecb10e8](https://github.com/bauer-group/IAC-Ansible/commit/ecb10e85b878bb0c6271da4472bb833074c64f45))

## [1.3.8](https://github.com/bauer-group/IAC-Ansible/compare/v1.3.7...v1.3.8) (2026-04-12)

### 🐛 Bug Fixes

* **inventory:** pinned iac_repo_branch=main for production hosts ([5b5bc3b](https://github.com/bauer-group/IAC-Ansible/commit/5b5bc3b320c58d4126e93a9dab879c8793c77441))

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
