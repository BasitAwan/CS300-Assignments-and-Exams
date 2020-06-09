-- ---------------------------------------------------------------------
-- DNA Analysis 
-- CS300 Spring 2018
-- Due: 24 Feb 2018 @9pm
-- ------------------------------------Assignment 2------------------------------------
--
-- >>> YOU ARE NOT ALLOWED TO IMPORT ANY LIBRARY
-- Functions available without import are okay
-- Making new helper functions is okay
--
-- ---------------------------------------------------------------------
--
-- DNA can be thought of as a sequence of nucleotides. Each nucleotide is 
-- adenine, cytosine, guanine, or thymine. These are abbreviated as A, C, 
-- G, and T.
--
type DNA = [Char]
type RNA = [Char]
type Codon = [Char]
type AminoAcid = Maybe String

-- ------------------------------------------------------------------------
-- 				PART 1
-- ------------------------------------------------------------------------				

-- We want to calculate how alike are two DNA strands. We will try to 
-- align the DNA strands. An aligned nucleotide gets 3 points, a misaligned
-- gets 2 points, and inserting a gap in one of the strands gets 1 point. 
-- Since we are not sure how the next two characters should be aligned, we
-- try three approaches and pick the one that gets us the maximum score.
-- 1) Align or misalign the next nucleotide from both strands
-- 2) Align the next nucleotide from first strand with a gap in the second     
-- 3) Align the next nucleotide from second strand with a gap in the first    
-- In all three cases, we calculate score of leftover strands from recursive 
-- call and add the appropriate penalty.
score :: DNA -> DNA -> Int
score [] [] = 0
score (_:xs) [] = 1 + score xs []
score [] (_:ys) = 1 + score ys []
score (x:xs) (y:ys) 
        | x==y =  max (max (1 + score (x:xs) (ys)) (3 + score (xs) (ys))) (1 + score (xs) (y:ys))
        | otherwise =  max (max (1 + score (x:xs) (ys)) (2 + score (xs) (ys))) (1 + score (xs) (y:ys)) 




-- -------------------------------------------------------------------------
--				PART 2
-- -------------------------------------------------------------------------
-- Write a function that takes a list of DNA strands and returns a DNA tree. 
-- For each DNA strand, make a separate node with zero score 
-- in the Int field. Then keep merging the trees. The merging policy is:
-- 	1) Merge two trees with highest score. Merging is done by making new
--	node with the smaller DNA (min), and the two trees as subtrees of this
--	tree
--	2) Goto step 1 :)
--
delete :: DNA -> [DNA] -> [DNA]
delete _ [] = []
delete x (y:ys)
            | x == y = ys
            | otherwise = [y] ++ delete x ys 
getThisDone:: DNATree->[DNA]->DNATree
getThisDone a [] = a
getThisDone a x@[_] = a 
getThisDone a (x1:x2:xs) = getThisDone (mergeTree (makeTree bestMatch) a ) (delete bestMatch (x1:x2:xs))
				where bestMatch = getBestMatch x1 xs x2
getBestMatch:: DNA -> [DNA] -> DNA -> DNA
getBestMatch _ [] z = z
getBestMatch   x (y:ys) z
            | score x y > score x z = getBestMatch x ys y
            | otherwise = getBestMatch x ys z 
makeTree:: DNA-> DNATree
makeTree x = Node x 0 Nil Nil
mergeTree:: DNATree -> DNATree -> DNATree
mergeTree Nil Nil = Nil
mergeTree Nil (Node w x y z) = Node w x y z 
mergeTree (Node w x y z) Nil = Node w x y z 
mergeTree (Node w x y z) (Node a b c d) 
				| x<=b = Node a (score w a) leftTree rightTree
				| otherwise= Node w (score w a) rightTree leftTree
				where leftTree= Node w x y z
				      rightTree= Node a b c d


data DNATree = Node DNA Int DNATree DNATree | Nil deriving (Ord, Show, Eq)

