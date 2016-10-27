;; NOTICE: This program will demonstrate the basic concept behind providing a certainty factor to encountering 
;; a pokemon animal using fuzzy interpretations  of geographic regions and pokemon animal abundance levels.
;; There are 150 pokemon, where each of the rules below will be adapted for that particular pokemon.
;; Clearly, this would result in an incredible amount of rules -- much greater than 150
;;
;; As such, the program demonstrates the proof of concept of how we can use fuzzy variables and certainty factor
;; to provide an expectation of encountering that pokemon in the wild.
;;
;; We use (salience) to control the flow of fact insertion and rule execution. Doing so will ensure that the correct sequence
;; of events occur that are needed to produce the correct fuzzy output.
;;
;; FuzzyCLIPs calculates the abundance in a very simple way. The abundance is calculated by 
;; CF(conclusion) = CF(rule) * min(CF[antecedent_1], CF[antecedent_2], ... , CF[antecedent_n])
;; When observing the rules defined below, notice how the certainty of the rule drops as the distance between the pokemon
;; animal and the user increases. This would make logical sense, which is what CF tries to encapsulate in any case - human perspective.
;; In addition, CFs increase as the abundance increases and the distance between pokemon animal and user decreases.
;;
;; The user of fuzzy rules allows for an overlapping of regions. Although a fact is inserted that does not match the
:: LHS of a rule verbatim, fuzzy rules will still fire if that fact overlaps in some sense with the distribution
;; of a fuzzy variable description for a particular set.
;;
;; In the example of our program, the regions middle and outskirts overlap. If a rule requires the existence of a fact
;; that the user is in the middle region to fire, but the fact base contains that the user is in the outskirts region,
;; that rule will still fire because there is an overlap between fuzzy variable sets (for middle and outskirts).
;; FuzzyCLIPS will associate a "membership" value to the result. Which indicates how strongly the value belongs to that particular
;; fuzzy variable set. This value is not outputted by the program, but the graph of the fuzzy variables are and can be used
;; to obtain the membership value.
;;
;; You see that for regions were a rule is fired due to an overlap in regions, the result lies in a region that can belong to both 
;; overlapped sets, with varying degreee of membership.

(defrule SetThresh
	(declare (salience 2000))
	=>
	(set-threshold 0.1)
)

(deftemplate region
	0			10
	(			(middle (pi 3 5))
				(centered below middle)
				(outskirts above middle)
	)
)
		
(deftemplate abundance
	0			10
	(			(low			(z 2 4))
				(moderate		(pi 3 5))
				(plentiful		(s 6 8.5))
	)
)

(deftemplate expectation
	0			10
	(			(not-likely		(z 2 4))
				(maybe			(pi 3 5))
				(probable		(s 6 8.5))
	)
)

(defrule plot-range-region
   (declare (salience 400))
   =>
   (plot-fuzzy-value t ".+-" nil nil (create-fuzzy-value region middle) (create-fuzzy-value region centered) 
				(create-fuzzy-value region outskirts))
)

(defrule plot-range-abundnace
   (declare (salience 400))
   =>
   (plot-fuzzy-value t ".+-" nil nil (create-fuzzy-value abundance low) (create-fuzzy-value abundance moderate) 
				(create-fuzzy-value abundance plentiful))
)

(defrule plot-range-expectation
   (declare (salience 400))
   =>
   (plot-fuzzy-value t ".+-" nil nil (create-fuzzy-value expectation not-likely) (create-fuzzy-value expectation maybe) 
				(create-fuzzy-value expectation probable))
)

(deftemplate user-region
	(slot location (type FUZZY-VALUE region))
)

(deftemplate pokemon-fuzzy-info
	(slot location (type FUZZY-VALUE region))
	(slot population (type FUZZY-VALUE abundance))
)

(defrule get-name
	(declare (salience 300))
	=>
	(printout t "Enter the name of the pokemon: ")
	(bind ?nm (read))
	(assert (pokemon-name ?nm))
)

