# NanoClaw Modification Guide

Use this guide to quickly find where to make changes for common customization tasks.

## 🛠️ Adding a Custom Command or Intercepting Messages

- **Where to change**: `src/index.ts` in the `channelOpts.onMessage` callback.
- **Example**: If you want to intercept a message like `/mycommand` before it reaches the database or agent.
- **Reference**: See how `/remote-control` is handled in `main()` in `src/index.ts`.

## 🤖 Changing Agent Behavior or Identity

- **Where to change**: `groups/global/CLAUDE.md` (for all groups) or `groups/main/CLAUDE.md` (for the main group).
- **Alternative**: Modify `src/index.ts` in the `registerGroup` function where it copies the template and replaces the assistant name.
- **Internal Tools**: To add tools available *inside* the container, look at `container/skills/`.

## 📁 Modifying Container Sandbox / Mounts

- **Where to change**: `src/container-runner.ts` in the `buildVolumeMounts` function.
- **Note**: This is where you grant the agent access to specific host folders.
- **Security**: Always check `src/mount-security.ts` if you want to use the `additionalMounts` feature.

## ⏲️ Changing How Tasks are Scheduled

- **Where to change**: `src/task-scheduler.ts` in the `computeNextRun` function.
- **Example**: If you want to add a new schedule type (like "every third Tuesday").

## 💬 Changing Message Formatting for Claude

- **Where to change**: `src/router.ts` in the `formatMessages` function.
- **Example**: If you want to include more metadata (like sender ID) in the XML tags sent to Claude.

## 🏗️ Adding a New Communication Channel

1.  **Create File**: Create `src/channels/yourchannel.ts`.
2.  **Implement Interface**: Implement the `Channel` interface from `src/types.ts`.
3.  **Register**: Call `registerChannel('yourchannel', factory)` at the bottom of your file.
4.  **Import**: Import your new file in `src/channels/index.ts` to ensure it's loaded.

## ⚙️ Changing Global Settings

- **Where to change**: `src/config.ts`.
- **Settings**: Polling intervals, timeouts, default assistant name, and data directory paths.

## 💾 Database Schema Changes

1.  **Modify Schema**: Update `createSchema` in `src/db.ts`.
2.  **Add Migration**: Add a `try { database.exec("ALTER TABLE ...") } catch {}` block in `createSchema` to handle existing databases.
3.  **Update Types**: Update corresponding interfaces in `src/types.ts`.
