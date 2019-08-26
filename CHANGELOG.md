# Change Log
All notable changes to this project will be documented in this file.
This project adheres to [Semantic Versioning](http://semver.org/).


## [Unreleased]

### Added

- Nothing

### Changed

- Nothing

### Fixed

- Nothing


## [0.3.4] - 2019-08-26

### Changed

- Add support for AR 6.x
- Drop support for Ruby < 2.4


## [0.3.3] - 2017-05-11

### Changed

- Add support for AR 5.1.x
- Drop support for AR 4.0.x
- Drop support for Ruby < 2.2


## [0.3.2] - 2016-12-23

### Changed

- Call `before_action` on included class if exists
- Add support for AR 5.0.x
- Drop support for AR 3.x
- Drop support for Ruby < 2.1

### Fixed

- Raise error if both `before_action` and `before_filter` does not exists


## [0.3.1] - 2015-03-03

### Fixed

- Fix session key still gets deleted when no option is set
- Fix options not passed to `#set_session` when `#set_session_with_expiry` is called


## [0.3.0] - 2014-03-14

### Added

- Add method `#set_session_with_expiry`
- Add option `expires_in` and `expires_at` to #set_session

### Changed

- Raise error when reserved session key(s) is set through the provided method

### Fixed

- Fix invalid header when using `#set_no_cache` for HTTP 1.0


## [0.2.0] - 2014-01-17

### Added

- Add option `expire_at` to #set_session


## 0.1 - 2013-08-30

### Added

- Initial Release


[Unreleased]: https://github.com/PikachuEXE/action_controller_tweaks/compare/v0.3.3...HEAD
[0.3.3]: https://github.com/PikachuEXE/action_controller_tweaks/compare/v0.3.2...v0.3.3
[0.3.2]: https://github.com/PikachuEXE/action_controller_tweaks/compare/v0.3.1...v0.3.2
[0.3.1]: https://github.com/PikachuEXE/action_controller_tweaks/compare/v0.3.0...v0.3.1
[0.3.0]: https://github.com/PikachuEXE/action_controller_tweaks/compare/v0.2.0...v0.3.0
[0.2.0]: https://github.com/PikachuEXE/action_controller_tweaks/compare/v0.1...v0.2.0

