# language: dockerfile
FROM python

WORKDIR /usr/src/app

# Install dependencies needed for psycopg2
RUN apt-get update && apt-get install -y libpq-dev gcc

# Copy the requirements file and install Python packages
COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt


# Keep the container running (you can change this to your actual startup command)
CMD ["sleep", "infinity"]