# NanoClaw Project Context

NanoClaw is an AI assistant runner that executes Claude agents securely within isolated Linux containers. It is designed to be lightweight, customizable, and secure by isolation rather than application-level checks.

## Project Overview

- **Core Technology:** Node.js (TypeScript), SQLite, Docker/Apple Container.
- **Architecture:** 
  - **Orchestrator:** A single Node.js process manages state, the message loop, and agent invocation.
  - **Channels:** Modular messaging interfaces (WhatsApp, Telegram, Slack, etc.) that self-register at startup.
  - **Containerization:** Agents run in Linux containers (via Docker or Apple Container) with filesystem isolation. Only explicitly mounted directories are accessible.
  - **Security:** Credentials are managed via OneCLI Agent Vault, injecting them at request time so agents never hold raw keys.
  - **Isolation:** Each group/chat has its own isolated filesystem, `CLAUDE.md` memory, and container sandbox.

## Key Components

- `src/index.ts`: The main orchestrator and entry point.
- `src/channels/registry.ts`: Handles registration and factory for messaging channels.
- `src/container-runner.ts`: Manages spawning and streaming agent containers.
- `src/db.ts`: SQLite database operations for messages, groups, and sessions.
- `src/ipc.ts`: Inter-process communication watcher for task processing.
- `src/task-scheduler.ts`: Manages recurring scheduled tasks.
- `src/config.ts`: Central configuration for names, intervals, and paths.

## Development Guide

### Building and Running

- **Install Dependencies:** `npm install`
- **Build Project:** `npm run build` (compiles TypeScript to `dist/`)
- **Run in Development:** `npm run dev` (uses `tsx` for hot-reload)
- **Start Production:** `npm start`
- **Setup:** `npm run setup` (runs the guided setup script)
- **Build Agent Container:** `./container/build.sh`

### Testing

- **Run Tests:** `npm test` (uses Vitest)
- **Watch Mode:** `npm run test:watch`
- **Type Checking:** `npm run typecheck`

### Linting and Formatting

- **Lint:** `npm run lint`
- **Fix Linting:** `npm run lint:fix`
- **Format:** `npm run format` (uses Prettier)

## Coding Conventions

- **Surgical Changes:** The codebase is designed to be small and understandable. Favor small, targeted modifications over large refactors.
- **AI-Native:** The project relies on Claude Code for setup, debugging, and customization.
- **Skill-Based Extension:** New features (like new channels) should be implemented as "skills" (often on separate branches) rather than being bundled into the core repository to prevent bloat.
- **Container Skills:** Logic intended to run *inside* the agent container belongs in `container/skills/`.

## Key Files & Directories

- `groups/`: Contains subdirectories for each registered group, including their `CLAUDE.md` and logs.
- `data/`: Stores environment files, IPC data, and session state.
- `docs/`: Comprehensive documentation on architecture, security, and the SDK.
    - `docs/CORE_MODULES.md`: Detailed breakdown of source files and their roles.
    - `docs/DATA_FLOW.md`: Mapping of message and task lifecycle.
    - `docs/MODIFICATION_GUIDE.md`: Quick-reference for common customization tasks.
- `container/`: Dockerfile and build scripts for the agent runner.
- `CLAUDE.md`: Contains project-specific instructions and a summary of key files.
