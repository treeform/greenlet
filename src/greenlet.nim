##
##  This file is part of cgreenlet. CGreenlet is free software available
##  under the terms of the MIT license. Consult the file LICENSE that was
##  shipped together with this source file for the exact licensing terms.
##
##  Copyright (c) 2012 by the cgreenlet authors. See the file AUTHORS for a
##  full list.
##

{.compile: "cgreenlet/src/greenlet-asm.S".}
{.compile: "cgreenlet/src/greenlet-sys.c".}
{.compile: "cgreenlet/src/greenlet.c".}


type
  greenlet_flags* = enum
    GREENLET_STARTED = 0x00000001, GREENLET_DEAD = 0x00000002


type
  greenletStartFunc* = proc (a1: pointer): pointer
  greenletInjectFunc* = proc (a1: pointer)
  Greenlet* = object 
    parent* {.importc: "gr_parent".}: ptr Greenlet
    stack* {.importc: "gr_stack".}: pointer
    stacksize* {.importc: "gr_stacksize".}: clong
    flags* {.importc: "gr_flags".}: cint
    start* {.importc: "gr_start".}: greenletStartFunc
    arg* {.importc: "gr_arg".}: pointer
    instance* {.importc: "gr_instance".}: pointer
    inject* {.importc: "gr_inject".}: greenletInjectFunc
    frame* {.importc: "gr_frame".}: array[8, pointer]


proc newGreenlet*(start_func: greenletStartFunc; parent: ptr Greenlet = nil; stacksize: clong = 0): ptr Greenlet {.importc: "greenlet_new".}
proc destroy*(greenlet: ptr Greenlet) {.importc: "greenlet_destroy".}
proc switchTo*(greenlet: ptr Greenlet; arg: pointer): pointer {.importc: "greenlet_switch_to".}
template switchTo*(greenlet: ptr Greenlet) = discard greenlet.switchTo(nil)
proc inject*(greenlet: ptr Greenlet; inject_func: greenletInjectFunc) {.importc: "greenlet_inject".}
proc reset*(greenlet: ptr Greenlet) {.importc: "greenlet_reset".}
proc rootGreenlet*(): ptr Greenlet {.importc: "greenlet_root".}
proc currentGreenlet*(): ptr Greenlet {.importc: "greenlet_current".}
proc parentGreenlet*(greenlet: ptr Greenlet): ptr Greenlet {.importc: "greenlet_parent".}
proc started*(greenlet: ptr Greenlet): bool {.importc: "greenlet_isstarted".}
proc dead*(greenlet: ptr Greenlet): bool {.importc: "greenlet_isdead".}