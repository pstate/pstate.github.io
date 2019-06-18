---
title: 'Home'
prev_page:
  url: 
  title: ''
next_page:
  url: /examples/sender-reciever
  title: 'Examples'
comment: "***PROGRAMMATICALLY GENERATED, DO NOT EDIT. SEE ORIGINAL FILES IN /content***"
---
# Welcome to pState

## What is pState?

_pState_ is a tool for working with pCharts. The predecessor, _iState_, used a LaTeX-based input format for charts and generated code for B and Pascal ([Sekerinski and Zurob 2001](https://dx.doi.org/10.1007/3-540-45441-1_28), [Sekerinski and Zurob 2002](https://dx.doi.org/10.1007/3-540-47884-1_8)); the correctness of charts is expressed through _state invariants_ ([Sekerinski 2009](https://10.1002/9780470522622.ch13)). Based on that work, pState was designed with a new Java-based user interface and added timing and probabilities to charts, hence the name _pState_ ([Nokovic and Sekerinski 2013](https://dx.doi.org/10.1109/MECO.2013.6601339), [Nokovic and Sekerinski 2014](https://dx.doi.org/10.1145/2641483.2641522)). Code generation was extended to C and PIC microcontrollers ([Nokovic and Sekerinski 2017](http://dx.doi.org/10.1007/978-3-319-47307-9_7)) and includes (for PIC) worst-case execution time analysis ([Nokovic and Sekerinski 2015](http://dx.doi.org/10.14279/tuj.eceasst.72.1026)). The analysis of charts was further extended with quantitative analysis and makes use of a probabilistic model checker to this end ([Nokovic and Sekerinski 2015](10.4204/EPTCS.187.6))
_PCharts_ are a visual formalism for the design and analysis of embedded systems.

The current implementation of pState is a redevelopment with two goals:

1. to decouple the user interface from the analysis of charts by using modern Web-based techniques, such that the computationally intensive analysis can also run remotely, and
2. to simplify and generalize the implementation in order to ease further development, in particular for more code generators and alternative verification and quantitative analysis tools.

The current implementation consists of:

- a _web-based client_, maintained at https://gitlab.cas.mcmaster.ca/lime/pstate-client,
- the _core backend_, maintained at https://gitlab.cas.mcmaster.ca/lime/pstate-jupyter.

The user guide is documented elsewhere [](). This document, a Jupyter notebook, describes the core backend. This is an example of _literate development:_ the executable Python code for the backend is extracted from this notebook.


<!-- # Books with Jupyter and Jekyll

<img src="https://circleci.com/gh/jupyter/jupyter-book.svg?style=svg" class="left">

Jupyter Books lets you build an online book using a collection of Jupyter Notebooks
and Markdown files. Its output is similar to the excellent [Bookdown](https://bookdown.org/yihui/bookdown/) tool,
and adds extra functionality for people running a Jupyter stack.

For an example of a book built with Jupyter Books, see the [textbook for Data 100](https://www.textbook.ds100.org/) at UC Berkeley (or this website!)

Here are a few features of Jupyter Books

* A Command-Line Interface (CLI) to quickly create, build, and upgrade books.
* Write book content in markdown and Jupyter Notebooks
* Convert these into Jekyll pages that can be hosted for free on GitHub
* Pages can have [Binder](https://mybinder.org), JupyterHub, or Theblab links
  automatically added for interactivity.
* The website itself is based on Jekyll and is highly extensible.
* There are lots of nifty HTML features under-the-hood, such as
  Turbolinks fast-navigation and click-to-copy in code cells.

Check out other features in the [Features section](features/features).

## Getting started

To get started, you may be interested in the following links.
Here are a few links of interest:

* **[Jupyter Book features](features/features)** is a quick demo and overview
  of Jupyter Books.

* **[The Jupyter Book Guide](guide/01_overview)**
  will step you through the process of configuring and building your own Jupyter Book.

### Installation

To install the Jupyter Book command-line interface (CLI), use `pip`!

```
pip install jupyter-book
```

### Create a new book

Once you've installed the CLI, create a new book using the demo book content
(the website that you're viewing now) with this command:

```
jupyter-book create mybookname --demo
```

### Build the markdown for your book

Now, build the markdown that Jekyll will use for your book. Run this command:

```
jupyter-book build mybookname
```

### That's it!

You can now either push your book to GitHub and serve the demo with gh-pages,
or modify the book with your own content.


## Acknowledgements

Jupyter Books was originally created by [Sam Lau][sam] and [Chris Holdgraf][chris]
with support of the **UC Berkeley Data Science Education Program and the
[Berkeley Institute for Data Science](https://bids.berkeley.edu/)**.

[sam]: http://www.samlau.me/
[chris]: https://predictablynoisy.com -->
