FROM python:3.10-slim as builder

# Set environment variables
ENV PYSPARK_PYTHON=python3

# Install Java 17 and minimal OS deps
RUN apt-get update && apt-get install -y --no-install-recommends \
    openjdk-17-jdk-headless \
    curl \
    build-essential \
    git \
    procps \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Set JAVA_HOME based on architecture
RUN if [ "$(uname -m)" = "aarch64" ]; then \
    export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-arm64; \
    else \
    export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64; \
    fi && \
    echo "export JAVA_HOME=$JAVA_HOME" >> /etc/profile.d/java.sh

# Set working directory
WORKDIR /app

# Install uv
RUN pip install uv

# Copy only dependency definition first for better layer caching
COPY pyproject.toml .

# Install dependencies using uv without virtual environment
RUN uv pip install --system -e .

# Copy the rest of the application
COPY . .

# Final stage
FROM python:3.10-slim

# Install only runtime dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    openjdk-17-jre-headless \
    curl \
    procps \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Set JAVA_HOME based on architecture
RUN if [ "$(uname -m)" = "aarch64" ]; then \
    export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-arm64; \
    else \
    export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64; \
    fi && \
    echo "export JAVA_HOME=$JAVA_HOME" >> /etc/profile.d/java.sh

# Set working directory
WORKDIR /app

# Copy installed packages and application from builder
COPY --from=builder /usr/local/lib/python3.10/site-packages /usr/local/lib/python3.10/site-packages
COPY --from=builder /app/src /app/src

# Create directories in EFS mount point
RUN mkdir -p /chromadb/delta_table /chromadb/jsonl_file && \
    chown -R 1000:1000 /chromadb

# The command to run your script
CMD ["python", "-m", "src.main"]
