require_relative 'Sorts'
require 'hitimes'

# generates a random array of n values from 0 to range
def generate_array(n, range, random = true)
  array = []
  if !random.nil? && random
    n.times { array.push(rand(0..range)) }
  else
    n.times { |val| array.push(val) }
  end
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
    puts "====================#{sort_name} Correctness Tests======================"
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
# Tests
# Speed tests for bucket sort
# can run tests for increasing n, k, n and k, passed in as options
def bucket_tests(n, range, increments, options = { random: false })
  k = range
  bucket = BucketSort.new

  sort_type = if options[:sort_type]
                options[:sort_type]
              else
                :merge
              end

  increments.times do
    timed_metric = Hitimes::TimedMetric.new('Operation')
    5.times do
      arr = generate_array n, k, options[:random]
      timed_metric.start
      bucket.sort(arr, k, sort_type)
      timed_metric.stop
    end

    if options[:n]
      type_string = "n"
      type_val = n
    elsif options[:k]
      type_string = "k"
      type_val = k
    else
      type_string = "n and k"
      type_val = "#{n} and #{k}"
    end
    puts "=================Bucket Sort Increasing #{type_string}, #{type_string} = #{type_val.to_s.reverse.scan(/\d{1,3}/).join(",").reverse}=======================\n"
    puts "Min: #{timed_metric.min.round(4)}"
    puts "Max: #{timed_metric.max.round(4)}"
    puts "Mean: #{timed_metric.mean.round(4)}"

    if options[:n]
      n *= 2
    elsif options[:k]
      k *= 10
    else
      n *= 2
      k = n
    end

  end
end

def counting_tests(n, increments, options = {})
  counting = CountingSort.new

  increments.times do
    timed_metric = Hitimes::TimedMetric.new('Operation')
    5.times do
      arr = generate_array n, n, true
      arr << 10_000_000_000 if options[:break]
      timed_metric.start
      counting.sort(arr)
      timed_metric.stop
    end

    puts "=================Counting Sort Increasing n = #{n.to_s.reverse.scan(/\d{1,3}/).join(",").reverse}=======================\n"
    puts "Min: #{timed_metric.min.round(4)}"
    puts "Max: #{timed_metric.max.round(4)}"
    puts "Mean: #{timed_metric.mean.round(4)}"

    n *= 2
  end
end

def radix_tests(n, increments, options = {})
  counting = RadixSort.new

  increments.times do
    timed_metric = Hitimes::TimedMetric.new('Operation')
    5.times do
      arr = generate_array n, n, true
      arr << 100_000_000_000 if options[:break]
      timed_metric.start
      counting.sort(arr)
      timed_metric.stop
    end

    puts "=================Counting Sort Increasing n = #{n.to_s.reverse.scan(/\d{1,3}/).join(",").reverse}=======================\n"
    puts "Min: #{timed_metric.min.round(4)}"
    puts "Max: #{timed_metric.max.round(4)}"
    puts "Mean: #{timed_metric.mean.round(4)}"

    n *= 2
  end
end

def sort_compare(n, increments, options={})
  merge = MergeSort.new
  bucket = BucketSort.new
  counting = CountingSort.new
  radix = RadixSort.new


  increments.times do
    timed_metric_merge = Hitimes::TimedMetric.new('Operation')
    timed_metric_bucket = Hitimes::TimedMetric.new('Operation')
    timed_metric_counting = Hitimes::TimedMetric.new('Operation')
    timed_metric_radix = Hitimes::TimedMetric.new('Operation')
    5.times do
      array_merge = generate_array n, n, true
      array_bucket = copy_array(array_merge)
      array_counting = copy_array(array_merge)
      array_radix = copy_array(array_merge)

      if !options.nil? && options[:merge_on]
        timed_metric_merge.start
        merge.sort(array_merge)
        timed_metric_merge.stop
      end

      timed_metric_bucket.start
      bucket.sort(array_bucket)
      timed_metric_bucket.stop

      timed_metric_counting.start
      counting.sort(array_counting)
      timed_metric_counting.stop

      timed_metric_radix.start
      radix.sort(array_radix)
      timed_metric_radix.stop
    end

    puts "=================All Sorts Increasing n = #{n.to_s.reverse.scan(/\d{1,3}/).join(",").reverse}=======================\n"
    puts "Merge:\n\tMin: #{timed_metric_merge.min.round(4)}\tMax: #{timed_metric_merge.max.round(4)}\tMean: #{timed_metric_merge.mean.round(4)}" unless options.nil? || !options[:merge_on]
    puts "Bucket:\n\tMin: #{timed_metric_bucket.min.round(4)}\tMax: #{timed_metric_bucket.max.round(4)}\tMean: #{timed_metric_bucket.mean.round(4)}"
    puts "Counting:\n\tMin: #{timed_metric_counting.min.round(4)}\tMax: #{timed_metric_counting.max.round(4)}\tMean: #{timed_metric_counting.mean.round(4)}"
    puts "Radix:\n\tMin: #{timed_metric_radix.min.round(4)}\tMax: #{timed_metric_radix.max.round(4)}\tMean: #{timed_metric_radix.mean.round(4)}"


    n *= 2
  end
