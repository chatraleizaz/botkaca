# Stage 1: Prepare environment and install dependencies
FROM alpine:latest as prepare_env
WORKDIR /app

# Install build dependencies
RUN apk --no-cache -q add \
    python3 python3-dev py3-pip libffi libffi-dev musl-dev gcc

# Create virtual environment
RUN python3 -m venv /app/venv
ENV PATH="/app/venv/bin:$PATH" VIRTUAL_ENV="/app/venv"

# Install pipenv and distlib in the virtual environment
RUN pip install -q --ignore-installed distlib pipenv

# Copy and install requirements in the virtual environment
COPY requirements.txt .
RUN pip install -q -r requirements.txt

# Stage 2: Execution environment
FROM alpine:latest as execute
WORKDIR /app

# Install runtime dependencies
RUN apk --no-cache -q add \
    python3 libffi \
    aria2 \
    ffmpeg

# Copy virtual environment from prepare_env stage
COPY --from=prepare_env /app/venv /app/venv
ENV PATH="/app/venv/bin:$PATH" VIRTUAL_ENV="/app/venv"

# Copy application code
COPY bot bot

# Run the application
CMD ["python3", "-m", "bot"]
