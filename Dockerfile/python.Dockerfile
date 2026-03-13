FROM python:3.12-alpine

# Install system dependencies for GDAL and psycopg2
RUN apk add --no-cache \
    gdal \
    gdal-dev \
    gdal-tools \
    geos \
    geos-dev \
    proj \
    proj-dev \
    gcc \
    g++ \
    musl-dev \
    python3-dev \
    postgresql-dev \
    linux-headers

# Set GDAL environment variables so pip can find headers and libs
ENV GDAL_CONFIG=/usr/bin/gdal-config
ENV CPLUS_INCLUDE_PATH=/usr/include/gdal
ENV C_INCLUDE_PATH=/usr/include/gdal

# Install shadow package to manage UIDs/GIDs easily
RUN apk add --no-cache shadow

# Create a non-root user and group matching the standard host UID/GID (1000)
RUN groupadd -g 1000 appgroup && \
    useradd -u 1000 -g appgroup -s /bin/sh -m appuser

WORKDIR /usr/src/app

# Change ownership of the working directory
RUN chown -R appuser:appgroup /usr/src/app

# Switch to the non-root user
USER appuser

# Ensure local user bin is in PATH for pip installs
ENV PATH="/home/appuser/.local/bin:${PATH}"

COPY --chown=appuser:appgroup requirements.txt ./

# Install GDAL pip package pinned to system version, then the rest
RUN pip install --user --no-cache-dir GDAL==$(gdal-config --version) && \
    pip install --user --no-cache-dir -r requirements.txt

COPY --chown=appuser:appgroup . .

CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]