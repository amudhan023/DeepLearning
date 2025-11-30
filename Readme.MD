All learning related google collab files


For setup in VS Code

What to do (concrete steps)

1) Use a single environment for your project
    Create/activate a venv or conda env for the project and install packages once:

```shell
# create (if not created)
python3 -m venv .venv
# activate
source .venv/bin/activate
# install once
pip install -r /path/to/DeepLearning/requirements.txt
```

2) Make that env available to Jupyter/VS Code kernels (so notebooks can pick it)
Install an IPython kernel from that environment (run once while the env is active):
```shell
# using the env's python
.venv/bin/python -m pip install ipykernel
.venv/bin/python -m ipykernel install --user --name=deep-learning-venv --display-name "Python (deep-learning .venv)"
```
In VS Code: open the notebook, click the kernel/interpreter selector (top-right) and choose "Python (deep-learning .venv)" or select the interpreter via the Command Palette: "Python: Select Interpreter".


3) Use requirements.txt for reproducibility
Put the packages you need in requirements.txt (already added). To reproduce or set up a new environment:
Run the below commands to install the packages

```shell
python -m venv .venv
.venv/bin/python -m pip install -r requirements.txt
```

4) Verify from a notebook or terminal
In the notebook (first code cell) or terminal:
```shell
import sys, torch, numpy as np
print(sys.executable)
print('torch', torch.__version__)
```