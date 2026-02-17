# Configuration file for the Sphinx documentation builder.
#
# For the full list of built-in configuration values, see the documentation:
# https://www.sphinx-doc.org/en/master/usage/configuration.html

# -- Project information -----------------------------------------------------
# https://www.sphinx-doc.org/en/master/usage/configuration.html#project-information

import os
import sys
import subprocess

project = 'Cuda_MC'
copyright = '2026, Kieran Wylie'
author = 'Kieran Wylie'
release = '0.1'

# -- General configuration ---------------------------------------------------
# https://www.sphinx-doc.org/en/master/usage/configuration.html#general-configuration

subprocess.call(["doxygen", "Doxyfile"], cwd=os.path.abspath("../"), shell=True)

extensions = ["breathe"]

breathe_projects = {
    "Cuda_MC": "../xml"
}
breathe_default_project = "Cuda_MC"



templates_path = ['_templates']
exclude_patterns = []

language = 'c++'

# -- Options for HTML output -------------------------------------------------
# https://www.sphinx-doc.org/en/master/usage/configuration.html#options-for-html-output

html_theme = "sphinx_rtd_theme"
html_static_path = ['_static']
