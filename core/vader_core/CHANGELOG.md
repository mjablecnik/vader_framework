# Changelog

All notable changes to this project will be documented in this file.


## [Unreleased] - 2025-08-31
### Fixed
- HttpClient success status code handling.
  

## [0.5.0] - 2025-08-31
### Added
- Add get and tryGet methods to injector.
- Set use and tryUse methods to be deprecated.
  
### Fixed
- Fixed providing lazy instances.
  

## [0.4.2] - 2025-04-18
### Added
- Add simple sandbox for testing.
 

## [0.4.1] - 2025-03-17
### Fixed
- Add lazy instance into injector.

 
## [0.4.0] - 2025-03-09
### Breaking Changes
- Renamed `BaseEntity` to `VaderEntity`.
- Removed `Injector` as a global singleton.
  
### Fixed
- Fixed opening Hive box.
  
### Added
- Added logger observer.


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
