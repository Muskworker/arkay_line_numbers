$current_line = 0
$lines = []
$fors = {}

# line(10) { puts "Hello World" }
def line(symbol)
  $lines << symbol

  define_method :"line_#{symbol}" do
    yield
  end
end

# line(20) { goto 30 }
def goto(symbol)
  throw :goto, symbol
end

# line(30) { __for__(:i, 1..@whatever) }
def __for__(symbol, range)
  info = { value: range.first,
           range: range,
           startline: $current_line }

  $fors.update(symbol => info)
end

# line(40) { puts "This is iteration #{iteration(:i)}" }
def iteration(symbol)
  $fors[symbol][:value]
end

# line(50) { __next__(:i) }
def __next__(symbol)
  $fors[symbol][:value] += 1

  if iteration(symbol) <= $fors[symbol][:range].end
    goto $fors[symbol][:startline] + 1
  end
end

# Run lines sequentially.
def run
  $current_line ||= 0

  while $current_line
    $current_line = $lines.find { |existing| existing >= $current_line }

    # Next integer after next_line, unless a goto is thrown
    $current_line = catch(:goto) do
      $current_line ? send(:"line_#{$current_line}") : exit
      $current_line += 1
    end
  end
end
