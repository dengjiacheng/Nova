---
title: 测试基线与覆盖率计划
status: active
updated_at: 2025-10-22
dcp: TASK-20251022-1909-ONBRD
---

# 当前基线

| 模块 | 框架/命令 | 当前覆盖率 | 备注 |
| ---- | ---------- | ---------- | ---- |
| NovaServer | `pytest --cov=app --cov-report=xml` | 88.2%（coverage.xml） | 覆盖 REST/API/WS/服务层，缺 Worker 守护、协议兼容测试 |
| NovaAgent | `./gradlew testDebugUnitTest jacocoTestReport` | 未统计（需启用 Jacoco 汇总） | `core/src/test` 覆盖消息、执行、回放逻辑；缺网络/离线场景回归 |
| NovaDesk | `flutter test --coverage` | 未统计（需生成 `coverage/lcov.info`） | 现有单元测试覆盖 Controller/Service，缺 UI 集成及 Golden 测试 |

# 行动计划

1. **覆盖率采集统一化**
   - 更新 CI Workflow：新增 Jacoco 与 Flutter coverage 步骤，统一上传到 `artifacts/coverage/<module>.xml|lcov`。
   - 编写 `scripts/testing/aggregate_coverage.py`（待建）将多端结果转为统一 JSON，供守护/仪表板消费。
2. **关键场景补测**
   - NovaServer：为 `app/workers`、`app/services/executions` 增补失败重试、版本兼容单元测试；增加 WebSocket 合约测试。
   - NovaAgent：引入模拟后端 WebSocket 的集成测试，覆盖离线重连与任务回放；补断电恢复（队列落盘）测试。
   - NovaDesk：构建设备列表刷新、脚本下发流程的 Widget/Integration 测试；采用 Golden 测试锁定关键 UI。
3. **端到端回归链路**
   - 使用守护或本地 docker-compose 拉起 NovaServer Mock，结合 Agent 仿真和 Desk 测试驱动完整流程。
   - 定义冒烟用例（脚本下发成功、失败回滚、资产同步差异）并纳入每次发布前自动执行。
4. **守门与追踪**
   - 短期阈值：75%（失败阻断合并，允许豁免需 DCP 说明）。
   - 长期目标：85%+，并对关键链路（端到端）保持 95% 执行成功率。
   - 将覆盖率指标与缺陷逃逸率关联，纳入季度治理复盘。

# 责任分配

- **QA/SRE**：维护 CI 脚本、覆盖率汇总、指标看板。
- **模块负责人**：各自补全单元/集成测试，确保阈值稳定。
- **守护脚本**：监控 `coverage-summary.json`（待实现），低于阈值时标记 PR。

# 验收标准

- CI 产物包含三端覆盖率报告，守护与 Looker/Grafana 能读取并展示；
- `docs/reference/testing/` 更新覆盖率历史（计划在守护中自动写入）；
- 每次发布需附加覆盖率对比与关键场景回归结果。