makeDNATree :: [DNA] -> DNATree
makeDNATree [] = Nil
makeDNATree x@[_] = Nil
makeDNATree (x1:x2:xs) = getThisDone (makeTree x1) (x1:x2:xs)

-- -------------------------------------------------------------------------
--				PART 3
-- -------------------------------------------------------------------------

-- Even you would have realized it is hard to debug and figure out the tree
-- in the form in which it currently is displayed. Lets try to neatly print 
-- the DNATree. Each internal node should show the 
-- match score while leaves should show the DNA strand. In case the DNA strand 
-- is more than 10 characters, show only the first seven followed by "..." 
-- The tree should show like this for an evolution tree of
-- ["AACCTTGG","ACTGCATG", "ACTACACC", "ATATTATA"]
--
-- 20
-- +---ATATTATA
-- +---21
--     +---21
--     |   +---ACTGCATG
--     |   +---ACTACACC
--     +---AACCTTGG
--
-- Make helper functions as needed. It is a bit tricky to get it right. One
-- hint is to pass two extra string, one showing what to prepend to next 
-- level e.g. "+---" and another to prepend to level further deep e.g. "|   "
lol = do
	putStrLn "Lol"
draw :: DNATree -> [Char]
draw = undefined
{-
-- ---------------------------------------------------------------------------
--				PART 4
-- ---------------------------------------------------------------------------
--
--
-- Our score function is inefficient due to repeated calls for the same 
-- suffixes. Lets make a dictionary to remember previous results. First you
-- will consider the dictionary as a list of tuples and write a lookup
-- function. Return Nothing if the element is not found. Also write the 
-- insert function. You can assume that the key is not already there.
type Dict a b = [(a,b)]

lookupDict :: (Eq a) => a -> Dict a b -> Maybe b
lookupDict = undefined

insertDict :: (Eq a) => a -> b -> (Dict a b)-> (Dict a b)
insertDict = undefined

-- We will improve the score function to also return the alignment along
-- with the score. The aligned DNA strands will have gaps inserted. You
-- can represent a gap with "-". You will need multiple let expressions 
-- to destructure the tuples returned by recursive calls.

alignment :: String -> String -> ((String, String), Int)
alignment = undefined

-- We will now pass a dictionary to remember previously calculated scores 
-- and return the updated dictionary along with the result. Use let 
-- expressions like the last part and pass the dictionary from each call
-- to the next. Also write logic to skip the entire calculation if the 
-- score is found in the dictionary. You need just one call to insert.
type ScoreDict = Dict (DNA,DNA) Int

scoreMemo :: (DNA,DNA) -> ScoreDict -> (ScoreDict,Int)
scoreMemo = undefined
-- In this part, we will use an alternate representation for the 
-- dictionary and rewrite the scoreMemo function using this new format.
-- The dictionary will be just the lookup function so the dictionary 
-- can be invoked as a function to lookup an element. To insert an
-- element you return a new function that checks for the inserted
-- element and returns the old dictionary otherwise. You will have to
-- think a bit on how this will work. An empty dictionary in this 
-- format is (\_->Nothing)

type Dict2 a b = a->Maybe b
insertDict2 :: (Eq a) => a -> b -> (Dict2 a b)-> (Dict2 a b)
insertDict2 = undefined

type ScoreDict2 = Dict2 (DNA,DNA) Int

scoreMemo2 :: (DNA,DNA) -> ScoreDict2 -> (ScoreDict2,Int)
scoreMemo2 = undefined
-}
-- ---------------------------------------------------------------------------
-- 				PART 5
-- ---------------------------------------------------------------------------

-- Now, we will try to find the mutationDistance between two DNA sequences.
-- You have to calculate the number of mutations it takes to convert one 
-- (start sequence) to (end sequence). You will also be given a bank of 
-- sequences. However, there are a couple of constraints, these are as follows:

