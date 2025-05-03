# Stage 1: Build dependencies
FROM alpine:3.19 as prepare_env
WORKDIR /app

# Install build dependencies, including git
RUN apk --no-cache -q add \
    python3 python3-dev py3-pip libffi libffi-dev musl-dev gcc git

# Create virtual environment
RUN python3 -m venv /app/venv
ENV PATH="/app/venv/bin:$PATH" VIRTUAL_ENV="/app/venv"

# Upgrade pip
RUN pip install -q --upgrade pip

# Install pipenv and distlib
RUN pip install -q --ignore-installed distlib pipenv

# Install requirements
COPY requirements.txt .
RUN pip install -q -r requirements.txt

# Stage 2: Runtime
FROM alpine:3.19
WORKDIR /app

# Install runtime dependencies
RUN apk --no-cache -q add \
    python3 libffi \
    aria2 \
    ffmpeg

# Copy virtual environment from build stage
COPY --from=prepare_env /app/venv /app/venv
ENV PATH="/app/venv/bin:$PATH" VIRTUAL_ENV="/app/venv"

# Copy application code
COPY bot bot

# Command to run the bot
CMD ["python3", "-m", "bot"]
