Trackmania 2020:
  # goal: 
  # AP-Goal-RPG = When the checks amount is reach, the RPG map can be complete (Gold, AT or finished, depends on settings). Consider a RPG map a "boss".
  # AP-Goal-Checks = When the amount of check is reach, it release all (settings)
  # AP-Goal-AT = When a certain amount of AT have been reached
  # AP-Goal-AT-RPG = When AT is reached, the RPG can be complete
  goal: AP-Goal-RPG
  
  # StarterPack = 1 to 10 / random(1,10) => Number of map available from the start.
  starterpack: 5

  # TotalMap
  totalmap: 100

  # Objective
  objective: 90

  # TotalMapLow = ex: 80
  # TotalMapHigh = ex: 120
  # TotalMapRandom = True => THere's between 80 to 120 TotalMap, override TotalMap if true.
  # ObjectiveRng = in percent: 90 = 90%, with default value (80 - 120) we need 72/80, 108/120
  # If the value is a fraction and gamemode is check, you need a "ceil" amount (92.5 => 93)

  # Gamemode = Check => need 90 Gold
  #            Points=> Each medal give a certain amount
  gamemode:check

  # medal-value = Numerical value of each medal type
  at-value:1.25
  gold-value:1
  silver-value:0.75
  bronze-value:0

  ## Bonus/Malus
  # There's no modification to the car or map available.
  # Some kind of possible bonus: Free Gold, Skip map for Gold, Skip map for AT, Change gold to AT, 
  # Some king of malus: Lose a Checked, +1 requiered points/gold, map is forced (need the medal), 1 map is inaccessible (total - 1)


  ## Items
  # Could be one Items => one map
  # Could be Progressive-MapPack


  ## Hint
  # There's a trial map (World of wompus like), every CP (once) give an hint to someone in the player-world.
  

description: 'Generated by https://archipelago.gg with the default preset.'
game: Trackmania 2020
name: CidolfusTM20
