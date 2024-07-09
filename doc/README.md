
README
======

This folder contains the official documentation set for CubedOS. The master document is
CubedOS.tex. That document includes, directly or indirectly, all the other document components.

To build the documentation, first be sure you have a LaTeX system installed. The precise way to
do this depends on your system and is outside the scope of this document. Then, issue the
following commands:

    > pdflatex CubedOS
    > bibtex CubedOS
    > pdflatex CubedOS
    > pdflatex CubedOS
    
It is necessary to run the `pdflatex` command multiple times to ensure that all cross references
are resolved properly. The resulting documentation will be in `CubedOS.pdf`.

LaTeX Resources
---------------

For a quick primer on LaTeX see the [LaTeX at
VTSU](https://www.pchapin.org/VTSU/LaTeX/LaTeX.zip) document. The [Not So Short Introduction to
LaTeX2e](http://tobi.oetiker.ch/lshort/lshort.pdf) is also an excellent resource.

We recommend using [JabRef](http://jabref.sourceforge.net/) for managing BibTeX databases. Note
that a text editor is technically all that is necessary but JabRef provides many useful services
most text editors do not.
