FROM python:3.11-slim

WORKDIR /app

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

RUN chmod +x render_start.sh

EXPOSE 8000

# Render sets PORT env var; default to 8000
ENV PORT=8000

CMD ["bash", "render_start.sh"]
