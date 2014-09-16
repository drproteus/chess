def vector_sum(vectors)
  result = [0,0]
  vectors.each do |vec|
    result[0] += vec[0]
    result[1] += vec[1]
  end
  result
end