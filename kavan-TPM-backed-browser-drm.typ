#import "@preview/arkheion:0.1.1": arkheion

#show: arkheion.with(
  title: "TPM-Backed Browser DRM: Trust Signals, Output Security, and Controversies",
  authors: (
    (name: "Harrys Kavan", email: "ir241506@fhstp.ac.at", affiliation: "FH St. Pölten University of Applied Sciences"),
  ),
  abstract: [
    Streaming platforms rely on browser-based digital rights management to release high-value UHD content. This paper analyses how Trusted Platform Module (TPM) attestation interacts with Encrypted Media Extensions, operating system DRM services, and hardware output protection. By comparing vendor policies and case studies, I argue that TPMs provide identity and posture evidence but do not enforce the pixels; that task falls to GPUs, trusted execution environments, and HDCP-protected display chains. The discussion highlights the incentives of studios, browser vendors, hardware makers, and end users, as well as privacy and competition risks of tightening integrity checks in the browser.
  ],
  keywords: ("TPM", "DRM", "Encrypted Media Extensions", "Widevine", "PlayReady"),
  date: "2025-10-21",
)

Disclosure: I used generative artificial intelligence tools to proof-read and polish this paper; all research, fact checking, and conclusions are my own.
#set cite(style: "ieee")
#show link: underline

= Introduction
Digital rights management (DRM) on the open web has to satisfy studio demands for robust protection without breaking the user experience that made browser video successful. The past decade brought a layered stack: Encrypted Media Extensions (EME) standardise application signalling, Content Decryption Modules (CDM) bind to proprietary Widevine or PlayReady systems, and the operating system negotiates secure surfaces and outputs.@chromium_cdm_readme Despite the marketing focus on Trusted Platform Modules (TPMs), real-world enforcement hinges on hardware display paths and trusted execution environments (TEE) that can keep decrypted frames out of user space.@garrett_gpu_root_drm This paper explores how TPM-backed signals complement, but don't replace, those mechanisms, and where the resulting socio-technical system leaves gaps for innovation and abuse.

= Research Approach
Targeted searches on “TPM DRM”, “Webbrowser TPM”, and “Netflix TPM” led to primary help centre articles and Microsoft Learn documentation that explain platform expectations.@google_widevine_overview@netflix_windows_uhd@netflix_hdcp_requirement@disneyplus_video_quality@microsoft_output_protection I then reviewed commentary from hardware security researchers to contrast marketing claims with technical enforcement realities.@garrett_gpu_root_drm Finally, I checked ongoing W3C and Android initiatives around attestation-driven web media to understand current debates and possible future trajectories.@w3c_web_media_snapshot@android_media_integrity_api

= Anatomy of Browser DRM

== Standard APIs and CDMs
EME provides the JavaScript API that allows streaming sites to discover supported key systems, create `MediaKeys`, and exchange licence messages with a CDM embedded in the browser.@chromium_cdm_readme In practice, two families dominate: Google’s Widevine and Microsoft’s PlayReady. Widevine defines three security levels; Level 1 keeps decryption and decoding inside a TEE, Level 2 decrypts in secure hardware but decodes in software, and Level 3 operates entirely in software for legacy devices.@google_widevine_overview PlayReady uses Security Levels (SL2000, SL3000) to gate access to high-value content, with SL3000 requiring hardware isolation that often maps to a TEE on the system-on-chip.@microsoft_playready_sl

== Operating System Enforcement
On Windows, the CDM interfaces with Media Foundation’s Protected Media Path, which is responsible for enforcing output policies like HDCP 2.2 on HDMI links.@microsoft_output_protection macOS and Linux rely on vendor-specific integrations with their graphics stacks, but the common requirement is that decrypted pixels land on a surface the OS recognises as protected. Browser source code confirms that Chrome and Edge delegate output protection enforcement to the host platform rather than interacting with the TPM directly.@chromium_cdm_readme

= TPM-Backed Integrity Signals
The TPM anchors measured boot, storing hashes of firmware and OS components in Platform Configuration Registers (PCR). Device Health Attestation (DHA) can export these measurements to a remote service so that policy engines decide whether the machine is in a trusted state.@microsoft_device_health_attestation In corporate environments, integration with Microsoft’s attestation services allows streaming platforms to request proof that Secure Boot is enabled, the OS is up to date, and antivirus is active.@microsoft_measured_boot However, the TPM does not decrypt media or guard the display pipeline directly. Instead, it raises confidence that the platform is unmodified, helping licence servers decide whether to issue high bitrate keys. From a threat perspective, this shifts the risk from “unknown client” to “known compliant client”, but hardware exploits above the TPM (for example, GPU driver vulnerabilities) remain in scope.

