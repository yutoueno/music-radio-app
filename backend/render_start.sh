#!/bin/bash
set -e

# Run database migrations
echo "Running database migrations..."
alembic upgrade head

# Seed initial data if needed
echo "Starting server..."
exec uvicorn app.main:app --host 0.0.0.0 --port $PORT
