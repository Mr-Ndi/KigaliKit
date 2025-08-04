FROM python:3.11-slim

# Set working directory
WORKDIR /app

# Install system dependencies required by Firefox
RUN apt-get update && apt-get install -y --no-install-recommends \
    wget \
    unzip \
    curl \
    firefox-esr \
    ca-certificates \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Install Geckodriver with SHA256 verification
ENV GECKODRIVER_VERSION=v0.36.0
ENV GECKODRIVER_SHA256=0f4ce6dc176a163986c6bc3c1b786498028fc5e02f0f8ee03f1ea7fa228fa947

RUN wget -q "https://github.com/mozilla/geckodriver/releases/download/${GECKODRIVER_VERSION}/geckodriver-${GECKODRIVER_VERSION}-linux64.tar.gz" && \
    tar -xzf "geckodriver-${GECKODRIVER_VERSION}-linux64.tar.gz" && \
    mv geckodriver /usr/local/bin/ && chmod +x /usr/local/bin/geckodriver && \
    rm *.tar.gz

# Create a non-root user for running the app securely
RUN useradd --create-home appuser
USER appuser

# Copy source code
COPY --chown=appuser:appuser . /app

ENV PATH=$PATH:/home/appuser/.local/bin
ENV PATH="/home/appuser/.local/bin:$PATH"
# Install Python dependencies
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# Ensure logs are unbuffered (good for Docker logging)
ENV PYTHONUNBUFFERED=1

# Run the main script
CMD ["python", "main.py"]
