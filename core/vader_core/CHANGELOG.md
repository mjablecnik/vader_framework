# Changelog

All notable changes to this project will be documented in this file.


<!-- ## [Unreleased] - 2025-02-26 -->


## [Unreleased] - 2025-02-26
### Breaking Changes
- Renamed `BaseEntity` to `VaderEntity`.
- Removed `Injector` as a global singleton.


## [0.3.0]
### Added
- Created `Injector` as a wrapper around `AutoInjector`.


## [0.2.0]
### Added
- Implemented cache client for results after performant processes.
- Added cache for `HttpClient`.
- Updated `LogLevel` in `Logger`.

### Changed
- Replaced `flutter_secure_storage` with `hive_ce`.
- Renamed `SecureStorage` to `StorageClient`.


## [0.1.0]
### Added
- Introduced `HttpClient`.
- Implemented `Logger`.
- Added `SecureStorage`.
- Created `Repository`.
- Integrated `AutoInjector`.
- Defined `Exceptions`.
- Added `BaseEntity`.
