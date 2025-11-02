# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.2.2] - 2025-10-31

### Changed

- Supplying a pesde token is now optional

### Fixed

- Pesde token being used to authenticate with github

## [0.2.1] - 2025-10-30

### Fixed

- Release CI no longer installs Rokit (tooling is managed by pesde now)

## [0.2.0] - 2025-10-30

### Changed

- New default Lune version is 0.10.4
- New default pesde version is 0.7.1
- Test CI now also runs the Lune runtime
- Bumped stylua to v2.3.0
- Bumped luau-lsp to v1.55.0
- Bumped selene v0.29.0+toolchainlib.1
- Bumped darklua to v0.17.2
- Contents of pesde packages are now ignored by auto import by default
- Contents of pesde packages and distribution folders are now read-only by default in VS Code

### Fixed

- Test CI being broken because of a package unexpectedly updating to Lune v10, because SemVer technically allows it (pesde does not care if major version is zero)
- Working directory while running tests is now actually set to the built runtime directory instead of it's parent directory

## [0.1.4] - 2025-08-31

### Fixed

- Fix command substitution in changelog `echo "Test?? should show full command and not substitue"`

## [0.1.3] - 2025-08-31

### Fixed

- Actually fixed pede.toml (and did `pesde publish --dry-run` to verify this time)

## [0.1.2] - 2025-08-31

### Fixed

- Update pesde.toml to actually include data required for publishing

## [0.1.1] - 2025-08-31

## [0.1.0] - 2025-08-31

- Initial release

[unreleased]: https://github.com/ewd3v/pesde_package_template/compare/v0.2.2...HEAD
[0.2.2]: https://github.com/ewd3v/pesde_package_template/compare/v0.2.1...v0.2.2
[0.2.1]: https://github.com/ewd3v/pesde_package_template/compare/v0.2.0...v0.2.1
[0.2.0]: https://github.com/ewd3v/pesde_package_template/compare/v0.1.4...v0.2.0
[0.1.4]: https://github.com/ewd3v/pesde_package_template/compare/v0.1.3...v0.1.4
[0.1.3]: https://github.com/ewd3v/pesde_package_template/compare/v0.1.2...v0.1.3
[0.1.2]: https://github.com/ewd3v/pesde_package_template/compare/v0.1.1...v0.1.2
[0.1.1]: https://github.com/ewd3v/pesde_package_template/compare/v0.1.0...v0.1.1
[0.1.0]: https://github.com/ewd3v/pesde_package_template/compare/1e62886861473c5c43ada9f5a7c81eeb9b9a6cfc...v0.1.0