;; create fuzzy rules
;; ##############################


(defrule combo-makes-exp-low-1
	(declare (CF 0.95))
	(pokemon-fuzzy-info (location centered))
	(user-region (location outskirts))
	(pokemon-fuzzy-info (population low))
	=>
	(assert (expectation not-likely))
)

(defrule combo-makes-exp-low-2
	(declare (CF 0.95))
	(pokemon-fuzzy-info (location outskirts))
	(pokemon-fuzzy-info (population low))
	(user-region (location centered))
	=>
	(assert (expectation not-likely))
)


(defrule combo-makes-exp-low-5
	(declare (CF 0.65))
	(pokemon-fuzzy-info (location centered))
	(pokemon-fuzzy-info (population low))
	(user-region (location centered))
	=>
	(assert (expectation not-likely))
)

(defrule combo-makes-exp-low-6
	(declare (CF 0.65))
	(pokemon-fuzzy-info (location outskirts))
	(pokemon-fuzzy-info (population low))
	(user-region (location outskirts))
	=>
	(assert (expectation not-likely))
)


(defrule combo-makes-exp-maybe-4
	(declare (CF 0.65))
	(pokemon-fuzzy-info (location centered))
	(pokemon-fuzzy-info (population plentiful))
	(user-region (location outskirts))
	=>
	(assert (expectation maybe))
)

(defrule combo-makes-exp-maybe-5
	(declare (CF 0.65))
	(pokemon-fuzzy-info (location outskirts))
	(pokemon-fuzzy-info (population plentiful))
	(user-region (location centered))
	=>
	(assert (expectation maybe))
)



(defrule combo-makes-exp-maybe-7
	(declare (CF 0.30))
	(pokemon-fuzzy-info (location outskirts))
	(pokemon-fuzzy-info (population plentiful))
	(user-region (location centered))
	=>
	(assert (expectation (pi 1 3)))
)

(defrule combo-makes-exp-maybe-7
	(declare (CF 0.30))
	(pokemon-fuzzy-info (location centered))
	(pokemon-fuzzy-info (population plentiful))
	(user-region (location outskirts))
	=>
	(assert (expectation (pi 1 3)))
)


(defrule combo-makes-exp-high-1
	(declare (CF 0.95))
	(pokemon-fuzzy-info (location centered))
	(pokemon-fuzzy-info (population plentiful))
	(user-region (location centered))
	=>
	(assert (expectation probable))
)


(defrule combo-makes-exp-high-3
	(declare (CF 0.95))
	(pokemon-fuzzy-info (location outskirts))
	(pokemon-fuzzy-info (population plentiful))
	(user-region (location outskirts))
	=>
	(assert (expectation probable))
)


;; get the pokemon's information
;; ############################

(defrule get-pokemon-location
	(declare (salience 190))
	=>
	(printout t "Where is the pokemon located (centered, middle, outskirts): ")
	(bind ?loc (read))
	(assert (pok-loc ?loc))
)

(defrule get-pokemon-abundance
	(declare (salience 190))
	=>
	(printout t "What is the abundance of the pokemon (plentiful, moderate, low): ")
	(bind ?abun (read))
	(assert (pok-abun ?abun))
)

;; pokemon combination abundance - plentiful - with differering location
;; ############################


(defrule create-pok-1
	(declare (salience 170))
	(pok-abun plentiful)
	(pok-loc centered)
	=>
	(printout t "What is your combined confidence in these values (0 to 1): ")
	(bind ?cf (read))
	(assert (pokemon-fuzzy-info (location centered) (population plentiful)) CF ?cf)
)

(defrule create-pok-2
	(declare (salience 170))
	(pok-abun plentiful)
	(pok-loc middle)
	=>
	(printout t "What is your combined confidence in these values (0 to 1): ")
	(bind ?cf (read))
	(assert (pokemon-fuzzy-info (location middle) (population plentiful)) CF ?cf)
)

