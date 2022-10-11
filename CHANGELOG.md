## [Unreleased]

## [2.2.0] - 2022-10-11

### Changed

- automatic json response decoding, and remove legacy token support by @nov in https://github.com/nov/rack-oauth2/pull/95

## [2.1.0] - 2022-10-10

### Added

- accept local_http_config on Rack::OAuth2::Client#access_token! & revoke!  to support custom headers etc. by @nov in https://github.com/nov/rack-oauth2/pull/93

## [2.0.1] - 2022-10-09

### Fixed

- changes for mTLS on faraday by @nov in https://github.com/nov/rack-oauth2/pull/92

## [2.0.0] - 2022-10-09

### Added

- start recording CHANGELOG

### Changed

- Switch from httpclient to faraday v2 https://github.com/nov/rack-oauth2/pull/91
- make url-encoded the default https://github.com/nov/rack-oauth2/commit/98faf139be4f5bf9ec6134d31f65a298259d8a8b
- let faraday encode params https://github.com/nov/rack-oauth2/commit/f399b3afb8facb3635b8842baee8584bc4d3ce73