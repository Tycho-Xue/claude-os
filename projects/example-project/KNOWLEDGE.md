# Example Project — Knowledge

## Setup
- Language: Python 3.11
- Framework: FastAPI
- Database: PostgreSQL
- Deploy: Docker + cloud provider

## Gotchas
- API rate limit is 100 req/min in staging, 1000 in prod
- Database migrations must be backward-compatible (zero-downtime deploys)

## Commands
```bash
# Dev server
uvicorn app.main:app --reload --port 8000

# Run tests
pytest tests/ -v

# Database migration
alembic upgrade head
```

## Architecture Decisions
- Chose FastAPI over Flask for async support and auto-generated OpenAPI docs
- PostgreSQL over SQLite for concurrent write support in production

## Records Index
<!-- Auto-updated on handoff: grep "^## " from RECORDS.md -->
- 2026-03-15 14:00 Initial deploy to staging — 200ms p99 latency
- 2026-03-10 09:30 Failure: Connection pool exhaustion under load
- 2026-03-01 16:00 Architecture decision: FastAPI + PostgreSQL

## Archive
- 2026-03-01 Initial project scaffold with FastAPI + SQLAlchemy
