module List.Ext exposing (..)


concatAp : a -> List (a -> List b) -> List b
concatAp a fns =
    List.concatMap ((|>) a) fns


partitionMap : (a -> Maybe b) -> List a -> ( List a, List b )
partitionMap fn list =
    (\( aVs, bVs ) ->
        ( List.reverse aVs, List.reverse bVs )
    )
    <|
        List.foldl
            (\step ( accAs, accBs ) ->
                case fn step of
                    Just b ->
                        ( accAs, b :: accBs )

                    Nothing ->
                        ( step :: accAs, accBs )
            )
            ( [], [] )
            list


partitionMapResult : (a -> Result b c) -> List a -> ( List b, List c )
partitionMapResult fn list =
    (\( bVs, cVs ) ->
        ( List.reverse bVs, List.reverse cVs )
    )
    <|
        List.foldl
            (\step ( accBs, accCs ) ->
                case fn step of
                    Err b ->
                        ( b :: accBs, accCs )

                    Ok c ->
                        ( accBs, c :: accCs )
            )
            ( [], [] )
            list
