module List.Ext exposing (..)


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
