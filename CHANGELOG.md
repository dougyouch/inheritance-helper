# Changelog

## [0.3.0](https://github.com/dougyouch/inheritance-helper/compare/v0.2.6...v0.3.0) (2026-10-05)


### ⚠ BREAKING CHANGES

* **class-builder:** get_class_name no longer calls String#classify when ActiveSupport is loaded, so names are no longer singularized there (:line_items now gives LineItems, not LineItem). Class names are now the same whether or not ActiveSupport is loaded.
* **gem:** requires Ruby 3.3. Ruby 3.2 reached end of life in March 2026 and is no longer supported.

### Features

* **class-builder:** build class names the same way with or without activesupport ([#5](https://github.com/dougyouch/inheritance-helper/issues/5)) ([11bb5a8](https://github.com/dougyouch/inheritance-helper/commit/11bb5a8d056d7b6c2794895bd01c9d9bce14805d))
* **methods:** raise a TypeError naming the class method when it returns nil ([#5](https://github.com/dougyouch/inheritance-helper/issues/5)) ([11bb5a8](https://github.com/dougyouch/inheritance-helper/commit/11bb5a8d056d7b6c2794895bd01c9d9bce14805d))

## [0.2.6](https://github.com/dougyouch/inheritance-helper/compare/v0.2.5...v0.2.6) (2026-10-05)


### Bug Fixes

* **class-builder:** handle repeated and trailing underscores in class names ([92488f2](https://github.com/dougyouch/inheritance-helper/commit/92488f260e9da03693745c46c9064cafb1f2159f))
* **methods:** keep the visibility of redefined class methods ([5cd1f79](https://github.com/dougyouch/inheritance-helper/commit/5cd1f79529de471c27249a163b6de66cc45d9453))
