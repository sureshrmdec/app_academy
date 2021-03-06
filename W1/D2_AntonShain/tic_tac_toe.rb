require 'byebug'
class Game

  attr_accessor :board

  def initialize
    @board = Board.new
  end

  def play
    player1 = HumanPlayer.new("X", self.board)
    player2 = ComputerPlayer.new("O", self.board)

    # set current player to Human
    current_player = player1

    until self.board.won?
      self.board.render
      puts "#{current_player.mark}'s turn...pick a row and column: "

      if current_player == player2
        current_player.determine_best_move
        current_player = player1
      else
        begin
          pos = gets.chomp.split(",")
          row, col = pos[0].to_i, pos[1].to_i
          current_player.move([row,col])
          current_player = player2
        rescue
          puts "You can't place a mark there!"
          current_player = player1
          retry
        end
      end
    end

    self.board.render
    current_player = current_player == player1 ? player2 : player1
    puts "#{current_player.mark} wins!"
  end
end

class Board

  attr_reader :board

  def initialize
    @board = Array.new(3) { Array.new(3) }
  end

  def [](pos)
    row, col = pos
    @board[row][col]
  end

  def []=(pos, chr)
    row, col = pos
    @board[row][col] = chr
  end

  def empty?(pos)
    @board[pos].nil?
  end

  def rows
    rows = []
    self.board.each do |row|
      rows << row
    end

    rows
  end

  def cols
    @cols = [[],[],[]]
    self.board.each do |row|
      row.each_with_index do |col, col_index|
        @cols[col_index] << col
      end
    end

    @cols
  end

  def diags
    diagonal1 = [[0,0],[1,1],[2,2]]
    diagonal2 = [[2,0],[1,1],[0,2]]
    diags = [[],[]]
    diagonal1.each { |pos| diags[0] << self[pos] }
    diagonal2.each { |pos| diags[1] << self[pos] }
    diags
  end

  def won?
    draw = true
    (rows + cols + diags).each do |three|
      return true if three.all? { |chr| chr == 'X' }
      return true if three.all? { |chr| chr == 'O' }
      three.each do |chr|
        draw = false if chr.nil?
      end
    end

    draw
  end

  def place_mark(mark, pos)
    self[pos] = mark
  end

  def dup
    b = Board.new

    (0...b.board.count).each do |row|
      (0...b.board.count).each do |col|
        if !self.board[row][col].nil?
          b.board[row][col] = String.new(self.board[row][col])
        end
      end
    end

    b
  end

  def render
    self.board.each_with_index do |row, row_index|
      self.board.each_with_index do |col, col_index|
        if @board[row_index][col_index].nil?
          print "|_|"
        else
          print "|" + @board[row_index][col_index] + "|"
        end
      end
      print "\n"
    end
  end
end

class HumanPlayer

  attr_reader :mark, :board

  def initialize(mark, board)
    @mark = mark
    @board = board
  end

  def move(pos)
    unless self.board[pos].nil?
      raise ArgumentError
    else
      self.board.place_mark(self.mark, pos)
    end
  end
end

class ComputerPlayer
  attr_reader :mark, :board

  def initialize(mark, board)
    @mark = mark
    @board = board
  end

  def move(pos)
    self.board.place_mark(self.mark, pos)
  end

  def determine_best_move
    should_continue = true
    # go through board to see if computer has winning move
    self.board.board.each_with_index do |row, row_index|
      row.each_with_index do |col, col_index|
        copy = self.board.dup
        pos = [row_index, col_index]
        copy.place_mark(self.mark, pos) if copy[[row_index, col_index]].nil?
        if copy.won?
          self.board.place_mark(self.mark, [row_index, col_index])
          should_continue = false
        else
          copy.place_mark("|_|", [row_index, col_index])
        end
      end
    end

    # go through board to see if human has winning move and stop him
    self.board.board.each_with_index do |row, row_index|
      row.each_with_index do |col, col_index|
        opponent = self.mark == 'O' ? 'X' : 'O'

        copy = self.board.dup
        pos = [row_index, col_index]
        copy.place_mark(opponent, pos) if copy[[row_index, col_index]].nil?
        if copy.won?
          self.board.place_mark(self.mark, [row_index, col_index])
          should_continue = false
        else
          copy.place_mark("|_|", [row_index, col_index])
        end
      end
    end

    if should_continue
      # if there are no winning moves
      r = (0..2).to_a.sample
      c = (0..2).to_a.sample
      until self.board.board[r][c].nil?
        r = (0..2).to_a.sample
        c = (0..2).to_a.sample
      end
      self.board.place_mark(self.mark, [r,c])
    end
  end
end

g = Game.new.play
