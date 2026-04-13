#!/bin/bash
# conda-forge build script for opendataloader-pdf
# Builds the Java CLI JAR, then installs the Python wrapper.

set -euo pipefail

# PKG_VERSION is automatically set by conda-build from meta.yaml's version field.

# ------------------------------------------------------------------
# 1. Set the Maven version to match the conda package version
# ------------------------------------------------------------------
cd "${SRC_DIR}/java"
mvn -B versions:set -DnewVersion="${PKG_VERSION}" -DgenerateBackupPoms=false

# ------------------------------------------------------------------
# 2. Build the Java CLI JAR (skip tests — covered upstream in CI)
# ------------------------------------------------------------------
mvn -B clean package -DskipTests -P release

# ------------------------------------------------------------------
# 3. Pin the Python package version and install
# ------------------------------------------------------------------
cd "${SRC_DIR}/python/opendataloader-pdf"
sed -i "s/^version = \"[^\"]*\"/version = \"${PKG_VERSION}\"/" pyproject.toml

# The hatch_build.py hook detects the JAR in java/target/ and copies it
# into src/opendataloader_pdf/jar/ automatically during the pip install.
"${PYTHON}" -m pip install . \
    --no-deps \
    --no-build-isolation \
    -vv
