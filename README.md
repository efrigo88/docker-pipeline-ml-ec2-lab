# PDF Text Analysis with ChromaDB

This project processes PDF documents, extracts text, and performs semantic search using ChromaDB and Ollama embeddings.

## Project Structure

```
.
├── data/                      # Directory for data files
│   ├── input/                # Input PDF files
│   ├── output/               # Processed data (JSONL files)
│   │   └── delta_table/      # Date-based delta table
│   └── answers/              # Query results
├── src/                      # Source code
│   ├── __init__.py
│   ├── queries.py           # Predefined queries for testing
│   ├── helpers.py           # Utility functions
│   └── main.py              # Main script
├── docker-compose.yml       # Docker Compose configuration
├── Dockerfile               # Docker configuration
├── pull_model.sh            # Script to pull Ollama model
├── requirements.txt         # Python dependencies
└── README.md                # This file
```

## Prerequisites

- Docker
- Docker Compose
- Make (optional, for using Makefile commands)

## Getting Started

1. Clone the repository:

   ```bash
   git clone git@github.com:efrigo88/docker-chromadb-lab.git
   cd docker-chromadb-lab
   ```

2. Create a `.env` file in the project root. You can copy the contents from `.env.example` and modify as needed:

   ```bash
   # Spark configuration
   THREADS="local[4]"
   DRIVER_MEMORY="8g"
   SHUFFLE_PARTITIONS="4"
   COMPOSE_BAKE="true"
   ```

3. Build and start the containers:

   ```bash
   docker compose up -d --build
   ```

4. Pull the Ollama model:

   ```bash
   chmod +x pull_model.sh
   ./pull_model.sh
   ```

   This script will:

   - Start all containers
   - Wait for Ollama service to be ready
   - Pull the required model (nomic-embed-text)

5. View logs:
   ```bash
   make logs
   ```

## Available Commands

- `make up` - Start containers
- `make down` - Stop containers
- `make build` - Build containers
- `make rebuild` - Rebuild and restart containers
- `make logs` - View container logs
- `make ps` - Check container status
- `make clean` - Remove containers and volumes

## Container Setup and Usage

1. Start the containers:

   ```bash
   docker compose up -d --build
   ```

   This will build and start both the app and chroma containers in the background.

2. Run your script in the app container:

   ```bash
   docker exec -it app python -m src.main
   ```

   The container will stay running, allowing you to:

   - Modify code in the `src` directory
   - Run the script multiple times
   - See the output in your terminal

3. To stop the containers when done (will delete the volume as well):
   ```bash
   docker compose down -v
   ```

## Usage

1. Place your PDF in the project directory
2. Update `FILE_PATH` in `src/main.py` if needed
3. Run the script:
   ```bash
   docker exec -it app python -m src.main
   ```

## Troubleshooting

If you encounter connection issues:

1. Check if ChromaDB is running: `make ps`
2. View logs: `make logs`
3. Rebuild containers: `make rebuild`
4. If Ollama model is not available, run the pull script again:
   ```bash
   ./pull_model.sh
   ```
