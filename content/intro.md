# Welcome to pState

## What is pState?

_pState_ is a tool for working with pCharts. _PCharts_ are a visual formalism for the design and analysis of embedded systems. The predecessor, _iState_, used a LaTeX-based input format for charts and generated code for B and Pascal ([Sekerinski and Zurob 2001](https://dx.doi.org/10.1007/3-540-45441-1_28), [Sekerinski and Zurob 2002](https://dx.doi.org/10.1007/3-540-47884-1_8)); the correctness of charts is expressed through _state invariants_ ([Sekerinski 2009](https://10.1002/9780470522622.ch13)). Based on that work, pState was designed with a new Java-based user interface and added timing and probabilities to charts, hence the name _pState_ ([Nokovic and Sekerinski 2013](https://dx.doi.org/10.1109/MECO.2013.6601339), [Nokovic and Sekerinski 2014](https://dx.doi.org/10.1145/2641483.2641522)). Code generation was extended to C and PIC microcontrollers ([Nokovic and Sekerinski 2017](http://dx.doi.org/10.1007/978-3-319-47307-9_7)) and includes (for PIC) worst-case execution time analysis ([Nokovic and Sekerinski 2015](http://dx.doi.org/10.14279/tuj.eceasst.72.1026)). The analysis of charts was further extended with quantitative analysis and makes use of a probabilistic model checker to this end ([Nokovic and Sekerinski 2015](10.4204/EPTCS.187.6))

The current implementation of pState is a redevelopment with two goals:

1. to decouple the user interface from the analysis of charts by using modern Web-based techniques, such that the computationally intensive analysis can also run remotely, and
2. to simplify and generalize the implementation in order to ease further development, in particular for more code generators and alternative verification and quantitative analysis tools.

The current implementation consists of:

- a _web-based client_, maintained at https://gitlab.cas.mcmaster.ca/lime/pstate-client,
- the _core backend_, maintained at https://gitlab.cas.mcmaster.ca/lime/pstate-jupyter.

The user guide is documented elsewhere [](). This document, a Jupyter notebook, describes the core backend. This is an example of _literate development:_ the executable Python code for the backend is extracted from this notebook.
