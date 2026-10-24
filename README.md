# Konsenxia — Open Source Development Prototype

Flutter and TypeScript source for a healthcare-oriented collaboration and AI-workflow prototype, maintained by Kerem Çelik in a personal capacity. First-party source is MIT licensed.

## Scope

This is a clean first public source export of the Konsenxia project: Flutter client features and design system, backend, Cloud Functions, platform scaffolding and existing tests. It is **not clinically validated, approved for medical use, or production-ready**. Existing screens and mock flows must not be interpreted as implemented clinical functionality or measured efficacy.

Production Firebase configuration, private deployment settings, old Git history, design screenshots, and legacy standalone HTML demos are deliberately excluded. The application will require your own isolated development configuration. This release does not connect to the original production project.

## Development setup

1. Install a compatible Flutter SDK (see pubspec.yaml), Node.js and npm.
2. Run `flutter pub get` and configure your own Firebase development project with `flutterfire configure`; replace the deliberately disabled Firebase options stub. Never use real patient data for development.
3. Generate the Android/iOS service files for that project if building mobile targets.
4. In `backend`, use `npm ci --ignore-scripts`, copy `.env.example` to `.env`, and supply only your own development values.
5. Review authentication, authorization, database rules and mock fallback behavior before enabling any network deployment. Production Firestore rules and deployment configuration are not included.

## Checks and known limits

```sh
cd backend
npm ci --ignore-scripts
npm run build
npm test -- --runInBand
```

Flutter: `flutter analyze` and `flutter test` after SDK/dependency setup. See VALIDATION.md for the actual checks performed on this release and any failures. Do not assume these commands pass or that source publication proves end-to-end operation.

The source includes incomplete integrations, mock/fallback behavior and development defaults. Clinical correctness, privacy compliance and deployment security require separate review. AI output must not be used as autonomous medical advice or a diagnosis. Synthetic test fixtures only; no patient datasets are included.

## Roadmap

Repair and expand automated checks; unify configuration and authentication; remove misleading mock success paths; develop reproducible synthetic AI-workflow evaluations; document human review, privacy boundaries and cost controls.

See CONTRIBUTING.md, SECURITY.md, NOTICE.md and SOURCE_PROVENANCE.json.
