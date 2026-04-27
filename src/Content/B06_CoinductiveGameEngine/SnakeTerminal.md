```lean
import Content.B06_CoinductiveGameEngine.games.Snake

open Content.B06_CoinductiveGameEngine.games.Snake
open Content.B06_CoinductiveGameEngine.chapters.CS6501_Coinduction

def main : IO Unit := do
  IO.println "Snake game in Lean 4"
  IO.println "Steer the snake (#) to eat food (*)."
  IO.println "Type `help` for commands."
  runTerminal snakeBigBang initialSnake
```
