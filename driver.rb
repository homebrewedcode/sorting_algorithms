require_relative 'Sorts'

# generates a random array of n values from 0 to range
def generate_array(n, range)
  random = Random.new
  array = []
  n.times { array.push(rand(0..range)) }
  array
end

# creates a new array with duplicate contents
# does not refer to same objects, so we ensure that array is
# a copy and not a reference
def copy_array(arr)
  new_array = []
  arr.each { |val| new_array << val.dup }
  new_array
end

# build separate arrays for merge, counting, and radix sort, return in hash
def build_sorting_array n, range

  arr_merge = generate_array n, range
  arr_counting = copy_array arr_merge
  arr_radix = copy_array arr_merge

  array_hash = { merge: arr_merge, counting: arr_counting, radix: arr_radix }
end



# test for correctness
def empirical_tests
  array_hash = build_sorting_array 1_000, 1_000
  pass, fail = 0, 0

  array_test = lambda do |sort, arr|
    1000.times do
      sort.sort(arr)
      loop = arr.length - 1

      loop.times do |val|
        if arr[val] > arr[val + 1]
          fail += 1
          break
        end
      end
      pass += 1 if fail.zero?
    end
  end

  print_screen = lambda do |sort_name|
    puts "===============#{sort_name} Tests======================"
    puts "Pass: #{pass}\n"
    puts "Fail: #{fail}\n"
  end

  array_test.call(MergeSort.new, array_hash[:merge])
  print_screen.call("Merge Sort")
  pass, fail = 0, 0
  array_test.call(BucketSort.new, array_hash[:counting])
  print_screen.call("Counting Sort")
  pass, fail = 0, 0
  array_test.call(RadixSort.new, array_hash[:radix])
  print_screen.call("Radix Sort")

end

empirical_tests

# n = arr_merge.length
# MergeSort.sort(arr_merge, 0, n - 1)
# sort = MergeSort.new
#
# sort.sort(arr, 0, n - 1)

# bucket = BucketSort.new
#
# bucket.sort(arr)

# RadixSort.sort(arr, 10)
# (0..n - 1).each { |val| puts "#{arr_merge[val]}" }
# puts "\n******RADIX****\n"
# (0..n - 1).each { |val| puts "#{arr_radix[val]}" }



