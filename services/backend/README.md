# Backend (FastAPI)

```bash
uv sync                      # install deps into .venv
uv run python -m uvicorn townpass_backend.main:app --reload --host 0.0.0.0 --port 8000
# (python -m avoids Windows Smart App Control blocking .venv\Scripts\uvicorn.exe)
uv run pytest                # tests
uv run ruff check --fix .    # lint
```

- API docs / contract: http://localhost:8000/docs
- From the Android emulator the backend is at `http://localhost:8000` after `adb reverse tcp:8000 tcp:8000`
- No LLM inference here (competition rule) - on-device only.
