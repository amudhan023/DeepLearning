#!/usr/bin/env bash
set -euo pipefail

# setup_project_env.sh
# Create a Python virtual environment, install requirements, and register an ipykernel
# Usage:
#   ./scripts/setup_project_env.sh               # use defaults (.venv, requirements.txt)
#   ./scripts/setup_project_env.sh -v .venv -r requirements.txt -n deep-learning-venv -d "Python (deep-learning .venv)"

usage() {
  cat <<EOF
Usage: $0 [-v VENV_DIR] [-r REQ_FILE] [-n KERNEL_NAME] [-d KERNEL_DISPLAY_NAME] [--python PYTHON_EXECUTABLE]

Defaults:
  VENV_DIR=.venv
  REQ_FILE=requirements.txt
  KERNEL_NAME=deep-learning-venv
  KERNEL_DISPLAY_NAME="Python (deep-learning .venv)"

This script will:
  - create the virtualenv if missing
  - upgrade pip and install packages from REQ_FILE (or a minimal set if REQ_FILE is missing)
  - install ipykernel and register a Jupyter kernel for the venv

EOF
}

VENV_DIR=.venv
REQ_FILE=requirements.txt
KERNEL_NAME=deep-learning-venv
KERNEL_DISPLAY_NAME="Python (deep-learning .venv)"
PYTHON_EXECUTABLE=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    -v|--venv) VENV_DIR="$2"; shift 2 ;;
    -r|--requirements) REQ_FILE="$2"; shift 2 ;;
    -n|--kernel-name) KERNEL_NAME="$2"; shift 2 ;;
    -d|--display-name) KERNEL_DISPLAY_NAME="$2"; shift 2 ;;
    --python) PYTHON_EXECUTABLE="$2"; shift 2 ;;
    -h|--help) usage; exit 0 ;;
    --) shift; break ;;
    *) echo "Unknown option: $1"; usage; exit 1 ;;
  esac
done

echo "Using settings:"
echo "  VENV_DIR: $VENV_DIR"
echo "  REQ_FILE: $REQ_FILE"
echo "  KERNEL_NAME: $KERNEL_NAME"
echo "  KERNEL_DISPLAY_NAME: $KERNEL_DISPLAY_NAME"

# Choose python executable
if [[ -n "$PYTHON_EXECUTABLE" ]]; then
  PYTHON_CMD="$PYTHON_EXECUTABLE"
else
  if command -v python3 >/dev/null 2>&1; then
    PYTHON_CMD=python3
  elif command -v python >/dev/null 2>&1; then
    PYTHON_CMD=python
  else
    echo "No python executable found on PATH. Install Python 3 or pass --python /path/to/python" >&2
    exit 1
  fi
fi

echo "Using python: $($PYTHON_CMD -c 'import sys; print(sys.executable)')"

# Create venv if missing
if [[ ! -d "$VENV_DIR" ]]; then
  echo "Creating virtualenv at $VENV_DIR..."
  $PYTHON_CMD -m venv "$VENV_DIR"
else
  echo "Virtualenv $VENV_DIR already exists. Skipping creation."
fi

VENV_PY="$VENV_DIR/bin/python"
VENV_PIP="$VENV_DIR/bin/pip"

if [[ ! -x "$VENV_PY" ]]; then
  echo "Error: python in venv not found at $VENV_PY" >&2
  exit 1
fi

echo "Upgrading pip and core packaging tools in venv..."
"$VENV_PY" -m pip install --upgrade pip setuptools wheel

if [[ -f "$REQ_FILE" ]]; then
  echo "Installing packages from $REQ_FILE into venv..."
  "$VENV_PIP" install -r "$REQ_FILE"
else
  echo "No $REQ_FILE found — installing a minimal default set into venv..."
  # Default (CPU) install. If you need CUDA or MPS builds, install manually per platform.
  "$VENV_PIP" install torch numpy pandas matplotlib scikit-learn ipython
fi

echo "Installing ipykernel and registering kernel '$KERNEL_NAME'..."
"$VENV_PY" -m pip install --upgrade ipykernel
"$VENV_PY" -m ipykernel install --user --name "$KERNEL_NAME" --display-name "$KERNEL_DISPLAY_NAME"

echo "Done. To use the kernel in VS Code or Jupyter, select kernel: $KERNEL_DISPLAY_NAME"
echo "Activate the venv locally with: source $VENV_DIR/bin/activate"
echo "To pin currently installed versions for reproducibility (optional):"
echo "  $VENV_PY -m pip freeze | grep -E 'torch|numpy|pandas|matplotlib|scikit-learn|ipython' > $REQ_FILE"
