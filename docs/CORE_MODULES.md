# Core Modules Analysis

This document provides a detailed breakdown of each module in the NanoClaw project, its responsibilities, and key functions. Use this as a map when you need to modify specific parts of the system.

## 1. Orchestration & Entry Point

### `src/index.ts`
- **Role**: The central nervous system of NanoClaw. It initializes all subsystems and runs the main message loop.
- **Key Responsibilities**:
    - Initializing the database and state.
    - Loading and connecting all registered channels (Telegram, etc.).
    - Starting the IPC watcher, Task Scheduler, and Remote Control subsystems.
    - **`startMessageLoop()`**: Polls the database for new messages and routes them to the appropriate group queue.
    - **`processGroupMessages()`**: The function called when it's time to run an agent for a group. It gathers context and starts the container.
    - **`registerGroup()`**: Handles logic for adding a new group (directory creation, CLAUDE.md template).

## 2. Communication Channels

### `src/channels/registry.ts`
- **Role**: A simple registry for communication channels.
- **Responsibility**: Allows channels to self-register during startup.

### `src/channels/telegram.ts`
- **Role**: Telegram bot integration.
- **Key Responsibilities**:
    - Listening for Telegram messages using the `grammy` library.
    - Translating Telegram mentions into NanoClaw trigger patterns.
    - Handling non-text messages (photos, voice, etc.) by creating text placeholders.
    - Implementing the `/chatid` and `/ping` commands.
    - Forwarding messages to the NanoClaw orchestrator via `onMessage`.

## 3. Container & Agent Execution

### `src/container-runner.ts`
- **Role**: Manages the lifecycle of agent containers.
- **Key Responsibilities**:
    - **`buildVolumeMounts()`**: Defines which host directories are visible to the agent. This is crucial for security.
    - **`runContainerAgent()`**: Spawns the Docker or Apple Container process.
    - Handles streaming output from the container using `OUTPUT_START_MARKER` and `OUTPUT_END_MARKER`.
    - Manages log rotation for container runs.

### `src/container-runtime.ts`
- **Role**: Abstraction layer for different container runtimes (Docker, Apple Container, Docker Sandboxes).
- **Responsibility**: Provides a consistent interface for starting and stopping containers regardless of the underlying engine.

### `src/group-queue.ts`
- **Role**: Concurrency and lifecycle manager for group agents.
- **Key Responsibilities**:
    - Ensuring no more than `MAX_CONCURRENT_CONTAINERS` run at once.
    - Queuing messages and tasks when the limit is reached.
    - **`sendMessage()`**: Sends follow-up messages to a container that is *already running* using the IPC input directory.
    - Handling retries with exponential backoff for failed agent runs.

## 4. Database & State

### `src/db.ts`
- **Role**: SQLite database management.
- **Key Responsibilities**:
    - **`chats` table**: Tracks metadata about all chats the bot has seen.
    - **`messages` table**: Stores message history (for registered groups only).
    - **`scheduled_tasks` table**: Stores recurring jobs.
    - **`registered_groups` table**: Tracks which chats the bot is active in.
    - Providing CRUD operations for all the above.

## 5. Message Routing & Formatting

### `src/router.ts`
- **Role**: Formats data for the agent and routes responses back to the user.
- **Key Responsibilities**:
    - **`formatMessages()`**: Converts database message rows into an XML-like format that Claude agents are trained to understand.
    - **`stripInternalTags()`**: Removes `<internal>` reasoning blocks from agent output before sending to the user.
    - **`findChannel()`**: Maps a chat JID to the correct channel (e.g., `tg:` -> Telegram).

## 6. Subsystems

### `src/ipc.ts`
- **Role**: Host-to-Container and Container-to-Host communication via the filesystem.
- **Key Responsibilities**:
    - Polling the `data/ipc` directory for requests from the agent.
    - Handling commands like `schedule_task`, `register_group`, and `send_message`.
    - Enforcing security by ensuring groups can only interact with their own data or authorized targets.

### `src/task-scheduler.ts`
- **Role**: Triggers recurring tasks.
- **Key Responsibilities**:
    - Polling the database for "due" tasks.
    - **`computeNextRun()`**: Calculating the next execution time (handles cron and intervals).
    - Enqueuing task execution into the `GroupQueue`.

### `src/remote-control.ts`
- **Role**: Manages the "Remote Control" feature.
- **Responsibility**: Spawns and monitors the `claude remote-control` process, capturing the session URL.

## 7. Supporting Modules

- **`src/config.ts`**: Centralized configuration (timeouts, polling intervals, paths).
- **`src/env.ts`**: Environment variable parsing.
- **`src/types.ts`**: Central TypeScript type definitions.
- **`src/logger.ts`**: Logging configuration.
- **`src/timezone.ts`**: Timezone-aware date formatting.
- **`src/mount-security.ts`**: Validates additional mounts requested by groups against an allowlist.
- **`src/sender-allowlist.ts`**: Manages which users are allowed to trigger the bot in specific chats.
