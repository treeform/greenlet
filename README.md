# Greenlet - Coroutines library for nim simmilar to python's greenlet.

Greenlet tries to be a FAST!, easy to use and yet simple to understand and library for using flavor of coroutines called "greenlets".

* It is based on the cgreenlet library: https://github.com/geertj/cgreenlet
* Which itself is based on the python's greenlet library: https://github.com/python-greenlet/greenlet


# Very simple to use

Only a 3 `proc`s do most of the work:

* newGreenlet()
* g.switchTo()
* g.destroy()

Only 2 extra convience `proc`s to manage errors or gain speed:

* g.inject()
* g.reset()

And 5 getter `proc`s to see state of things:

* rootGreenlet()
* currentGreenlet()
* parentGreenlet()
* g.started
* g.dead

# Example

```nim
import greenlet

var g = newGreenlet proc (arg: pointer): pointer =
  echo "in func1 (greenlet 1)"
  discard rootGreenlet().switchTo()
  echo "exiting func1 (greenlet 1)"
  return nil

echo "entering greenlet 1"
discard g.switchTo()

echo "re-entering greenlet 1"
discard g.switchTo() 

echo "exiting program"
g.destroy()
```

output:

```
entering greenlet 1
in func1 (greenlet 1)
re-entering greenlet 1
exiting func1 (greenlet 1)
exiting program
```

# Very fast switching:

Compared to other coroutines methods:

| Method                | million saves+restores/sec  |
| --------------------- |----------------------------:| 
| getcontext/setcontext | 0.97                        |
| sigsetjmp/siglongjmp  | 1.10                        |
| setjmp/longjmp        | 88.32                       |
| greenlet save/swtich  | 214.09                      |

Compared to threads:

| Method                | million context switches/sec  |
| --------------------- |------------------------------:| 
| setjmp/longjmp        | 0.06                          |
| greenlet switch_to    | 27.39                         |


# Basaed on CGreenlet

It is based on the cgreenlet library: https://github.com/geertj/cgreenlet

Following is the explanation of how cgreenlet library works.

## Platform portability

Greenlet requires 4 platform and/or architecture specific pieces of
functionality in order to be able to offer coroutines:

 1. Thread-local storage.
 2. Stack allocation and deallocation
 3. Stack switching
 4. Context switching

For each platform that is supported, these 4 areas of functionality have to be
provided. What follows now is an overview on how each of these are
implemented:

## Thread-local storage

Currently two approaches are supported. The fastest and preferred way is to
use a __thread allocation class keyword on thread-local variables. This is
available on Linux and on Windows. This if is not available (e.g. on Mac OSX),
the pthread_getspecific() API is used.

Thread-local storage is implemented in "greenlet-system.c".

## Allocation of the stack

On Unix-like systems, greenlet uses mmap() and on Windows, it uses
VirtualAlloc(). The stack is protected with one PROT_NONE guard page. Stack
allocation is implemented in "greenlet-system.c".

## Stack switching

There is really no portably way to do this. On Unix-like platforms, we could
use sigaltstack() + longjmp(), or the deprecated POSIX makecontext(). On
Windows, the Fiber API could be used.

The approach that greenlet has taken is to implement an architecture specific
function to switch stacks:

```c
  void _greenlet_callnewstack(void *stack, void *(*func)(void *), void *arg);
```

This function will switch stack to `stack`, and call `func(arg)` on the new
stack. The function may not return. If it does try to return, a SIGSEGV will
be raised because we overwrite the return address to NULL. The way to get out
of this function is to switch context to a parent of the current context (see
next section).

This function is implemented in assembly in "greenlet-asm.S".

## Context switching

A relatively portably way to implement this would be setjmp()/longjmp(). The
function is available on Unix-like platforms and Windows. However the
performance of these functions varies greatly, as on some platforms this saves
the signal stack and on others it doesn't. Also, setjmp()/longjmp() do not
allow you to inject code just before execution is resumed in the target. Code
injection is needed to propagate exceptions.

The approach taken by greenlet is to provide a fast architecture specific
implementation of setjmp()/longjmp():

```c
  int _greenlet_setjmp_fast(void *frame);
  void _greenlet_longjmp_fast(void *frame, void (*inject_func)(void *),
                              void *arg);
```

These functions work just like setjmp()/longjmp() only that they are about 2x
faster and allow for code injection. 

These functios are implemented in assemlby in "greenlet-asm.S".

# Contributing

Feel free to add an issue on the github site, or fork it and send me a merge
request. 