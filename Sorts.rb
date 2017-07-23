class MergeSort
  def merge(arr, left, mid, right)

    # variables for tracking indices of left and right halves
    left_current_index = left
    right_current_index = mid + 1

    aux_array = Array.new(arr.length)

    # build temp array
    (left..right).each { |val| aux_array[val] = arr[val] }

    # alter array in place
    (left..right).each do |val|
      # left half is exhausted, take from the right
      if left_current_index > mid
        arr[val] = aux_array[right_current_index]
        right_current_index += 1
      # right half is exhausted, take from the left
      elsif right_current_index > right
        arr[val] = aux_array[left_current_index]
        left_current_index += 1
      # current left key is less than current right key, take from right
      elsif aux_array[right_current_index] < aux_array[left_current_index]
        arr[val] = aux_array[right_current_index]
        right_current_index += 1
      # current right key is greater or equal to current left key, take from left
      else
        arr[val] = aux_array[left_current_index]
        left_current_index += 1
      end
    end
  end

  def sort(arr, left = 0, right = arr.length - 1)
    if left < right
      middle = (left + right) / 2

      sort(arr, left, middle)
      sort(arr, middle + 1, right)
      merge(arr, left, middle, right)
    end
  end
end

# This class courtesy of: http://www.growingwiththeweb.com/2014/05/counting-sort.html
class CountingSort
  # Sorts an array using counting sort.
  def sort(array, max_value = array.max)
    buckets = Array.new(max_value + 1)
    sorted_index = 0

    (0..array.length - 1).each do |i|
      if buckets[array[i]].nil?
        buckets[array[i]] = 0
      end
      buckets[array[i]] += 1
    end

    (0..buckets.length - 1).each do |i|
      while not buckets[i].nil? and buckets[i] > 0
        array[sorted_index] = i
        sorted_index += 1
        buckets[i] -= 1
      end
    end
  end
end

# This class courtesy of: http://www.growingwiththeweb.com/2015/06/bucket-sort.html
class BucketSort
    # Sorts an array using bucket sort.
  def sort(array, bucket_size = 5)
    if array.empty?
      return
    end

    # Determine minimum and maximum values
    min_value = array.min
    max_value = array.max

    # Initialise buckets
    bucket_count = ((max_value - min_value) / bucket_size).floor + 1
    buckets = Array.new(bucket_count)
    (0..buckets.length - 1).each do |i|
      buckets[i] = []
    end

    # Distribute input array values into buckets
    (0..array.length - 1).each do |i|
      buckets[((array[i] - min_value) / bucket_size).floor].push(array[i])
    end

    # Sort buckets and place back into input array
    merge = MergeSort.new
    array.clear
    (0..buckets.length - 1).each do |i|
      merge.sort(buckets[i], 0, buckets[i].length - 1)
      buckets[i].each do |value|
        array.push(value)
      end
    end
  end
end

# code courtesy of: http://www.growingwiththeweb.com/sorting/radix-sort-lsd/
class RadixSort
  # Sorts an array using radix sort.
  def sort(array, radix = 10)
    if array.length <= 1
      return array
    end

    # Determine minimum and maximum values
    minValue = array[0]
    maxValue = array[0]
    (1..array.length - 1).each do |i|
      if array[i] < minValue
        minValue = array[i]
      elsif array[i] > maxValue
        maxValue = array[i]
      end
    end

    # Perform counting sort on each exponent/digit, starting at the least
    # significant digit
    exponent = 1
    while (maxValue - minValue) / exponent >= 1
      countingSortByDigit(array, radix, exponent, minValue)
      exponent *= radix
    end
  end

  private

   # Stable sorts an array by a particular digit using counting sort.
  def countingSortByDigit(array, radix, exponent, minValue)
    buckets = Array.new(radix)
    output = Array.new(array.length)

    # Initialize bucket
    (0..radix - 1).each do |i|
      buckets[i] = 0
    end

    # Count frequencies
    (0..array.length - 1).each do |i|
      bucketIndex = (((array[i] - minValue) / exponent) % radix).floor
      buckets[bucketIndex] += 1
    end

    # Compute cumulates
    (1..radix - 1).each do |i|
      buckets[i] += buckets[i - 1]
    end

    # Move records
    (array.length - 1).downto(0) do |i|
      bucketIndex = (((array[i] - minValue) / exponent) % radix).floor
      buckets[bucketIndex] -= 1
      output[buckets[bucketIndex]] = array[i]
    end

    # Copy back
    (0..array.length - 1).each do |i|
      array[i] = output[i]
    end
  end
end