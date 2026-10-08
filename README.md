# RUSHD

RUSHD (رُشْد) is a personal Islamic worship companion focused on helping users build consistent daily worship habits with clarity and minimal distraction.

## Development principle

Every completed feature is treated as production-ready. UI, interaction, state, domain models, repository boundaries, loading/error/empty states, persistence requirements, and backend contracts are considered together before a feature is marked complete.

## Architecture

```text
Presentation
    ↓
Domain / State
    ↓
Repository
    ↓
Data Source
    ↓
Local / Remote Backend
```

Feature code lives under `lib/features/<feature>/` and is divided into:

- `presentation/` — screens and UI state
- `domain/` — business models and repository contracts
- `data/` — repository implementations and data sources

Cross-cutting concerns live under `lib/core/`, shared models/widgets under `lib/shared/`, and future protocol definitions under `proto/`.

## Current foundation

- Material 3 theme and RUSHD design tokens
- Riverpod state-management foundation
- GoRouter navigation foundation
- Local persistence abstraction backed by SharedPreferences
- Repository/result/error abstractions
- Feature-oriented project structure
- Asset and protobuf directories prepared
- Minimal production app shell
