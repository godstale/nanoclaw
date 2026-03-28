# NanoClaw Data Flow

This document describes how data flows through NanoClaw, from a user message to an agent's response and scheduled tasks.

## 1. Inbound Message Flow

1.  **Channel Reception**: A user sends a message on a channel (e.g., Telegram).
2.  **Channel Processing (`src/channels/telegram.ts`)**:
    *   The channel identifies the chat JID (e.g., `tg:12345`).
    *   It checks if the group is registered via `opts.registeredGroups()`.
    *   If registered, it calls `opts.onMessage()`.
3.  **Storage (`src/index.ts` -> `src/db.ts`)**:
    *   The orchestrator receives the message and calls `storeMessage(msg)`.
4.  **Message Loop (`src/index.ts`)**:
    *   `startMessageLoop()` polls the database for new messages since `lastTimestamp`.
    *   It identifies which registered group the message belongs to.
    *   If the group requires a trigger (e.g., `@Andy`), it checks for the trigger pattern.
5.  **Queuing (`src/group-queue.ts`)**:
    *   The orchestrator calls `queue.enqueueMessageCheck(chatJid)`.
    *   If a container is already running for this group, it sends the message via IPC (`data/ipc/FOLDER/input/`).
    *   If no container is running and there's a slot, it starts a new run.
6.  **Agent Invocation (`src/index.ts` -> `src/container-runner.ts`)**:
    *   `processGroupMessages()` gathers context (recent messages from DB).
    *   `runContainerAgent()` spawns the container with appropriate mounts.
7.  **Container Execution**:
    *   The `agent-runner` inside the container reads the input JSON.
    *   It starts a `claude` session.
    *   Claude processes the messages and calls tools if necessary.
8.  **Streaming Output**:
    *   The `agent-runner` captures Claude's output and wraps it in `---NANOCLAW_OUTPUT_START---` and `---NANOCLAW_OUTPUT_END---`.
    *   `container-runner.ts` on the host parses these markers.
9.  **Outbound Routing (`src/router.ts`)**:
    *   The response is stripped of internal tags.
    *   `findChannel()` identifies the correct channel.
    *   `channel.sendMessage()` sends the response back to the user.

## 2. Scheduled Task Flow

1.  **Scheduler Poll (`src/task-scheduler.ts`)**:
    *   `startSchedulerLoop()` polls `getDueTasks()` from the DB.
2.  **Queuing**:
    *   Due tasks are added to the `GroupQueue` via `queue.enqueueTask()`.
3.  **Execution**:
    *   When a slot is available, `runTask()` is called.
    *   It triggers `runContainerAgent()` with the task's prompt.
4.  **Completion**:
    *   The agent's result is sent to the chat via `deps.sendMessage()`.
    *   The database is updated with `updateTaskAfterRun()`, calculating the next run time.

## 3. IPC (Agent to Host) Flow

1.  **Agent Action**: An agent uses a tool that writes a JSON file to `/workspace/ipc/tasks/` or `/workspace/ipc/messages/`.
2.  **Host Polling (`src/ipc.ts`)**:
    *   `startIpcWatcher()` polls the host directory `data/ipc/`.
3.  **Verification**:
    *   The watcher identifies the source group based on the directory path.
    *   It verifies if the group is authorized to perform the requested action.
4.  **Execution**:
    *   The host performs the action (e.g., schedules a new task, sends a message to another chat).
    *   The IPC file is deleted.
