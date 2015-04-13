# Release process #

  1. Test that the current trunk is working by compiling and running the test suite
```
cd ocaml-extlib/trunk/test
make 
make run
make opt
make run
```
  1. Inspect the results.  **All** test cases must pass in both byte code and native code.
    * Also run tests with the extlib version that's installed on ocamlfind, with `make USE_OCAMLFIND=1`.  If the release fixes any bugs, the previously ocamlfind extlib should fail some test cases
  1. Create release
    * Increment VERSION in Makefile, commit
    * `make release` will create directory `extlib-VERSION` and release tarball `extlib-VERSION.tar.gz`
  1. QA released extlib version once again, by installing it with ocamlfind and running test suite.
  1. Tag the release, by running `svn copy` as suggested by `make release`
    * svn copy https://ocaml-extlib.googlecode.com/svn/trunk https://ocaml-extlib.googlecode.com/svn/tags/extlib-VERSION`
    * Mention trunk revision in the commit message
  1. Upload the release tarball to http://code.google.com/p/ocaml-extlib/downloads
  1. Update API reference and changelog:
    * Compile the API ref by running `make doc` in `trunk/extlib`
    * `cp trunk/extlib/doc/* doc/apiref/`
    * Commit change to SVN (review `svn st` for added files)
    * Update wiki/ReleaseNotes.wiki
  1. Announce the new extlib release on OCaml & extlib mailing lists.