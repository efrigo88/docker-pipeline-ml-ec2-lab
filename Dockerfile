FROM python:3.10-slim as builder

ENV PYSPARK_PYTHON=python3
ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64

# Install Java 17 and minimal OS deps
RUN apt-get update && apt-get install -y --no-install-recommends \
    openjdk-17-jdk-headless \
    curl \
    procps \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Install uv
RUN pip install uv

COPY pyproject.toml .
RUN uv pip install --system -e . && rm -rf ~/.cache

# Copy the rest of the application
COPY . .

# Final stage
FROM python:3.10-slim

ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64

# Install only runtime dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    openjdk-17-jre-headless \
    curl \
    procps \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy application and dependencies from builder stage
COPY --from=builder /app /app
COPY --from=builder /usr/local/lib/python3.10/site-packages /usr/local/lib/python3.10/site-packages

CMD ["python", "-m", "src.main"]
