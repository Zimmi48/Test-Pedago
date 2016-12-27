module Counter.Decreasing exposing (Counter, init, decr, print, printWith)


type Counter
    = Counter Int



{- initialize counter to zero for nonpositive integers -}


init : Int -> Counter
init =
    max 0 >> Counter


decr : Counter -> Maybe Counter
decr (Counter c) =
    if c >= 1 then
        Just (Counter (c - 1))
    else
        Nothing


print : Counter -> String
print (Counter c) =
    Basics.toString c


printWith : (Int -> String) -> Counter -> String
printWith printer (Counter c) =
    printer c
