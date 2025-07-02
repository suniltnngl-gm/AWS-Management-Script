FROM python:3.11-alpine

# @description Backend API container for AWS Management Scripts
WORKDIR /app

# Install system dependencies
RUN apk add --no-cache bash curl aws-cli

# Copy requirements and install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy backend code
COPY . .

# Copy shell scripts from parent directory
COPY ../*.sh ./

# Set permissions
RUN chmod +x *.sh run.sh

# Expose API port
EXPOSE 5000

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:5000/api/resources || exit 1

# Start server
CMD ["./run.sh"]