= Hardware Output Protection
Matthew Garrett emphasises that the GPU, not the TPM, is the decisive enforcement point for hardware DRM because the GPU controls scan-out and can refuse to render to unprotected outputs.@garrett_gpu_root_drm Discrete and integrated GPUs coordinate with display interfaces via HDCP 2.2 to ensure external monitors negotiate encrypted links before 4K frames leave the device.@digitalcp_hdcp22 If a non-compliant sink is detected, the OS downscales or blocks playback to stay within studio requirements.@microsoft_output_protection This is why even attested devices fail UHD playback when connected to older televisions. This policy couples TPM-backed identity with real-time hardware capability checks.

= Service Requirements and Case Studies
Streaming vendors communicate these constraints in their support material. Netflix restricts 4K playback on Windows to Microsoft Edge or the Netflix Store app, requires HEVC support, and demands that every connected display be HDCP 2.2 compliant.@netflix_windows_uhd@netflix_hdcp_requirement Disney+ presents similar guidance, highlighting that UHD availability depends on both browser and display chain, with explicit references to HDCP-compliant HDMI paths.@disneyplus_video_quality These policies show that the trust decision is multi-dimensional: the browser must expose the right key system (Widevine or PlayReady), the OS must provide a protected media pipeline, the GPU and display must pass output protection checks, and the service must deem the device posture acceptable—often informed by TPM attestations for enterprise scenarios.

= Stakeholder Incentives and Tensions

#figure(
  table(
    columns: (auto, auto, auto),
    align: center,
    [Stakeholder], [Primary Goal], [Risks / Concerns],
    [Studios & distributors], [Prevent easy ripping of UHD masters], [Over-reliance on closed hardware ecosystems and opaque vendor assurances],
    [Browser vendors], [Provide compliant playback without breaking the web model], [Becoming gatekeepers for attested clients, regulatory scrutiny],
    [Hardware OEMs], [Differentiate devices via “premium DRM” capability], [Support costs for legacy devices, user backlash when features break],
    [End users], [Watch content at promised fidelity], [Privacy erosion, loss of device control, accessibility regressions],
    [Regulators], [Balance copyright enforcement and competition], [Difficult to audit proprietary DRM stacks, potential for anticompetitive lock-in],
  ),
  caption: [Stakeholders in TPM-backed browser DRM and their conflicting incentives.]
) <stakeholder-table>

Studios reward compliant platforms with higher bitrate streams, incentivising browsers to integrate attestation flows even when they complicate open-source distribution. End users, by contrast, often discover the system only when it fails, such as connecting a projector that lacks HDCP 2.2 support and seeing playback blocked. Meanwhile, regulators worry that hardware-bound DRM creates de facto licensing barriers for alternative browsers or open hardware that cannot secure the same vendor attestations.

= Privacy, UX, and Emerging Debates
TPM-backed integrity checks leak device identifiers that can persist across browser profiles, contributing to long-term fingerprinting.@microsoft_edge_privacy Web users have limited visibility into which attestation claims are sent, eroding transparency. Recent proposals like Google’s (now paused) Web Environment Integrity sparked debate because they could let websites demand hardware-backed attestations before serving content, potentially locking out alternative browser engines.@w3c_web_media_snapshot At the same time, Android’s Media Integrity API for WebView shows that platforms continue to explore remote attestation to gate premium media experiences or KYC-heavy services.@android_media_integrity_api The user experience suffers when integrity checks misfire, revoked certificates or stale firmware can brick playback, which leaves support desks to resolve issues that end users cannot diagnose.

= Critical Reflection
TPM integration raises the bar for casual piracy by letting studios trust that a device booted sanctioned firmware, but it also concentrates power in platform vendors who act as policy intermediaries. The defender’s advantage is fragile: once a vulnerability in the GPU path or TEE becomes public, attackers can bypass restrictions without touching the TPM. Conversely, legitimate users pay the complexity tax through firmware updates, codec add-ons, or inaccessible outputs. The system further assumes continuous connectivity to fetch licences and revocation lists, disadvantaging offline or bandwidth-constrained scenarios. Finally, heavy reliance on HDCP and proprietary CDMs sidelines accessibility tooling and research, because these components are locked behind NDAs.

= Conclusion
TPM-backed browser DRM is best understood as a trust signal that feeds service policy engines rather than an enforcement mechanism on its own. Real protection emerges from the combination of CDMs running in TEEs, GPU-managed secure surfaces, and HDCP-controlled display links. While this architecture satisfies content licensors, it trades away user autonomy and transparency, creates support burden for edge cases, and risks entrenching a handful of ecosystem gatekeepers. Future work should explore more user-friendly attestation disclosures, open audit interfaces for CDMs, and fallback paths that maintain accessibility without sacrificing legitimate security goals.

#bibliography("bibliography.bib")
