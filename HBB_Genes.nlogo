;;;;;;;;;;;;;;;;;;
;; Declarations ;;
;;;;;;;;;;;;;;;;;;

globals
[
  ;; number of people that are sick
  num-sick
  lifespan ;;average lifespan of poeople
  average-offspring ;; the average number of offspring a people can have
  geneNumber;a random number to set the genes of the people
]

;;;;;;;;;;;;;;;;;;;;;
;; Bread of people ;;
;;;;;;;;;;;;;;;;;;;;;

breed [people person]
people-own 
[
  gender ;; female, male 
  HBB-Genes ; 4 types{A,A} {A,S} {S,A} {S,S}
  infected? ;; whether people are infected with maleria or not
  immune?;; wehter people are imune
  age ;; how many weeks old person is
] 

;; the average life expectancy in Ghana is 65 years for people  with A,A
;; for people with S,A and A,S 53
;; and 42 for poeple with S,S 

to setup
   clear-all ;;clears the interface from the previous setup
   set-default-shape people "person"
   reset-ticks
   setup-constants ;; lifespan and average-offspring
  create-people numberOfpeople
  [
       set size 1.5  ;; easier to see
       setxy random-xcor random-ycor ;random x,y coordinates
       set pen-mode "up"
       ;set label who ;set the count of the person from 0 display it on the interface 
       set infected? false
       set age random lifespan
       ;;intial population with malaria 10%
       set infected? (who < numberOfpeople * 0.1)  
       
       ;; generate a number between 1 and 100 
       set geneNumber random 100
       if geneNumber <= 68
       [
         set HBB-Genes "A,A"
         set color blue
       ]
        if (geneNumber > 68) and (geneNumber <= 83) 
       [
         set HBB-Genes "A,S"
         set color green
       ]
       
       if (geneNumber > 83) and geneNumber <= 98
       [
         set HBB-Genes "S,A"
         set color green
       ]
       if geneNumber > 98
       [
         set HBB-Genes "S,S"
         set color red
       ]      
  ] 
end

;; go is responsible for starting the simulation of the model
to go
  get-older
  if ticks >= 2000 [ stop ] ;; stop after 2000 ticks
  print "simulating" 
   ask people with [ infected? ]
  [ spread-disease ]
  set num-sick count people with [ infected? ]
  ask people  
  [
    move
    reproduce
  ] 
  tick
end

;; move is responsible for moving the poeple on the map
to move  
  rt random 50
  lt random 50
  fd 1
end

to reproduce
  ;print "reproducing ==>"
  let person1 one-of people
  let person2 one-of people
  ask person1 [
    ; person2 one-of people
    ;make sure person2 isn't person1
    while [person1 = person2]
    [
     set person2 one-of people 
    ]  
  ]
  let a1 0 ;1st allele of gene
  ifelse( [HBB-Genes] of person1 = "S,S" or [HBB-Genes] of person1 = "S,A" )
    [
      set a1 "S,"
    ]
    [
    set a1 "A,"
    ]   
  let a2 0 ; 2nd allele of gene
    ifelse( [HBB-Genes] of person2 = "S,S" or [HBB-Genes] of person2 = "S,A" ) 
    [
      set a2 "S"
    ]
    [
    set a2 "A"
    ] 
    if random 100 < 1
    [
       hatch-people 1
      ; a gene is made up of 2 alleles
      ; possible combinations are: SS, SA, AS and AA
      
      
      if( (a1 = "A,") and (a2 = "A") ) 
      [
        set HBB-Genes "A,A"
        set color blue
      ]
      
      if( (a1 = "A,") and (a2 = "S") ) 
      [
        set HBB-Genes "A,S"
        set color green
      ]
      if( (a1 = "S,") and (a2 = "A") ) 
      [
        set HBB-Genes "S,A"
        set color green
      ]
      ; sickle cell
      if( (a1 = "S,") and (a2 = "S") ) 
      [  
        set HBB-Genes "S,S"
        set color red
      ]
    ]
    print "person born"
end


to infect
  ask one-of people 
  [get-sick] ;;infect only with A,A
end

;; get-sick  is responsible to make a person sick if he is not.
to get-sick 
  if not infected?
  [ 
    set infected? true
    set shape word shape " sick"
    set label "M" 
  ]
end

;;spread-desease is responsible to spread the maleria to the other people.
to spread-disease 
  ask other people-here
   [ maybe-get-sick ]
end

;;maybe-get-sick is responsible for getting a person sick depending which genes he has.
to maybe-get-sick ;; turtle procedure
  ;;control the infection chance according the genes of the people
  if (not infected?) and (random 100 < A_A-infect) and (HBB-Genes = "A,A")
      [ get-sick]     
  if (not infected?) and (random 100 < S_A&A_S_infect) and ((HBB-Genes = "A,S") or (HBB-Genes = "S,A"))
      [ get-sick]    
  if (not infected?) and (random 100 < S_S_infect) and (HBB-Genes = "S,S")
      [ get-sick]       
end


;;setup-constants is responsible to set up the constants in the model.
to setup-constants
  set lifespan 300 ;; in weeks
  set average-offspring 4 
