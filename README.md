# Cluster

[English](README.md) | [中文文档](README_CN.md)

A powerful Agent management and coordination system.

## Quick Start

For detailed Chinese documentation, please see [中文使用教程](README_CN.md).

## Features

- 🚀 Simple and easy to use
- 🔧 Flexible configuration
- 📊 Monitoring and management
- 🔄 Auto-scaling
- 🛡️ Fault tolerance

## Installation

```bash
git clone https://github.com/20980061/Cluster.git
cd Cluster
pip install -r requirements.txt
```

## Basic Usage

```python
from cluster import Agent, Cluster

# Create an agent
agent = Agent(name="agent-001", task="process data")

# Create a cluster
cluster = Cluster(name="my-cluster")

# Add agent to cluster
cluster.add_agent(agent)

# Start the cluster
cluster.start()
```

## Documentation

- [Chinese Tutorial (中文教程)](README_CN.md) - Comprehensive guide in Chinese
- [API Reference](docs/api.md) - Coming soon
- [Examples](examples/) - Coming soon

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

MIT License

## Contact

- Issues: [GitHub Issues](https://github.com/20980061/Cluster/issues)