# Documentation

Provided below are two documentation generators (Note: Both ddoc and doxygen are quite similar as far as the commenting style goes). For your final deliverable, you will be asked to post this documentation on your final project website.

## Doxygen

If you choose to use doxygen, here is a tutorial (Note the document style is very similar to doxygen).

- Doxygen Tutorial: https://www.youtube.com/watch?v=tLPHQMosF9M
- A helpful tool to use may be: [Doxywizard](http://www.doxygen.nl/manual/doxywizard_usage.html)

## DDoc style comments

If you choose to use DDoc here are some examples listed here: https://dlang.org/spec/ddoc.html

Comments within code are in the style of:

```d
/// This is a one line documentation comment.

/** So is this. */

/++ And this. +/

/**
   This is a brief documentation comment.
 */

/**
 * The leading * on this line is not part of the documentation comment.
 */

/*********************************
   The extra *'s immediately following the /** are not
   part of the documentation comment.
 */

/++
   This is a brief documentation comment.
 +/

/++
 + The leading + on this line is not part of the documentation comment.
 +/

/+++++++++++++++++++++++++++++++++
   The extra +'s immediately following the / ++ are not
   part of the documentation comment.
 +/

/**************** Closing *'s are not part *****************/

/*! \brief Brief description.
 *         Brief description continued.
 *
 *  Detailed description starts here.
 */

int a;  /// documentation for a; b has no documentation
int b;

/** documentation for c and d */
/** more documentation for c and d */
int c;
/** ditto */
int d;

/** documentation for e and f */ int e;
int f;  /// ditto

/** documentation for g */
int g; /// more documentation for g

/// documentation for C and D
class C
{
    int x; /// documentation for C.x

    /** documentation for C.y and C.z */
    int y;
    int z; /// ditto
}

/// ditto
class D { }
```
