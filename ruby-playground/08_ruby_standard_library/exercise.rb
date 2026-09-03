# Covers:
# 1. Enumerable
# 2. Comparable
# 3. Set
# 4. Struct
# 5. OpenStruct
# 6. Mutex
# 7. Thread
# 8. Fiber


require "set"
require "ostruct"

puts "=== Ruby Standard Library Mastery Playground ==="


# ============================================================
# 1. Enumerable
# ============================================================

puts "\n=== 1. Enumerable ==="

class Team
  include Enumerable

  def initialize(players)
    @players = players
  end

  def each
    @players.each do |player|
      yield player
    end
  end
end

team = Team.new(
  [
    "John",
    "Mike",
    "Alex"
  ]
)

puts "Team players: #{team.to_a}"
puts "Enumerable map: #{team.map(&:upcase)}"
puts "Enumerable select: #{team.select { |player| player.start_with?("A") }}"
puts "Enumerable owner: #{Team.ancestors}"


# ============================================================
# 2. Comparable
# ============================================================

puts "\n=== 2. Comparable ==="

class PlayerScore
  include Comparable

  attr_reader :score

  def initialize(score)
    @score = score
  end

  def <=>(other)
    score <=> other.score
  end

  def inspect
    "Score: #{score}"
  end
end

player1 = PlayerScore.new(50)
player2 = PlayerScore.new(100)

puts "player1 < player2 => #{player1 < player2}"
puts "player1 > player2 => #{player1 > player2}"
puts "player1.between?(10,60) => #{player1.between?(PlayerScore.new(10), PlayerScore.new(60))}"


# ============================================================
# 3. Set
# ============================================================

puts "\n=== 3. Set ==="

users = Set.new
users << "John"
users << "John"
users << "Mike"
users << "Alex"

puts "Set content: #{users}"
puts "users.include?('John') => #{users.include?("John")}"

puts "Set operations"

a = Set.new([1,2,3])
b = Set.new([3,4,5])

puts "\tUnion => #{a | b}"
puts "\tIntersection => #{a & b}"
puts "\tDifference => #{a - b}"


# ============================================================
# 4. Struct
# ============================================================

puts "\n=== 4. Struct ==="

UserStruct = Struct.new(:name, :age)
user = UserStruct.new("John", 30)

puts "Struct Content: #{user}"
puts "user.to_h => #{user.to_h}"
puts "Struct methods: user.methods.grep(/name|age/) => #{user.methods.grep(/name|age/)}"


# ============================================================
# 5. OpenStruct
# ============================================================

puts "\n=== 5. OpenStruct ==="

settings = OpenStruct.new
settings.name = "Ruby"
settings.version = 3

puts "OpenStruct Content: #{settings}"
puts "OpenStruct class: settings.class => #{settings.class}"


# ============================================================
# 6. Mutex
# ============================================================

puts "\n=== 6. Mutex ==="

counter = 0
threads = []

2.times do
  threads << Thread.new do
    100000.times do
      counter += 1
    end
  end
end

threads.each(&:join)

puts "Without Mutex counter: #{counter}"

puts "With Mutex"
counter = 0

mutex = Mutex.new
threads = []

2.times do
  threads << Thread.new do
    100000.times do
      mutex.synchronize do
        counter += 1
      end
    end
  end
end

threads.each(&:join)

puts "With Mutex counter: #{counter}"


# ============================================================
# 7. Thread
# ============================================================

puts "\n=== 7. Thread ==="

thread1 =
  Thread.new do
    puts "Thread 1 started"
    sleep 1
    puts "Thread 1 finished"
  end

thread2 =
  Thread.new do
    puts "Thread 2 started"
    sleep 1
    puts "Thread 2 finished"
  end

thread1.join
thread2.join

puts "All threads completed"


# ============================================================
# 8. Fiber
# ============================================================


puts "\n=== 8. Fiber ==="

fiber = Fiber.new do
  puts "Fiber started"
  Fiber.yield
  puts "Fiber resumed"
end

puts "Before resume"
fiber.resume
puts "After first resume"
fiber.resume
puts "After second resume"


# ============================================================
# Internal Inspection
# ============================================================

puts "\n=== Internal Inspection ==="

puts "Enumerable ancestors => #{Team.ancestors}"
puts "Comparable ancestors => #{PlayerScore.ancestors}"
puts "Thread class => #{Thread.class}"
puts "Fiber class => #{Fiber.class}"

puts "\n=== Finished ==="