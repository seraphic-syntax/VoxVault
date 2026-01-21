# Security Policy

This document explains how to report security issues for VoxVault and what to expect from the response process.

## Supported Versions

VoxVault is in private development. Only the current `main` branch is supported with security updates.

| Version | Supported |
| ------- | --------- |
| main    | ✅        |
| others  | ❌        |

## Reporting a Vulnerability

Please report security issues **privately**.

- **Email:** security@voxvault.app
- **Subject:** "VoxVault Security Report"
- **Preferred language:** English

If email is not an option, use GitHub Security Advisories (if enabled) from the repository’s **Security** tab.

### What to Include

Provide as much detail as possible to help us reproduce and validate the issue:

- A clear, concise description of the vulnerability
- Affected component(s) or file(s)
- Steps to reproduce (PoC or minimal sample preferred)
- Expected vs. actual behavior
- Impact assessment (what could be compromised)
- Affected version/commit hash
- Logs, screenshots, or crash reports (redact sensitive data)
- Whether the issue is reproducible on a clean device/simulator

### What **Not** to Do

- Do not open public issues, pull requests, or discussions for security reports
- Do not run automated scanners against production systems without permission
- Do not include secrets, personal data, or access tokens in reports

## Response Timeline

We aim to respond on the following schedule:

- **Acknowledgement:** within 3 business days
- **Initial assessment:** within 7 business days
- **Status updates:** at least every 14 days until resolution
- **Fix or mitigation plan:** as soon as reasonably possible based on severity

These timelines may vary based on issue complexity, reproducibility, and the availability of maintainers.

## Coordinated Disclosure

We support coordinated disclosure. Please allow a reasonable time for us to investigate and remediate before public disclosure. If you intend to publish, let us know in advance so we can coordinate a release.

## Severity Guidance (High-Level)

- **Critical:** remote code execution, auth bypass, data exfiltration at scale
- **High:** sensitive data exposure, privilege escalation, persistent compromise
- **Medium:** limited data exposure, significant functionality misuse
- **Low:** minor information leaks or non‑exploitable misconfigurations

## Safe Harbor

We will not pursue legal action for good‑faith security research that complies with this policy, avoids privacy violations, and does not disrupt services.
