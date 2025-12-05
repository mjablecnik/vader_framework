# Changelog

All notable changes to this project will be documented in this file.

## [0.6.1] - 2025-12-05
- Remove path_provider due to Flutter dependency


## [0.6.0] - 2025-11-28
### Added
- Enhance internet connection checks in `HttpClient`.
- Add method to check internet connection in `HttpClient`.
- Add connect timeout configuration to `HttpClient`.
  
### Changed
- Simplify `HttpClient` initialization and enhance timeout handling.
- Improve HTTP client response handling.
- Update HTTP client success status code handling.

### Fixed
- HttpClient success status code handling.
- Enhance internet connection checks in `HttpClient` class.
- Enhance `HttpResponse` with error handling and update request timeout.


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
