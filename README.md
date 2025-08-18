# Repoinit
`repoinit` provides tooling and configuration for packaging software into either **RPMs** or **bootable ISOs**, with built-in support for uploading generated artifacts to a `https://repo.redborder.com`.  
It is intended for developers who need a repeatable and configurable way to build and distribute system images or packages.

## ⚠️ Important considerations
  - `repo.redborder.com` is on deprecation. We normally use `packages.redborder.com`.
  - Developers can access to `rbrepo.redbordersc.lan`.
  - `rbrepo` and `rbrepo-devel` are on deprecation. We can use `https://github.com/redBorder/redborder-repo`, which points to `packages.redborder.com`.

## Features
- Build **RPM packages** or full **ISO images**.
- Architecture-aware configuration (x86, ARM, etc.).
- Modular structure for extending and customizing builds.
- Ready-to-use Kickstart and repo configs.
- Automated upload to the web server after build.

## 📂 Repository Structure
- **`*.sh` scripts** → Main entry points for building packages and ISOs.
  - `build_common.sh` – shared helpers used across other scripts.
  - `build_minimal_structure.sh` – sets up the minimal directory structure for builds.
  - `build_module.sh` – builds individual modules/packages.
  - `make_isofile.sh` – generates a bootable ISO image.
- **Config files**:
  - `sdk7.cfg` – Config file for running mock for a Centos 7
  - `sdk9.cfg` – Config file for running mock for a Rocky 9
  - `.repoinit_project`, `.sdk7_project` – SDK and repo definitions per architecture.
  - `ks-base.cfg`, `isolinux-base.cfg` – Kickstart and bootloader configurations for ISOs.
  - `rbrepo.cfg`, `rbrepo.repo` – repository definitions.
- **`modules/`** – source modules available for packaging.
- **`projects/IPS/`** – example project layout.
- **`Jenkinsfile`** – CI/CD integration.
- **`splash.png`** – boot splash for generated ISOs.

## Requirements
- A **Red Hat–based operating system** (CentOS, RHEL, Rocky Linux, AlmaLinux, etc.) is expected as the build environment.
- Basic development and packaging tools must be installed:
```bash
yum install -y epel-release mock
```

## Usage
### 1. Clone the repository
```bash
git clone https://github.com/redBorder/repoinit.git
cd repoinit
```

### 2. Select the script for your task
To build a minimal build structure:
```bash
./build_minimal_structure.sh
To build a module/package:
```

To build just one of the directories:
```bash
./build_module.sh <module-name>
```

To create an ISO image:
```bash
./make_isofile.sh
```

To build a full release (RPMs + ISO), run the appropriate script for your architecture and configuration.

### 3. Upload
By default, generated packages/ISOs are uploaded to the configured `repo.redborder.com`.

## 👩‍💻 Intended Audience
This project is meant for:

- Developers working on packaging modules and systems.
- Release supervisors responsible for generating and publishing official RPM/ISO releases.
- External contributors

## 🔍 Please, review these links:

http://www.smorgasbork.com/2014/07/16/building-a-custom-centos-7-kickstart-disc-part-1/
http://kfei.logdown.com/posts/143152-build-your-own-customized-install-disc-from-centos-64
https://fedoraproject.org/wiki/QA:Testcase_Kickstart_File_Path_Ks_Cfg
https://access.redhat.com/documentation/en-US/Red_Hat_Enterprise_Linux/7/html/Installation_Guide/chap-anaconda-boot-options.html#list-boot-options-sources

## 🤝 Contributing

- Fork the repo
- Create a feature branch (git checkout -b feature/your-feature)
- Commit your changes
- Open a Pull Request
