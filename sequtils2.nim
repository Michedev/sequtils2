import sequtils
import algorithm
import options
import sets
import math

proc `**`*[T, V](s: openArray[T], t: openArray[V]): seq[tuple[a: T, b: V]] =
    ## Return a seq of all possible pairs between s and t
    result = newSeq[tuple[a: T, b: V]](s.len()*t.len())
    var i = 0
    for el1 in s:
        for el2 in t:
            result[i] = (el1, el2)
            i += 1

proc count*[T](s: openArray[T], cond: proc(a:T): bool): Natural =
    ## Count the elements in s that satisfy cond
    result = 0
    for el in s:
        if cond(el):
            result += 1

proc filterWithIndex*[T](s: openArray[T], filterF: proc(el: T, i : int): bool) : seq[T] =
    ##Alternative form for filter function where you have in input in filterF also the index of the element
    result = newSeq[T](0)
    for i in 0..<s.len():
        if filterF(s[i], i):
            result.add s[i]
            
proc forEach*[T](s: openArray[T], action: proc(el: T)) =
    ##Execute action on each element of s
    for el in s:
        action(el)

proc forEachWithIndex*[T](s: openArray[T], action: proc(el: T, i: int)) =
    ##Execute action on each element of s with its index
    for i in 0..<s.len():
        action(s[i], i)

proc mapWithIndex*[T, V](s: openArray[T], mappingF: proc(el:T, i: int): V): seq[V] =
    ##Alternative of map function where mappingF receive also in input the index of the element
    result = newSeq[V](s.len())
    for i in 0..<s.len():
        result[i] = mappingF(s[i], i)

proc maxBy*[T, V](s: openArray[T], keyF: proc(a:T): V): T =
    ##Find the max in s by keyF criteria
    var max = keyF(s[0])
    var max_i = 0
    for i in 1..<s.len():
        let el_i = keyF(s[i])
        if el_i > max:
            max = el_i
            max_i = i
    return s[max_i]

proc minBy*[T, V](s: openArray[T], keyF: proc(a:T): V): T =
    ##Find the min in s by keyF criteria
    ##
    ##Example:
    ##
    ##let seqPoints : seq[Point] = @[newPoint(1,4), newPoint(2,4), newPoint(3,4), newPoint(4,4), newPoint(3, 9), newPoint(7,3), newPoint(10,1), newPoint(5,4)]
    ##let minByX: Point = seqPoints.minBy do(p: Point) -> int : p.x 
    ##minByX == newPoint(1,4)

    var min = keyF(s[0])
    var min_i = 0
    for i in 1..<s.len():
        let el_i = keyF(s[i])
        if el_i < min:
            min = el_i
            min_i = i
    return s[min_i]

proc product*[T](s: openArray[T]) : T = s.reduce do (a,b: T) -> T : a * b
    
#TODO Add optional starting value param
proc reduce*[T](s: openArray[T], accumulator: proc(a,b:T): T): T =
    ##Apply the accumulation function sequentially on the sequence s two by two
    ##
    ##Example:
    ##
    ##let sum = @[1,2,3].reduce do (a,b: int) -> int : a + b
    ##sum == ((1+2)+3)
    
    result = s[0]
    for i in 1..<s.len():
        result = accumulator(result, s[i])

proc reduceReverse*[T](s: openArray[T], accumulator: proc(a,b:T): T): T =
    ##Apply the accumulation function sequentially from the last element to the first on sequence s
    ##
    ##Example:
    ##
    ##let diff = @[1,2,3].reduceReverse do (a,b: int) -> int : a - b
    ##diff == ((3-2)-1)
    
    result = s[s.len()-1]
    for i in countdown(s.len()-2, 0, 1):
        result = accumulator(result, s[i])

proc reverse*[T](s: openArray[T]): seq[T] =
    ##Swap the last elements of s with the firsts
    result = newSeq[T](s.len())
    for i in 0..<s.len():
        result[i] = s[s.len()-i-1]

proc sortBy*[T, V](s: openArray[T], keyF: proc(a:T): V): seq[T] =
    ##Sort by key obtained by keyF
    var keysIndexed : seq[tuple[el: V, i: int]] = s.map(keyF).zipWithIndex()

    proc compare(a,b: tuple[el: V, i: int]) : int =
        if a.el < b.el:
            return -1
        if a.el == b.el:
            return 0
        else:
            return 1
        
    keysIndexed.sort(compare)
    result = newSeq[T](s.len())
    for j in 0..<s.len():
        result[j] = s[keysIndexed[j].i]

proc sum*[T](s: openArray[T]) : T = s.reduce do (a,b: T) -> T : a + b
        
proc uniques*[T](s: seq[T], preserve_order = true): seq[T] =
    ##Return s without duplicates
    ##If preserve_order = true use an additional hash set to keep all the inserted elements
    ##If preserve_order = false remove duplicates by sorting the list and checking the duplicates with an iteration on the sorted list
    ##Prefer preserve_order = false if the size of input is very big
    ##
    ##Example: 
    ##
    ##let sequence = @[1,3,2,4,5,6,4,3,1,2]
    ##sequence.uniques() == @[1,3,2,4,5,6]
    result = newSeq[T](0)    
    if preserve_order:
        var set_uniques : HashSet[T]
        set_uniques.init(nextPowerOfTwo(s.len()))
        for el in s:
            if not set_uniques.contains(el):
                set_uniques.incl(el)
                result.add(el)
    else:
        var sCopy : seq[T]
        sCopy.deepCopy(s)
        sCopy.sort(cmp)
        for i in 1..<s.len():
            if sCopy[i-1] != sCopy[i]:
                result.add sCopy[i-1]
        if sCopy[sCopy.len()-1] != sCopy[sCopy.len()-2]:
            result.add sCopy[sCopy.len()-1]

proc zipWithIndex*[T](s: openArray[T]): seq[tuple[el: T, i: int]] =
    ##Zip each element of s with its index
    s.mapWithIndex do(el: T, i: int) -> tuple[el: T, i: int] : (el, i)
