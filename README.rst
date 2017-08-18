======================================================================
Polyglot.jl: transparent remote/recursive evaluation between languages
======================================================================

.. contents::

The Julia module ``Polyglot.jl`` supports transparent remote/recursive
evaluation between Julia and another interpreter through automatic call
serialization.

In poorer words, ``Polyglot.jl`` lets you call functions in other languages as
they were regular Julia functions. It *also* allows other languages to *call
Julia functions* as if they were native.

Remote output is also transparently redirected locally, and since the
evaluation is performed through a persistent co-process, you can actually spawn
interpreters on different hosts through "ssh" efficiently.

``Polyglot.jl`` currently supports PHP, Perl, JavaScript (Node.js) and Python.

``Polyglot.jl`` is currently a work-in-progress. Suggestions about API design
are highly appreciated: we're looking for a consistent calling interface
between regular Julia's multiprocessing_ and other external language bridges.

As an additional note, while ``Polyglot.jl`` can be used with Python, it's
definitely not as sophisticated or as efficient as PyCall_. If you don't need
to run multiple/remote/mixed Python instances (for example, to mix major Python
versions or to use PyPy), using PyCall_ is advisable.

.. _multiprocessing: https://julia.readthedocs.org/en/latest/manual/parallel-computing/
.. _bond module documentation: https://www.thregr.org/~wavexx/software/python-bond/
.. _PyCall: https://github.com/stevengj/PyCall.jl


Overview
========

``Polyglot.jl`` can communicate with another interpreter by "bonding" with it:

.. code:: jlcon

  julia> # Let's bond with a PHP interpreter
  julia> using Polyglot;
  julia> php = bond!("PHP");
  julia> reval(php, "echo \"Hello world!\\n\""; block=true);
  Hello world!

  julia> # Make an expensive split function using PHP's explode
  julia> explode = importfn(php, "explode");
  julia> explode(" ", "Hello world splitted by PHP!")
  5-element Array{Any,1}:
   "Hello"
   "world"
   "splitted"
   "by"
   "PHP!"

  julia> # Call Julia from PHP
  julia> call_me() = println("Hi, this is Julia talking!");
  julia> exportfn(php, call_me);
  julia> reval(php, "call_me()");
  Hi, this is Julia talking!

  julia> # Bridge two worlds!
  julia> perl = bond!("Perl");
  julia> proxyfn(php, "explode", perl);
  julia> # note: explode is now available to Perl, but still executes in PHP
  julia> reval(perl, "explode(\"=\", \"Mind=blown!\")")
  2-element Array{Any,1}:
   "Mind"  
   "blown!"


Practical examples
==================

Incomplete section.

Please see https://www.thregr.org/~wavexx/software/python-bond/#practical-examples


API
===

Initialization
--------------

Bonds can be constructed by using the ``bond!()`` function:

.. code:: julia

  using Polyglot
  interpreter = bond!("language")

The first argument should be the desired language name ("JavaScript", "PHP",
"Perl", "Python"). The list of supported languages can be fetched dynamically
using ``Polyglot.list_drivers()``.

You can override the default interpreter command using the second argument,
which allows to specify any regular command_ to be executed:

.. code:: julia

  using Polyglot
  py = bond!("Python", `ssh remote python3`)

An additional *list* of arguments to the interpreter can be provided using the
third argument, ``args``:

.. code:: julia

  using Polyglot
  py = bond!("Python", `ssh remote python3`, String["-E"; "-OO"])

The optional *arguments* are just strings. They are quoted and appended to the
main command *after* default arguments.

Default arguments may be supplied automatically by the driver to force an
interactive shell; for example "-i" is supplied if Python is requested. You can
disable default arguments by using ``def_args=False``.

The following keyword arguments are supported:

``cwd``:

  Working directory for the interpreter (defaults to current working
  directory).

``env``:

  Environment for the interpreter (defaults to ``ENV``).

``def_args``:

  Enable (default) or suppress default, extra command-line arguments to the
  interpreter.

``timeout``:

  Defines the timeout for the underlying communication protocol. Note that
  ``bond!()`` cannot distinguish between a slow call or noise generated while
  the interpreter is set up. Defaults to 60 seconds.

``trans_except``:

  .. warning:: Unimplemented

  Enables/disables "transparent exceptions". Exceptions are always first class,
  but when ``trans_except`` is enabled, the exception objects themselves will
  be forwarded across the bond. If ``trans_except`` is disabled (the default
  for all languages except Julia), then local exceptions will always contain a
  string representation of the remote exception instead, which avoids
  serialization errors.

.. _command: http://julia.readthedocs.org/en/latest/manual/running-external-programs/