-- 1) The DNA sequences are of length 8
-- 2) For a sequence to be a part of the mutation distance, it must contain 
-- "all but one" of the neuclotide bases as its preceding sequence in the same 
-- order AND be present in the bank of valid sequences
-- 'AATTGGCC' -> 'AATTGGCA' is valid only if 'AATTGGCA' is present in the bank
-- 3) Assume that the bank will contain valid sequences and the start sequence
-- may or may not be a part of the bank.
-- 4) Return -1 if a mutation is not possible

	
-- mutationDistance "AATTGGCC" "TTTTGGCA" ["AATTGGAC", "TTTTGGCA", "AAATGGCC" "TATTGGCC", "TTTTGGCC"] == 3
-- mutationDistance "AAAAAAAA" "AAAAAATT" ["AAAAAAAA", "AAAAAAAT", "AAAAAATT", "AAAAATTT"] == 2

calDiff:: DNA -> DNA -> Int
calDiff [] [] = 0
calDiff (x:xs) (y:ys)
				| x==y = calDiff xs ys
				| otherwise = 1 + calDiff xs ys 

firstOneDiff:: DNA -> [DNA] -> DNA
firstOneDiff _ [] = "A"
firstOneDiff a (x:xs)
			| calDiff a x == 1 = x
			| otherwise= firstOneDiff a xs
checkAb :: Int -> Int
checkAb a 
		| a <= 0 = -1
		| otherwise = a
mutationDistance :: DNA -> DNA -> [DNA] -> Int
mutationDistance _ _ [] =0
mutationDistance a b (x:xs)
				| a == b = 0
				| firstOne == "A" = -9999
				| otherwise = checkAb(max (1 + mutationDistance firstOne b (delete firstOne (dnaString))) (mutationDistance a b (delete (firstOne) (dnaString)))) 
				where firstOne = firstOneDiff a (x:xs)
				      dnaString = delete a (x:xs)



-- ---------------------------------------------------------------------------
-- 				PART 6
-- ---------------------------------------------------------------------------
--
-- Now, we will write a function to transcribe DNA to RNA. 
-- The difference between DNA and RNA is of just one base i.e.
-- instead of Thymine it contains Uracil. (U)
--
transcribeDNA :: DNA -> RNA
transcribeDNA [] = []
transcribeDNA (x:xs)
				| x=='T' = ['U'] ++ transcribeDNA xs
				| otherwise = [x] ++ transcribeDNA xs

-- Next, we will translate RNA into proteins. A codon is a group of 3 neuclotides 
-- and forms an aminoacid. A protein is made up of various amino acids bonded 
-- together. Translation starts at a START codon and ends at a STOP codon. The most
-- common start codon is AUG and the three STOP codons are UAA, UAG and UGA.
-- makeAminoAcid should return Nothing in case of a STOP codon.
-- Your translateRNA function should return a list of proteins present in the input
-- sequence. 
-- Please note that the return type of translateRNA is [String], you should convert
-- the abstract type into a concrete one.
-- You might wanna use the RNA codon table from 
-- https://www.news-medical.net/life-sciences/RNA-Codons-and-DNA-Codons.aspx
-- 
--
delete1:: String -> String ->String
delete1 _ [] = []
delete1 [] y = y 
delete1 _ y@[_] = []
delete1 _ (y1:y2:ys) 
		| length(y1:y2:ys) == 2 = [] 
delete1 (x1:x2:x3:xs) (y1:y2:y3:ys) 
			| x1 == y1 && x2 == y2 && x3 == y3 = delete1 xs ys
			| otherwise = delete1 (x1:x2:x3:xs) (y2:y3:ys)

getStringOut :: Maybe String -> String
getStringOut (Just a) = a
getStringOut Nothing = ""
findEnd :: RNA -> String
findEnd [] = []
findEnd x@[_] =[]
findEnd (x1:x2:xs)
			| length (x1:x2:xs)== 2 = []
findEnd (x1:x2:x3:xs)
			| aminoAc == "STOP" = x1:x2:[x3]
			| otherwise = x1:x2:[x3] ++ findEnd (xs)
			where aminoAc = getStringOut(makeAminoAcid(x1:x2:[x3]))
findStart :: RNA-> String
findStart [] = []
findStart x@[_] =[]
findStart (x1:x2:xs)
			| length (x1:x2:xs)== 2 = []