end

;; get-older is responsible for age of the people and handles
;; different cases depending on the genes of the people and the malaria
to get-older
  ask people
  [
    set age age + 1
    ;; Turtles die of old age once their age equals the
    ;; lifespan (set at 1500 l).
    if age > lifespan
      [ die ]
      ;;malaria case with aa
      if (infected?) and (HBB-Genes = "A,A") and (random 100 < A_A-dieRate)
      [
        die
      ]
      if (infected?) and ((HBB-Genes = "A,S") or (HBB-Genes = "S,A")) and (random 100 < S_A&A_S-dieRate)
      [
        die
      ]      
      if (infected?) and (HBB-Genes = "S,S") and (random 100 < S_S-dieRate)
      [
        die
      ]
  ] 
end
@#$#@#$#@
GRAPHICS-WINDOW
246
10
1101
886
32
32
13.0
1
10
1
1
1
0
1
1
1
-32
32
-32
32
1
1
1
weeks
30.0

SLIDER
8
10
180
43
numberOfpeople
numberOfpeople
0
250
250
1
1
NIL
HORIZONTAL

BUTTON
8
53
71
86
NIL
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
94
53
171
86
simulate
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

MONITOR
7
152
64
197
A,A
count people with [HBB-Genes = \"A,A\"]
1
1
11

MONITOR
71
101
128
146
A,S
count people with [HBB-Genes = \"A,S\"]
1
1
11

PLOT
12
525
212
675
Totals
time
people
0.0
5.0
0.0
10.0
true
true
"" ""
PENS
"total" 1.0 0 -2064490 true "" "plot count people"
"A,A " 1.0 0 -14070903 true "" "plot count people with[HBB-genes = \"A,A\"]"
"A,S & S,A " 1.0 0 -13840069 true "" "plot count people with[HBB-genes = \"A,S\" or HBB-genes = \"S,A\"]"
"S,S" 1.0 0 -2674135 true "" "plot count people with[HBB-genes = \"S,S\"]"
"maleria" 1.0 0 -16448764 true "" "plot num-sick"

BUTTON
90
474
180
507
NIL
infect\n
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
9
207
196
240
A_A-infect
A_A-infect
0
100
40
1
1
%
HORIZONTAL

MONITOR
135
152
193
197
infected
num-sick
17
1
11

MONITOR
13
472
70
517
years
ticks / 52
1
1
11

MONITOR
73
152
130
197
S,A
count people with [HBB-Genes = \"S,A\"]
1
1
11

MONITOR
136
101
193
146
S,S
count people with [HBB-Genes = \"S,S\"]
1
1
11

MONITOR
6
100
63
145
total
count people
1
1
11

SLIDER
10
250
226
283
S_A&A_S_infect
S_A&A_S_infect
0
100
10
1
1
%
HORIZONTAL

SLIDER
10
295
195
328
S_S_infect
S_S_infect
0
100
20
1
1
%
HORIZONTAL

SLIDER
12
341
184
374
A_A-dieRate
A_A-dieRate
0
100
30
1
1
%
HORIZONTAL

SLIDER
12
384
184
417
S_A&A_S-dieRate
S_A&A_S-dieRate
0
100
20
1
1
%
HORIZONTAL

SLIDER
12
429
184
462
S_S-dieRate
S_S-dieRate
0
100
50
1
1
%
HORIZONTAL

@#$#@#$#@
## WHAT IS IT?

(a general understanding of what the model is trying to show or explain)

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105
Circle -7500403 true true 110 5 80
Circle -7500403 true true 110 5 80
Circle -7500403 true true 110 5 80
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90

person doctor
false
0
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Polygon -13345367 true false 135 90 150 105 135 135 150 150 165 135 150 105 165 90
Polygon -7500403 true true 105 90 60 195 90 210 135 105
Polygon -7500403 true true 195 90 240 195 210 210 165 105
Circle -7500403 true true 110 5 80
Rectangle -7500403 true true 127 79 172 94
Polygon -1 true false 105 90 60 195 90 210 114 156 120 195 90 270 210 270 180 195 186 155 210 210 240 195 195 90 165 90 150 150 135 90
Line -16777216 false 150 148 150 270
Line -16777216 false 196 90 151 149
Line -16777216 false 104 90 149 149
Circle -1 true false 180 0 30
Line -16777216 false 180 15 120 15
Line -16777216 false 150 195 165 195
Line -16777216 false 150 240 165 240
Line -16777216 false 150 150 165 150

person sick
false
0
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105
Circle -7500403 true true 110 5 80
Circle -7500403 true true 110 5 80
Circle -7500403 true true 110 5 80
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 120 90 135 195 105 285 120 300 150 300 165 225 180 300 210 300 225 285 195 195 195 120
Line -2674135 false 165 105 120 180
Line -2674135 false 165 105 180 150
Line -2674135 false 195 105 180 150
Line -2674135 false 195 105 225 180

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270

@#$#@#$#@
NetLogo 5.0.4
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 1.0 0.0
0.0 1 1.0 0.0
0.2 0 1.0 0.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180

@#$#@#$#@
0
@#$#@#$#@
