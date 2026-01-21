```markdown
```
<div align="center">

# VOXVAULT

### The Definitive Audio Journaling System for iOS

[![Platform](https://img.shields.io/badge/Platform-iOS%2014.0+-0A84FF?style=for-the-badge&logo=apple&logoColor=white)](https://developer.apple.com/ios/)
[![Swift](https://img.shields.io/badge/Swift-5.0-FA7343?style=for-the-badge&logo=swift&logoColor=white)](https://swift.org/)
[![Build Status](https://img.shields.io/badge/Build-Passing-34C759?style=for-the-badge&logo=github-actions&logoColor=white)](https://github.com/seraphic-syntax/VoxVault/actions)
[![License](https://img.shields.io/badge/License-Proprietary-FF3B30?style=for-the-badge&logo=lock&logoColor=white)](LICENSE)
[![Architecture](https://img.shields.io/badge/Architecture-UIKit-5856D6?style=for-the-badge&logo=xcode&logoColor=white)](https://developer.apple.com/documentation/uikit)
[![Code Quality](https://img.shields.io/badge/Code%20Quality-Production-FFD60A?style=for-the-badge&logo=codacy&logoColor=black)](https://github.com/seraphic-syntax/VoxVault)

---

**VoxVault** represents a paradigm shift in mobile audio capture technology. Engineered from the ground up with an uncompromising focus on privacy, performance, and user autonomy, this application transforms your iOS device into a sophisticated audio journaling laboratory—where every spoken word becomes a permanent, searchable, and exportable artifact of human expression.

*Your voice. Your vault. Your rules.*

---

[Features](#features) | [Architecture](#architecture) | [Installation](#installation) | [Configuration](#configuration) | [Privacy](#privacy-doctrine) | [Roadmap](#development-roadmap)

</div>

---

## Abstract

In an era where personal data has become a commodity traded on digital marketplaces, VoxVault emerges as a counterweight—a recording application that operates entirely within the confines of your device's silicon. No cloud dependencies. No analytics pipelines. No subscription models extracting value from your most intimate thoughts.

The application leverages Apple's AVFoundation framework for audio capture, the Speech framework for on-device transcription, and a meticulously crafted file management system that treats your recordings with the reverence they deserve. Whether you are documenting fleeting ideas during your morning commute, archiving lengthy lecture sessions, or simply preserving the sonic texture of a meaningful conversation, VoxVault provides the infrastructure to do so with scientific precision and delightful simplicity.

---

## Features

### Audio Capture Engine

The heart of VoxVault beats at sample rates up to 48,000 Hz, capturing the full spectrum of human vocalization with remarkable fidelity. The recording subsystem has been engineered to operate seamlessly in background execution contexts, meaning your device can slip into your pocket, its screen darkening to conserve power, while the application continues its silent vigil—capturing every word, pause, and inflection.

**Core Capabilities:**

| Capability | Technical Implementation | User Benefit |
|:-----------|:-------------------------|:-------------|
| Background Recording | `AVAudioSession` with `.playAndRecord` category and `.mixWithOthers` option | Uninterrupted capture during device lock or app switching |
| Auto-Segmentation | Timer-based file rotation with seamless audio buffer handoff | Manageable file sizes without manual intervention |
| Dynamic Quality Selection | Configurable `AVAudioRecorder` settings dictionary | Optimal balance between fidelity and storage consumption |
| Pause/Resume | Audio session state preservation with buffer continuity | Natural workflow accommodation |

The auto-segmentation system deserves particular attention. Long-form recordings—lectures spanning hours, marathon brainstorming sessions, overnight ambient captures—are automatically partitioned into discrete files at configurable intervals. This approach solves the dual problems of unwieldy file sizes and catastrophic data loss; if a recording session terminates unexpectedly, only the current segment is at risk.

### Organizational Taxonomy

A recording without context is merely noise with a timestamp. VoxVault implements a multi-dimensional organizational schema that transforms raw audio files into a navigable knowledge base.

**Hierarchical Structure:**

```bash
  Recording
      │
      ├── Metadata Layer
      │   ├── Title (user-defined or auto-generated)
      │   ├── Creation Timestamp (ISO 8601 format)
      │   ├── Duration (calculated from audio frames)
      │   └── File Size (bytes, with human-readable conversion)
      │
      ├── Taxonomic Layer
      │   ├── Categories (hierarchical groupings)
      │   ├── Tags (flat, non-exclusive labels)
      │   └── Favorite Status (boolean flag for rapid access)
      │
      └── Content Layer
          ├── Audio Data (M4A container, AAC codec)
          └── Transcription (plain text, tokenized for search)

```

The search engine operates across all textual fields simultaneously, employing substring matching algorithms that surface relevant recordings regardless of whether the query matches the title, a tag, a category name, or a phrase buried within the transcription. It is like having a librarian who has memorized the contents of every book.

### Transcription Subsystem

VoxVault harnesses the computational linguistics capabilities embedded within iOS itself. The `SFSpeechRecognizer` class performs speech-to-text conversion entirely on-device, meaning your spoken words never traverse network boundaries to reach distant servers operated by entities with opaque data retention policies.

The transcription pipeline operates asynchronously, processing audio buffers through Apple's neural speech recognition models. The resulting text is tokenized, indexed, and persisted alongside the original audio—creating a dual-representation system where recordings can be discovered through textual search but experienced in their original auditory form.

**Transcription Specifications:**

| Parameter | Value |
|:----------|:------|
| Processing Location | On-device (Neural Engine / CPU) |
| Supported Languages | System language + installed keyboard languages |
| Recognition Mode | Offline-capable (iOS 13+) |
| Output Format | Plain text with punctuation inference |

A word of caution: transcription accuracy varies with audio quality, speaker clarity, background noise levels, and the complexity of vocabulary employed. The system excels at conversational speech recorded in quiet environments but may produce creative interpretations of technical jargon or heavily accented dialogue. Such is the nature of probabilistic language models—they do their best with the information provided.

### Export Infrastructure

Data imprisoned within a single application is data at risk. VoxVault implements a comprehensive export pipeline supporting three industry-standard audio formats, each with distinct characteristics suited to different downstream use cases.

**Format Comparison Matrix:**

| Format | Container | Codec | Compression | Compatibility | Ideal Use Case |
|:-------|:----------|:------|:------------|:--------------|:---------------|
| **M4A** | MPEG-4 Part 14 | AAC | Lossy | Apple ecosystem, modern players | Default export, quality/size balance |
| **MP3** | MPEG Audio Layer III | MP3 | Lossy | Universal | Maximum compatibility |
| **WAV** | RIFF | PCM | Lossless | Professional audio software | Archival, editing workflows |

The export system integrates with iOS's native share sheet, enabling one-tap distribution through AirDrop, email, messaging applications, cloud storage services, or any third-party application that registers as an audio file handler.

### Synchronization and Persistence

For users operating within Apple's ecosystem across multiple devices, VoxVault offers optional iCloud synchronization. When enabled, recordings propagate automatically through Apple's CloudKit infrastructure to other devices authenticated with the same Apple ID.

The storage management subsystem maintains continuous awareness of disk utilization, presenting users with clear metrics regarding the cumulative footprint of their recording library. An automated cleanup daemon can be configured to purge recordings exceeding a specified age threshold—a feature designed for users who treat the application as a capture-and-process tool rather than a permanent archive.

**Storage Management Parameters:**

| Setting | Options | Default |
|:--------|:--------|:--------|
| Auto-Delete Threshold | Never / 7 days / 30 days / 90 days / 1 year | Never |
| iCloud Sync | Enabled / Disabled | Disabled |
| Storage Warnings | Configurable threshold percentage | 90% |


## Architecture

VoxVault adheres to a modular architectural philosophy, decomposing functionality into discrete manager classes with well-defined responsibilities. This separation of concerns facilitates maintainability, testability, and future extensibility.



### Directory Structure

```bash
VoxVault/
│
├── App/
│   ├── AppDelegate.swift ............... Application lifecycle orchestration
│   └── SceneDelegate.swift ............. UI scene lifecycle management
│
├── Managers/
│   ├── AudioRecordingManager.swift ..... AVAudioRecorder wrapper and configuration
│   ├── AudioPlaybackManager.swift ...... AVAudioPlayer wrapper with transport controls
│   ├── RecordingFileManager.swift ...... File system operations and path management
│   ├── RecordingMetadataManager.swift .. JSON serialization and metadata persistence
│   ├── SettingsManager.swift ........... UserDefaults wrapper for preferences
│   ├── StorageManager.swift ............ Disk space monitoring and calculations
│   ├── RecordingStateManager.swift ..... Recording state machine implementation
│   ├── PermissionManager.swift ......... Runtime permission request handling
│   ├── AutoDeleteManager.swift ......... Scheduled cleanup daemon logic
│   ├── CategoryManager.swift ........... Category CRUD operations
│   ├── TranscriptionManager.swift ...... SFSpeechRecognizer integration
│   └── iCloudSyncManager.swift ......... CloudKit synchronization logic
│
├── Models/
│   └── Models.swift .................... Core data structures (Codable conformance)
│
├── ViewControllers/
│   ├── RecordingViewController.swift ... Primary recording interface
│   ├── RecordingsListViewController.swift Library browsing and search
│   ├── RecordingDetailViewController.swift Metadata viewing and editing
│   ├── PlaybackViewController.swift .... Audio player with scrubbing
│   ├── SettingsViewController.swift .... Preference configuration UI
│   ├── TagEditorViewController.swift ... Tag management interface
│   └── TranscriptionViewController.swift Transcript display and editing
│
├── Views/
│   ├── RecordingCell.swift ............. Custom UITableViewCell for recordings
│   ├── DetailCell.swift ................ Metadata display cells
│   └── SettingCell.swift ............... Settings row cells
│
├── Utilities/
│   └── RecordingExporter.swift ......... Format conversion and share sheet integration
│
└── Resources/
    ├── Info.plist ...................... Application configuration manifest
    ├── PrivacyInfo.xcprivacy ........... Privacy nutrition label
    └── VoxVault.entitlements ........... Capability declarations
```

### Design Principles

The codebase adheres to several foundational principles that inform its structure:

**Single Responsibility Principle:** Each manager class encapsulates exactly one domain of functionality. The `AudioRecordingManager` knows nothing of file organization; the `RecordingFileManager` is blissfully ignorant of audio codecs.

**Dependency Injection:** View controllers receive manager instances rather than instantiating them directly, facilitating unit testing through mock object substitution.

**Protocol-Oriented Design:** Where appropriate, functionality is abstracted behind protocols, enabling future substitution of implementations without cascading changes through dependent code.

**Programmatic UI:** The entire interface is constructed through code rather than Interface Builder storyboards. This approach eliminates merge conflicts in XML files, enables precise control over layout mathematics, and produces interfaces that are trivially inspectable through code review.


---

## Availability

VoxVault is currently in private development. The application is not available for public distribution at this time.

For licensing inquiries or partnership opportunities, please open an issue on this repository.


---

## Configuration

### Audio Quality Profiles

VoxVault exposes three pre-configured quality profiles, each representing a deliberate tradeoff between audio fidelity and storage efficiency.

| Profile | Sample Rate | Bit Depth | Channels | Bit Rate | Minutes per GB |
|:--------|:------------|:----------|:---------|:---------|:---------------|
| **Low** | 22,050 Hz | 16-bit | Mono | 64 kbps | ~2,184 minutes |
| **Medium** | 44,100 Hz | 16-bit | Mono | 128 kbps | ~1,092 minutes |
| **High** | 48,000 Hz | 16-bit | Stereo | 256 kbps | ~546 minutes |

The "Low" profile is optimized for voice capture in controlled environments—dictation, personal notes, voice memos. The "High" profile approaches broadcast quality and is suitable for music recording, ambient soundscapes, or archival-grade documentation where storage constraints are secondary considerations.

### Segmentation Intervals

Auto-segmentation boundaries can be configured to any of the following durations:

| Interval | Use Case |
|:---------|:---------|
| 5 minutes | Short-form notes, quick captures |
| 10 minutes | Meeting segments, podcast chapters |
| 15 minutes | Lecture portions, interview segments |
| 30 minutes | Extended recordings with moderate chunking |
| 1 hour | Long-form content with minimal segmentation |
| Disabled | Continuous recording without automatic splits |

### Data Retention Policy

The auto-delete daemon supports the following retention windows:

| Policy | Behavior |
|:-------|:---------|
| Never | Recordings persist indefinitely |
| 7 days | Recordings older than one week are purged |
| 30 days | Recordings older than one month are purged |
| 90 days | Recordings older than one quarter are purged |
| 1 year | Recordings older than one year are purged |

Deletion operations are non-recoverable. Recordings flagged as favorites are exempt from automatic deletion regardless of age.

---

## Privacy Doctrine

VoxVault operates under a strict privacy-first philosophy. The following table enumerates what the application does and does not do with your data:

| Activity | Status | Explanation |
|:---------|:-------|:------------|
| Network transmission of recordings | **Never** | Audio data does not leave your device |
| Analytics collection | **Never** | No usage tracking, crash reporting, or telemetry |
| User account requirements | **None** | The application functions without any authentication |
| Server-side processing | **None** | All computation occurs on-device |
| Advertising | **None** | No ads, no ad SDKs, no tracking pixels |
| Third-party SDK integration | **Minimal** | Only Apple frameworks are employed |
| Transcription processing location | **On-device** | Speech recognition uses local Neural Engine |
| iCloud synchronization | **Optional** | User-initiated, uses personal iCloud storage |

### Permission Requirements

| Permission | Trigger | Consequence of Denial |
|:-----------|:--------|:----------------------|
| Microphone | First recording attempt | Application cannot capture audio |
| Speech Recognition | First transcription attempt | Transcription feature disabled |

Both permissions can be modified at any time through iOS Settings.

---

## Development Roadmap

### Version 1.0 (Current) 
[![Build VoxVault](https://github.com/seraphic-syntax/VoxVault/actions/workflows/build.yml/badge.svg)](https://github.com/seraphic-syntax/VoxVault/actions/workflows/build.yml)

The inaugural release establishes the foundational feature set:

- Background-capable audio recording engine
- Configurable auto-segmentation system
- Three-tier audio quality selection
- Tag and category organizational system
- On-device speech transcription
- Multi-format export pipeline (M4A, MP3, WAV)
- Optional iCloud synchronization
- Automated storage management
- Full-text search across all metadata and transcriptions

---

## Known Limitations

**Transcription Accuracy:** Speech recognition performance varies with audio quality, speaker characteristics, background noise, and vocabulary complexity. Technical terminology and proper nouns may require manual correction.

**Long Recording Load Times:** Recordings exceeding two hours in duration may exhibit brief delays during initial load due to audio buffer allocation requirements.

**iCloud Sync Latency:** Large recordings may require several minutes to propagate through iCloud infrastructure, particularly on constrained network connections.

**Background Recording on Older Devices:** Devices with limited RAM may experience occasional background task termination under memory pressure conditions.

---

## Technical Specifications

| Specification | Value |
|:--------------|:------|
| Minimum iOS Version | 14.0 |
| Supported Devices | iPhone, iPad, iPod touch |
| Primary Language | Swift 5 |
| UI Framework | UIKit (Programmatic) |
| Audio Framework | AVFoundation |
| Speech Framework | Speech (SFSpeechRecognizer) |
| Persistence | FileManager + JSON |
| Sync Infrastructure | CloudKit (Optional) |
| Build System | XcodeGen + GitHub Actions |
| Bundle Identifier | com.voxvault.app |

---

## License

This software is **proprietary and confidential**.

All rights reserved. Unauthorized copying, modification, distribution, reverse engineering, or commercial use of this software, via any medium, is strictly prohibited without express written permission from the copyright holder.

This repository is provided for reference purposes only. The code contained herein may not be used, in whole or in part, for any purpose without explicit authorization.

---

## Contact

**Author:** seraphic-syntax

**Repository:** [github.com/seraphic-syntax/VoxVault](https://github.com/seraphic-syntax/VoxVault)

For inquiries regarding licensing, collaboration, or feature requests, please open an issue on the GitHub repository.

---

<div align="center">

---

**VOXVAULT**

*Precision Audio Journaling for the Privacy-Conscious Mind*

---

`v1.0.0` | `Swift 5` | `iOS 14+` | `AVFoundation` | `On-Device Processing`

---


</div>
```
