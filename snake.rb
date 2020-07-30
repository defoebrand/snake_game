require 'ruby2d'

set background: 'navy'
set fps_cap: 20

# width = 640 / 20 = 32
# height = 480 / 20 = 24
GRID_SIZE = 20
GRID_WIDTH = Window.width / GRID_SIZE
GRID_HEIGHT = Window.height / GRID_SIZE
class Snake
  attr_writer :direction

  def initialize
    @positions = [[2, 0], [2, 1], [2, 2], [2, 3]]
    @direction = 'down'
    @growing = false
  end

  def draw
    @positions.each do |position|
      Square.new(x: position[0] * GRID_SIZE, y: position[1] * GRID_SIZE, size: GRID_SIZE - 1, color: 'white')
    end
  end

  def move
    @positions.shift unless @growing
    case @direction
    when 'down'
      @positions.push(new_coords(head[0], head[1] + 1))
    when 'up'
      @positions.push(new_coords(head[0], head[1] - 1))
    when 'left'
      @positions.push(new_coords(head[0] - 1, head[1]))
    when 'right'
      @positions.push(new_coords(head[0] + 1, head[1]))
    end
    @growing = false
  end

  def can_change_direction_to?(new_direction)
    case @direction
    when 'up'
      new_direction != 'down'
    when 'down'
      new_direction != 'up'
    when 'left'
      new_direction != 'right'
    when 'right'
      new_direction != 'left'
    end
  end

  def x
    head[0]
  end

  def y
    head[1]
  end

  def grow
    @growing = true
  end

  def hit_itself?
    @positions.uniq.length != @positions.length
  end

  private

  def head
    @positions.last
  end

  def new_coords(x, y)
    [x % GRID_WIDTH, y % GRID_HEIGHT]
  end
end

class Game
  def initialize
    @score = 0
    @ball_x = rand(GRID_WIDTH)
    @ball_y = rand(GRID_HEIGHT)
    @finished = false
  end

  def draw
    Square.new(x: @ball_x * GRID_SIZE, y: @ball_y * GRID_SIZE, size: GRID_SIZE, color: 'yellow') unless finished?
    Text.new(text_message, color: 'green', x: 10, y: 10, size: 25)
  end

  def snake_hit_ball?(x, y)
    @ball_x == x && @ball_y == y
  end

  def record_hit
    @score += 1
    @ball_x = rand(GRID_WIDTH)
    @ball_y = rand(GRID_HEIGHT)
  end

  def finish
    @finished = true
  end

  def finished?
    @finished
  end

  private

  def text_message
    if finished?
      "Game Over! Your score was: #{@score}. Press 'R' to restart"
    else
      "Score: #{@score}"
    end
  end
end

snake = Snake.new
game = Game.new

update do
  clear
  snake.move unless game.finished?
  snake.draw
  game.draw

  if game.snake_hit_ball?(snake.x, snake.y)
    game.record_hit
    snake.grow
  end
  game.finish if snake.hit_itself?
end

on :key_down do |event|
  if %w[up down left right].include?(event.key)
    snake.direction = event.key if snake.can_change_direction_to?(event.key)
  elsif event.key == 'r'
    snake = Snake.new
    game = Game.new
  elsif event.key == 'space'
    set fps_cap: 0
  end
end

show
