import ../sequtils2
import unittest
import options
import sequtils

type Point = ref object
    x: int
    y: int

proc newPoint(x,y: int): Point =
    new result
    result.x = x
    result.y = y

proc `==`(a,b: Point): bool = a.x == b.x and a.y == b.y

suite "Test sequtils2":
    setup:
        let seq1 = @[5,4,31,421,41,4,897,54324,43,76]
        let seq2 = @[1,2,3]
        let seq3 = @[4,5,6]
        let seqPoints : seq[Point] = @[newPoint(1,4), newPoint(2,4), newPoint(3,4), newPoint(4,4), newPoint(3, 9), newPoint(7,3), newPoint(10,1), newPoint(5,4)]

    test "Reduce sum from seq1":
        let sum = seq1.reduce do (a,b: int) -> int : a + b
        let expected = 5+4+31+421+41+4+897+54324+43+76
        check(sum == expected)

    test "Reduce reverse sum from seq1":
        let sum = seq1.reduceReverse do (a,b: int) -> int : a + b
        let expected = 5+4+31+421+41+4+897+54324+43+76
        check(sum == expected)

    test "Reduce substraction from seq1":
        let diff = seq1.reduce do (a,b: int) -> int : a - b
        let expected = 5-4-31-421-41-4-897-54324-43-76
        check(diff == expected)
    
    test "Reduce reversed substraction from seq1":
        let diff = seq1.reduceReverse do (a,b: int) -> int : a - b
        let expected = 76-43-54324-897-4-41-421-31-4-5
        check(diff == expected)

    test "Map with index from seq1":
        let actual = seq1.mapWithIndex do(a: int, i : int) -> float : a.toFloat() + i / 2
        check(actual[0] == 5.0)
        check(actual[1] == 4.5)
        check(actual[2] == 32.0)
        check(actual[7] == 54327.5)
        
    test "Cartesian product between seq2 and seq3":
        let actual = seq2 ** seq3
        check(actual.len() == 9)
        check(actual[0] == (1,4))
        check(actual[8] == (3,6))
        check(actual[7] == (3,5))

    test "Find max by x and y in a sequence of points":
        let maxByX: Point = seqPoints.maxBy do(p: Point) -> int : p.x
        let maxByY: Point = seqPoints.maxBy do(p: Point) -> int : p.y
        let expectedMaxByX = newPoint(10, 1)
        let expectedMaxByY = newPoint(3,9)
        check(expectedMaxByX == maxByX)
        check(expectedMaxByY == maxByY)

    test "Find min by x and y in a sequence of points":
        let minByX: Point = seqPoints.minBy do(p: Point) -> int : p.x
        let minByY: Point = seqPoints.minBy do(p: Point) -> int : p.y
        let expectedMinByX = newPoint(1,4)
        let expectedMinByY = newPoint(10, 1)
        check(expectedMinByX == minByX)
        check(expectedMinByY == minByY)
    
    test "Removed duplicates from a sequence":
        let sequence = @[1,3,2,4,5,6,4,3,1,2]
        let actual = sequence.uniques()
        check(sequence.len() == 10)
        check(actual.len() == 6)
        check(actual[0] == 1)
        check(actual[1] == 3)

    test "Remove duplicates from a sequence without keeping the order":
        let sequence = @[1,3,2,4,5,6,4,3,1,2]
        let actual = sequence.uniques(preserve_order=false)
        check(sequence.len() == 10)
        check(actual.len() == 6)
        check(actual[0] == 1)
        check(actual[1] == 2)

    test "Removed a lot of duplicates from a sequence":
        let sequence = @[4,3,2,3,1,3,4,5,6,7,5,3,1,4,3,1,3,2,3,4,4,4,4,4,5,5,5,7,8,1,3,2,4,5,6,4,3,1,2]
        let actual = sequence.uniques()
        check(sequence.len() == 39)
        check(actual.len() == 8)
        check(actual[0] == 4)
        check(actual[1] == 3)
    
    test "Removed a lot of duplicates from a sequence without keeping the order":
        let sequence = @[4,3,2,3,1,3,4,5,6,7,5,3,1,4,3,1,3,2,3,4,4,4,4,4,5,5,5,7,8,1,3,2,4,5,6,4,3,1,2]
        let actual = sequence.uniques(preserve_order=false)
        check(sequence.len() == 39)
        check(actual.len() == 8)
        check(actual[0] == 1)
        check(actual[1] == 2)

    test "Count elements less than 500 in seq1":
        let lessThan500 = seq1.count do(el: int) -> bool : el < 500
        let expected = 8
        check(lessThan500 == expected)

    test "Sort points by x and then by y":
        let sortedByX = seqPoints.sortBy do(p: Point) -> int : p.x
        let sortedByY = seqPoints.sortBy do(p: Point) -> int : p.y
        check(sortedByX[0] == newPoint(1,4))
        check(sortedByY[0] == newPoint(10,1))
        check(sortedByX[2] == newPoint(3,4))
        check(sortedByX[sortedByX.len()-1] == newPoint(10, 1))
        check(sortedByY[sortedByY.len()-1] == newPoint(3, 9))

    test "Reverse a sequence":
        let reversed = seq2.reverse()
        check(reversed == @[3,2,1])

    test "Find first multiplier of 4":
        let first_multiplier_4 = seq1.first(proc(n: int):bool = (n mod 4 == 0))
        
        check(first_multiplier_4.is_some() and first_multiplier_4.get() == 4)

    test "Find last multiplier of 4":
        let last_multiplier_4 = seq1.last(proc(n: int):bool = (n mod 4 == 0))
        check(last_multiplier_4.is_some() and last_multiplier_4.get() == 76)

    test "Element-wise sum":
        let summed = seq2 + seq3
        check(summed != @[7, 7, 9])
        check(summed == @[5, 7, 9])

    test "Element-wise difference":
        let summed = seq2 - seq3
        check(summed != @[1,1,1])
        check(summed == @[-3, -3, -3])

    test "Element-wise product":
        let prod = seq2 * seq3
        check(prod != @[10, 10, 18])
        check(prod == @[4, 10, 18])

    test "Element-wise division":
        let quoz = seq2.mapIt(it.float) / seq3.mapIt(it.float)
        check(quoz != @[0.0,0,0])
        check(quoz == @[0.25, 2.0/5.0, 0.5])
        let quoz_int: seq[int] = seq2 / seq3
        check(quoz_int == @[0, 0, 0])
    
    
