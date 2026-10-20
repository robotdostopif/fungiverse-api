FROM ghcr.io/astral-sh/uv:0.13.1 AS uv

FROM python:3.14-slim AS build

COPY --from=uv /uv /uvx /bin/

WORKDIR /src

ENV UV_PROJECT_ENVIRONMENT=/src/.venv \
    UV_NO_DEV=1 \
    UV_LINK_MODE=copy \
    UV_PYTHON_DOWNLOADS=0 \
    PYTHONDONTWRITEBYTECODE=1

COPY pyproject.toml uv.lock ./

RUN uv sync --locked --no-install-project

FROM python:3.14-slim AS runtime

ENV PATH="/src/.venv/bin:$PATH" \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

WORKDIR /src

COPY --from=build --chown=10001:10001 /src/.venv /src/.venv
COPY --chown=10001:10001 src/ ./src/

USER 10001:10001

EXPOSE 8000

CMD ["uvicorn", "src.main:app", "--host", "0.0.0.0", "--port", "8000"]
