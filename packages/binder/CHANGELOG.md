# Change Log

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.3.1]
### Fixed
- Issue when watching a computed which uses an overriden ref of ref.
- Flutter upper bound.

## [0.3.0]
### Fixed
- Issue when watching a computed which uses an overriden ref multiple times.

## [0.2.3]
### Fixed
- Issue when modifying state from a child scope.

## [0.2.2]
### Added
- `LogicLoader` to asynchronoulsy load data from your logic when this widget is inserted into the tree.

## [0.2.1]
### Modified
- `BuildContext.read()` can be called with any watchable, not only a `StateRef`.

## [0.2.0]
### Added
- `Consumer` widget used to watch one watchable.

### Modified
- `Watchable` has now only one generic type.

## [0.1.5] 
### Modified
- Only calls `Aspect.shouldRebuild` when necessary.

## [0.1.4] 
### Fixed
- `flutter analyze` issue.

## [0.1.3] 
### Fixed
- Memory leak issue when using `select`.

## [0.1.2] 
### Added
- Test coverage badge.

## [0.1.1] 
### Fixed
- Broken image links in README.

## [0.1.0] 
### Added
- Initial release.

[Unreleased]: https://github.com/letsar/binder/compare/v0.3.1...HEAD
[0.3.1]: https://github.com/letsar/binder/compare/releases/tag/v0.3.1
[0.3.0]: https://github.com/letsar/binder/compare/releases/tag/v0.3.0
[0.2.3]: https://github.com/letsar/binder/compare/releases/tag/v0.2.3
[0.2.2]: https://github.com/letsar/binder/compare/releases/tag/v0.2.2
[0.2.1]: https://github.com/letsar/binder/compare/releases/tag/v0.2.1
[0.2.0]: https://github.com/letsar/binder/compare/releases/tag/v0.2.0
[0.1.5]: https://github.com/letsar/binder/compare/releases/tag/v0.1.5
[0.1.4]: https://github.com/letsar/binder/compare/releases/tag/v0.1.4
[0.1.3]: https://github.com/letsar/binder/compare/releases/tag/v0.1.3
[0.1.2]: https://github.com/letsar/binder/compare/releases/tag/v0.1.2
[0.1.1]: https://github.com/letsar/binder/compare/releases/tag/v0.1.1
[0.1.0]: https://github.com/letsar/binder/compare/releases/tag/v0.1.0
