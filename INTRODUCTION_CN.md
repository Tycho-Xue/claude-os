# Claude OS 是什么

**Claude Code 是一颗没有操作系统的 CPU。**

它很强——写代码、debug、搜索、推理都行。但每次启动都是裸机状态：不知道你是谁，不知道在做什么项目，不知道昨天的 debug 卡在哪，不知道上周犯过什么错。你想让它做真正的工作——跨天的、多项目的、多机器的——它做不到。不是因为它不够聪明，是因为它没有基础设施。

**它缺的不是记忆。是操作系统。**

记忆只是 OS 的一个功能。OS 真正提供的是：让一个 stateless 的算力变成一个 stateful 的、可协作的、能自我纠正的工作环境。

Claude OS 就是这个操作系统。它是一个 AI researcher 在日常高强度使用 Claude Code 做研究的过程中，逐步摸索、迭代出来的一套系统。不是一次性设计的产物——每一个机制都是因为真实踩过坑才加上的。

## 架构

Claude OS 解决的问题，和计算机 OS 解决的是同一组问题，只是对象从硬件变成了 AI agent：

| 计算机 OS | Claude OS | 解决的问题 |
|-----------|-----------|-----------|
| 内存管理 | CONTEXT / KNOWLEDGE / RECORDS 三层冷热分离 | Context window = RAM，有限且昂贵。按需 page in，不全量加载 |
| 文件系统 | File contracts + Resource Map + No ghost file | 知识需要结构化存储、索引、格式规范 |
| 文件完整性 | Knowledge quality（fact / observation / inference 分级 + graduation review） | 错误的知识比没有知识更危险，需要防止坏数据污染长期存储 |
| 进程隔离 | Task sections（共享读、隔离写） | 多个 session 并行不能互相覆盖 |
| 安全补丁 | Feedback 系统 + Structure > Rules | 犯过的错持久化修正；反复违反的规则升级为 hook 强制执行 |
| 网络同步 | Git + rebase 策略 | 多台机器同一份状态，冲突自动解决 |

## Kernel

Claude Code 本身是**硬件 + BIOS**——它有一个硬编码行为：启动时自动读 `~/.claude/CLAUDE.md`。这就是 BIOS 去固定地址加载 bootloader。

CLAUDE.md 同时包含了 **bootloader 和 kernel**：

- `## Boot` 是 **bootloader**：`git pull` → 按 Loading 规则加载项目文件 → 报告状态。启动序列，决定接下来挂载什么
- Rules + Protocol + Resource Map 是 **kernel**：常驻内存，定义所有行为，管理所有资源调度。不会被 page out

合成一个文件是有意的设计——之前是分开的（PROTOCOL.md, MEMORY.md, coding-rules.md…），相当于 kernel modules 分散加载。后来发现 1M context 下 ~2300 tokens 根本不算什么，不如做 **monolithic kernel**，一次加载，省掉 multi-step boot 的复杂度。

再往下：

- **init system** = Loading protocol（根据场景决定挂载什么：项目工作 → mount CONTEXT+KNOWLEDGE，技术问题 → 按需 mount learnings/）
- **syscall** = slash commands（`/handoff` = sync+shutdown，`/reload` = mount+init，`/deduce` = gdb，`/refactor` = fsck）
- **user space** = 项目文件、learnings、pipelines——应用层数据，通过 kernel 定义的协议读写

## 结果

装上 OS 之后，Claude 不再是每次重启都失忆的工具。它变成一个有工作方法的 agent——知道怎么接手项目、怎么管理自己积累的知识的可靠性、怎么和你沟通进度、怎么从错误中自我纠正、怎么在 session 结束时保存状态让下一个 session 无缝继续。

而且这个系统是活的——不只是从自己的使用中成长（每次纠正变成永久的行为补丁，每个踩坑沉淀为规则），也天然能吸收外部的优秀实践。看到社区里好的模式——比如 Karpathy autoresearch 的 append-only log 和 baseline ratchet——评估、适配，就能落到 OS 已有的结构里。OS 提供的不是一套固定的规则，而是一个能持续吸收经验和进化迭代的框架。

它不依赖额外的基础设施——底层就是 markdown 文件和 git。真正的复杂度在协议设计：什么该加载、什么该持久化、怎么保证知识质量、怎么跨 session 保持一致。这些设计不是一次想出来的——是一个 AI researcher 在日常用 Claude Code 做研究的过程中，一个坑一个坑踩出来、一轮一轮迭代调出来的。

---

> **AI agent 目前大多处于"没有操作系统"的状态——每个用户都在裸机上编程。Claude OS 是从日常 AI research 实战中长出来的一个解法。**
