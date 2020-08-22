# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to
[Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.2.2] - 2020-08-22

### Added

- Make app installable as a PWA with icon files for Android & iOS.

## [0.2.1] - 2020-08-08

### Added

- Prevent double-tap zoom on touch devices. Pressing the buttons too quickly was
  causing zooming, not game actions.

## [0.2.0] - 2020-08-08

### Breaking

- Include a service worker which caches the game and serves cache-first with
  network fallback afterwards

### Added

- Started a CHANGELOG
