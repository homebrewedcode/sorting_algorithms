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
  arr_bucket = copy_array arr_merge
  arr_counting = copy_array arr_merge
  arr_radix = copy_array arr_merge

  array_hash = { merge: arr_merge, bucket: arr_bucket, counting: arr_counting, radix: arr_radix }
end



# test for correctness
def empirical_tests tests
  # builds a hash of arrays to sort.
  # keys are :merge, :counting, :radix

  pass = { merge: 0, bucket: 0, counting: 0, radix: 0 }
  fail = { merge: 0, bucket: 0, counting: 0, radix: 0 }

  # run sorting test, based on passed sort algoorithm and array and record results
  array_test = lambda do |sort, arr, key|
    sort.sort(arr)
    loop = arr.length - 1

    loop.times do |val|
      if arr[val] > arr[val + 1]
        fail += 1
        break
      end
    end

    pass[key] += 1 if fail[key].zero?
  end

  # lambda for printing results
  print_screen = lambda do |sort_name, key|
    puts "===============#{sort_name} Tests======================"
    puts "Pass: #{pass[key]}\n"
    puts "Fail: #{fail[key]}\n"
  end

  # run the tests based on the parameter tests
  tests.times do
    array_hash = build_sorting_array 1_000, 1_000
    array_test.call(MergeSort.new, array_hash[:merge], :merge)
    array_test.call(BucketSort.new, array_hash[:bucket], :bucket)
    array_test.call(CountingSort.new, array_hash[:counting], :counting)
    array_test.call(RadixSort.new, array_hash[:radix], :radix)
  end

  print_screen.call("Merge Sort", :merge)
  print_screen.call("Bucket Sort", :bucket)
  print_screen.call("Counting Sort", :counting)
  print_screen.call("Radix Sort", :radix)


end

empirical_tests 1000





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



