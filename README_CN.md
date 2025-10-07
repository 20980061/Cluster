# Cluster - Agent 中文使用教程

## 目录
- [简介](#简介)
- [快速开始](#快速开始)
- [安装与配置](#安装与配置)
- [基本使用](#基本使用)
- [高级功能](#高级功能)
- [常见问题](#常见问题)
- [最佳实践](#最佳实践)

## 简介

Cluster 是一个强大的 Agent 管理和协调系统，旨在帮助您轻松管理和部署多个智能代理。

### 主要特性

- 🚀 **简单易用**: 直观的 API 设计，快速上手
- 🔧 **灵活配置**: 支持多种配置方式，满足不同需求
- 📊 **监控管理**: 实时监控 Agent 状态和性能
- 🔄 **自动扩展**: 根据负载自动调整 Agent 数量
- 🛡️ **容错处理**: 内置故障恢复机制

## 快速开始

### 前置要求

在开始之前，请确保您的系统满足以下要求：

- Python 3.8 或更高版本
- pip 包管理器
- 至少 2GB 可用内存

### 安装

```bash
# 克隆仓库
git clone https://github.com/20980061/Cluster.git
cd Cluster

# 安装依赖
pip install -r requirements.txt
```

## 安装与配置

### 基础配置

创建配置文件 `config.yaml`：

```yaml
cluster:
  name: "my-cluster"
  max_agents: 10
  min_agents: 1
  
agent:
  type: "default"
  timeout: 30
  retry: 3
  
logging:
  level: "INFO"
  file: "cluster.log"
```

### 环境变量

您也可以通过环境变量进行配置：

```bash
export CLUSTER_NAME="my-cluster"
export MAX_AGENTS=10
export MIN_AGENTS=1
```

## 基本使用

### 创建第一个 Agent

```python
from cluster import Agent, Cluster

# 创建 Agent
agent = Agent(
    name="agent-001",
    task="处理数据",
    config={
        "timeout": 30,
        "retry": 3
    }
)

# 创建 Cluster
cluster = Cluster(name="my-cluster")

# 添加 Agent 到 Cluster
cluster.add_agent(agent)

# 启动 Cluster
cluster.start()
```

### 管理 Agent 生命周期

```python
# 启动 Agent
agent.start()

# 检查 Agent 状态
status = agent.get_status()
print(f"Agent 状态: {status}")

# 停止 Agent
agent.stop()

# 重启 Agent
agent.restart()
```

### 执行任务

```python
# 提交任务给 Agent
result = agent.execute_task({
    "action": "process",
    "data": {"key": "value"}
})

# 获取任务结果
if result.success:
    print(f"任务完成: {result.output}")
else:
    print(f"任务失败: {result.error}")
```

## 高级功能

### 多 Agent 协调

```python
from cluster import Cluster, Agent

# 创建多个 Agent
agents = [
    Agent(name=f"agent-{i}", task="处理任务")
    for i in range(5)
]

# 创建 Cluster 并添加 Agent
cluster = Cluster(name="multi-agent-cluster")
for agent in agents:
    cluster.add_agent(agent)

# 启动所有 Agent
cluster.start_all()

# 分配任务
tasks = [{"id": i, "data": f"task-{i}"} for i in range(10)]
results = cluster.distribute_tasks(tasks)

# 处理结果
for result in results:
    print(f"任务 {result.task_id}: {result.status}")
```

### 负载均衡

```python
# 配置负载均衡策略
cluster.configure_load_balancer(
    strategy="round-robin",  # 或 "least-loaded", "random"
    health_check_interval=10
)

# 启用自动扩展
cluster.enable_auto_scaling(
    min_agents=2,
    max_agents=10,
    scale_up_threshold=0.8,   # CPU 使用率 > 80% 时扩展
    scale_down_threshold=0.3   # CPU 使用率 < 30% 时缩减
)
```

### 监控和日志

```python
# 获取 Cluster 统计信息
stats = cluster.get_statistics()
print(f"活跃 Agent 数量: {stats.active_agents}")
print(f"处理的任务总数: {stats.total_tasks}")
print(f"平均响应时间: {stats.avg_response_time}ms")

# 设置自定义日志
import logging

cluster.set_logger(
    level=logging.DEBUG,
    format="%(asctime)s - %(name)s - %(levelname)s - %(message)s",
    file="cluster_debug.log"
)

# 监听 Agent 事件
@cluster.on_event("agent_started")
def handle_agent_start(event):
    print(f"Agent {event.agent_name} 已启动")

@cluster.on_event("agent_failed")
def handle_agent_failure(event):
    print(f"Agent {event.agent_name} 失败: {event.error}")
```

### 错误处理和重试

```python
from cluster import Agent, RetryPolicy

# 配置重试策略
retry_policy = RetryPolicy(
    max_retries=3,
    retry_delay=1.0,      # 初始延迟 1 秒
    backoff_factor=2.0,   # 指数退避系数
    max_delay=60.0        # 最大延迟 60 秒
)

agent = Agent(
    name="resilient-agent",
    retry_policy=retry_policy
)

# 错误处理
try:
    result = agent.execute_task(task)
except AgentTimeoutError:
    print("Agent 执行超时")
except AgentFailedError as e:
    print(f"Agent 执行失败: {e}")
finally:
    agent.cleanup()
```

## 常见问题

### Q: 如何调试 Agent 问题？

A: 启用调试日志并检查详细输出：

```python
cluster.set_log_level(logging.DEBUG)
agent.enable_debug_mode()
```

### Q: Agent 启动失败怎么办？

A: 检查以下几点：
1. 确认配置文件正确
2. 检查依赖是否安装完整
3. 查看日志文件了解详细错误
4. 确保端口未被占用

### Q: 如何优化 Agent 性能？

A: 性能优化建议：
1. 调整 `max_workers` 参数
2. 使用连接池减少开销
3. 启用缓存机制
4. 合理配置超时时间
5. 使用异步操作

### Q: 多个 Agent 如何通信？

A: 使用消息队列进行 Agent 间通信：

```python
from cluster import MessageBus

# 创建消息总线
bus = MessageBus()

# Agent 1 发送消息
agent1.send_message("agent2", {"type": "request", "data": "hello"})

# Agent 2 接收消息
@agent2.on_message
def handle_message(sender, message):
    print(f"收到来自 {sender} 的消息: {message}")
```

### Q: 如何进行集群备份和恢复？

A: 使用内置的备份功能：

```python
# 备份集群状态
cluster.backup(path="/path/to/backup")

# 从备份恢复
cluster.restore(path="/path/to/backup")
```

## 最佳实践

### 1. 资源管理

- 合理设置 Agent 数量上下限
- 监控资源使用情况
- 及时清理不需要的 Agent

```python
# 定期清理空闲 Agent
cluster.cleanup_idle_agents(idle_time=300)  # 5分钟无活动则清理
```

### 2. 错误处理

- 总是为 Agent 操作添加异常处理
- 使用重试机制处理临时故障
- 记录详细的错误日志

### 3. 配置管理

- 使用配置文件而非硬编码
- 为不同环境使用不同配置
- 敏感信息使用环境变量

### 4. 监控告警

- 设置关键指标的告警
- 定期检查 Agent 健康状态
- 建立故障响应机制

```python
# 配置健康检查
cluster.configure_health_check(
    interval=30,          # 每30秒检查一次
    timeout=5,            # 超时时间5秒
    failure_threshold=3   # 连续3次失败则标记为不健康
)

# 设置告警
@cluster.on_alert("agent_unhealthy")
def handle_unhealthy_agent(alert):
    # 发送通知或自动修复
    print(f"告警: Agent {alert.agent_name} 不健康")
```

### 5. 性能调优

- 使用连接池减少连接开销
- 批量处理任务提高效率
- 根据实际负载调整并发数

```python
# 批量处理任务
tasks = [task1, task2, task3, ...]
results = cluster.execute_batch(tasks, batch_size=10)
```

### 6. 安全性

- 启用认证和授权机制
- 加密敏感数据
- 定期更新依赖包

### 7. 测试

- 为 Agent 编写单元测试
- 进行集成测试
- 模拟故障场景测试容错性

```python
# 测试示例
import unittest

class TestAgent(unittest.TestCase):
    def setUp(self):
        self.agent = Agent(name="test-agent")
    
    def test_agent_start(self):
        self.agent.start()
        self.assertEqual(self.agent.status, "running")
    
    def test_task_execution(self):
        result = self.agent.execute_task({"action": "test"})
        self.assertTrue(result.success)
    
    def tearDown(self):
        self.agent.stop()
```

## 贡献指南

欢迎提交问题报告、功能建议或代码贡献！

1. Fork 本仓库
2. 创建特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m '添加某个很棒的功能'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 开启 Pull Request

## 许可证

本项目采用 MIT 许可证，详情请见 LICENSE 文件。

## 联系我们

- 问题反馈: [GitHub Issues](https://github.com/20980061/Cluster/issues)
- 邮件: support@example.com
- 文档: [在线文档](https://cluster.example.com/docs)

## 更新日志

### v1.0.0 (待发布)
- 初始版本发布
- 基础 Agent 管理功能
- 支持多 Agent 协调
- 自动扩展和负载均衡
- 完整的中文文档

---

感谢使用 Cluster！如有任何问题，欢迎随时联系我们。
