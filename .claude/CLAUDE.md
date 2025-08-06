# User-Level CLAUDE.md - ML/LLM Engineering & Agentic AI Systems

This file contains specialized instructions for Claude Code when working with Machine Learning, LLM engineering, and Agentic AI systems.

## Core Principles

### AI Engineering Philosophy
- **Start Simple, Add Complexity When Needed**: Always begin with the simplest solution and only increase complexity when demonstrably required
- **Context Engineering Over Prompt Engineering**: Focus on dynamic context management rather than static prompt optimization
- **Deterministic Where Possible**: Prefer deterministic logic for control flow, use LLMs for intelligence
- **Test-Driven Development**: Build comprehensive evaluation suites before production deployment
- **Human-in-the-Loop**: Implement checkpoints and approval mechanisms for critical decisions

### Commit and Documentation Standards
- NEVER mention Claude, Claude Code, AI assistants, or code generation tools in commits or code
- Write commit messages focusing on WHAT changed and WHY, not HOW it was created
- Document architectural decisions and trade-offs in code comments
- Maintain clear separation between experimental and production code

## LLM & Agent Development

### Agent Architecture Best Practices
- **Memory Management**: Implement structured memory (short-term, long-term, episodic) with clear retention policies
- **Tool Integration**: Design tools with clear interfaces, error handling, and fallback mechanisms
- **State Management**: Use explicit state machines or graphs (LangGraph) for complex workflows
- **Observability**: Implement comprehensive tracing for debugging non-deterministic behaviors
- **Planning Systems**: Use explicit planning tools (even no-op ones) to maintain agent focus

### Prompt Engineering Guidelines
- **System Prompts**: Create detailed, example-rich system prompts with clear behavioral boundaries
- **Few-Shot Examples**: Include diverse, representative examples for complex tasks
- **Dynamic Prompting**: Generate prompts at runtime based on context and state
- **Chain-of-Thought**: Encourage step-by-step reasoning for complex problems
- **Output Formatting**: Use structured outputs (JSON, Pydantic) with validation

### Multi-Agent Systems
- **Task Decomposition**: Break complex tasks into specialized agent responsibilities
- **Communication Protocols**: Define clear message formats and handoff procedures
- **Parallelization**: Design for concurrent execution where tasks are independent
- **Orchestration**: Use frameworks like LangGraph for explicit control flow
- **Failure Handling**: Implement graceful degradation and retry strategies

## ML Engineering Standards

### Experiment Management
- **Tracking**: Use MLflow, Weights & Biases, or Comet ML for all experiments
- **Versioning**: Version datasets, models, and configurations separately
- **Reproducibility**: Set random seeds, log environment details, use deterministic operations
- **A/B Testing**: Implement proper statistical significance testing
- **Metrics**: Define clear success metrics before starting experiments

### Model Development
- **Baseline First**: Always establish simple baselines before complex models
- **Iterative Refinement**: Use rapid prototyping with increasing complexity
- **Evaluation Suites**: Build comprehensive test sets covering edge cases
- **Ablation Studies**: Systematically test component contributions
- **Error Analysis**: Maintain error categorization and analysis pipelines

### Data Engineering
- **Data Quality**: Implement validation, deduplication, and quality checks
- **Feature Engineering**: Document feature creation logic and dependencies
- **Pipeline Design**: Build idempotent, resumable data pipelines
- **Caching Strategy**: Cache expensive computations (embeddings, API calls)
- **Version Control**: Track data lineage and transformations

## RAG (Retrieval-Augmented Generation) Systems

### Vector Database Management
- **Indexing Strategy**: Choose appropriate embedding models and chunk sizes
- **Hybrid Search**: Combine vector similarity with keyword/metadata filtering
- **Update Mechanisms**: Implement incremental updates and re-indexing strategies
- **Performance Optimization**: Use appropriate distance metrics and index types
- **Fallback Logic**: Handle retrieval failures gracefully

### Knowledge Graph Integration
- **Structured Retrieval**: Use knowledge graphs for deterministic information access
- **Entity Resolution**: Implement robust entity linking and disambiguation
- **Relationship Modeling**: Capture and utilize entity relationships
- **Graph Updates**: Maintain consistency during updates
- **Query Optimization**: Design efficient traversal patterns

## Production Considerations

### Performance Optimization
- **Latency Budget**: Define and monitor latency requirements for each component
- **Batch Processing**: Use batching for API calls and model inference
- **Async Operations**: Implement async/await for I/O-bound operations
- **Resource Management**: Monitor and limit memory/CPU usage
- **Cost Optimization**: Track and optimize API usage and compute costs

### Safety and Security
- **Input Validation**: Sanitize all user inputs before processing
- **Output Filtering**: Implement content filtering and safety checks
- **Rate Limiting**: Protect against abuse with appropriate limits
- **Prompt Injection Defense**: Implement guards against malicious prompts
- **Data Privacy**: Never log or store sensitive information

### Monitoring and Observability
- **Metrics Collection**: Track latency, throughput, error rates, and costs
- **Distributed Tracing**: Implement OpenTelemetry for cross-service tracing
- **Logging Standards**: Use structured logging with appropriate levels
- **Alerting**: Set up alerts for anomalies and failures
- **Dashboard Creation**: Build actionable monitoring dashboards

