# Nexora App Store submission checklist

This repository is prepared for submission, but nothing here uploads or
publishes the app.

## Verified project settings

- Product: `NexoraMobile`
- Display name: `Nexora`
- Bundle identifier: `com.martinpdev.nexoramobile`
- Marketing version: `1.0.0`
- Build number: `1`
- Platform: iPhone only
- Minimum OS: iOS 17.0
- Category: Finance
- Icon master: `NexoraMobile/Assets.xcassets/AppIcon.appiconset/AppIcon-1024.png`
- Launch screen: `NexoraMobile/Resources/LaunchScreen.storyboard`
- Privacy manifest: `NexoraMobile/Resources/PrivacyInfo.xcprivacy`

The identifier is valid and consistently configured. Before uploading, confirm
that it is registered to the intended Apple Developer team and exactly matches
the App Store Connect record. It cannot be changed after the first upload.

## Signing requirements

1. Active Apple Developer Program membership.
2. App Store Connect record for `com.martinpdev.nexoramobile`.
3. Explicit App ID using that same identifier.
4. Apple Distribution certificate installed on the signing Mac.
5. App Store Connect provisioning profile, or Xcode automatic signing.
6. In the target's **Signing & Capabilities**, choose the intended Team.
7. Keep **Automatically manage signing** enabled unless manual signing is
   required by the organization.
8. Archive on macOS with Xcode:

   ```bash
   xcodebuild \
     -project NexoraMobile.xcodeproj \
     -scheme NexoraMobile \
     -configuration Release \
     -destination 'generic/platform=iOS' \
     archive \
     -archivePath build/NexoraMobile.xcarchive
   ```

9. Run **Validate App** in Xcode Organizer before distribution.
10. Increment `CURRENT_PROJECT_VERSION` for every uploaded build.

Never commit certificates, private keys, provisioning profiles, or App Store
Connect API keys.

## Required screenshots

Apple accepts one to ten screenshots per device class and localization. For
this iPhone-only app, prepare at least one 6.9-inch iPhone set.

Accepted 6.9-inch portrait sizes:

- 1260 × 2736 pixels
- 1290 × 2796 pixels
- 1320 × 2868 pixels

Accepted 6.9-inch landscape sizes:

- 2736 × 1260 pixels
- 2796 × 1290 pixels
- 2868 × 1320 pixels

If a 6.9-inch set isn't supplied, a 6.5-inch set is required:

- 1284 × 2778 or 1242 × 2688 pixels in portrait
- 2778 × 1284 or 2688 × 1242 pixels in landscape

Files must be PNG, JPEG, or JPG with no alpha channel. Use one consistent size
within each device/localization set.

Recommended sequence:

1. Dashboard overview
2. Bot controls
3. Strategy configuration
4. Secure exchange connection
5. Account and server information

Use non-sensitive demo data. Never show real keys, tokens, balances, email
addresses, or customer information.

## Owner input still required

- Confirm App Store name availability
- Support URL and privacy policy URL
- Copyright owner and year
- App Review contact and demo-account credentials
- App privacy questionnaire
- Export compliance answers
- Content-rights declaration
- Age rating
- Pricing, territories, and release method

## Final pre-upload checks

- Set the production HTTPS API URL in `Config/Local.xcconfig`.
- Test all flows against production on a physical iPhone.
- Confirm exchange keys have no withdrawal permission.
- Reconcile the privacy manifest and privacy questionnaire with actual
  production analytics, logging, and backend practices.
- Produce and validate a signed Release archive.
- Confirm build `1` has not already been uploaded for version `1.0.0`.