(defrule create-pok-3
	(declare (salience 170))
	(pok-abun plentiful)
	(pok-loc outskirts)
	=>
	(printout t "What is your combined confidence in these values (0 to 1): ")
	(bind ?cf (read))
	(assert (pokemon-fuzzy-info (location outskirts) (population plentiful)) CF ?cf)
)

;; pokemon combination abundance - low - with differing locations
;; ############################

(defrule create-pok-4
	(declare (salience 170))
	(pok-abun low)
	(pok-loc centered)
	=>
	(printout t "What is your combined confidence in these values (0 to 1): ")
	(bind ?cf (read))
	(assert (pokemon-fuzzy-info (location centered) (population low)) CF ?cf)
)


(defrule create-pok-5
	(declare (salience 170))
	(pok-abun low)
	(pok-loc middle)
	=>
	(printout t "What is your combined confidence in these values (0 to 1): ")
	(bind ?cf (read))
	(assert (pokemon-fuzzy-info (location middle) (population low)) CF ?cf)
)


(defrule create-pok-6
	(declare (salience 170))
	(pok-abun low)
	(pok-loc outskirts)
	=>
	(printout t "What is your combined confidence in these values (0 to 1): ")
	(bind ?cf (read))
	(assert (pokemon-fuzzy-info (location outskirts) (population low)) CF ?cf)
)

;; pokemon combination abundance - moderate - with differing locations
;; ############################

(defrule create-pok-7
	(declare (salience 170))
	(pok-abun moderate)
	(pok-loc outskirts)
	=>
	(printout t "What is your combined confidence in these values (0 to 1): ")
	(bind ?cf (read))
	(assert (pokemon-fuzzy-info (location outskirts) (population moderate)) CF ?cf)
)

(defrule create-pok-8
	(declare (salience 170))
	(pok-abun moderate)
	(pok-loc middle)
	=>
	(printout t "What is your combined confidence in these values (0 to 1): ")
	(bind ?cf (read))
	(assert (pokemon-fuzzy-info (location middle) (population moderate)) CF ?cf)
)

(defrule create-pok-9
	(declare (salience 170))
	(pok-abun moderate)
	(pok-loc centered)
	=>
	(printout t "What is your combined confidence in these values (0 to 1): ")
	(bind ?cf (read))
	(assert (pokemon-fuzzy-info (location centered) (population moderate)) CF ?cf)
)


;; get user location
;; ###################

(defrule ask-user-location
	(declare (salience 150))
	=>
	(printout t "Where are you located? (centered, middle, outskirts): ")
	(bind ?x (read))
	(assert (user-location ?x))
)


;; Now that the rules have been created for a expectation probable, we can move on to obtaining 
;; the CFs for each of the antecedents in the rules above.
;;
;;###########


(defrule GetCF-user-subregion-outskirts
	(declare (salience 90))
	(user-location outskirts)
	=>
	(printout t "Enter your confidence in your adherence to the outskirts region (0 to 1): ")
	(bind ?cf (read))
	(assert (user-region (location outskirts)) CF ?cf)
)

(defrule GetCF-user-subregion-middle
	(declare (salience 90))
	(user-location middle)
	=>
	(printout t "Enter your confidence in your adherence to the middle region (0 to 1): ")
	(bind ?cf (read))
	(assert (user-region (location middle)) CF ?cf)
)

(defrule GetCF-user-subregion-centered
	(declare (salience 90))
	(user-location centered)
	=>
	(printout t "Enter your confidence in your adherence to the centered region (0 to 1): ")
	(bind ?cf (read))
	(assert (user-region (location centered)) CF ?cf)
)


;; print results
;; ##############

(defrule results
	(declare (salience -100))
	(expectation ?ex)
	(pokemon-name ?nm)
	?f <- (expectation ?ex)
	=>
	(printout t "You have a " (get-cf ?f) " certainty of expectation " (moment-defuzzify ?f) crlf)
)
