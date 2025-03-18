FROM python:3.12-alpine
WORKDIR /code
# Set environment variables
ENV FLASK_APP app.py
ENV FLASK_RUN_HOST 0.0.0.0
# Install system dependencies needed for building Python packages
RUN apk add --no-cache gcc musl-dev linux-headers
# Copy and install Python dependencies
COPY requirements.txt requirements.txt
RUN pip install -r requirements.txt
# Expose port 5000 for the Flask application
EXPOSE 5000
# Copy application code into the container
COPY app.py app.py
# Command to run the Flask application
CMD ["flask", "run"]