## Framework-Specific Guidelines

### LangChain/LangGraph
- **Explicit Control**: Maintain full control over LLM inputs and execution flow
- **No Hidden Prompts**: Avoid frameworks that hide prompt construction
- **State Management**: Use LangGraph's state schema for complex workflows
- **Checkpointing**: Implement persistence for multi-turn conversations
- **Tool Design**: Create focused, single-purpose tools with clear interfaces

### OpenAI/Anthropic APIs
- **Retry Logic**: Implement exponential backoff with jitter
- **Streaming Responses**: Use streaming for better user experience
- **Token Management**: Track and optimize token usage
- **Model Selection**: Choose appropriate models for each task
- **Function Calling**: Use structured outputs and tool calls effectively

### Vector Stores (Pinecone, Weaviate, Qdrant)
- **Namespace Strategy**: Organize data into logical namespaces
- **Metadata Design**: Structure metadata for efficient filtering
- **Batch Operations**: Use batch upserts and queries
- **Index Management**: Plan for index growth and maintenance
- **Backup Strategy**: Implement regular backups and recovery plans

## Testing Strategies

### Unit Testing
- **Mock External Services**: Mock LLM APIs, databases, and external tools
- **Deterministic Tests**: Use fixed seeds and controlled inputs
- **Edge Cases**: Test boundary conditions and error scenarios
- **Component Isolation**: Test each component independently
- **Coverage Targets**: Maintain high test coverage for critical paths

### Integration Testing
- **End-to-End Flows**: Test complete agent workflows
- **Tool Integration**: Verify tool calls and responses
- **State Transitions**: Test state management and persistence
- **Error Propagation**: Ensure errors are handled correctly across components
- **Performance Testing**: Validate latency and throughput requirements

### Evaluation Frameworks
- **Ground Truth Sets**: Maintain curated evaluation datasets
- **Automated Metrics**: Implement BLEU, ROUGE, BERTScore, etc.
- **Human Evaluation**: Design protocols for human judgment when needed
- **A/B Testing**: Run controlled experiments in production
- **Regression Testing**: Prevent performance degradation over time

## Development Workflow

### Project Setup
- Check for existing ML/LLM frameworks (transformers, langchain, etc.)
- Review data pipelines and preprocessing scripts
- Understand evaluation metrics and baselines
- Identify compute resources and constraints
- Review existing experiments and results

### Code Organization
```
project/
├── src/
│   ├── agents/         # Agent implementations
│   ├── tools/          # Tool definitions
│   ├── prompts/        # Prompt templates
│   ├── evaluation/     # Evaluation scripts
│   └── utils/          # Shared utilities
├── configs/            # Configuration files
├── experiments/        # Experiment tracking
├── data/              # Datasets and preprocessed data
├── models/            # Trained models and checkpoints
└── notebooks/         # Exploratory analysis
```

### Version Control
- **Large Files**: Use Git LFS for models and datasets
- **Experiment Branches**: Create branches for major experiments
- **Config Management**: Version control all configurations
- **Results Tracking**: Store experiment results with code
- **Collaboration**: Use clear branch naming and PR descriptions

## Best Practices Checklist

### Before Starting
- [ ] Define clear success metrics
- [ ] Establish baseline performance
- [ ] Set up experiment tracking
- [ ] Create evaluation datasets
- [ ] Design system architecture

### During Development
- [ ] Start with simple implementations
- [ ] Add complexity incrementally
- [ ] Test each component thoroughly
- [ ] Document design decisions
- [ ] Monitor resource usage

### Before Production
- [ ] Comprehensive testing suite
- [ ] Performance benchmarks met
- [ ] Safety checks implemented
- [ ] Monitoring in place
- [ ] Rollback plan prepared

## Common Pitfalls to Avoid

1. **Over-engineering**: Don't build complex multi-agent systems when simple prompts suffice
2. **Ignoring Costs**: LLM API calls add up quickly - optimize and cache
3. **Poor Error Handling**: LLMs fail in unexpected ways - plan for it
4. **Inadequate Testing**: Non-deterministic systems need extensive testing
5. **Memory Leaks**: Long-running agents can accumulate memory - implement cleanup
6. **Context Overflow**: Monitor and manage context window usage
7. **Prompt Drift**: Prompts degrade over time - implement regression testing
8. **Tool Proliferation**: Too many tools confuse agents - keep tool sets focused

## Continuous Learning

### Stay Updated
- Follow latest research papers and arxiv submissions
- Monitor framework updates and best practices
- Participate in ML/AI communities
- Attend conferences and workshops
- Contribute to open-source projects

### Experimentation Culture
- Maintain experimentation notebooks
- Document failed approaches and learnings
- Share findings with team
- Build reusable components
- Create internal best practices documentation

## Notes

- Always consider the trade-off between complexity and performance
- Remember that simpler solutions are often more maintainable
- Focus on solving the actual problem, not building impressive architecture
- Keep human oversight in critical decision paths
- Document why decisions were made, not just what was implemented