findStart (x1:x2:x3:xs)
			| aminoAc == "Met" = x1:x2:x3:xs
			| otherwise = findStart (x2:x3:xs)
			where aminoAc = getStringOut(makeAminoAcid(x1:x2:[x3]))
convertLong:: RNA -> String
convertLong [] = []
convertLong x@[_] = []
convertLong (x1:x2:xs)
			| length (x1:x2:xs)==2 = []
convertLong (x1:x2:x3:xs)
			|length (x1:x2:x3:xs) >= 3 = aminoAc ++ "-" ++ convertLong(xs)
			|otherwise = [] 
			where aminoAc = getStringOut(makeAminoAcid(x1:x2:[x3]))
makeAminoAcid :: Codon -> AminoAcid
makeAminoAcid x 
			| x == "UUU" = Just "Phe"
			| x == "UCU" = Just "Ser"
			| x == "UAU" = Just "Tyr"
			| x == "UGU" = Just "Cys"
			| x == "UUC" = Just "Phe"
			| x == "UCC" = Just "Ser"
			| x == "UAC" = Just "Tyr"
			| x == "UGC" = Just "Cys"
			| x == "UUA" = Just "Leu"
			| x == "UCA" = Just "Ser"
			| x == "UAA" = Just "STOP"
			| x == "UGA" = Just "STOP"
			| x == "UUG" = Just "Leu"
			| x == "UCG" = Just "Ser"
			| x == "UAG" = Just "STOP"
			| x == "UGG" = Just "Trp"
			| x == "CUU" = Just "Leu"
			| x == "CCU" = Just "Pro"
			| x == "CAU" = Just "His"
			| x == "CGU" = Just "Arg"
			| x == "CUC" = Just "Leu"
			| x == "CCC" = Just "Pro"
			| x == "CAC" = Just "His"
			| x == "CGC" = Just "Arg"
			| x == "CUA" = Just "Leu"
			| x == "CCA" = Just "Pro"
			| x == "CAA" = Just "Gln"
			| x == "CGA" = Just "Arg"
			| x == "CUG" = Just "Leu"
			| x == "CCG" = Just "Pro"
			| x == "CAG" = Just "Gln"
			| x == "CGG" = Just "Arg"
			| x == "AUU" = Just "Ile"
			| x == "ACU" = Just "Thr"
			| x == "AAU" = Just "Asn"
			| x == "AGU" = Just "Ser"
			| x == "AUC" = Just "Ile"
			| x == "ACC" = Just "Thr"
			| x == "AAC" = Just "Asn"
			| x == "AGC" = Just "Ser"
			| x == "AUA" = Just "Ile"
			| x == "ACA" = Just "Thr"
			| x == "AAA" = Just "Lys"
			| x == "AGA" = Just "Arg"
			| x == "AUG" = Just "Met" 
			| x == "ACG" = Just "Thr"
			| x == "AAG" = Just "Lys"
			| x == "AGG" = Just "Arg"
			| x == "GUU" = Just "Val"
			| x == "GCU" = Just "Ala"
			| x == "GAU" = Just "Asp"
			| x == "GGU" = Just "Gly"
			| x == "GUC" = Just "Val"
			| x == "GCC" = Just "Ala"
			| x == "GAC" = Just "Asp"
			| x == "GGC" = Just "Gly"
			| x == "GUA" = Just "Val"
			| x == "GCA" = Just "Ala"
			| x == "GAA" = Just "Glu"
			| x == "GGA" = Just "Gly"
			| x == "GUG" = Just "Val"
			| x == "GCG" = Just "Ala"
			| x == "GAG" = Just "Glu"
			| x == "GGG" = Just "Gly"
			| otherwise = Nothing
translateRNA :: RNA -> [String] 
translateRNA [] = []
translateRNA x 
			| length segment == 0 = []
			| segment == [] = []
			|otherwise= [convertLong segment] ++ translateRNA (delete1 (segment) x)
			where segment = (findEnd(findStart x))