end
# ======================EMPIRICAL TESTS============================================
#empirical_tests 1000
# ======================BUCKET SORT TESTS============================================
# Neat Discovery.  As range and k exceeded n, we started to get stronger.
# probably making sure we have less merge sorts in each bucket due to high bucket count
# this steadied out with higher values.

puts "=============BUCKET SORT INCREASING K======================"
puts "n = 25,000\nk = 10 to start"
# small k, increases by factor of 10. Values are also in range k.
bucket_tests(25_000, 10, 17, k: true)
# puts "=============BUCKET SORT INCREASING N======================"
# puts "n = 1,000 to start\nk = 100,000"
# # small n, increases by factor of 2
# # provide large k
# bucket_tests(1_000, 100_000, 10, n: true)
# puts "=============BUCKET SORT INCREASING N======================"
# puts "n = 1,000 to start\nk = 1,000"
# # provide smaller k
# bucket_tests(1_000, 1_000, 10, n: true)
# puts "=============BUCKET SORT INCREASING K and N======================"
# puts "n = 1,000 to start\nk = 1,000 to start"
# # increase both n and k to match
# # interesting, seem to be able to handle larger values of n
# bucket_tests(1_000, 1_000, 8)
# puts "=============BUCKET SORT INCREASING K======================"
# puts "n = 1,000 to start\nk = 100"
# puts "Use a perfectly reversed array."
# # use a perfectly reversed array and make k = n
# # this will essentially make an individual bucket for each value
# # and turn this into counting sort
# bucket_tests(1_000, 100, 8, n: true, random: false)
#
# puts "=============BUCKET SORT INCREASING N======================"
# puts "n = 1,000 to start\nk = 1,000"
# puts "Use a perfectly reversed array."
# bucket_tests(1_000, 1000, 8, n: true,  random: false)
#
# puts "=============BUCKET SORT INCREASING N======================"
# puts "n = 1,000 to start\nk = 1,000"
# puts "Use a perfectly reversed array."
# bucket_tests(1_000, 1000, 8, n: true,  random: false)
#
# puts "=============BUCKET SORT INCREASING N======================"
# puts "n = 10,000 to start\nk = 10,000"
# puts "Use a perfectly reversed array."
# bucket_tests(10_000, 10_000, 8, n: true, random: false)

# # ======================COUNTING SORT TESTS============================================
# puts "=============Counting SORT INCREASING N======================"
# puts "n = 25,000 to start, k = n on each pass"
# counting_tests 25_000, 10

# puts "=============Counting SORT INCREASING N======================"
# puts "n = 25,000 to start, k = n on each pass"
# puts "tags an arbitrarily high value to k to an auxiliary array with lots of empties"
# counting_tests(25_000, 10, break: true)

# ======================RADIX SORT TESTS============================================
# puts "=============Radix SORT INCREASING N======================"
# puts "n = 10,000 to start, k = n on each pass"
# radix_tests 10_000, 10

# puts "=============Radix SORT INCREASING N======================"
# puts "n = 10,000, Radix = 10"
# puts "tags an arbitrarily high value to k to throw off our word size"
# radix_tests(10_000, 10, break: true)
#
# sort_compare(1_000, 8, merge_on: true)
# sort_compare(25_000, 10, merge_on: false)