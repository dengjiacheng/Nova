---
title: 两周接手基线
status: active
updated_at: 2025-10-22
dcp: TASK-20251022-1909-ONBRD
---

# 接手目标

- 构建可持续维护的权威知识库，覆盖架构、运行、运维与跨端协同细节。
- 在两周内将 NovaServer、NovaAgent、NovaDesk 的自动化测试覆盖率稳定在 ≥ 75%。
- 建立治理路线与 KPI 体系，支持守护/CI 形成自动化守门。

# 模块关注点

| 模块 | 现状 | 风险 | 优先事项 |
| ---- | ---- | ---- | -------- |
| NovaServer（Python/FastAPI） | coverage 报告显示 88.2% 行覆盖；API/WS/Worker 含完备测试目录 | 部署/运行手册缺失；异步 Worker 监控薄弱 | 记录运行手册、补充 Observability 指标、保持覆盖率并补契约测试 |
| NovaAgent（Android/Kotlin） | `core/src/test` 覆盖消息路由、执行协调等单元；未统计覆盖率 | 端到端链路与离线补偿缺回归用例 | 拉通本地/CI 构建、补充仿真测试与覆盖统计 |
| NovaDesk（Flutter 桌面） | 单元测试有限，多为 Controller/Service；缺覆盖统计 | 状态管理复杂，缺端到端 UI 测试 | 建立 Golden/Integration 测试基线，接入 `flutter test --coverage` |

# 两周执行节奏

## Week 1

1. **文档盘点与骨架搭建**
   - 复查 `docs/reference/*`，对缺漏主题建立占位文档（运行、部署、协议、应急）。
   - 建立文档维护规范：front-matter、状态标签、变更流程。
2. **现状评估**
   - 收集覆盖率：`pytest --cov=app`, `./gradlew testDebugUnitTest jacocoTestReport`, `flutter test --coverage`.
   - 记录测试矩阵，识别高风险流程（脚本下发、设备上线、资产同步）。
3. **KPI 定义草案**
   - 与负责人确认可靠性、质量、安全、效率四类指标。
   - 标注数据源（Grafana/Prometheus、CI 产物、Issue Tracker）。

## Week 2

1. **测试补强**
   - NovaServer：覆盖异步 worker 守护、脚本版本兼容性回归。
   - NovaAgent：补断线重连、脚本执行失败回放的自动化测试。
   - NovaDesk：构建 UI 集成测试（Riverpod 状态切片、设备列表刷新）。
2. **治理闭环**
   - 在 CI 加入覆盖率与质量守门；将报告产物上传（Codecov/S3）。
   - 输出 KPI 看板需求、每周例会模板、风险日志模板。
3. **交付验收**
   - 更新 `docs/reference/` 中的运行手册、测试基线、治理路线。
   - 完成复盘，形成下一迭代行动项（持续治理、依赖升级等）。

# 角色与协作

- **技术负责人**：审批 DCP、协调跨端资源、确认 KPI。
- **后端代表**：提供部署/运维细节、支持 Worker 测试补强。
- **客户端代表**：负责 Agent/Dek 集成测试与发布流程。
- **QA/SRE**：搭建覆盖率统计、CI 守门、指标采集。

# 工具与依赖

- 覆盖率工具：coverage.py、Jacoco、Flutter coverage Lcov。
- 报告汇总：`scripts/coverage/aggregate.py`（待补充）或 CI 上传脚本。
- 指标采集：Prometheus + Grafana（若无现有平台需申请）。

# 完成标准

- 文档目录结构完整，所有关键主题记录 `status: active` 或 `draft` 并指向 DCP。
- 三端测试覆盖率通过 CI 报表可查；低于阈值阻断合并。
- 治理路线、KPI 模板与例行节奏在 Reference 中可查，守护脚本识别并应用。