Exported functions
------------------

``reval(bond, code; block=false)``

  With ``block=false`` (the default), evaluate and return the value of a
  *single statement* of code in the top-level of the interpreter.

  With ``block=true`` instead, evaluate a code block in the top-level of the
  interpreter. Any construct which is legal by the current interpreter is
  allowed. Nothing is returned.

``rref(bond, code)``:

  Return a reference to an *single, unevaluated statement* of code, which can
  be later used in reval() or as an *immediate* argument to rcall(). See
  `Quoted expressions`_.

``close(bond)``:

  Terminate the communication with the interpreter.

``rcall(bond, name, args...)``:

  Call a function "name" in the interpreter using the supplied list of
  arguments \*args (apply \*args to a callable *statement* defined by "name").
  The arguments are automatically converted to their other language's
  counterpart. The return value is captured and converted back to Julia as
  well.

``importfn(bond, name)``:

  Return a function that calls "name":

  .. code:: julia

    explode = importfn(bond, "explode")
    # Now you can call explode as a normal, local function
    explode(" ", "Hello world")

``exportfn(bond, func, name)``:

  Export a local function "func" so that can be called on the remote language
  as "name". If "name" is not specified, use the local function name directly.
  Note that "func" must be a local function, not a function name.

``proxyfn(bond, name, other_bond, other_name)``:

  Export a remote function "name" from "bond" to "other_bond", named as
  "other_name". If "other_name" is not provided, the same value as "name" is
  used:

  .. code:: julia

    php = bond!("PHP")
    py = bond!("Python")
    proxyfn(php, "explode", py)

``interact()``:

  .. warning:: Unimplemented

  Start an interactive session with the underlying interpreter.


Exceptions
----------

``BondException``:
  Thrown during ``bond!()`` initialization or unrecoverable errors.

``BondTerminatedException``:
  Thrown when the bond exits unexpectedly.

``BondSerializationException``:
  Thrown when an object/exception which is sent *or* received cannot be
  serialized by the current protocol. The ``remote`` record can be either
  ``false`` (when attempting to *send*) or ``true`` (when *receiving*). A
  ``BondSerializationException`` is not fatal.

``BondRemoteException``:
  Thrown for uncaught remote exceptions. The "data" record contains either
  the error message (with ``trans_except=False``) or the remote exception
  itself (``trans_except=True``).

Beware that both ``BondSerializationException`` (with ``remote==true``) and
``BondRemoteException`` may actually be originating from uncaught *local*
exceptions when an exported function is called. Pay attention to the error
text/data in these cases, as it will contain several nested exceptions.


Quoted expressions
------------------

``Polyglot.jl`` has minimal support for working with quoted expressions,
through the use of ``rref()``. ``rref()`` returns a reference to a unevaluated
statement that can be fed back to ``reval()`` or as an *immediate* (i.e.: not
nested) argument to ``rcall()``. References are bound to the interpreter that
created them.

``rref()`` allows to "call" methods that take remote un-serializable arguments,
such as file descriptors, without the use of a support function and/or eval:

.. code:: julia

  pl = bond!("Perl")
  reval(pl, "open(\$fd, \">file.txt\");"; block=true)
  fd = rref(pl, "\$fd")
  rcall(pl, "syswrite", fd, "Hello world!")
  rcall(pl, "close", fd)

Since references cannot be nested, there are still cases where it might be
necessary to use a support function. To demonstrate, we rewrite the above
example without quoted expressions, while still allowing an argument ("Hello
world!") to be local:

.. code:: julia

  pl = bond!("Perl")
  reval(pl, "open(\$fd, \">file.txt\");"; block=true)
  reval(pl, "sub syswrite_fd { syswrite(\$fd, shift()); };", block=true)
  rcall("syswrite_fd", "Hello world!")
  reval("close(\$fd)")

Or more succinctly:

.. code:: julia

  rcall(pl, "sub { syswrite(\$fd, shift()); }", "Hello world!")


Language support
================

Incomplete section.

Please see https://www.thregr.org/~wavexx/software/python-bond/#language-support


General/support mailing list
============================

If you are interested in announcements and development discussions about
``Polyglot.jl``, you can subscribe to the `bond-devel` mailing list by sending
an empty email to <bond-devel+subscribe@thregr.org>.

You can contact the main author directly at <wavexx@thregr.org>, though using
the general list is encouraged.


Authors and Copyright
=====================

| "Polyglot.jl" is distributed under the GNU GPLv2+ license (see ``COPYING.txt``).
| Copyright(c) 2015-2017 by wave++ "Yuri D'Elia" <wavexx@thregr.org>.
